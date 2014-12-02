require 'bundler'
Bundler.require

require_relative 'account'
require_relative 'ballot'
require_relative 'option'
require_relative 'ranking'

class Poll  # Rancor is the name of the sinatra class
  include DataMapper::Resource

  property :rid,        Serial
  property :question,   Text
  property :open,       Boolean, default: true
  property :closedate,  DateTime

  belongs_to :owner, 'Account', required: false
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
