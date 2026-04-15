![Spotify Logo](spotify_logo.jpg)

# Spotify SQL Data Analysis Project

## Project Overview
This project analyzes a Spotify dataset using SQL to explore track performance, artist output, album-level trends, and platform-based streaming behavior. The dataset contains music metadata, audio features, user engagement metrics, and playback indicators from platforms such as Spotify and YouTube.

The project was built as a hands-on SQL practice exercise with a business-analysis lens. Instead of limiting the work to simple retrieval queries, it progresses from basic filtering and aggregation to more advanced analytical logic using window functions, Common Table Expressions (CTEs), ranking methods, and cumulative calculations.

The main objective of this project is to strengthen practical SQL skills while generating meaningful insights from a real-world style music dataset.

---

## Project Objectives
- Practice SQL through structured problem-solving
- Analyze track, album, and artist-level performance
- Compare music engagement and streaming patterns across platforms
- Apply SQL concepts used in analytics and reporting workflows
- Build a portfolio-ready SQL project for interviews and GitHub

---

## Dataset Description
The project uses a single denormalized table named `spotify_data`.

The dataset includes:
- **Track and artist details** such as artist name, track name, album, and album type
- **Audio features** such as danceability, energy, loudness, liveness, tempo, and valence
- **Engagement metrics** such as views, likes, comments, and streams
- **Content indicators** such as licensed status and official video flag
- **Platform information** such as where the track was most played

This combination makes the dataset useful for both descriptive analysis and SQL skill development.

---

## Table Creation Script

```sql
DROP TABLE IF EXISTS spotify_data;

CREATE TABLE IF NOT EXISTS spotify_data (
    artist              VARCHAR(50),
    track               VARCHAR(250),
    album               VARCHAR(250),
    album_type          VARCHAR(50),
    danceability        FLOAT,
    energy              FLOAT,
    loudness            FLOAT,
    speechiness         FLOAT,
    acousticness        FLOAT,
    instrumentalness    FLOAT,
    liveness            FLOAT,
    valence             FLOAT,
    tempo               FLOAT,
    duration_min        FLOAT,
    title               VARCHAR(250),
    channel             VARCHAR(100),
    views               BIGINT,
    likes               BIGINT,
    comments            BIGINT,
    licensed            BOOLEAN,
    official_video      BOOLEAN,
    stream              BIGINT,
    energy_liveness     FLOAT,
    most_playedon       VARCHAR(20)
);
```

---

## Project Process

### 1. Dataset Understanding
The first step was understanding the structure of the dataset and identifying the available business questions that could be answered through SQL. Since the dataset was denormalized, the focus was not on joins across multiple tables, but on extracting meaningful insights from one wide analytical table.

### 2. Table Creation and Data Setup
A raw table named `spotify_data` was created to store all columns from the dataset. Appropriate data types were assigned based on the nature of each column, such as `VARCHAR` for text fields, `FLOAT` for audio features, `BIGINT` for engagement metrics, and `BOOLEAN` for flags.

### 3. Query Design by Difficulty Level
The SQL questions were divided into three levels:
- **Easy** for filtering, sorting, and basic aggregation
- **Medium** for grouped analysis, ranking, and platform comparisons
- **Advanced** for analytical calculations using CTEs and window functions

This structure helped build complexity gradually and made the project easier to review and present.

### 4. Analytical SQL Implementation
The project applied SQL techniques such as:
- `WHERE`, `ORDER BY`, and `GROUP BY`
- aggregate functions like `SUM()` and `AVG()`
- window functions like `DENSE_RANK()` and cumulative `SUM() OVER()`
- Common Table Expressions using `WITH`
- conditional logic using `CASE`
- null handling using `COALESCE()`

These techniques allowed the project to move from basic data retrieval to more advanced business-oriented analysis.

### 5. Query Refinement
Some queries were improved for correctness, efficiency, and readability. For example:
- artist-level track counts were rewritten using `GROUP BY` instead of returning repeated rows
- album-level total views were corrected to aggregate properly at the album level
- Spotify versus YouTube stream comparisons were improved using grouped conditional aggregation

This refinement step made the final project more accurate and more suitable for portfolio use.

### 6. Portfolio Presentation
The final step was organizing the work into a clear GitHub-ready README with strong structure, better explanations, corrected queries, and a more professional presentation style. This makes the project useful not only for SQL practice, but also as a portfolio artifact for internships and analyst roles.

---

## SQL Concepts Demonstrated
This project demonstrates practical use of the following SQL concepts:

- Data Definition Language (DDL)
- filtering and sorting
- aggregation and grouping
- distinct selection
- CASE statements
- Common Table Expressions (CTEs)
- window functions
- ranking logic
- cumulative calculations
- comparative analysis
- query structuring for readability

---

## 15 SQL Practice Questions

## Easy Level

### 1. Retrieve the names of all tracks that have more than 1 billion streams
```sql
SELECT
    artist,
    track,
    stream
FROM spotify_data
WHERE stream > 1000000000
ORDER BY stream DESC;
```

### 2. List all albums along with their respective artists
```sql
SELECT DISTINCT
    artist,
    album
FROM spotify_data
ORDER BY artist, album;
```

### 3. Get the total number of comments for tracks where `licensed = TRUE`
```sql
SELECT
    SUM(comments) AS total_comments
FROM spotify_data
WHERE licensed = TRUE;
```

### 4. Find all tracks that belong to the album type `single`
```sql
SELECT
    artist,
    track,
    album,
    album_type
FROM spotify_data
WHERE album_type = 'single'
ORDER BY artist, track;
```

### 5. Count the total number of tracks by each artist
```sql
SELECT
    artist,
    COUNT(track) AS total_tracks
FROM spotify_data
GROUP BY artist
ORDER BY total_tracks DESC, artist;
```

---

## Medium Level

### 6. Calculate the average danceability of tracks in each album
```sql
SELECT
    album,
    ROUND(AVG(danceability)::NUMERIC, 2) AS avg_danceability
FROM spotify_data
GROUP BY album
ORDER BY avg_danceability DESC, album;
```

### 7. Find the top 5 tracks with the highest energy values
```sql
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
```

### 8. List all tracks along with their views and likes where `official_video = TRUE`
```sql
SELECT
    track,
    views,
    likes
FROM spotify_data
WHERE official_video = TRUE
ORDER BY views DESC;
```

### 9. For each album, calculate the total views of all associated tracks
```sql
SELECT
    album,
    SUM(views) AS total_views
FROM spotify_data
GROUP BY album
ORDER BY total_views DESC, album;
```

### 10. Retrieve the track names that have been streamed more on Spotify than on YouTube
```sql
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
```

**Alternate Solution**
```sql
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
```

---

## Advanced Level

### 11. Find the top 3 most-viewed tracks for each artist using window functions
```sql
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
```

### 12. Find tracks where the liveness score is above the average liveness of all tracks
```sql
SELECT DISTINCT
    track,
    liveness
FROM spotify_data
WHERE liveness > (
    SELECT AVG(liveness)
    FROM spotify_data
)
ORDER BY liveness DESC;
```

**Alternate Solution**
```sql
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
```

### 13. Calculate the difference between the highest and lowest energy values for tracks in each album
```sql
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
```

**Alternate Window Function Solution**
```sql
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
```

### 14. Find tracks where the energy-to-liveness ratio is greater than 1.2
```sql
SELECT DISTINCT
    track,
    ROUND((energy / liveness)::NUMERIC, 5) AS energy_to_liveness_ratio
FROM spotify_data
WHERE liveness > 0
    AND (energy / liveness) > 1.2
ORDER BY energy_to_liveness_ratio DESC;
```

### 15. Calculate the cumulative sum of likes for tracks ordered by the number of views using window functions
```sql
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
```

---

## Key Learning Outcomes
Through this project, I strengthened my ability to:
- write clean and structured SQL queries
- solve analytical questions using SQL logic
- use window functions for ranking and cumulative analysis
- apply CTEs for modular query building
- translate business questions into database queries
- format technical work for portfolio presentation

---

## How to Use This Project
1. Create the `spotify_data` table using the provided DDL script
2. Load the dataset into the table
3. Run the SQL queries section by section
4. Review the outputs and compare alternate approaches where provided
5. Use the project as a reference for SQL practice, interviews, or portfolio presentation

---

## Conclusion
This project demonstrates how SQL can be used to move from raw dataset exploration to structured business analysis. Even with a single denormalized table, it is possible to answer a wide range of performance, engagement, and platform-related questions using strong SQL fundamentals and analytical thinking.

---

## Thank You
Thank you for reviewing this project.
