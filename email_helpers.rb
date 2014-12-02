module EmailHelpers
  def send_confirmation(address)
    send_email address, 'Welcome to rancor!', :email_confirm
  end

  def send_invite(address)
    send_email address, 'You have been invited to participate in a poll!', :email_invite
  end

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
