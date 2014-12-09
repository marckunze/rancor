require 'bundler'
Bundler.require
require_relative '../rancor'

desc "This tasks is called by the Heroku scheduler add-on"
task :mail_results do
  rancor = Rancor.new
  polls = rancor.helpers.expired_polls
  polls.each do |poll|
    poll.close
    poll.invites.each do |invite|
      rancor.helpers.send_results(invite.email, poll)
    end
  end
end
