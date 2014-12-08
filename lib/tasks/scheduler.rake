require 'bundler'
Bundler.require
#require_relative 'models/models'
require './rancor'

# TODO Having problems including the email helpers
require_relative '../../email_helpers'
#require "#{settings.root}/email_helpers"

helpers do
  include EmailHelpers
end

desc "This tasks is called by the Heroku scheduler add-on"
task :mail_results do
  #mails the results of any polls within time period
  #Initialize variables, need current time
  cur_date = Date.new
  #cur_datetime = DateTime.new

  puts "Hello, it is currently: " + cur_date.to_s
  puts "mailing results...."

  #TODO Get all polls with close date of past time period (hours or minutes)

  #########
  ## This is now taken care for you in the helpers. As it's currently set up,
  ## you should be allow to perform this with one statement:
  ## Rancor.new.helpers.close_polls
  ## (SHOULD, because I haven't tested it yet)
  #########

    #TODO Get poll/rank winner and info from tables
    # TODO move this work to email_results.erb and poll.rb
    #temp example
    @poll_question = "What the f?"
    @poll_winning_option = "Yeah, seriously?"
    #@poll_closedate = DateTime.new(2014,12,07,03,00,'-8')
    @poll_closedate = DateTime.now

    #if closedate is within timeframe then mail
    # TODO needs proper close_date check logic
    if (Time.now..Time.now+4).cover?(Time.now) then
    	puts "mailing: " + @poll_question

    
    	#voters.each mail a result
        puts "The winner or poll " + @poll_question + " was: " + @poll_winning_option

        #TODO change to correct email dest
        #send_results('rancorapp@mailinator.com')

    end
  
 # @options = poll.options.all(order: :score.desc)
 # puts erb :results
end
