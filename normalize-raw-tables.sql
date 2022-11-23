-------------------Simple Example-------------------
-- x,y
-- Zap,A
-- Zip,A
-- One,B
-- Two,B
DROP TABLE IF EXISTS xy_raw;
DROP TABLE IF EXISTS y;
DROP TABLE IF EXISTS xy;
CREATE TABLE xy_raw(x TEXT, y TEXT, y_id INTEGER);
CREATE TABLE y(id SERIAL PRIMARY KEY, y TEXT);
CREATE TABLE xy(id SERIAL PRIMARY KEY, x TEXT, y_id INTEGER, UNIQUE(x, y_id));

INSERT INTO xy_raw(x, y) VALUES ('Zip', 'A'), ('Zap', 'A'), ('One', 'B'), ('Two', 'B');

-- 1
INSERT INTO y(y) SELECT DISTINCT y from xy_raw;
--2
UPDATE xy_raw SET y_id = (SELECT y.id FROM y WHERE y.y = xy_raw.y);
--3
INSERT INTO xy(x, y_id) SELECT x, y_id FROM xy_raw;


-------------------Many-TO-One Example-------------------
DROP TABLE IF EXISTS track_raw CASCADE;
CREATE TABLE track_raw
	(title TEXT, artist TEXT, album TEXT, album_id INTEGER,
	count INTEGER, rating INTEGER, len INTEGER);
  

DROP TABLE IF EXISTS album CASCADE;
CREATE TABLE album (
	id SERIAL,
	title VARCHAR(128) UNIQUE,
	PRIMARY KEY(id));

DROP TABLE IF EXISTS track CASCADE;
CREATE TABLE track (
	id SERIAL,
	title VARCHAR(128),
	len INTEGER, rating INTEGER, count INTEGER,
	album_id INTEGER REFERENCES album(id) ON DELETE CASCADE,
	UNIQUE(title, album_id),
	PRIMARY KEY(id));

--To insert data from csv to track_raw table, in psql terminal:
-- wget https://www.pg4e.com/tools/sql/library.csv
-- \copy track_raw(title,artist,album,count,rating,len) FROM 'library.csv' WITH DELIMITER ',' CSV;
--or simply import to the table in pgAdmin

--1 
INSERT INTO album(title) SELECT album FROM track_raw;
--2
UPDATE track_raw SET album_id = (SELECT album.id FROM album WHERE album.title = track_raw.album);
--3
INSERT INTO track(title, album_id) SELECT title, album_id FROM track_raw;


SELECT track.title, album.title
    FROM track
    JOIN album ON track.album_id = album.id
    ORDER BY track.title LIMIT 3;


-------------------Many-TO-Many Example-------------------
DROP TABLE IF EXISTS album CASCADE;
CREATE TABLE album (
    id SERIAL,
    title VARCHAR(128) UNIQUE,
    PRIMARY KEY(id)
);

DROP TABLE IF EXISTS track CASCADE;
CREATE TABLE track (
    id SERIAL,
    title TEXT, 
    artist TEXT, 
    album TEXT, 
    album_id INTEGER REFERENCES album(id) ON DELETE CASCADE,
    count INTEGER, 
    rating INTEGER, 
    len INTEGER,
    PRIMARY KEY(id)
);

DROP TABLE IF EXISTS artist CASCADE;
CREATE TABLE artist (
    id SERIAL,
    name VARCHAR(128) UNIQUE,
    PRIMARY KEY(id)
);

DROP TABLE IF EXISTS tracktoartist CASCADE;
CREATE TABLE tracktoartist (
    id SERIAL,
    track VARCHAR(128),
    track_id INTEGER REFERENCES track(id) ON DELETE CASCADE,
    artist VARCHAR(128),
    artist_id INTEGER REFERENCES artist(id) ON DELETE CASCADE,
    PRIMARY KEY(id)
);

-- wget https://www.pg4e.com/tools/sql/library.csv
-- \copy track(title,artist,album,count,rating,len) FROM 'library.csv' WITH DELIMITER ',' CSV;

INSERT INTO album (title) SELECT DISTINCT album FROM track;
UPDATE track SET album_id = (SELECT album.id FROM album WHERE album.title = track.album);

INSERT INTO tracktoartist (track, artist) SELECT DISTINCT title, artist FROM track;

INSERT INTO artist (name) SELECT DISTINCT artist FROM track;

UPDATE tracktoartist SET track_id = (SELECT id FROM track WHERE track.title = tracktoartist.track);
UPDATE tracktoartist SET artist_id = (SELECT id FROM artist WHERE artist.name = tracktoartist.artist);

-- We are now done with these text fields
ALTER TABLE track DROP COLUMN album;
ALTER TABLE track DROP COLUMN artist;
ALTER TABLE tracktoartist DROP COLUMN track;
ALTER TABLE tracktoartist DROP COLUMN artist;

SELECT track.title, album.title, artist.name
FROM track
JOIN album ON track.album_id = album.id
JOIN tracktoartist ON track.id = tracktoartist.track_id
JOIN artist ON tracktoartist.artist_id = artist.id
ORDER BY track.title
LIMIT 3;


-------------------Another Example-------------------
-- Unesco Heritage Sites Many-to-One
-- In this assignment you will read some Unesco Heritage Site data in comma-separated-values (CSV) format 
-- and produce properly normalized tables.
DROP TABLE IF EXISTS unesco_raw CASCADE;
CREATE TABLE unesco_raw
	(name TEXT, description TEXT, justification TEXT, year INTEGER,
	longitude FLOAT, latitude FLOAT, area_hectares FLOAT,
	category TEXT, category_id INTEGER, state TEXT, state_id INTEGER,
	region TEXT, region_id INTEGER, iso TEXT, iso_id INTEGER);

DROP TABLE IF EXISTS category CASCADE;
CREATE TABLE category(
	id SERIAL,
	name VARCHAR(128) UNIQUE,
	PRIMARY KEY(id));

DROP TABLE IF EXISTS state CASCADE;
CREATE TABLE state(
	id SERIAL,
	name VARCHAR(128) UNIQUE,
	PRIMARY KEY(id));

DROP TABLE IF EXISTS region CASCADE;
CREATE TABLE region(
	id SERIAL,
	name VARCHAR(128) UNIQUE,
	PRIMARY KEY(id));

DROP TABLE IF EXISTS iso CASCADE;
CREATE TABLE iso(
	id SERIAL,
	name VARCHAR(128) UNIQUE,
	PRIMARY KEY(id));

-- To insert data from csv to unesco_raw table, in psql terminal:
-- wget https://www.pg4e.com/tools/sql/whc-sites-2018-small.csv
--	\copy unesco_raw(name,description,justification,year,longitude,latitude,area_hectares,category,state,region,iso) FROM 'whc-sites-2018-small.csv' WITH DELIMITER ',' CSV HEADER;
-- or simply import to the table in pgAdmin

INSERT INTO category(name) SELECT DISTINCT category from unesco_raw;
UPDATE unesco_raw SET category_id = (SELECT id FROM category WHERE category.name = unesco_raw.category);

INSERT INTO state(name) SELECT DISTINCT state from unesco_raw;
UPDATE unesco_raw SET state_id = (SELECT id FROM state WHERE state.name = unesco_raw.state);

INSERT INTO region(name) SELECT DISTINCT region from unesco_raw;
UPDATE unesco_raw SET region_id = (SELECT id FROM region WHERE region.name = unesco_raw.region);

INSERT INTO iso(name) SELECT DISTINCT iso from unesco_raw;
UPDATE unesco_raw SET iso_id = (SELECT id FROM iso WHERE iso.name = unesco_raw.iso);


DROP TABLE IF EXISTS unesco;
CREATE TABLE unesco
	(name TEXT, description TEXT, justification TEXT, year INTEGER,
	longitude FLOAT, latitude FLOAT, area_hectares FLOAT,
	category_id INTEGER, state_id INTEGER, region_id INTEGER, iso_id INTEGER);

INSERT INTO unesco(name, description, justification, year, longitude, latitude, area_hectares,
	category_id, state_id, region_id, iso_id)
	SELECT name, description, justification, year, longitude, latitude, area_hectares,
	category_id, state_id, region_id, iso_id FROM unesco_raw;
				   

SELECT unesco.name, year, category.name, state.name, region.name, iso.name
	FROM unesco
	JOIN category ON unesco.category_id = category.id
	JOIN iso ON unesco.iso_id = iso.id
	JOIN state ON unesco.state_id = state.id
	JOIN region ON unesco.region_id = region.id
	ORDER BY iso.name, unesco.name
	LIMIT 3;