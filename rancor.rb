require 'sinatra'
require 'data_mapper'

# sets up a new database in this directory
configure :development do
	DataMapper.setup(:default, "sqlite3://#{Dir.pwd}/db/rancor.db")
end

configure :production do
	DataMapper.setup(:default, ENV['DATABASE_URL'] || 'postgres://localhost/mydb')
end


# sets up the Polls table in the above database
# the syntax is:
# 			 column name, datatype
class User
	include DataMapper::Resource
	property :id, Serial
	property :username, Text, :required => true
	property :email, Text, :required => true
	property :joined_at, DateTime
end

DataMapper.finalize.auto_upgrade!

# homepage displays all of the users
get '/' do
	@users = User.all :order => :id.desc
	@title = 'rancor:users'
	erb :home
end

post '/' do
	# Nothing here yet
end

get '/new_user' do
	@title = 'rancor:register'
	erb :new_user
end

post '/new_user' do
	redirect to('/new_user') unless params[:password1] == params[:password2]
	User.create(
		:username  => params[:username],
		:email 		 => params[:email],
		:joined_at => Time.now
	)
	redirect to('/')
end

#TODO

#TODO voting page
#get '/vote' do
#	@title = 'rancor:vote!'
	#erb :vote
#end

#TODO Confirmation page? Not sure on routing on this or if this needs separate page.
#get '/vote/confirm' do
#	@title = 'rancor:your vote?'
#	#erb :confirm
#end

#TODO basic results page for people who voted (and for organizers for now)
#get '/results' do
#	@title = 'rancor:results'
#	erb :results
#end

#TODO new poll creation page
#get '/new_poll' do
#	@title = 'rancor:new poll?'
#	erb :new_poll
#end

#TODO organizer results page? not sure if needed, and routing on this
#get '/results-org' do
#	@title = 'rancor:results(org)'
#	erb :results_organizer
#end
