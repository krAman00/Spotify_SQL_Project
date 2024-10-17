--ADVANCE SQL PROJECT-- SPOTIFY DATASETS--

-- create table
-- DROP TABLE IF EXISTS spotify;
-- CREATE TABLE spotify (
--     artist VARCHAR(255),
--     track VARCHAR(255),
--     album VARCHAR(255),
--     album_type VARCHAR(50),
--     danceability FLOAT,
--     energy FLOAT,
--     loudness FLOAT,
--     speechiness FLOAT,
--     acousticness FLOAT,
--     instrumentalness FLOAT,
--     liveness FLOAT,
--     valence FLOAT,
--     tempo FLOAT,
--     duration_min FLOAT,
--     title VARCHAR(255),
--     channel VARCHAR(255),
--     views FLOAT,
--     likes BIGINT,
--     comments BIGINT,
--     licensed BOOLEAN,
--     official_video BOOLEAN,
--     stream BIGINT,
--     energy_liveness FLOAT,
--     most_played_on VARCHAR(50)
-- );

--EDA--
SELECT COUNT(*) FROM spotify;

SELECT COUNT(DISTINCT(artist)) FROM spotify;
SELECT COUNT(DISTINCT(album)) FROM spotify;
SELECT DISTINCT album_type FROM spotify;
SELECT MAX(duration_min) , MIN(duration_min) FROM spotify;

SELECT * FROM spotify
WHERE duration_min = 0;

DELETE FROM spotify
WHERE duration_min = 0;

SELECT DISTINCT channel FROM spotify;
SELECT DISTINCT most_played_on FROM spotify;
-------------------------------------------------------------------------
-- DATA ANALYSIS -- BEGINNER LEVEL
-------------------------------------------------------------------------
--Question 1) Retrieve the names of all tracks that have more than 1 billion streams.

SELECT * FROM spotify
WHERE stream > 1000000000;

--Question 2) List all albums along with their respective artists.

SELECT album, artist 
from spotify;

SELECT 
DISTINCT album , 
		artist
FROM spotify
ORDER BY 1;

--Question 3) Get the total number of comments for tracks where licensed = TRUE.

SELECT 
SUM(comments) AS total_Comments
FROM spotify
WHERE licensed = 'true';

-- Question 4) Find all tracks that belong to the album type single.

SELECT * FROM  spotify
WHERE album_type = 'single';

--Question 5) Count the total number of tracks by each artist.

SELECT artist , COUNT(track)
FROM spotify
GROUP BY artist
ORDER BY count(track) DESC;

-------------------------------------------------------------------------
-- DATA ANALYSIS -- MODERATE LEVEL
-------------------------------------------------------------------------
 -- Question 1) Calculate the average danceability of tracks in each album.
 
SELECT 	album,  
		AVG(danceability) 
		AS avg_danceability
FROM spotify
GROUP BY album
ORDER BY AVG(danceability) DESC;

 -- Question 2) Find the top 5 tracks with the highest energy values.
SELECT  track , 
		energy
FROM spotify
ORDER BY energy DESC
LIMIT 5;

-- Question 3) List all tracks along with their views and likes where official_video = TRUE.
 SELECT track, 
 		SUM(views) AS total_views,
		SUM(likes) AS total_likes
FROM spotify
WHERE official_video = 'true'
GROUP BY track
LIMIT 5;

--Question 4)For each album, calculate the total views of all associated tracks.

SELECT album,
		track,
		SUM(VIEWS) AS total_views
FROM spotify
GROUP BY album, track
ORDER BY SUM(views) DESC;

-- Question 5) Retrieve the track names that have been streamed on Spotify more than YouTube.

SELECT * FROM 
(SELECT 
	track, 
	COALESCE(SUM(CASE WHEN LOWER(most_played_on) = 'youtube' THEN stream END), 0) AS streamed_on_youtube,
	COALESCE(SUM(CASE WHEN LOWER(most_played_on) = 'spotify' THEN stream END), 0) AS streamed_on_spotify
FROM spotify
GROUP BY track) AS T1
WHERE 
streamed_on_youtube > streamed_on_spotify
AND 
streamed_on_spotify <> 0

-------------------------------------------------------------------------
-- DATA ANALYSIS -- ADVANCE LEVEL
-------------------------------------------------------------------------
 -- Question 1) Find the top 3 most-viewed tracks for each artist using window functions.
 
 WITH artist_ranking AS 
(SELECT artist,
 		track,
		SUM(VIEWS) AS total_views ,
		DENSE_RANK () OVER(PARTITION BY artist ORDER BY SUM(views) DESC) AS RANK
 FROM spotify
 GROUP BY 1 , 2
 ORDER BY 1 , 3 DESC)
 
 SELECT * FROM artist_ranking
 WHERE RANK <= 3
 
  -- Question 2) Write a query to find tracks where the liveness score is above the average.

SELECT 
		artist,
		track,
		liveness
FROM spotify
WHERE liveness > ( SELECT AVG(liveness) FROM spotify);

--Question 3) Use a WITH clause to calculate the difference between the highest and lowest energy values for tracks in each album.

WITH find_diff AS (
    SELECT  
        album,
        MAX(energy) AS max_energy,
        MIN(energy) AS min_energy
    FROM spotify
    GROUP BY album
)

SELECT 
    album,
    ROUND(CAST(max_energy - min_energy AS numeric), 2) AS difference_in_energy
FROM find_diff
ORDER BY 2 DESC;

--Question 4) Find tracks where the energy-to-liveness ratio is greater than 1.2.

SELECT track,
	energy / liveness AS ratio_of_energy_to_liveness
FROM spotify
WHERE energy / liveness > 1.2;

--Question 5) Calculate the cumulative sum of likes for tracks ordered by the number of views, using window functions.

SELECT track,
		views,
		SUM(likes) OVER(ORDER BY views) AS cumulative_sum
FROM spotify
ORDER BY SUM(likes) OVER(ORDER BY views) DESC;