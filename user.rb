require 'bundler'
Bundler.require

# sets up a new database in this directory
configure :development do
  DataMapper.setup(:default, "sqlite3://#{Dir.pwd}/db/rancor.db")
end

configure :production do
  DataMapper.setup(:default, ENV['DATABASE_URL'] || 'postgres://localhost/mydb')
end


# sets up the Polls table in the above database
# the syntax is:
#            column name, datatype
class User
  include DataMapper::Resource
  include BCrypt

  property :id,           Serial
  property :username,     Text, :required => true, :unique => true
  property :email,        Text, :required => true, :unique => true
  property :password,     BCryptHash
  property :joined_at,    DateTime, :default => Time.now
  property :account_type, Enum[ :user, :admin ], :default => :user

  has n, :polls

  def self.authenticate(user, password)
    u = first(username: user)
    u ||= first(email: user)
    return nil if u.nil?  # user not found

    u = nil unless u.password == password
    return u
  end

  def self.exists?(user)
    first(username: user).nil? || first(email: user).nil?
  end
end

class Poll
  include DataMapper::Resource

  property :id,            Serial
  property :poll_question, Text
  property :open,          Boolean
  property :close_date,    DateTime

  belongs_to :user, :required => false
  has n, :questions
end

class Question
  include DataMapper::Resource

  property :id,     Serial
  property :answer, Text
  property :points, Integer

  belongs_to :poll
end

DataMapper.finalize.auto_upgrade!