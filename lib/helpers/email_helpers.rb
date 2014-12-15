# Internal: Module for helpers that will be used by sinatra. These methods revolve
#           around the sending of email.
require 'bundler'
Bundler.require
require 'time'

module EmailHelpers
  # Internal: Sends a confirmation email when a user creates a new account
  #
  # address - The email address attached to the new account that was created.
  #
  # Examples
  #
  #   send_confirmation(foo@bar.com)
  #
  # Returns nothing
  def send_confirmation(address)
    send_email('Welcome to rancor!', :email_confirm, address)
  end

  # Internal: Sends a invitation email to all invited participates.
  #
  # poll - The poll containing the invites
  #
  # Examples
  #
  #   send_invite(@poll)
  #
  # Returns nothing
  def send_invites(poll)
    @poll = poll
    puts @poll.closedate
    @closing_hours = TimeDifference.between(Time.now, @poll.closedate.to_i).in_hours.floor
    @poll.invites.each do |invite|
      next if (!@poll.owner.nil?) && invite.email == @poll.owner.email
      send_email('You have been invited to participate in a poll!',
                 :email_invite, invite.email)
    end
  end

  # Internal: Sends a results email to all invited participates.
  #
  # poll - The poll containing the invites
  #
  # Examples
  #
  #   send_results(@poll)
  #
  # Returns nothing
  def send_results(poll)
    @poll = poll
    score = @poll.options.max(:score)
    @winner = @poll.options.first(score: score)
    @poll.invites.each do |invite|
      send_email('The results are in!', :email_results, invite.email)
    end
  end

  # Internal: Sends an email using Pony
  #
  # subject   - The subject line of the email
  # body      - An .erb file (file name passed as a symbol) that contains the
  #             body of the email.
  # recipient - The email address of the recipient
  # sender    - The owner of the poll the email is related to.
  #
  # Examples
  #
  #   send_email foo@bar.com, "Hello, world!", :hello_world
  #
  # Returns nothing
  def send_email(subject, body, recipient)
    @email_body = erb body, :layout => false
    begin
      Pony.mail({
        :to => recipient,
        :from => ENV['MANDRILL_USERNAME'],
        :subject => subject,
        :via => :smtp,
        :html_body => @email_body,
        :via_options => {
          :address  => 'smtp.mandrillapp.com',
          :user_name => ENV['MANDRILL_USERNAME'],
          :password =>  ENV['MANDRILL_APIKEY'],
          :port =>      '587',
          :domain =>    'heroku.com',
          :authentication => :plain
        }
      })
    rescue
      raise if ENV['RACK_ENV'] == :production
      # else: fall through and do nothing, you were testing locally.
    end
  end
end
