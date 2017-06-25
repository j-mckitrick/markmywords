
DROP TABLE IF EXISTS MMY_WORDS;
CREATE TABLE MMY_WORDS (
       idx int PRIMARY KEY AUTO_INCREMENT,
       user_idx int NOT NULL DEFAULT 0,
       date date NOT NULL,
       category varchar(40) NOT NULL DEFAULT 'General',
       title varchar(40) NOT NULL DEFAULT 'Title',
       content varchar(2000) NOT NULL DEFAULT 'No content',
       up_votes int NOT NULL DEFAULT 0,
       down_votes int NOT NULL DEFAULT 0,
       verified boolean not null default false,
);

CREATE TRIGGER wordsdate BEFORE INSERT ON MMY_WORDS FOR EACH ROW SET NEW.date = curdate();

INSERT INTO MMY_WORDS (user_idx, content) VALUES(1, 'Mark my words!');
INSERT INTO MMY_WORDS (user_idx, content) VALUES(1, 'Another word.');
