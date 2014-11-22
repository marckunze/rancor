# This file is meant to act as a workspace for converting the SQL statements
# into the appropriate DataMapper classes
require 'bundler'
Bundler.require

# sets up a new database in this directory
configure :development do
  DataMapper.setup(:default, "sqlite3://#{Dir.pwd}/db/rancor_workspace.db")
end

configure :production do
  DataMapper.setup(:default, ENV['DATABASE_URL'] || 'postgres://localhost/mydb')
end

# DROP TABLE IF EXISTS access_to;
# DROP TABLE IF EXISTS choices;
# DROP TABLE IF EXISTS rancor;
# DROP TABLE IF EXISTS User;
#
# Handled by DataMapper.auto_migrate!
#
# PRAGMA foreign_keys = ON;

# CREATE TABLE User
class User
  include DataMapper::Resource
  include BCrypt

  # id INTEGER PRIMARY KEY,
  property :id,         Serial
  # username TEXT NOT NULL UNIQUE,
  property :username,   Text, required: true, unique: true
  # email VARCHAR(320) NOT NULL UNIQUE,
  property :email,      String, length: 320, required: true, unique: true
  property :password,   BCryptHash
  # joined_at DATETIME
  property :joined_at,  DateTime, default: DateTime.now

  has n, :poll
end

class Poll  # Rancor is the name of the sinatra class
  include DataMapper::Resource

  # CREATE TABLE rancor
  storage_names[:default] = "rancor"
  # rid INTEGER PRIMARY KEY,
  property :rid,        Serial
  # question TEXT NOT NULL,
  property :question,   Text
  # open BOOLEAN DEFAULT 1,
  property :open,       Boolean, default: true
  # closedate DATETIME,
  property :closedate,  DateTime

  # oid INTEGER NOT NULL,
  # FOREIGN KEY (oid) REFERENCES User(id)
  belongs_to :user, required: false
  has n, :choice, child_key: :rid
end

# CREATE TABLE choices(
class Choice
  include DataMapper::Resource

  # cid INTEGER, PRIMARY KEY(rid,cid)
  property :cid,    Integer, key: true, unique: false
  # option TEXT NOT NULL,
  property :option, Text, required: true
  # count INTEGER DEFAULT 0,
  property :count, Integer, default: 0

  # rid INTEGER,
  # FOREIGN KEY (rid) REFERENCES rancor(rid)
  belongs_to :poll, child_key: :rid, key: true
  # PRIMARY KEY(rid,cid)
end

###### I don't think the following is necessary with DataMapper's belong_to
###### and has n properties. Please correct me if I'm wrong.
# CREATE TABLE IF NOT EXISTS access_to(
# rid INTEGER,
# id INTEGER,
# voted BOOLEAN DEFAULT 0,
# choice INTEGER DEFAULT null,
# FOREIGN KEY (rid) REFERENCES rancor(rid),
# FOREIGN KEY (id) REFERENCES User(id),
# FOREIGN KEY (rid,choice) REFERENCES choices(rid,cid)
# );

DataMapper.finalize
DataMapper.auto_migrate!

# INSERT INTO User (id,username,email) VALUES(1,'p1','abc@email.com');
p1 = User.create(username: 'p1', email: 'abc@email.com')

# INSERT INTO User (id,username,email) VALUES(2,'student','cdad@email.com');
student = User.create(username: 'student', email: 'cdad@email.com')

# INSERT INTO rancor (rid,oid,question) VALUES(1,1,'What is for dinner?');
dinner = Poll.create(question: 'What is for dinner?')
p1.poll << dinner
p1.save

# INSERT INTO rancor (rid,oid,question) VALUES(2,2,'Go out for drinks?');
drinks = Poll.create(question: 'Go out for drinks?')
student.poll << drinks
student.save

# INSERT INTO choices (rid,cid,option) VALUES(1,1,'steak');
dinner.choice << Choice.create(cid: 1, option: 'steak')

# INSERT INTO choices (rid,cid,option) VALUES(1,2,'sushi');
dinner.choice << Choice.create(cid: 2, option: 'sushi')
dinner.save

# INSERT INTO choices (rid,cid,option) VALUES(2,1,'yes');
drinks.choice << Choice.create(cid: 1, option: 'yes')

#INSERT INTO choices (rid,cid,option) VALUES(2,2,'no');
drinks.choice << Choice.create(cid: 2, option: 'no')
drinks.save

###### Ignored because there is no access_to table currently.
# INSERT INTO access_to (rid,id) VALUES(1,1);
# INSERT INTO access_to (rid,id) VALUES(1,2);
# INSERT INTO access_to (rid,id) VALUES(2,1);
# INSERT INTO access_to (rid,id) VALUES(2,2);
