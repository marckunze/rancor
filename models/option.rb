require 'bundler'
Bundler.require

require_relative 'poll'
require_relative 'ranking'

class Option
  include DataMapper::Resource

  property :rid,   Serial
  property :cid,   Integer, unique: false
  property :text,  Text, required: true
  property :score, Integer, default: 0

  belongs_to :poll
  has n, :rankings

  # Internal: Returns, as a integer, the percentage of the total score the object
  #           represents
  #
  # Examples
  #
  #   b.percent_of_total
  #   # => 20
  #
  # Returns an integer in the range of [0, 100]
  def percent_of_total
    # Prevents a error caused by attempting to round the value NaN
    poll.total_points == 0 ? 0 : (score.to_f/poll.total_points.to_f * 100).round
  end
end
