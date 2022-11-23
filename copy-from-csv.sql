DROP TABLE IF EXISTS track_raw;
CREATE TABLE track_raw
	(title TEXT, artist TEXT, album TEXT,
	count INTEGER, rating INTEGER, len INTEGER);
	
DELETE FROM track_raw; 

--in psql terminal:
-- wget https://www.pg4e.com/tools/sql/library.csv
-- \copy track_raw(title,artist,album,count,rating,len) FROM 'library.csv' WITH DELIMITER ',' CSV;
--or simply import to the table in pgAdmin

select * from track_raw;