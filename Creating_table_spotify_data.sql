-- Creating Table spotify_data
CREATE TABLE IF NOT EXISTS spotify_data(
    Artist	VARCHAR(50),
    Track	VARCHAR(250),
    Album	VARCHAR(250),
	Album_type	VARCHAR(50),
    Danceability FLOAT,
    Energy	FLOAT,
    Loudness FLOAT,
    Speechiness	FLOAT,
    Acousticness FLOAT,
    Instrumentalness FLOAT,
    Liveness FLOAT,
    Valence	FLOAT,
    Tempo FLOAT,
    Duration_min FLOAT,	
    Title VARCHAR(250),
    Channel	VARCHAR(100),
    Views BIGINT,
    Likes BIGINT,
    Comments BIGINT,
    Licensed BOOLEAN,
    official_video BOOLEAN,
    Stream	BIGINT,
    EnergyLiveness FLOAT,
    most_playedon VARCHAR(20)
);

-- Deleating Table spotify_data
DROP TABLE IF EXISTS spotify_data