require 'bundler'
Bundler.require
require 'time'

require_relative 'account'
require_relative 'ballot'
require_relative 'option'
require_relative 'poll'
require_relative 'ranking'
require_relative 'invite'

# sets up a new database in this directory
configure :development do
  DataMapper.setup(:default, "sqlite3://#{Dir.pwd}/db/rancor.db")
  DataMapper.finalize.auto_upgrade!
end

configure :production do
  DataMapper.setup(:default, ENV['DATABASE_URL'] || 'postgres://localhost/rancor')
  DataMapper.finalize.auto_migrate!
end

if Account.all.size == 0
  # INSERT INTO User (id,username,email) VALUES(1,'p1','abc@email.com');
  p1 = Account.create(username: 'p1',
                      email: 'rancorapp@mailinator.com',
                      password: "test")

  # INSERT INTO User (id,username,email) VALUES(2,'student','cdad@email.com');
  student = Account.create(username: 'student',
                           email: 'rancorapp2@mailinator.com',
                           password: 'student')

  # INSERT INTO rancor (rid,oid,question) VALUES(1,1,'What is for dinner?');
  dinner = Poll.create(question: 'What is for dinner?')
  p1.polls << dinner
  p1.save

  # INSERT INTO rancor (rid,oid,question) VALUES(2,2,'Go out for drinks?');
  drinks = Poll.create(question: 'Go out for drinks?')
  student.polls << drinks
  student.save

  # INSERT INTO choices (rid,cid,option) VALUES(1,1,'steak');
  steak = Option.new(cid: 1, text: 'steak')
  dinner.options << steak
  # INSERT INTO choices (rid,cid,option) VALUES(1,2,'sushi');
  sushi = Option.new(cid: 2, text: 'sushi')
  dinner.options << sushi
  dinner.save

  # INSERT INTO choices (rid,cid,option) VALUES(2,1,'yes');
  yes = Option.new(cid: 1, text: 'yes')
  drinks.options << yes
  #INSERT INTO choices (rid,cid,option) VALUES(2,2,'no');
  no = Option.new(cid: 2, text: 'no')
  drinks.options << no
  drinks.save

  # third poll with a closedate
  curtime = Time.new.round
  curtime += curtime.min >= 30 ? 1 * 60 * 60 : 0
  curtime -= curtime.min * 60 + curtime.sec

  foo = Poll.create(question: "Will the A's trade away everyone this offseason?",
                    closedate: curtime.localtime(0).to_datetime)
  student.polls << foo
  student.save

  foo.options << Option.new(cid: 1, text:'yes')
  foo.options << Option.new(cid: 2, text:'of course')
  foo.options << Option.new(cid: 3, text: 'Is there anyone left to trade?')
  foo.save

end
