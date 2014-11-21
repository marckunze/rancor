-- create database with SQLite3
-- sqlite3 rancor.db < create_rancor.sql
-- PRAGMA foreign_keys = ON; -- to turn on foreign_key
-- boolean false(0) and true(1)

DROP TABLE IF EXISTS access_to;
DROP TABLE IF EXISTS choices;
DROP TABLE IF EXISTS rancor;
DROP TABLE IF EXISTS User;

PRAGMA foreign_keys = ON;

CREATE TABLE IF NOT EXISTS User(
id INTEGER PRIMARY KEY,
username TEXT NOT NULL UNIQUE,
email VARCHAR(320) NOT NULL UNIQUE,
joined_at DATETIME
);

CREATE TABLE IF NOT EXISTS rancor(
rid INTEGER PRIMARY KEY,
oid INTEGER NOT NULL,
question TEXT NOT NULL,
open BOOLEAN DEFAULT 1,
closedate DATETIME,
FOREIGN KEY (oid) REFERENCES User(id)
);

CREATE TABLE IF NOT EXISTS choices(
rid INTEGER,
cid INTEGER,
option TEXT NOT NULL,
count INTEGER DEFAULT 0,
FOREIGN KEY (rid) REFERENCES rancor(rid),
PRIMARY KEY(rid,cid)
);


CREATE TABLE IF NOT EXISTS access_to(
rid INTEGER,
id INTEGER,
voted BOOLEAN DEFAULT 0,
choice INTEGER,
FOREIGN KEY (rid) REFERENCES rancor(rid),
FOREIGN KEY (id) REFERENCES User(id)
);

INSERT INTO User (id,username,email) VALUES(1,'p1','abc@email.com');
INSERT INTO User (id,username,email) VALUES(2,'student','cdad@email.com');
INSERT INTO rancor (rid,oid,question) VALUES(1,1,'What is for dinner?');
INSERT INTO rancor (rid,oid,question) VALUES(2,2,'Go out for drinks?');
INSERT INTO choices (rid,cid,option) VALUES(1,1,'steak');
INSERT INTO choices (rid,cid,option) VALUES(1,2,'sushi');
INSERT INTO choices (rid,cid,option) VALUES(2,1,'yes');
INSERT INTO choices (rid,cid,option) VALUES(2,2,'no');
INSERT INTO access_to (rid,id) VALUES(1,1);
INSERT INTO access_to (rid,id) VALUES(1,2);
INSERT INTO access_to (rid,id) VALUES(2,2);
