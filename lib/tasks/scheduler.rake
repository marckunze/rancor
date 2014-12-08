require 'bundler'
Bundler.require
require_relative '../rancor'

desc "This tasks is called by the Heroku scheduler add-on"
task :mail_results do
  Rancor.new.helpers.close_polls
end
