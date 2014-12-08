require 'time'

module MiscHelpers
  HOUR = 60 * 60
  MIN = 60

  # Internal: Returns the poll that corresponds to the id or sends the requester
  # to the 404 page
  #
  # Examples
  #
  #   poll.options.all(order: :score.desc)
  #
  #   poll.add_results(params[:vote], request.ip)
  #
  # Returns the poll that corresponds to the id parameter.
  def poll
    @poll ||= Poll.get(params['id']) || not_found
  end

  # Internal: Closes all polls that are set to be closed at the top of the
  #           nearest hour.
  #
  # Examples
  #   Rancor.new.helpers.close_polls
  #
  # Returns true if operation is successful, false if not.
  def close_polls
    p "Closing polls set to close at #{nearest_hour = round_to_hour}"
    Poll.all(open: true, closedate: nearest_hour).each { |poll| poll.close }
  end

  # Internal: Takes a instance of a Time object and returns a DateTime object
  #           representing the passed time rounded to the nearest hour. If no Time
  #           object is passed, rounds the current time to the nearest hour
  #
  # Examples
  #   round_to_hour
  #   # => #<DateTime: 2014-12-08T14:00:00-08:00 ((2457000j,79200s,0n),-28800s,2299161j)>
  #
  #   round_to_hour(Time.new(2002, 10, 31, 2, 2, 2))
  # ` # => #<DateTime: 2002-10-31T02:00:00-08:00 ((2452579j,36000s,0n),-28800s,2299161j)>
  #
  #   round_to_hour(5)
  #   # => nil
  #
  # Returns a DateTime object, or nil if an incompatible object was passed.
  def round_to_hour(time = Time.now)
    return nil unless time.is_a? Time
    # Eliminates the milliseconds.
    time = time.round
    # rounds to the nearest hour (E.G. 10:57 becomes 11:00)
    time += time.min >= 30 ? 1 * HOUR : 0
    time -= time.min * MIN + time.sec
    # convert to utc time before converting to DateTime
    time.localtime(0).to_datetime
  end
end