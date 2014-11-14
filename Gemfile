source 'http://rubygems.org'

gem 'sinatra' 		#Required for running framework
gem 'data_mapper' 	#ORM adapter for db

# http://bundler.io/v1.3/sinatra.html
# http://bundler.io/v1.3/gemfile.html
# https://devcenter.heroku.com/articles/rack

group :test, :development do
  # for any gems that are required in testing but not production
  gem 'dm-sqlite-adapter' 
  # and other variations in dev/test compared to production
end

group :production do
	#Same but with production
	# mk - I can't get this working just yet
	#gem 'dm-postgres-adapter'
end
