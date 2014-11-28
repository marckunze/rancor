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
        success!(account)
      end
    end
  end

  public

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
    flash[:positive] = "You have successfully logged in"
    redirect to('/home')
  end

  get '/logout' do
    env['warden'].logout
    flash[:positive] = "You have successfully logged out"
    redirect to('/')
  end

  get '/home' do
    unless env['warden'].authenticated?
      flash[:negative] = "You are not logged in!"
      redirect to('/login')
    end

    @polls = env['warden'].user.polls.all
    erb :homepage
  end

  get '/new_user' do
    @title = 'rancor:register'
    erb :new_user
  end

  post '/new_user' do
    if params['password'] != params['confirmation']
      flash[:negative] = "Your passwords do not match"
      redirect to('/new_user')
    elsif Account.exists?(params['username'])
      flash[:negative] = "Username is already registered"
      redirect to('/new_user')
    elsif Account.exists?(params['email'])
      flash[:negative] = "Email address is already registered"
      redirect to('/new_user')
    end

    Account.create(
      :username  => params['username'],
      :email     => params['email'],
      :password  => params['password'],
    )

    flash[:neutral] = "Your account has been created."
    env['warden'].authenticate!
    redirect to('/')
  end

  post '/unauthenticated' do
    # Reserve '/unauenticated' for failed logins until I figure out why fail!()
    # is not passing the messages you insert.

    # Message is currently nil. I need to figure out how to access it.
    flash[:negative] ||= env['warden'].message || "Incorrect username and/or password"
    redirect to('/login')
  end

  # TODO

  # TODO voting page
  before '/poll/:id/?' do
    @title = "rancor:poll.#{params['id']}"
    @poll ||= Poll.get(params['id']) || halt(404)

    unless @poll.open
      flash[:neutral] = "Voting is closed for this poll"
      redirect to("/poll/#{params['id']}/results")
    end
  end

  get '/poll/:id/?' do
    erb :poll
  end

  post '/poll/:id/?' do
    # TODO Vote update not yet possible, but ballots saved
    # Random IPs for testing ballots
    ip = "%d.%d.%d.%d" % [rand(256), rand(256), rand(256), rand(256)]
    ballot = Ballot.create(voter: ip)
    # ballot = Ballot.create(voter: request.ip)
    unless @poll.ballots.first(voter: request.ip).nil?
      flash[:neutral] = "You have already voted!"
      redirect to("/poll/#{params['id']}/results")
    end

    @poll.ballots << ballot
    @poll.save

    params[:vote].each_with_index do |vote, i|
      ranking = Ranking.create(rank: i + 1)
      opt = @poll.options.first(text: vote)
      opt.score += @poll.options.size - i
      opt.rankings << ranking
      ballot.rankings << ranking

      ballot.save
      opt.save
    end

    flash[:positive] = "You vote has been recorded!"
    redirect to("/poll/#{params['id']}/results")
  end

  # TODO basic results page for people who voted (and for organizers for now)
  get '/poll/:id/results/?' do
    @options = Poll.get(params['id']).options order: :score.desc
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

  # TODO organizer results page? not sure if needed, and routing on this
  # get '/results-org' do
  #   @title = 'rancor:results(org)'
  #   erb :results_organizer
  # end

  not_found do
    "There is nothing here yet"
  end

  private


end
