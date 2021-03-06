BEGIN TRANSACTION;
CREATE TABLE "categories"(num INT PRIMARY KEY, name VARCHAR(30), desc VARCHAR(100));
INSERT INTO "categories" VALUES(1,'tools','Coding and System Tools');
INSERT INTO "categories" VALUES(2,'affordances','Affordances');
INSERT INTO "categories" VALUES(3,'examples','Test, Benchmarking, and Example Code');
INSERT INTO "categories" VALUES(4,'toys','Toys and Games');
INSERT INTO "categories" VALUES(5,'algorithms','Algorithms and Data Structures');
INSERT INTO "categories" VALUES(6,'other','Other');
CREATE TABLE "languages"(num INT PRIMARY KEY, name VARCHAR(30), desc VARCHAR(100));
INSERT INTO "languages" VALUES(1,'c','C');
INSERT INTO "languages" VALUES(2,'haskell','Haskell');
INSERT INTO "languages" VALUES(3,'java','Java');
INSERT INTO "languages" VALUES(4,'shell','Shell Scripts');
INSERT INTO "languages" VALUES(5,'misc','Misc');
CREATE TABLE "master"(intname VARCHAR(30) PRIMARY KEY, category VARCHAR(30), visname VARCHAR(30), attrib VARCHAR(100), language VARCHAR(30), langdetail VARCHAR(100), adddate DATE NOT NULL DEFAULT(CURRENT_DATE));
COMMIT;
