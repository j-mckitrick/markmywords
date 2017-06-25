-- Create map table for markmywords.

DROP SEQUENCE IF EXISTS map_seq CASCADE;
CREATE SEQUENCE map_seq;

DROP TABLE IF EXISTS mmy_map;
CREATE TABLE mmy_map (
	   idx int PRIMARY KEY DEFAULT nextval('map_seq'),
	   user_idx int NOT NULL DEFAULT 0,
	   words_idx int NOT NULL DEFAULT 0,
	   UNIQUE(user_idx, words_idx)
);

