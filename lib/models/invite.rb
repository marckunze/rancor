require 'bundler'
Bundler.require

require_relative 'poll'

class Invite
  include DataMapper::Resource

  property :id,         Serial
  property :email,      String, length: 320, required: true, unique: false

  belongs_to :poll

  # Internal: Safe version of destroy, removes resource after performing all
  #           validations. Removes connection to owner poll before destroying
  #           resource. Will automatically fail if connection is not removed.
  #
  # Examples
  #
  #   @poll.invites.destroy
  #
  # Returns true if the operation was successful, false if not.
  def destroy
    self.poll = nil
    super
  end

  # Internal: Unsafe version of destroy, removes resource after performing no
  #           validations. Removes connection to owner poll before destroying
  #           resource. Will not automatically fail if connection is not removed.
  #
  # Examples
  #
  #   @poll.invites.destroy!
  #
  # Returns true if the operation was successful, false if not.
  def destroy!
    self.poll = nil
    super
  end
end
