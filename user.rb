require 'bundler'
Bundler.require

# sets up a new database in this directory
configure :development do
  DataMapper.setup(:default, "sqlite3://#{Dir.pwd}/db/rancor.db")
end

configure :production do
  DataMapper.setup(:default, ENV['DATABASE_URL'] || 'postgres://localhost/mydb')
end

class Account
  include DataMapper::Resource
  include BCrypt

  property :id,         Serial
  property :username,   Text, required: true, unique: true
  property :email,      String, length: 320, required: true, unique: true
  property :password,   BCryptHash # , required: true
  property :created_at, DateTime

  has n, :polls

  def self.authenticate(user, password)
    u = first(username: user)
    u ||= first(email: user)
    return nil if u.nil?  # user not found

    u = nil unless u.password == password
    return u
  end

  def self.exists?(user)
    self.username_exists?(user) || self.email_exists?(user)
  end

  def self.username_exists?(username)
    !first(username: username).nil?
  end

  def self.email_exists?(email)
    !first(email:email).nil?
  end
end

class Poll  # Rancor is the name of the sinatra class
  include DataMapper::Resource

  property :rid,        Serial
  property :question,   Text
  property :open,       Boolean, default: true
  property :closedate,  DateTime

  belongs_to :account, required: false
  has n, :options
  has n, :ballots
  has n, :rankings, through: :options

  def total_points()
  # 1 + 2 + ... + (n - 1) + n = ((n(n + 1)) / 2)
  # 0 + 1 + 2 + ... + (n - 1) + n = (((n - 1)((n - 1) + 1)) / 2)
  # (((n - 1)((n - 1) + 1)) / 2) = ((n(n - 1)) / 2)
  ((options.size * (options.size - 1)) / 2) * ballots.size
  end

  def add_results(vote_results, voter)
    ballot = new_ballot voter
    reload
    vote_results.each_with_index do |vote, i|
      rank = i + 1
      ranking = Ranking.create(rank: rank)
      opt = options.first(text: vote)
      opt.score += options.size - rank
      opt.rankings << ranking
      ballot.rankings << ranking

      ballot.save
      opt.save
    end

    save
  end

  private

  def new_ballot(voter)
    b = Ballot.create(voter: voter)
    ballots << b
    save

    return b
  end
end

class Option
  include DataMapper::Resource

  property :cid,   Integer, key: true, unique: false
  property :text,  Text, required: true
  property :score, Integer, default: 0


  belongs_to :poll, key: true
  has n, :rankings

  def percent_of_total
    # Prevents a error caused by attempting to round the value NaN
    poll.total_points == 0 ? 0 : (score.to_f/poll.total_points.to_f * 100).round
  end
end

class Ballot
  include DataMapper::Resource

  property :rid,      Serial
  property :voter, IPAddress

  belongs_to :poll
  has n, :rankings

  def reset()
    score_offset = poll.options.size # rank begins at 1, not 0
    rankings.each do |ranking|
      opt = ranking.option
      opt.score -= (score_offset - ranking.rank)
      opt.save
    end

    save
  end

  def update_results(results)
    reset
    poll.reload # just in case

    results.each_with_index do |vote, i|
      rank = i + 1
      opt = poll.options.first(text: vote)
      opt.score += poll.options.size - rank
      opt.save

      ranking = opt.rankings.first(ballot: self)
      ranking.update(rank: rank)
      ranking.save
    end
  end

end

class Ranking
  include DataMapper::Resource

  property :rank, Integer

  belongs_to :ballot, key: true
  belongs_to :option, key: true
  has 1, :poll, through: :option
end

DataMapper.finalize
DataMapper.auto_upgrade!

if Account.all.size == 0
  # INSERT INTO User (id,username,email) VALUES(1,'p1','abc@email.com');
  p1 = Account.create(username: 'p1', email: 'abc@email.com', password: "test")

  # INSERT INTO User (id,username,email) VALUES(2,'student','cdad@email.com');
  student = Account.create(username: 'student', email: 'cdad@email.com')

  # INSERT INTO rancor (rid,oid,question) VALUES(1,1,'What is for dinner?');
  dinner = Poll.create(question: 'What is for dinner?')
  p1.polls << dinner
  p1.save

  # INSERT INTO rancor (rid,oid,question) VALUES(2,2,'Go out for drinks?');
  drinks = Poll.create(question: 'Go out for drinks?')
  student.polls << drinks
  student.save

  # INSERT INTO choices (rid,cid,option) VALUES(1,1,'steak');
  steak = Option.create(cid: 1, text: 'steak')
  dinner.options << steak
  # INSERT INTO choices (rid,cid,option) VALUES(1,2,'sushi');
  sushi = Option.create(cid: 2, text: 'sushi')
  dinner.options << sushi
  dinner.save

  # INSERT INTO choices (rid,cid,option) VALUES(2,1,'yes');
  yes = Option.create(cid: 1, text: 'yes')
  drinks.options << yes
  #INSERT INTO choices (rid,cid,option) VALUES(2,2,'no');
  no = Option.create(cid: 2, text: 'no')
  drinks.options << no
  drinks.save
end
