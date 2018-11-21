-- Participate

SET SEARCH_PATH TO parlgov;
drop table if exists q3 cascade;

-- You must not change this table definition.

create table q3(
        countryName varchar(50),
        year int,
        participationRatio real
);

-- You may find it convenient to do this for each of the views
-- that define your intermediate steps.  (But give them better names!)
DROP VIEW IF EXISTS intermediate_step CASCADE;

-- Define views for your intermediate steps here.

-- At least one election between 2001 ~ 2016 [2001,2016]
CREATE VIEW country_year AS
SELECT country.name as countryName, date_part('year', election.e_date) as year,
CAST(votes_cast AS FLOAT) / CAST(electorate AS FLOAT) AS participationRatio
FROM election JOIN country ON election.country_id = country.id;

CREATE VIEW avg_year AS
SELECT countryName, AVG(year) as year, participationRatio
FROM country_year
WHERE 2001 <= year AND year <= 2016
GROUP BY countryName, year, participationRatio;

CREATE VIEW correct_countries AS
SELECT distinct countryName
FROM avg_year;

CREATE VIEW wrong AS
SELECT t1.countryName
FROM avg_year t1 JOIN avg_year t2 ON t1.countryName = t2.countryName
  AND t1.year < t2.year
WHERE t1.participationRatio > t2.participationRatio;

CREATE VIEW partial_answer AS
SELECT DISTINCT countryName
FROM correct_countries
EXCEPT
SELECT countryName
FROM wrong;

CREATE VIEW answer as
SELECT p.countryName as countryName, year, participationRatio
FROM partial_answer p JOIN avg_year a ON p.countryName = a.countryName;


-- the answer to the query
insert into q3
SELECT * FROM answer;
