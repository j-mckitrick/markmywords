
DROP TABLE IF EXISTS MMY_USER;
CREATE TABLE MMY_USER (
       idx int PRIMARY KEY AUTO_INCREMENT,
       username varchar(30) NOT NULL default '',
       password varchar(30) NOT NULL default '',
       admin boolean not null default false,
	   accuracy decimal(5,2) default 0.0,
       UNIQUE(username)
);

INSERT INTO MMY_USER (username, password) VALUES ('jcm', 'jcm');
INSERT INTO MMY_USER (username, password) VALUES ('demo', 'demo');
