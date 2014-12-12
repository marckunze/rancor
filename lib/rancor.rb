require 'bundler'
Bundler.require
require_relative 'models/models'
require_relative 'helpers/email_helpers'
require_relative 'helpers/misc_helpers'

class Rancor < Sinatra::Base
  set :root, Dir.pwd # Sets the root directory as the directory config.ru is in.
  enable :sessions
  register Sinatra::Flash

  use Warden::Manager do |config|
    config.serialize_into_session{|account| account.id }
    config.serialize_from_session{|id| Account.get(id) }

    config.scope_defaults :default, strategies: [:password]
    # Warden "must have a failure application declared"
    # (https://github.com/hassox/warden/wiki/Setup)
    # Playing with fire here, because I'm not 100% sure how this works
    config.failure_app = self
  end

  Warden::Strategies.add(:password) do
    def valid?
      # docs claim this is optional. Acts as a guard.
      params['username'] && params['password']
    end

    def authenticate!
      account = Account.authenticate(params['username'], params['password'])
      if account.nil?
        fail!("Incorrect username and/or password")
      else
        success!(account)
      end
    end
  end

  helpers EmailHelpers, MiscHelpers

  # The following documentation treats sinatra's get and post helpers as methods.

  # Public: GET request for the path '/'. Serves as the welcome page for the site.
  #
  # Returns the rendering for the welcome page as a String
  get '/' do
    @title = 'rancor:home'
    erb :welcome
  end

  # Public: GET request for paths '/home' and '/home/'. Can only be access by a
  #         user who is logged in.
  #
  # Returns the rendering for the homepage as a String if the user is logged in.
  #         If the user is not logged in they are redirected to the login page.
  get '/home/?' do
    unless env['warden'].authenticated?
      flash[:negative] = "You are not logged in!"
      redirect to('/login')
    end

    # Display all polls owned by user
    @polls = env['warden'].user.polls.all
    # Display all polls user is invited to
    @invites = []
    Invite.all(email: env['warden'].user.email).each do |invite|
      # invite.poll.owner.email might be streching things too far.
      if invite.poll.open && invite.poll.owner.email != env['warden'].user.email
        @invites << invite.poll
      end
    end
    @title = 'rancor:user home'
    erb :homepage
  end

  # Public: GET request for paths '/login' and '/login/'. Serves as the login page.
  #
  # Returns the rendering for the login page as a String.
  get '/login/?' do
    @title = 'rancor:login'
    erb :login
  end

  # Public: POST request for paths '/login' and '/login/'. Authenticates user and
  #              redirects them to their homepage if authentication is successful.
  #
  # Returns nothing.
  post '/login/?' do
    env['warden'].authenticate!
    flash[:positive] = "You have successfully logged in"
    redirect to('/home')
  end

  # Public: GET request for paths '/logout' and '/logout/'. Logs out the user
  #         and redirects them to the welcome page.
  #
  # Returns nothing.
  get '/logout/?' do
    env['warden'].logout
    flash[:positive] = "You have successfully logged out"
    redirect to('/')
  end

  # Public: GET request for paths '/new_user' and '/new_user/'. Serves as the
  #         new user creation page.
  #
  # Returns the rendering for the new user page as a String.
  get '/new_user/?' do
    @title = 'rancor:register'
    erb :new_user
  end

  # Public: POST request for paths '/new_user' and '/new_user/'. Verifies the
  #         information provided, creates a new account, and sends a confirmation
  #         email provided by the account creator. Finally, logs the new user in
  #         and redirects them to the homepage.
  #
  # Returns nothing.
  post '/new_user/?' do
    # Redirect the user if they are already logged in.
    if env['warden'].authenticated?
      flash[:neutral] = "You already have an account!"
      redirect to('/home')
    end

    # various parameter checks
    if params['username'].empty? || params['email'].empty? || params['password'].empty?
      flash[:negative] = "Fields can not be empty!"
      redirect to('/new_user')
    elsif params['password'] != params['confirmation']
      flash[:negative] = "Your passwords do not match"
      redirect to('/new_user')
    elsif Account.exists?(params['username'])
      flash[:negative] = "Username is already registered"
      redirect to('/new_user')
    elsif Account.exists?(params['email'])
      flash[:negative] = "Email address is already registered"
      redirect to('/new_user')
    end

    #validation ok, create new account
    Account.create(
      :username  => params['username'].strip,
      :email     => params['email'].strip,
      :password  => params['password']
    )

    send_confirmation(params['email'])

    #redirect to home page, letting them know of account creation
    flash[:positive] = "Your account has been created."
    env['warden'].authenticate!
    redirect to('/home')
  end

  # Public: GET request for paths '/new_poll' and '/new_poll/'. Serves as the new
  #         poll creation page
  #
  # RReturns the rendering for the new poll page as a String.
  get '/new_poll/?' do
    @title = 'rancor:new poll'
    erb :new_poll
  end

  # Public: POST request for paths '/new_poll' and '/new_poll/'. Verifies input,
  #         creates poll, emails invited users, and finally redirects to the
  #         newly created poll page.
  #
  # Returns nothing.
  post '/new_poll/?' do
    # Check input
    ## Check question
    if params['question'].empty?
      flash[:negative] = "You can't have a poll without a question!"
      redirect to('/new_poll')
    end

    ## Check options
    poll_opts = []
    params['option'].each do |input|
      input.strip!
      poll_opts << input unless input.empty?
    end

    ## Check number of options (must be two or more)
    if poll_opts.size < 2
      flash[:negative] = "You must have at least two options!"
      redirect to('/new_poll')
    end

    # Create poll once once input check is complete
    @poll = Poll.create(question: params['question'].strip)
    @poll.closedate = DateTime.httpdate(params['closeDate']) unless params['closeDate'].empty?
    # "allow_dup" is only passed as a parameter is box is checked.
    # As a result, true == not nil and false == nil
    unless params["allow_dup"].nil?
      @poll.dup_check = false
    end
    # params['description'].nil? is just a temporary stopgap to prevent errors
    # until the feature is implemented.
    unless params['description'].nil? || params['description'].empty?
      @poll.description = params['description']
    end
    poll_opts.each do |opt|
      @poll.options << Option.new(cid: @poll.options.size + 1, text: opt)
    end
    halt(500) unless @poll.save


    # Add poll to user account
    if env['warden'].authenticated?
      env['warden'].user.polls << @poll
      halt(500) unless env['warden'].user.save
      @poll.invites << Invite.new(email: env['warden'].user.email)
    end
    
    # Add invites
    params['email'].each do |address|
      address.strip!
      next if address.empty?
      @poll.invites << Invite.new(email: address)
    end
    halt(500) unless @poll.save
    # Send invites
    send_invites(@poll)


    # Redirect to newly created poll
    flash[:positive] = "Your poll has been created!"
    redirect to("/poll/#{@poll.rid}")
  end

  # Public: before helper for requests for paths '/poll/<id>' and '/poll/<id>/'.
  #         Gets the relevant poll, checks to see if the owner of the poll is
  #         viewing the page, and verifies that the poll is still open for voting.
  #
  # Returns nothing.
  before '/poll/:id/?' do
    @title = "rancor:poll.#{params['id']}"
    # Works because nil is counted as false.
    @owner_viewing = (poll.owner.id == env['warden'].user.id) if env['warden'].authenticated?

    unless poll.open
      flash[:neutral] = "Voting is closed for this poll"
      redirect to("/poll/#{params['id']}/results")
    end
  end

  # Public: GET request for paths '/poll/<id>' and '/poll/<id>/'. Serves as the
  #         voting page.
  #
  # Returns the rendering for poll page as a String.
  get '/poll/:id/?' do
    erb :poll
  end

  # Public: POST request for paths '/poll/<id>' and '/poll/<id>/'. Gets the
  #         results of the vote and adds those results to the poll.
  #
  # Returns nothing.
  post '/poll/:id/?' do
    # Random IPs for testing ballots
    # ip = "%d.%d.%d.%d" % [rand(256), rand(256), rand(256), rand(256)]
    # ballot = poll.dup_check ? poll.ballots.first(voter: ip) : nil
    ballot = poll.dup_check ? poll.ballots.first(voter: request.ip) : nil

    if ballot.nil?
      # if poll.add_results(params[:vote], ip) # for testing purposes
      if poll.add_results(params[:vote], request.ip)
        flash[:positive] = "Your vote has been recorded!"
      else
        flash[:negative] = "Failure while recording vote"
        halt(500)
      end
    else
      if ballot.update_results(params[:vote])
        flash[:positive] = "Your vote has been updated!"
      else
        flash[:negative] = "Failure during vote update"
        halt(500)
      end
    end
  end

  # Public: GET request for paths '/poll/<id>/results' and '/poll/<id>/results/'.
  #         Displays the current results of the poll.
  #
  # Returns the rendering for the results page as a String
  get '/poll/:id/results/?' do
    @options = poll.options.all(order: :score.desc)
    erb :results
  end

  # Public: Post request for paths '/poll/<id>/close' and '/pool/<id>/close/'
  #         Closes the poll if requested by the owner.
  #
  # Returns nothing.
  post '/poll/:id/close/?' do
    # Check to see if currently logged in user is the poll owner
    unless env['warden'].authenticated? && poll.owner == env['warden'].user
      flash[:negative] = "You are not authorized to perform this action!"
      halt
    end

    poll.close
    # Comment out the following line when testing locally
    send_results(poll)
  end

  # Public: After helper for paths '/poll/<id>/close' and '/pool/<id>/closes/'
  #
  # Returns nothing. Redirects the requester back to the the original page.
  after '/poll/:id/close/?' do
    halt(404) unless request.post?
    redirect to(request.referrer || '/')
  end

  # Public: Post request for paths '/poll/<id>/destroy' and '/pool/<id>/destroy/'
  #         Deletes the poll if requested by the owner.
  #
  # Returns nothing.
  post '/poll/:id/destroy/?' do
    # Check to see if currently logged in user is the poll owner
    unless env['warden'].authenticated? && poll.owner == env['warden'].user
      flash[:negative] = "You are not authorized to perform this action!"
      halt
    end

    halt(500) unless poll.destroy
  end

  # Public: After helper for paths '/poll/<id>/destroy' and '/pool/<id>/destroy/'
  #
  # Returns nothing. Redirects the requester back to the the original page.
  after '/poll/:id/destroy/?' do
    halt(404) unless request.post?
    redirect to(request.referrer || '/')
  end
  
  before '/account/*' do
    halt(404) unless request.post?
    unless env['warden'].authenticated?
      flash[:negative] = "You are not authorized to perform this action!"
      halt
    end
    pass
  end

  # Public: Post request for paths '/account/destroy' and '/account/destroy/'
  #         Deletes the user's account.
  #
  # Returns nothing.
  post '/account/destroy/?' do
    halt(500) unless env['warden'].user.destroy
    env['warden'].logout
  end
  
  before '/account/change/*' do
    unless params['password'] == env['warden'].user.password
      flash[:negative] = "Password entered was incorrect!"
      halt
    end
  end

  post '/account/change/email/?' do 
    halt(500) unless env['warden'].user.update(email: params['new_email'])
  end
  
  post '/account/change/password/?' do
    unless params['new_pass'] == params['confirm']
      flash[:negative] = "Your new passwords do not match"
      halt
    end
    halt(500) unless env['warden'].user.update(password: params['new_pass'])
  end
  
  # Public: After helper all paths that are part of  '/account/*'
  #
  # Returns nothing. Redirects the requester back to the the original page.
  after '/account/*' do
    pass unless response.successful?
    redirect to(request.referrer || '/')
  end

  # Public: GET request for path '/unauthenticated'. Adds a message and redirects
  #         the user to the login page.
  #
  # Returns nothing.
  post '/unauthenticated' do
    # Reserve '/unauthenticated' for failed logins until I figure out why fail!()
    # is not passing the messages inserted.

    # Message is currently nil. I need to figure out how to access it.
    flash[:negative] ||= env['warden'].message || "Incorrect username and/or password"
    redirect to('/login')
  end

  # Public: Helper for server error handling.
  #
  # Returns the rendering for the error page as a String
  error 500..505 do
    @title = 'rancor:error'
    erb :error
  end

  # Public: Helper for handling a 404 status.
  #
  # Returns the rendering for the not_found page as a String
  not_found do
    @title = 'rancor:home'
    erb :not_found
  end
end
