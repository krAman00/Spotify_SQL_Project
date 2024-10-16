# Spotify Advanced SQL Project and Query Optimization P-6
Project Category: Advanced
[Click Here to get Dataset](https://www.kaggle.com/datasets/sanjanchaudhari/spotify-dataset)

![Spotify Logo](https://github.com/krAman00/Spotify_SQL_Project/blob/main/2024-spotify-brand-assets-media-kit.jpg)

## Overview
This project analyzes a Spotify dataset with various attributes about tracks, albums, and artists using SQL. It covers the end-to-end process of normalizing a denormalized dataset, performing SQL queries of varying complexity (easy, medium, and advanced), and optimizing query performance. The project's primary goals are to practice advanced SQL skills and generate valuable insights from the dataset.

```sql
-- create table
DROP TABLE IF EXISTS spotify;
CREATE TABLE spotify (
    artist VARCHAR(255),
    track VARCHAR(255),
    album VARCHAR(255),
    album_type VARCHAR(50),
    danceability FLOAT,
    energy FLOAT,
    loudness FLOAT,
    speechiness FLOAT,
    acousticness FLOAT,
    instrumentalness FLOAT,
    liveness FLOAT,
    valence FLOAT,
    tempo FLOAT,
    duration_min FLOAT,
    title VARCHAR(255),
    channel VARCHAR(255),
    views FLOAT,
    likes BIGINT,
    comments BIGINT,
    licensed BOOLEAN,
    official_video BOOLEAN,
    stream BIGINT,
    energy_liveness FLOAT,
    most_played_on VARCHAR(50)
);
```
## Project Steps

### 1. Data Exploration
Before diving into SQL, it’s important to understand the dataset thoroughly. The dataset contains attributes such as:
- `Artist`: The performer of the track.
- `Track`: The name of the song.
- `Album`: The album to which the track belongs.
- `Album_type`: The type of album (e.g., single or album).
- Various metrics such as `danceability`, `energy`, `loudness`, `tempo`, and more.

### 4. Querying the Data
After the data is inserted, various SQL queries can be written to explore and analyze the data. Queries are categorized into **easy**, **medium**, and **advanced** levels to help progressively develop SQL proficiency.

#### Easy Queries
- Simple data retrieval, filtering, and basic aggregations.
  
#### Medium Queries
- More complex queries involving grouping, aggregation functions, and joins.
  
#### Advanced Queries
- Nested subqueries, window functions, CTEs, and performance optimization.

### 5. Query Optimization
In advanced stages, the focus shifts to improving query performance. Some optimization strategies include:
- **Indexing**: Adding indexes on frequently queried columns.
- **Query Execution Plan**: Using `EXPLAIN ANALYZE` to review and refine query performance.
  
---

## 15 Practice Questions

### Beginner Level
1. Retrieve the names of all tracks that have more than 1 billion streams.
``` SQL
SELECT * FROM spotify
WHERE stream > 1000000000;

```

2. List all albums along with their respective artists.
``` SQL
SELECT 
DISTINCT album , 
		artist
FROM spotify
ORDER BY 1;

```
3. Get the total number of comments for tracks where `licensed = TRUE`.
``` SQL
SELECT 
SUM(comments) AS total_Comments
FROM spotify
WHERE licensed = 'true';

```
4. Find all tracks that belong to the album type `single`.
``` SQL
SELECT * FROM  spotify
WHERE album_type = 'single';
```
5. Count the total number of tracks by each artist.
``` SQL
SELECT artist , COUNT(track)
FROM spotify
GROUP BY artist
ORDER BY count(track) DESC;
```
### Moderate Level
1. Calculate the average danceability of tracks in each album.
``` SQL
SELECT 	album,  
        AVG(danceability) 
	AS avg_danceability
FROM spotify
GROUP BY album
ORDER BY AVG(danceability) DESC;

```
2. Find the top 5 tracks with the highest energy values.
``` SQL
SELECT  track , 
        energy
FROM spotify
ORDER BY energy DESC
LIMIT 5;

```

3. List all tracks along with their views and likes where `official_video = TRUE`.
``` SQL
 SELECT track, 
       SUM(views) AS total_views,
       SUM(likes) AS total_likes
FROM spotify
WHERE official_video = 'true'
GROUP BY track
LIMIT 5;

```
4. For each album, calculate the total views of all associated tracks.
``` SQL
SELECT album,
       track,
       SUM(VIEWS) AS total_views
FROM spotify
GROUP BY album, track
ORDER BY SUM(views) DESC;

```
5. Retrieve the track names that have been streamed on Spotify more than YouTube.
``` SQL
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

```
### Advanced Level
1. Find the top 3 most-viewed tracks for each artist using window functions.
``` SQL
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

```

2. Write a query to find tracks where the liveness score is above the average.
``` SQL
SELECT 
      artist,
      track,
      liveness
FROM spotify
WHERE liveness > ( SELECT AVG(liveness) FROM spotify);

```

3. Use a `WITH` clause to calculate the difference between the highest and lowest energy values for tracks in each album.
```sql
WITH cte
AS
(SELECT 
	album,
	MAX(energy) as highest_energy,
	MIN(energy) as lowest_energery
FROM spotify
GROUP BY 1
)
SELECT 
	album,
	highest_energy - lowest_energery as energy_diff
FROM cte
ORDER BY 2 DESC
```
   
4. Find tracks where the energy-to-liveness ratio is greater than 1.2.
``` SQL
SELECT track,
       energy / liveness AS ratio_of_energy_to_liveness
FROM spotify
WHERE energy / liveness > 1.2;

```
5. Calculate the cumulative sum of likes for tracks ordered by the number of views, using window functions.
``` SQL
SELECT track,
       views,
       SUM(likes) OVER(ORDER BY views) AS cumulative_sum
FROM spotify
ORDER BY SUM(likes) OVER(ORDER BY views) DESC;

```

Here’s an updated section for your **Spotify Advanced SQL Project and Query Optimization** README, focusing on the query optimization task you performed. You can include the specific screenshots and graphs as described.

---

## Query Optimization Technique 

To improve query performance, we carried out the following optimization process:

- **Initial Query Performance Analysis Using `EXPLAIN`**
    - We began by analyzing the performance of a query using the `EXPLAIN` function.
    - The query retrieved tracks based on the `artist` column, and the performance metrics were as follows:
        - Execution time (E.T.): **7 ms**
        - Planning time (P.T.): **0.17 ms**
    - Below is the **screenshot** of the `EXPLAIN` result before optimization:
      ![EXPLAIN Before Index](https://github.com/najirh/najirh-Spotify-Data-Analysis-using-SQL/blob/main/spotify_explain_before_index.png)

- **Index Creation on the `artist` Column**
    - To optimize the query performance, we created an index on the `artist` column. This ensures faster retrieval of rows where the artist is queried.
    - **SQL command** for creating the index:
      ```sql
      CREATE INDEX idx_artist ON spotify_tracks(artist);
      ```

- **Performance Analysis After Index Creation**
    - After creating the index, we ran the same query again and observed significant improvements in performance:
        - Execution time (E.T.): **0.153 ms**
        - Planning time (P.T.): **0.152 ms**
    - Below is the **screenshot** of the `EXPLAIN` result after index creation:
      ![EXPLAIN After Index](https://github.com/najirh/najirh-Spotify-Data-Analysis-using-SQL/blob/main/spotify_explain_after_index.png)

- **Graphical Performance Comparison**
    - A graph illustrating the comparison between the initial query execution time and the optimized query execution time after index creation.
    - **Graph view** shows the significant drop in both execution and planning times:
      ![Performance Graph](https://github.com/najirh/najirh-Spotify-Data-Analysis-using-SQL/blob/main/spotify_graphical%20view%203.png)
      ![Performance Graph](https://github.com/najirh/najirh-Spotify-Data-Analysis-using-SQL/blob/main/spotify_graphical%20view%202.png)
      ![Performance Graph](https://github.com/najirh/najirh-Spotify-Data-Analysis-using-SQL/blob/main/spotify_graphical%20view%201.png)

This optimization shows how indexing can drastically reduce query time, improving the overall performance of our database operations in the Spotify project.
---

## Technology Stack
- **Database**: PostgreSQL
- **SQL Queries**: DDL, DML, Aggregations, Joins, Subqueries, Window Functions
- **Tools**: pgAdmin 4 (or any SQL editor), PostgreSQL (via Homebrew, Docker, or direct installation)
