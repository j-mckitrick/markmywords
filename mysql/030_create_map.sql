
DROP TABLE IF EXISTS MMY_MAP;
CREATE TABLE MMY_MAP (
	   idx int PRIMARY KEY AUTO_INCREMENT,
	   user_idx int NOT NULL DEFAULT 0,
	   words_idx int NOT NULL DEFAULT 0,
	   UNIQUE(user_idx, words_idx)
--	   date date NOT NULL
);

