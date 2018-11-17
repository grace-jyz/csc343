-- VoteRange

SET SEARCH_PATH TO parlgov;
drop table if exists q1 cascade;

-- You must not change this table definition.

create table q1(
year INT,
countryName VARCHAR(50),
voteRange VARCHAR(20),
partyName VARCHAR(100)
);


-- You may find it convenient to do this for each of the views
-- that define your intermediate steps.  (But give them better names!)
DROP VIEW IF EXISTS intermediate_step CASCADE;

-- Define views for your intermediate steps here.
CREATE VIEW percentages AS
SELECT *, (votes / votes_valid) AS vote_percentage
FROM election JOIN election_result ON election_id = election.id;

CREATE VIEW averages AS
SELECT *, avg(vote_percentage)
FROM percentages
GROUP BY country_id, year(e_date), party_id;

CREATE VIEW answer AS
SELECT year(e_date) AS year, country.name AS countryName, 
    CASE
        WHEN vote_percentage IS NULL OR vote_percentage <= 5 THEN '(0-5]'
        WHEN 5 < vote_percentage AND vote_percentage <= 10 THEN '(5-10]'
        WHEN 10 < vote_percentage AND vote_percentage <= 20 THEN '(10-20]'
        WHEN 20 < vote_percentage AND vote_percentage <= 30 THEN '(20-30]'
        WHEN 30 < vote_percentage AND vote_percentage <= 40 THEN '(30-40]'
        ELSE '(40-100]'
    END AS voteRange, party.name_short AS partyName
FROM averages, country, party;

-- the answer to the query 
INSERT INTO q1 SELECT * FROM answer;