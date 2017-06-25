-- Create entry table for markmywords.

DROP SEQUENCE IF EXISTS entry_seq CASCADE;
CREATE SEQUENCE entry_seq;

DROP TABLE IF EXISTS mmy_entry;
CREATE TABLE mmy_entry (
       idx int PRIMARY KEY DEFAULT nextval('entry_seq'),
       user_idx int NOT NULL DEFAULT 0,
       date date NOT NULL DEFAULT now(),
       category varchar(40) NOT NULL DEFAULT 'General',
       title varchar(40) NOT NULL DEFAULT 'Title',
       content varchar(2000) NOT NULL DEFAULT 'No content',
       up_votes int NOT NULL DEFAULT 0,
       down_votes int NOT NULL DEFAULT 0,
       verified int NOT NULL DEFAULT 0
);

INSERT INTO mmy_entry (user_idx, content) VALUES(1, 'Mark my words!');
INSERT INTO mmy_entry (user_idx, content) VALUES(1, 'Another word.');
