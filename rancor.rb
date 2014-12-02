require 'bundler'
Bundler.require
require_relative 'models/models'
require_relative 'email_helpers'

class Rancor < Sinatra::Base
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

  helpers EmailHelpers

#######################################'/'######################################
  get '/' do
    @title = 'rancor:home'
    erb :home
  end

  post '/' do
    # Nothing here yet
  end

####################################'/home/?'###################################
  get '/home/?' do
    unless env['warden'].authenticated?
      flash[:negative] = "You are not logged in!"
      redirect to('/login')
    end

    # Display all polls owned by user
    @polls = env['warden'].user.polls.all
    erb :homepage
  end

###################################'/login/?'###################################
  get '/login/?' do
    @title = 'rancor:login'
    erb :login
  end

  post '/login/?' do
    env['warden'].authenticate!
    flash[:positive] = "You have successfully logged in"
    redirect to('/home')
  end

###################################'/logout/?'##################################
  get '/logout/?' do
    env['warden'].logout
    flash[:positive] = "You have successfully logged out"
    redirect to('/')
  end

##################################'/new_user/?'#################################
  get '/new_user/?' do
    @title = 'rancor:register'
    erb :new_user
  end

  post '/new_user/?' do
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
      :username  => params['username'].chomp,
      :email     => params['email'].chomp,
      :password  => params['password']
    )

    send_confirmation params['email']

    #redirect to home page, letting them know of account creation
    flash[:neutral] = "Your account has been created."
    env['warden'].authenticate!
    redirect to('/')
  end

##################################'/new_poll/?'#################################
  get '/new_poll/?' do
    @title = 'rancor:new poll'
    erb :new_poll
  end

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
      poll_opts << input.chomp unless input.empty?
    end

    ## Check number of options (must be two or more)
    if poll_opts.size < 2
      flash[:negative] = "You must have at least two options!"
      redirect to('/new_poll')
    end

    # Create poll once once input check is complete
    @poll = Poll.create(question: params['question'].chomp)

    poll_opts.each do |opt|
      @poll.options << Option.create(cid: @poll.options.size + 1, text: opt)
      @poll.save
    end

    # Add poll to user account
    if env['warden'].authenticated?
      env['warden'].user.polls << @poll
      env['warden'].user.save
    end
    
    # Send invites
    params['email'].each do |address|
      address.chomp!
      send_invite address unless address.empty?
    end

    # Redirect to newly created poll
    flash[:positive] = "Your poll has been created!"
    redirect to("/poll/#{@poll.rid}")
  end

##################################'/poll/:id/?'#################################
  before '/poll/:id/?' do
    @title = "rancor:poll.#{params['id']}"
    @poll ||= Poll.get(params['id']) || halt(404)
    # Works because nil is counted as false.
    @owner_viewing = (@poll.owner.id == env['warden'].user.id) if env['warden'].authenticated?

    unless @poll.open
      flash[:neutral] = "Voting is closed for this poll"
      redirect to("/poll/#{params['id']}/results")
    end
  end

  get '/poll/:id/?' do
    erb :poll
  end

  post '/poll/:id/?' do
    # Random IPs for testing ballots
    # ip = "%d.%d.%d.%d" % [rand(256), rand(256), rand(256), rand(256)]
    # ballot = @poll.ballots.first(voter: ip)
    ballot = @poll.ballots.first(voter: request.ip)

    if ballot.nil?
      # @poll.add_results params[:vote], ip # for testing purposes
      @poll.add_results params[:vote], request.ip
      flash.now[:positive] = "Your vote has been recorded!"
    else
      ballot.update_results params[:vote]
      flash.now[:positive] = "Your vote has been updated!"
    end

    redirect to("/poll/#{params['id']}/results")
  end

##############################'/poll/:id/results/?'#############################
  get '/poll/:id/results/?' do
    @poll ||= Poll.get(params['id']) || halt(404)
    @options = @poll.options.all order: :score.desc
    erb :results
  end

##############################'/unauthenticated/?'##############################
  post '/unauthenticated/?' do
    # Reserve '/unauthenticated' for failed logins until I figure out why fail!()
    # is not passing the messages inserted.

    # Message is currently nil. I need to figure out how to access it.
    flash[:negative] ||= env['warden'].message || "Incorrect username and/or password"
    redirect to('/login')
  end

#######################################404######################################
  not_found do
    erb :error
  end

  # TODO organizer results page? not sure if needed, and routing on this
  # get '/results-org' do
  #   @title = 'rancor:results(org)'
  #   erb :results_organizer
  # end
end
