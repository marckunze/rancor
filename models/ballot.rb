require 'bundler'
Bundler.require

require_relative 'option'
require_relative 'poll'
require_relative 'ranking'

class Ballot
  include DataMapper::Resource

  property :rid,      Serial
  property :voter, IPAddress

  belongs_to :poll
  has n, :rankings

  # Internal: Resets the rankings and allocated score of the ballot
  #
  # Examples
  #
  #   ballot.reset
  #   # => true
  #
  # Returns true if the reset was successful, false if not
  def reset
    score_offset = poll.options.size # rank begins at 1, not 0
    rankings.each do |ranking|
      opt = ranking.option
      opt.score -= (score_offset - ranking.rank)
      opt.save
    end

    save
  end

  # Internal: Updates the ballot to reflect the new vote
  #
  # results - The results of the poll, ranked from first to last, as a String array
  #
  # Examples
  #
  #   ballot.update_results(["yes", "no", "maybe?"])
  #   # => true
  #
  # Returns true if the reset was successful, false if not
  def update_results(results)
    return false unless reset # If reset failed then update must fail as well
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

    save
  end
end
