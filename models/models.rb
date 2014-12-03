require 'bundler'
Bundler.require

require_relative 'account'
require_relative 'ballot'
require_relative 'option'
require_relative 'poll'
require_relative 'ranking'

# sets up a new database in this directory
configure :development do
  DataMapper.setup(:default, "sqlite3://#{Dir.pwd}/db/rancor.db")
  DataMapper.finalize.auto_upgrade!
end

configure :production do
  DataMapper.setup(:default, ENV['DATABASE_URL'] || 'postgres://localhost/mydb')
  DataMapper.finalize.auto_migrate!
end

if Account.all.size == 0
  # INSERT INTO User (id,username,email) VALUES(1,'p1','abc@email.com');
  p1 = Account.create(username: 'p1', email: 'abc@email.com', password: "test")

  # INSERT INTO User (id,username,email) VALUES(2,'student','cdad@email.com');
  student = Account.create(username: 'student', email: 'cdad@email.com')

  # INSERT INTO rancor (rid,oid,question) VALUES(1,1,'What is for dinner?');
  dinner = Poll.create(question: 'What is for dinner?')
  p1.polls << dinner
  p1.save

  # INSERT INTO rancor (rid,oid,question) VALUES(2,2,'Go out for drinks?');
  drinks = Poll.create(question: 'Go out for drinks?')
  student.polls << drinks
  student.save

  # INSERT INTO choices (rid,cid,option) VALUES(1,1,'steak');
  steak = Option.create(cid: 1, text: 'steak')
  dinner.options << steak
  # INSERT INTO choices (rid,cid,option) VALUES(1,2,'sushi');
  sushi = Option.create(cid: 2, text: 'sushi')
  dinner.options << sushi
  dinner.save

  # INSERT INTO choices (rid,cid,option) VALUES(2,1,'yes');
  yes = Option.create(cid: 1, text: 'yes')
  drinks.options << yes
  #INSERT INTO choices (rid,cid,option) VALUES(2,2,'no');
  no = Option.create(cid: 2, text: 'no')
  drinks.options << no
  drinks.save
end
