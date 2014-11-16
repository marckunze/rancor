source 'http://rubygems.org'

gem 'sinatra' 		#Required for running framework
gem 'data_mapper' 	#ORM adapter for db

# http://bundler.io/v1.3/sinatra.html
# http://bundler.io/v1.3/gemfile.html
# https://devcenter.heroku.com/articles/rack

group :test, :development do
  # for any gems that are required in testing but not production
  # and other variations in dev/test compared to production
  gem "sqlite3"
  gem "dm-sqlite-adapter"
end

group :production do
	#Same but with production
	gem "pg"
	gem "dm-postgres-adapter"
	gem "dm-migrations"
end
