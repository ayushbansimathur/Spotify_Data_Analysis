/*
==============================================================
SPOTIFY SQL PRACTICE QUERIES
==============================================================

Purpose:
This SQL file is designed to practice and demonstrate SQL skills using a Spotify dataset.
It covers beginner, intermediate, and advanced query patterns that are widely used in
data analysis, reporting, and business problem-solving.

This file helps in:
1. Strengthening SQL fundamentals through hands-on query practice
2. Applying analytical thinking to real-world style dataset questions
3. Demonstrating SQL proficiency for portfolio projects and interviews
4. Understanding how structured queries answer business and performance questions

What this file includes:
- Filtering and sorting
- Aggregation and grouping
- CASE-based logic
- Common Table Expressions (CTEs)
- Window functions
- Ranking methods
- Comparative analysis
- Cumulative calculations

Note:
The queries are organized into Easy, Medium, and Advanced sections for clarity and progression.
Some questions include alternate solutions to show different SQL approaches.
The code has been cleaned and formatted to be suitable for learning, revision, GitHub, and portfolio use.

Dataset:
Table Name: spotify_data

Key Columns Used:
artist, track, album, album_type, stream, comments, licensed, danceability,
energy, official_video, views, likes, most_playedon, liveness

==============================================================
FILE HEADER NOTE
==============================================================

This file contains SQL practice queries built on a Spotify dataset to strengthen
query-writing ability and analytical problem-solving. The queries progress from basic
data retrieval tasks to more advanced analytical scenarios using aggregation,
window functions, CTEs, ranking, and performance comparisons. The overall objective
is to improve practical SQL skills and demonstrate readiness for data-focused roles.

==============================================================
EASY LEVEL
==============================================================
*/

-- 1. Retrieve the names of all tracks that have more than 1 billion streams
SELECT
    artist,
    track,
    stream
FROM spotify_data
WHERE stream > 1000000000
ORDER BY stream DESC;

-- 2. List all albums along with their respective artists
SELECT DISTINCT
    artist,
    album
FROM spotify_data
ORDER BY artist, album;

-- 3. Get the total number of comments for tracks where licensed = TRUE
SELECT
    SUM(comments) AS total_comments
FROM spotify_data
WHERE licensed = TRUE;

-- 4. Find all tracks that belong to the album type 'single'
SELECT
    artist,
    track,
    album,
    album_type
FROM spotify_data
WHERE album_type = 'single'
ORDER BY artist, track;

-- 5. Count the total number of tracks by each artist
SELECT
    artist,
    COUNT(track) AS total_tracks
FROM spotify_data
GROUP BY artist
ORDER BY total_tracks DESC, artist;


/*
==============================================================
MEDIUM LEVEL
==============================================================
*/

-- 6. Calculate the average danceability of tracks in each album
SELECT
    album,
    ROUND(AVG(danceability)::NUMERIC, 2) AS avg_danceability
FROM spotify_data
GROUP BY album
ORDER BY avg_danceability DESC, album;

-- 7. Find the top 5 tracks with the highest energy values
SELECT
    track,
    energy,
    rank_per_energy
FROM (
    SELECT
        track,
        energy,
        DENSE_RANK() OVER (ORDER BY energy DESC) AS rank_per_energy
    FROM spotify_data
) ranked_tracks
WHERE rank_per_energy <= 5
ORDER BY rank_per_energy, track;

-- 8. List all tracks along with their views and likes where official_video = TRUE
SELECT
    track,
    views,
    likes
FROM spotify_data
WHERE official_video = TRUE
ORDER BY views DESC;

-- 9. For each album, calculate the total views of all associated tracks
SELECT
    album,
    SUM(views) AS total_views
FROM spotify_data
GROUP BY album
ORDER BY total_views DESC, album;

-- 10. Retrieve the track names that have been streamed on Spotify more than YouTube
WITH platform_streams AS (
    SELECT
        track,
        SUM(CASE WHEN most_playedon ILIKE 'Spotify' THEN stream ELSE 0 END) AS streamed_on_spotify,
        SUM(CASE WHEN most_playedon ILIKE 'YouTube' THEN stream ELSE 0 END) AS streamed_on_youtube
    FROM spotify_data
    GROUP BY track
)
SELECT
    track,
    streamed_on_spotify,
    streamed_on_youtube
FROM platform_streams
WHERE streamed_on_spotify > streamed_on_youtube
    AND streamed_on_youtube > 0
ORDER BY streamed_on_spotify DESC;

-- Alternate Solution
WITH spotify_played_track AS (
    SELECT
        track AS track_name,
        stream AS spotify_streamed
    FROM spotify_data
    WHERE most_playedon ILIKE 'Spotify'
),
youtube_played_track AS (
    SELECT
        track AS track_name,
        stream AS youtube_streamed
    FROM spotify_data
    WHERE most_playedon ILIKE 'YouTube'
)
SELECT
    spt.track_name,
    spt.spotify_streamed,
    ypt.youtube_streamed
FROM spotify_played_track AS spt
JOIN youtube_played_track AS ypt
    ON spt.track_name = ypt.track_name
WHERE spt.spotify_streamed > ypt.youtube_streamed;


/*
==============================================================
ADVANCED LEVEL
==============================================================
*/

-- 11. Find the top 3 most-viewed tracks for each artist using window functions
SELECT
    artist,
    track,
    total_views,
    ranking_per_track
FROM (
    SELECT
        artist,
        track,
        SUM(views) AS total_views,
        DENSE_RANK() OVER (
            PARTITION BY artist
            ORDER BY SUM(views) DESC
        ) AS ranking_per_track
    FROM spotify_data
    GROUP BY artist, track
) ranked_artist_tracks
WHERE ranking_per_track <= 3
ORDER BY artist, ranking_per_track, track;

-- 12. Find tracks where the liveness score is above the average liveness of all tracks
SELECT DISTINCT
    track,
    liveness
FROM spotify_data
WHERE liveness > (
    SELECT AVG(liveness)
    FROM spotify_data
)
ORDER BY liveness DESC;

-- Alternate Solution
SELECT
    track
FROM (
    SELECT DISTINCT
        track,
        ROUND(AVG(liveness) OVER (PARTITION BY track)::NUMERIC, 2) AS avg_per_track,
        ROUND(AVG(liveness) OVER ()::NUMERIC, 2) AS avg_total
    FROM spotify_data
) liveness_comparison
WHERE avg_per_track > avg_total;

-- 13. Calculate the difference between the highest and lowest energy values for tracks in each album
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

-- Alternate Window Function Solution
WITH energy_category AS (
    SELECT
        album,
        track,
        energy,
        FIRST_VALUE(energy) OVER (
            PARTITION BY album
            ORDER BY energy DESC
        ) AS highest_energy_per_album,
        LAST_VALUE(energy) OVER (
            PARTITION BY album
            ORDER BY energy DESC
            ROWS BETWEEN CURRENT ROW AND UNBOUNDED FOLLOWING
        ) AS lowest_energy_per_album
    FROM spotify_data
)
SELECT DISTINCT
    album,
    ROUND((highest_energy_per_album - lowest_energy_per_album)::NUMERIC, 4) AS energy_difference
FROM energy_category
WHERE ROUND((highest_energy_per_album - lowest_energy_per_album)::NUMERIC, 4) > 0
ORDER BY album;

-- 14. Find tracks where the energy-to-liveness ratio is greater than 1.2
SELECT DISTINCT
    track,
    ROUND((energy / liveness)::NUMERIC, 5) AS energy_to_liveness_ratio
FROM spotify_data
WHERE liveness > 0
    AND (energy / liveness) > 1.2
ORDER BY energy_to_liveness_ratio DESC;

-- 15. Calculate the cumulative sum of likes for tracks ordered by the number of views
SELECT
    track,
    views,
    likes,
    SUM(likes) OVER (
        ORDER BY views DESC
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS cumulative_sum_likes
FROM spotify_data
ORDER BY views DESC;


/*
==============================================================
SHORT VERSION FOR TOP OF FILE
==============================================================

This file contains SQL practice queries written on a Spotify dataset to improve
query-writing skills and analytical problem-solving. The queries are divided into
Easy, Medium, and Advanced sections and demonstrate filtering, aggregation,
window functions, CTEs, ranking, and business-focused analysis.

==============================================================
ONE-LINE PURPOSE
==============================================================

Purpose:
To analyze Spotify streaming data and practice SQL concepts from basic to advanced
level using real analytical and business-oriented questions.

==============================================================
END OF FILE
==============================================================
*/
