require 'rubygems'
require 'sinatra'
require 'data_mapper'

# sets up a new database in this directory
configure :development do
	DataMapper.setup(:default, "sqlite3://#{Dir.pwd}/rancor.db")
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
	@title = 'All Users'
	erb :home
end

post '/' do

end

get '/new_user' do
	erb :new_user
end

post '/new_user' do
	if params[:password1] != params[:password2]
		redirect '/new_user'
	end
	u = User.new
	u.username = params[:username]
	u.email = params[:email]
	u.joined_at = Time.now
	u.save
	redirect '/'
end
