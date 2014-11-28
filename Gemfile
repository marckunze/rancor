source 'https://rubygems.org'
# fixing a ruby version to avoid a warning on heroku
ruby "2.0.0"
gem 'sinatra'     # Required for running framework
gem 'data_mapper' # ORM adapter for db
gem 'warden'      # Required for authentication
gem 'bcrypt'      # Required for passwords. Should be automatically install by data_mapper
gem 'sinatra-flash', require: 'sinatra/flash'
gem 'ordinalize', '~> 0.0.3'
gem 'pony'        # Required for email
gem 'mandrill-api'# also email, likely move to production once functioning

# http://bundler.io/v1.3/sinatra.html
# http://bundler.io/v1.3/gemfile.html
# https://devcenter.heroku.com/articles/rack

group :test, :development do
  # for any gems that are required in testing but not production
  # and other variations in dev/test compared to production
  gem "sqlite3"
  gem "dm-sqlite-adapter"
  #console that lets us run Ruby code in the environment of our app/database.
  gem "tux"
end

group :production do
  #Same but with production
  gem "pg"
  gem "dm-postgres-adapter"
  gem "dm-migrations"
end
