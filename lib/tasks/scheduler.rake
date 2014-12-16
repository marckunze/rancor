require 'bundler'
Bundler.require
require_relative '../rancor'

desc "This tasks closes and send the results of polls that have expired."
task :mail_results do
  rancor = Rancor.new
  # Following returns a collection of all expired polls. 
  polls = rancor.helpers.expired_polls
  polls.each do |poll|
    poll.close
    rancor.helpers.send_results(poll)
  end
end
