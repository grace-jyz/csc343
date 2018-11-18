-- VoteRange

SET SEARCH_PATH TO parlgov;
drop table if exists q1 cascade;

create table q1(
year INT,
countryName VARCHAR(50),
voteRange VARCHAR(20),
partyName VARCHAR(100)
);

-- Drop views for intermediate steps.
DROP VIEW IF EXISTS percentages CASCADE;
DROP VIEW IF EXISTS averages CASCADE;
DROP VIEW IF EXISTS answer CASCADE;

-- Views for intermediate steps.
CREATE VIEW percentages AS
SELECT date_part('year', e_date) AS year, country_id, party_id, (CAST(votes AS FLOAT) / votes_valid * 100) AS vote_percentage
FROM election JOIN election_result ON election_id=election.id;

CREATE VIEW averages AS
SELECT year, country_id, party_id, avg(vote_percentage) AS vote_percentage
FROM percentages
WHERE year >= 1996 AND year <= 2016 AND vote_percentage IS NOT NULL
GROUP BY year, country_id, party_id;

CREATE VIEW answer AS
SELECT year, country.name AS countryName, 
    CASE
        WHEN 0 < vote_percentage AND vote_percentage <= 5 THEN '(0-5]'
        WHEN 5 < vote_percentage AND vote_percentage <= 10 THEN '(5-10]'
        WHEN 10 < vote_percentage AND vote_percentage <= 20 THEN '(10-20]'
        WHEN 20 < vote_percentage AND vote_percentage <= 30 THEN '(20-30]'
        WHEN 30 < vote_percentage AND vote_percentage <= 40 THEN '(30-40]'
        ELSE '(40-100]'
    END AS voteRange,
    party.name_short AS partyName
FROM (averages JOIN country ON country_id=country.id) JOIN party ON party_id=party.id;

-- The answer to the query
INSERT INTO q1
SELECT * FROM answer;