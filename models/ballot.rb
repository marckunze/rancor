require 'bundler'
Bundler.require

require_relative 'option'
require_relative 'poll'
require_relative 'ranking'



# sets up a new database in this directory
configure :development do
  DataMapper.setup(:default, "sqlite3://../db/rancor.db")
end

configure :production do
  DataMapper.setup(:default, ENV['DATABASE_URL'] || 'postgres://localhost/mydb')
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