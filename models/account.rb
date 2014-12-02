require 'bundler'
Bundler.require

require_relative 'poll'

class Account
  include DataMapper::Resource
  include BCrypt

  property :id,         Serial
  property :username,   Text, required: true, unique: true
  property :email,      String, length: 320, required: true, unique: true
  property :password,   BCryptHash # , required: true
  property :created_at, DateTime

  has n, :polls, child_key: [ 'owner_id' ]

  def self.authenticate(user, password)
    u = first(username: user)
    u ||= first(email: user)
    return nil if u.nil?  # user not found

    u = nil unless u.password == password
    return u
  end

  def self.exists?(user)
    self.username_exists?(user) || self.email_exists?(user)
  end

  def self.username_exists?(username)
    !first(username: username).nil?
  end

  def self.email_exists?(email)
    !first(email:email).nil?
  end
end
