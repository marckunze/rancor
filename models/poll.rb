require 'bundler'
Bundler.require

require_relative 'account'
require_relative 'ballot'
require_relative 'option'
require_relative 'ranking'

class Poll
  include DataMapper::Resource

  property :rid,        Serial
  property :question,   Text
  property :open,       Boolean, default: true
  property :closedate,  DateTime

  belongs_to :owner, 'Account', required: false
  has n, :options
  has n, :ballots
  has n, :rankings, through: :options

  def destroy
    self.owner = nil
    rankings.destroy unless rankings.nil?
    options.destroy unless options.nil?
    ballots.destroy unless ballots.nil?
    reload
    super
  end

  def destroy!
    self.owner = nil
    rankings.destroy! unless rankings.nil?
    options.destroy! unless options.nil?
    ballots.destroy! unless ballots.nil?
    reload
    super
  end

  # Internal: Calculates and returns the total points available in the poll
  #
  # Examples
  #
  #   @poll.total_points
  #   #=> 45
  #
  # Returns the total number of points available in the poll
  def total_points
    # 1 + 2 + ... + (n - 1) + n = ((n(n + 1)) / 2)
    # 0 + 1 + 2 + ... + (n - 1) + n = (((n - 1)((n - 1) + 1)) / 2)
    # (((n - 1)((n - 1) + 1)) / 2) = ((n(n - 1)) / 2)
    ((options.size * (options.size - 1)) / 2) * ballots.size
  end

  # Internal: Adds a new ballot to the poll, based on the String array containing
  #           the user's preferences
  #
  # vote_results - a String array containing the poll's options ranked in order
  #                from first to last
  # voter - the ip address of the voter, represented as a String
  #
  # Examples
  #
  #   add_results(["Maybe?", "No", "Yes"], "127.0.0.1")
  #   # => true
  #
  # Returns true if the operation was successful, false if not
  def add_results(vote_results, voter)
    ballot = new_ballot voter
    return false if ballot.nil? # add fails if ballot creation fails

    reload
    vote_results.each_with_index do |vote, i|
      rank = i + 1
      ranking = Ranking.create(rank: rank)
      # add fails rank can not be recorded
      return false if ranking.nil?

      opt = options.first(text: vote)
      # Fail if option can not be found
      return false if opt.nil?
      opt.score += options.size - rank
      opt.rankings << ranking
      ballot.rankings << ranking

      # if either save fails return false, the add failed.
      return false unless ballot.save
      return false unless opt.save
    end

    save
  end

  private

  # Internal: Creates a new ballot for the poll
  #
  # voter - the ip address of the voter, represented as a String
  #
  # Example
  #   new_ballot("127.0.0.1")
  #   # => #<Ballot:0x00000008008135>
  #
  # Returns the newly created Ballot, or nil if the ballot creation failed.
  def new_ballot(voter)
    b = Ballot.create(voter: voter)
    ballots << b
    # Return nothing if save failed
    return nil unless save
    return b
  end
end
