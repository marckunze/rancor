require 'bundler'
Bundler.require

require_relative 'ballot'
require_relative 'option'
require_relative 'poll'

class Ranking
  include DataMapper::Resource

  property :rank, Integer

  belongs_to :ballot, key: true
  belongs_to :option, key: true
  has 1, :poll, through: :option


  # Internal: Safe version of destroy, removes resource after performing all
  #           validations. Removes all connections before destroying self. Will
  #           automatically fail if connections are not removed.
  #
  # Examples
  #
  #   @poll.rankings.destroy
  #   # => false
  #
  #
  # Returns true if the operation was successful, false if not.
  def destroy
    self.ballot = nil
    self.poll = nil
    self.option = nil
    super
  end

  # Internal: Unsafe version of destroy, removes resource after performing no
  #           validations. Removes all connections before destroying self. Will
  #           not automatically fail if connections are not removed.
  #
  # Examples
  #
  #   @poll.rankings.destroy!
  #   # => true
  #
  # Returns true if the operation was successful, false if not.
  def destroy!
    self.ballot = nil
    self.poll = nil
    self.option = nil
    super
  end

end
