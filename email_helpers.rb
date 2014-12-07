# Internal: Module for helpers that will be used by sinatra. These methods revolve
#           around the sending of email.
module EmailHelpers
  # Internal: Sends a confirmation email when a user creates a new account
  #
  # address - The email address attached to the new account that was created.
  #
  # Examples
  #
  #   send_confirmation foo@bar.com
  #
  # Returns nothing
  def send_confirmation(address)
    send_email(address, 'Welcome to rancor!', :email_confirm)
  end

  # Internal: Sends a invitation email when a new poll is created.
  #
  # address - The email address added by the poll creator
  #
  # Examples
  #
  #   send_invite foo@bar.com
  #
  # Returns nothing
  def send_invite(address)
    send_email(address, 'You have been invited to participate in a poll!', :email_invite)
  end

  # Internal: Sends a results email when a poll closes
  #
  # address - The email address attached to the new account that was created.
  #
  # Examples
  #
  #   send_results foo@bar.com
  #
  # Returns nothing
  def send_results(address)
    send_email(address, 'Welcome to rancor!', :email_results)
  end

  # Internal: Sends an email using Pony
  #
  # address - The email address of the recipient
  # subject - The subject line of the email
  # body    - An .erb file (file name passed as a symbol) that contains the body
  #           of the email.
  #
  # Examples
  #
  #   send_email foo@bar.com, "Hello, world!", :hello_world
  #
  # Returns nothing
  def send_email(address, subject, body)
    @email_body = erb body, :layout => false
    Pony.mail({
      :to => address,
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
  end
end
