require 'rubygems'
require 'bundler'

Bundler.require

require './rancor'
run Sinatra::Application
