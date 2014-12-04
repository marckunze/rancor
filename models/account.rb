require 'bundler'
Bundler.require

require_relative 'poll'

class Account
  include DataMapper::Resource
  include BCrypt

  property :id,         Serial
  property :username,   Text, required: true, unique: true
  property :email,      String, length: 320, required: true, unique: true
  property :password,   BCryptHash, required: true
  property :created_at, DateTime

  has n, :polls, child_key: [ 'owner_id' ]

  # Internal: Retrieves user account if their credentials are valid
  #
  # user     - The username or email of the user attempting to log in.
  # password - The password of the user attempting to log in.
  #
  # Examples:
  #
  #   Account.authenticate(foobar, password)
  #   # => nil
  #
  #   Account.authenticate(foobar, password1)
  #   # => #<Account:0x00000003467c80>
  #
  # Returns the account information of the user if the password is valid with the
  #         username or email that was submitted, else returns nil.
  def self.authenticate(user, password)
    u = first(username: user)
    u ||= first(email: user)
    return nil if u.nil?  # user not found

    u = nil unless u.password == password
    return u
  end

  # Internal: Search for a user who may already exist
  #
  # user - the username or email of someone who may have an account
  #
  # Examples:
  #
  #   Account.exists?(foobar)
  #   # => true
  #
  #   Account.exists?(foo@bar.com)
  #   # => false
  #
  # Returns true if a user was found, false if not.
  def self.exists?(user)
    self.username_exists?(user) || self.email_exists?(user)
  end

  # Internal: Search for a user who may already exist
  #
  # username - the username of someone who may have an account
  #
  # Examples:
  #
  #   Account.username_exists?(foobar)
  #   # => true
  #
  # Returns true if a user was found, false if not.
  def self.username_exists?(username)
    !first(username: username).nil?
  end

  # Internal: Search for a user who may already exist
  #
  # email - the email of someone who may have an account
  #
  # Examples:
  #
  #   Account.email_exists?(foo@bar.com)
  #   # => false
  #
  # Returns true if a user was found, false if not.
  def self.email_exists?(email)
    !first(email:email).nil?
  end
end
