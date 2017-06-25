-- Create user table for markmywords

DROP SEQUENCE IF EXISTS user_seq CASCADE;
CREATE SEQUENCE user_seq;

DROP TABLE IF EXISTS mmy_user;
CREATE TABLE mmy_user (
	   idx int PRIMARY KEY DEFAULT nextval('user_seq'),
       username varchar(30) NOT NULL default '',
       password varchar(30) NOT NULL default '',
       admin integer not null default 0,
	   accuracy float default 0.0,
       UNIQUE(username)
);

INSERT INTO mmy_user (username, password, admin) VALUES ('jcm', 'jcm', 1);
INSERT INTO mmy_user (username, password) VALUES ('demo', 'demo');
