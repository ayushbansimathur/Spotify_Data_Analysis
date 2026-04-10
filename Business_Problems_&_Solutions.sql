-- Easy Level
-- 1.Retrieve the names of all tracks that have more than 1 billion streams.
SELECT 
    artist,
    track,
    stream 
FROM spotify_data
WHERE stream > 1000000000 
ORDER BY stream DESC

-- 2.List all albums along with their respective artists.
SELECT
    artist,
    album
FROM spotify_data

-- 3.Get the total number of comments for tracks where licensed = TRUE.
SELECT 
    SUM(comments) AS total_comments
FROM spotify_data
WHERE licensed = TRUE;

-- 4.Find all tracks that belong to the album type single.
SELECT 
    * 
FROM spotify_data 
WHERE album_type = 'single' 
ORDER BY 1

-- 5.Count the total number of tracks by each artist.
SELECT 
    artist,
    COUNT(track) OVER(PARTITION BY artist)
FROM spotify_data
ORDER BY 2 DESC;

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Medium Level
-- 6.Calculate the average danceability of tracks in each album.
SELECT 
    album,
    ROUND(AVG(danceability) OVER(PARTITION BY album):: NUMERIC,2) AS avg_danceability
FROM spotify_data

-- 7.Find the top 5 tracks with the highest energy values.
SELECT * FROM (
    SELECT 
        track,
        energy,
        DENSE_RANK() OVER(ORDER BY energy DESC) AS rank_per_energy
    FROM spotify_data 
    ORDER BY 2 DESC
)
WHERE rank_per_energy <= 5

-- 8.List all tracks along with their views and likes where official_video = TRUE.
SELECT
    track,
    views,
    likes
FROM spotify_data
WHERE official_video IS TRUE

-- 9.For each album, calculate the total views of all associated tracks.
SELECT 
    album,
    track,
    SUM(views) AS all_views_per_album
FROM spotify_data
GROUP BY 1,2
ORDER BY 1 DESC, 3 DESC;

-- 10.Retrieve the track names that have been streamed on Spotify more than YouTube.
WITH 
    spotify_played_track AS (
        SELECT
            track AS track_played_on_spotify,
            stream AS spotify_streamed,
            most_playedon
        FROM spotify_data
        WHERE most_playedon ILIKE 'Spotify'
        ),
    YouTube_played_track AS (
        SELECT
            track AS track_played_on_Youtube,
            stream AS YouTube_streamed,
            most_playedon
        FROM spotify_data
        WHERE most_playedon ILIKE 'YouTube'
    )

SELECT
    spt.track_played_on_spotify,
    (CASE WHEN spt.spotify_streamed > ypt.YouTube_streamed THEN 'played more on spotify' 
    ELSE 'played more on YouTube' 
    END) AS winner_platform
FROM spotify_played_track AS spt
JOIN YouTube_played_track AS ypt ON spt.track_played_on_spotify = ypt.track_played_on_Youtube
WHERE
    (CASE 
        WHEN spt.spotify_streamed > ypt.YouTube_streamed THEN 'played more on spotify' 
        ELSE 'played more on YouTube' 
    END) = 'played more on spotify'

    -- Alternate Solution
SELECT * FROM (
    SELECT 
        track,
        SUM(COALESCE((CASE WHEN most_playedon = 'Spotify' THEN stream END),0)) AS streamed_on_spotify,
        SUM(COALESCE((CASE WHEN most_playedon = 'Youtube' THEN stream END),0)) AS streamed_on_YouTube
    FROM spotify_data
    GROUP BY 1
)
WHERE   
    streamed_on_YouTube <> 0 
    AND 
    streamed_on_spotify > streamed_on_YouTube
    
   

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Advanced Level
-- 11.Find the top 3 most-viewed tracks for each artist using window functions.
SELECT * FROM (
    SELECT 
        artist,
        track,
        SUM(views),
        DENSE_RANK() OVER(PARTITION BY artist ORDER BY SUM(views) DESC) AS ranking_per_track
    FROM spotify_data
    GROUP BY 1,2
)
WHERE ranking_per_track <= 3

-- 12.Write a query to find tracks where the liveness score is above the average.
SELECT 
    track
FROM (
    SELECT DISTINCT
        track, 
        ROUND (AVG(liveness) OVER (PARTITION BY track)::NUMERIC,2) AS avg_per_track,
        ROUND (AVG(liveness) OVER()::NUMERIC,2) AS avg_total
    FROM spotify_data
)
WHERE avg_per_track > avg_total

    -- Alternate Solution
SELECT DISTINCT 
    track 
FROM spotify_data
WHERE liveness > (SELECT AVG(liveness) FROM spotify_data);

-- 13.Use a WITH clause to calculate the difference between the highest and lowest energy values for tracks in each album.
WITH energy_category AS 
    (
    SELECT 
        album,
        track,
        energy,
        DENSE_RANK() OVER (PARTITION BY album ORDER BY track) AS energy_ranking_per_album,
        FIRST_VALUE (energy) OVER (PARTITION BY album ORDER BY energy DESC) AS highest_energy_per_album,
        LAST_VALUE(energy) OVER(PARTITION BY album ORDER BY energy DESC ROWS BETWEEN CURRENT ROW AND UNBOUNDED FOLLOWING) AS lowest_energy_per_album
    FROM spotify_data
    )

SELECT DISTINCT
    album,
    ROUND((highest_energy_per_album - lowest_energy_per_album):: NUMERIC,4) AS energy_difference
FROM energy_category
WHERE 
    ROUND((highest_energy_per_album - lowest_energy_per_album):: NUMERIC,4) > 0
ORDER BY 1

    -- Alternate Solution
WITH energy_category AS (
    SELECT 
        album,
        MAX(energy) AS highest_energy_per_album,
        MIN(energy) AS lowest_energy_per_album
    FROM spotify_data
    GROUP BY album
)
SELECT
    album,
    ROUND((highest_energy_per_album - lowest_energy_per_album)::NUMERIC, 4) AS energy_difference
FROM energy_category
WHERE (highest_energy_per_album - lowest_energy_per_album) > 0
ORDER BY album;

-- 14.Find tracks where the energy-to-liveness ratio is greater than 1.2.
SELECT DISTINCT
    track,
    ROUND((energy / liveness)::NUMERIC,5) eneregy_to_liveness_ratio
FROM spotify_data
WHERE
    energy / liveness > 1.2
    AND
    liveness > 0
ORDER BY 2

-- 15.Calculate the cumulative sum of likes for tracks ordered by the number of views, using window functions.
SELECT
    track,
    views,
    likes,
    SUM(likes) OVER (ORDER BY views DESC ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS cumulative_sum_likes
FROM spotify_data
ORDER BY views DESC;