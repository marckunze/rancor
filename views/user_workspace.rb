# This file is meant to act as a workspace for converting the SQL statements
# into the appropriate DataMapper classes
require 'bundler'
Bundler.require

# sets up a new database in this directory
configure :development do
  DataMapper.setup(:default, "sqlite3://#{Dir.pwd}/db/rancor.db")
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
#
# CREATE TABLE IF NOT EXISTS User(
# id INTEGER PRIMARY KEY,
# username TEXT NOT NULL UNIQUE,
# email VARCHAR(320) NOT NULL UNIQUE,
# joined_at DATETIME
# );
class User
  include DataMapper::Resource
  include BCrypt

  property :id,         Serial
  property :username,   Text, required: true, unique: true
  property :email,      String, length: 320, required: true, unique: true
  property :password,   BCryptHash
  property :joined_at,  DateTime, default: Time.now
end
# CREATE TABLE IF NOT EXISTS rancor(
# rid INTEGER PRIMARY KEY,
# oid INTEGER NOT NULL,
# question TEXT NOT NULL,
# open BOOLEAN DEFAULT 1,
# closedate DATETIME,
# FOREIGN KEY (oid) REFERENCES User(id)
# );
class Rancor
  property :rid,        Serial
  property :oid,        Integer, required: true
  property :question,   Text
  property :open,       Boolean, default: true
  property :closedate,  DateTime

  # FOREIGN KEY (oid) REFERENCES User(id)
end
# CREATE TABLE IF NOT EXISTS choices(
# rid INTEGER,
# cid INTEGER,
# option TEXT NOT NULL,
# count INTEGER DEFAULT 0,
# FOREIGN KEY (rid) REFERENCES rancor(rid),
# PRIMARY KEY(rid,cid)
# );
class Choice
  property :rid,    Integer, key: true
  property :cid,    Integer, key: true
  property :option, Text, required: true

  # FOREIGN KEY (rid) REFERENCES rancor(rid)
end
#
# CREATE TABLE IF NOT EXISTS access_to(
# rid INTEGER,
# id INTEGER,
# voted BOOLEAN DEFAULT 0,
# choice INTEGER DEFAULT null,
# FOREIGN KEY (rid) REFERENCES rancor(rid),
# FOREIGN KEY (id) REFERENCES User(id),
# FOREIGN KEY (rid,choice) REFERENCES choices(rid,cid)
# );
#
# INSERT INTO User (id,username,email) VALUES(1,'p1','abc@email.com');
User.create(id: 1, username: 'p1', email: 'abc@email.com')
# INSERT INTO User (id,username,email) VALUES(2,'student','cdad@email.com');
User.create(id: 2, username: 'student', email: 'cdad@email.com')
# INSERT INTO rancor (rid,oid,question) VALUES(1,1,'What is for dinner?');
# INSERT INTO rancor (rid,oid,question) VALUES(2,2,'Go out for drinks?');
# INSERT INTO choices (rid,cid,option) VALUES(1,1,'steak');
# INSERT INTO choices (rid,cid,option) VALUES(1,2,'sushi');
# INSERT INTO choices (rid,cid,option) VALUES(2,1,'yes');
# INSERT INTO choices (rid,cid,option) VALUES(2,2,'no');
# INSERT INTO access_to (rid,id) VALUES(1,1);
# INSERT INTO access_to (rid,id) VALUES(1,2);
# INSERT INTO access_to (rid,id) VALUES(2,2);
