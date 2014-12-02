require 'bundler'
Bundler.require

require_relative 'ballot'
require_relative 'option'
require_relative 'poll'

# sets up a new database in this directory
configure :development do
  DataMapper.setup(:default, "sqlite3://../db/rancor.db")
end

configure :production do
  DataMapper.setup(:default, ENV['DATABASE_URL'] || 'postgres://localhost/mydb')
end

class Ranking
  include DataMapper::Resource

  property :rank, Integer

  belongs_to :ballot, key: true
  belongs_to :option, key: true
  has 1, :poll, through: :option
end