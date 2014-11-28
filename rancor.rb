require 'bundler'
Bundler.require
require_relative 'user'
# require_relative 'user_workspace'  # for experimenting only

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
        env['warden'].set_user(@account)
        success!(account)
      end
    end
  end

  # homepage displays all of the users
  get '/' do
    @title = 'rancor:home'
    erb :home
  end

  post '/' do
    # Nothing here yet
  end

  get '/all_users' do
    @users = Account.all :order => :id.desc
    @title = 'rancor:users'
    erb :all_users
  end

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
    elsif Account.exists?(params['username'])
      flash[:status] = "Username is already registered"
      redirect to('/new_user')
    elsif Account.exists?(params['email'])
      flash[:status] = "Email address is already registered"
      redirect to('/new_user')
    end

    Account.create(
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
    flash[:status] ||= env['warden'].message || "You are not logged in"
    redirect to('/login')
  end

  # TODO

  # TODO voting page
  before '/poll/:id/?' do
    @title = "rancor:poll.#{params[:id]}"
    @poll ||= Poll.get(params[:id]) || halt(404)
  end

  get '/poll/:id/?' do
    erb :poll
  end

  post '/poll/:id/?' do
    # TODO implement voting logic.
    "Nothing here yet"
  end

  # TODO basic results page for people who voted (and for organizers for now)
  get '/poll/:id/results/?' do
    @options = Poll.get(params[:id]).options order: :score.desc
    erb :results
  end

  # TODO Confirmation page? Not sure on routing on this or if this needs separate page.
  # I think we should redirect to the results page with a flash message detailing
  # that the user's vote has been successfully stored
  # get '/vote/confirm' do
  #   @title = 'rancor:your vote?'
  #   #erb :confirm
  # end


  get '/new_poll' do
    @title = 'rancor:new poll'
    # TODO erb for new poll
  end

  post '/new_poll' do
    # TODO Implement poll creation logic
  end

  get '/confirmation' do
    @title = 'rancor:new poll?'
    
    erb :confirmation
  end

  # TODO organizer results page? not sure if needed, and routing on this
  # get '/results-org' do
  #   @title = 'rancor:results(org)'
  #   erb :results_organizer
  # end

  not_found do
    "There is nothing here yet"
  end
end
