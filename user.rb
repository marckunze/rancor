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
  property :password,   BCryptHash
  property :created_at, DateTime

  has n, :poll

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
  has n, :options, child_key: :rid
end

class Option
  include DataMapper::Resource

  property :cid,   Integer, key: true, unique: false
  property :text,  Text, required: true
  property :score, Integer, default: 0


  belongs_to :poll, child_key: :rid, key: true
end

DataMapper.finalize
DataMapper.auto_migrate!

# INSERT INTO User (id,username,email) VALUES(1,'p1','abc@email.com');
p1 = Account.create(username: 'p1', email: 'abc@email.com')

# INSERT INTO User (id,username,email) VALUES(2,'student','cdad@email.com');
student = Account.create(username: 'student', email: 'cdad@email.com')

# INSERT INTO rancor (rid,oid,question) VALUES(1,1,'What is for dinner?');
dinner = Poll.create(question: 'What is for dinner?')
p1.poll << dinner
p1.save

# INSERT INTO rancor (rid,oid,question) VALUES(2,2,'Go out for drinks?');
drinks = Poll.create(question: 'Go out for drinks?')
student.poll << drinks
student.save

# INSERT INTO choices (rid,cid,option) VALUES(1,1,'steak');
dinner.options << Option.create(cid: 1, text: 'steak')

# INSERT INTO choices (rid,cid,option) VALUES(1,2,'sushi');
dinner.options << Option.create(cid: 2, text: 'sushi')
dinner.save

# INSERT INTO choices (rid,cid,option) VALUES(2,1,'yes');
drinks.options << Option.create(cid: 1, text: 'yes')

#INSERT INTO choices (rid,cid,option) VALUES(2,2,'no');
drinks.options << Option.create(cid: 2, text: 'no')
drinks.save