require 'bundler'
Bundler.require

require_relative 'poll'
require_relative 'ranking'

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
