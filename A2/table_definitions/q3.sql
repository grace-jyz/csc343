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
votes_cast/seats_total AS participationRatio
FROM election JOIN country ON election.country_id = country.id

CREATE VIEW 2001_to_2016 AS
SELECT countryName, AVG(year) as year, participationRatio
FROM country_year
WHERE 2001 <= date_part('year', e_date) AND date_part('year', e_date) <= 2016
GROUP By countryName, year

CREATE VIEW answer AS
SELECT countryName, year, participationRatio
FROM 2001_to_2016 t1 JOIN 2001_to_2016 t2 ON t1.countryName = t2.countryName
  AND t1.year < t2.year
WHERE t1.participationRatio <= t2.participationRatio


-- the answer to the query
insert into q3
SELECT * FROM answer;
