require 'bundler'
Bundler.require

require_relative 'ballot'
require_relative 'option'
require_relative 'poll'

class Ranking
  include DataMapper::Resource

  property :rank, Integer

  belongs_to :ballot, key: true
  belongs_to :option, key: true
  has 1, :poll, through: :option

  def destroy
    self.ballot = nil
    self.poll = nil
    self.option = nil
    super
  end

  def destroy!
    self.ballot = nil
    self.poll = nil
    self.option = nil
    super
  end

end
