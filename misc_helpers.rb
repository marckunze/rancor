require 'time'

module MiscHelpers
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

  def close_polls
    Poll.all(open: true, closedate: datetime).close
  end

  def datetime
    @datetime ||= get_datetime
  end

  def get_datetime
    time = Time.now.round
    # rounds to the nearest hour (E.G. 12:57 becomes 1:00)
    time += time.min >= 30 ? 1 * hour : 0
    time -= time.min * min + time.sec
    time.to_datetime
  end

  def hour
    60 * 60
  end

  def min
    60
  end
end