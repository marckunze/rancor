require 'bundler'
Bundler.require
require_relative 'user'
# require_relative 'user_workspace'  # for experimenting only

class Rancor < Sinatra::Base
  enable :sessions
  register Sinatra::Flash

  use Warden::Manager do |config|
    config.serialize_into_session{|user| user.id }
    config.serialize_from_session{|id| User.get(id) }

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
      user = User.authenticate(params['username'], params['password'])
      if user.nil?
        fail!("Incorrect username and/or password")
      else
        env['warden'].set_user(@user)
        success!(user)
      end
    end
  end

  # homepage displays all of the users
  get '/' do
    @title = 'rancor:home'
    erb :home
  end

  get '/all_users' do
    @users = User.all :order => :id.desc
    @title = 'rancor:users'
    erb :all_users
  end

  post '/' do
    # Nothing here yet
  end
1
  get '/login' do
    @title = 'rancor:login'
    erb :login
  end

  post '/login' do
    env['warden'].authenticate!
    flash[:status] = "You have successfully logged in"
    redirect to('/')
  end

  get '/logout' do
    env['warden'].logout
    flash[:status] = "You have successfully logged out"
    redirect to('/')
  end

  get '/new_user' do
    @title = 'rancor:register'
    erb :new_user
  end

  post '/new_user' do
    if params[:password] != params[:confirmation]
      flash[:status] = "Your passwords do not match"
      redirect to('/new_user')
    elsif User.exists?(params['username'])
      flash[:status] = "Username is already registered"
      redirect to('/new_user')
    elsif User.exists?(params['email'])
      flash[:status] = "Email address is already registered"
      redirect to('/new_user')
    end

    User.create(
      :username  => params[:username],
      :email     => params[:email],
      :password  => params[:password],
    )

    flash[:status] = "Your account has been created."
    env['warden'].authenticate!
    redirect to('/')
  end

  post '/unauthenticated' do
    # Message is currently nil. I need to figure out how to access it.
    flash[:status] = env['warden'].message
    flash[:status] ||= "You are not logged in"
    redirect to('/login')
  end

  # TODO

  # TODO voting page
  # get '/vote' do
  #   @title = 'rancor:vote!'
  #   erb :vote
  # end

  # TODO Confirmation page? Not sure on routing on this or if this needs separate page.
  # get '/vote/confirm' do
  #   @title = 'rancor:your vote?'
  #   #erb :confirm
  # end

  # TODO basic results page for people who voted (and for organizers for now)
  # get '/results' do
  #   @title = 'rancor:results'
  #   erb :results
  # end

  get '/new_poll' do
    @title = 'rancor:new poll?'
    erb :new_poll
  end

  # TODO organizer results page? not sure if needed, and routing on this
  # get '/results-org' do
  #   @title = 'rancor:results(org)'
  #   erb :results_organizer
  # end
end
