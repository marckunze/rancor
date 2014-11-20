require 'bundler'
Bundler.require
require_relative 'user'

class Rancor < Sinatra::Base
  enable :sessions

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
    @users = User.all :order => :id.desc
    @title = 'rancor:users'
    erb :home
  end

  post '/' do
    # Nothing here yet
  end

  get '/login' do
    @title = 'rancor:login'
    erb :login
  end

  post '/login' do
    env['warden'].authenticate!
    redirect to('/authenticated')
  end

  get '/logout' do
    env['warden'].logout
    "Logged out"
  end

  get '/new_user' do
    @title = 'rancor:register'
    erb :new_user
  end

  post '/new_user' do
    redirect to('/new_user') unless params[:password1] == params[:password2]
    User.create(
      :username  => params[:username],
      :email     => params[:email],
      :password  => params[:password1],
    )
    redirect to('/')
  end

  get '/authenticated' do
    if env['warden'].authenticated?
      "Success  User: #{env['warden'].user.username}"
    else
      "User not authenticated"
    end
  end

  post '/unauthenticated' do
    # Message is currently nil. I need to figure out how to access it.
    "Failure: #{env['warden'].message}"
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
