-- Left-right

SET SEARCH_PATH TO parlgov;
drop table if exists q4 cascade;

CREATE TABLE q4(
        countryName VARCHAR(50),
        r0_2 INT,
        r2_4 INT,
        r4_6 INT,
        r6_8 INT,
        r8_10 INT
);

-- Drop views for intermediate steps.
DROP VIEW IF EXISTS party_pos CASCADE;
DROP VIEW IF EXISTS pos_and_country CASCADE;
DROP VIEW IF EXISTS range1 CASCADE;
DROP VIEW IF EXISTS range2 CASCADE;
DROP VIEW IF EXISTS range4 CASCADE;
DROP VIEW IF EXISTS range5 CASCADE;

-- Views for intermediate steps.
CREATE VIEW party_pos AS
SELECT party_position.party_id, party_position.left_right, party.country_id
FROM party_position JOIN party ON party_position.party_id = party.id;

CREATE VIEW pos_and_country AS
SELECT party_pos.party_id, party_pos.left_right, country.name countryName
FROM country LEFT JOIN party_pos ON party_pos.country_id = country.id;

-- Range [0,2)
CREATE VIEW range1 AS
SELECT countryName, count(party_id) r0_2
FROM pos_and_country
WHERE IS NULL OR (left_right >= 0 AND left_right < 2)
GROUP BY countryName;

-- Range [2,4)
CREATE VIEW range2 AS
SELECT countryName, count(party_id) r2_4
FROM pos_and_country
WHERE left_right >= 2 AND left_right < 4
GROUP BY countryName;

-- Range [4,6)
CREATE VIEW range3 AS
SELECT countryName, count(party_id) r4_6
FROM pos_and_country
WHERE left_right >= 4 AND left_right < 6
GROUP BY countryName;

-- Range [6,8)
CREATE VIEW range4 AS
SELECT countryName, count(party_id) r6_8
FROM pos_and_country
WHERE left_right >= 6 AND left_right < 8
GROUP BY countryName;

-- Range [8,10]
CREATE VIEW range5 AS
SELECT countryName, count(party_id) r8_10
FROM pos_and_country
WHERE left_right >= 8 AND left_right <= 10
GROUP BY countryName;

-- The answer to the query.
INSERT INTO q4 
SELECT countryName, r0_2, r2_4, r4_6, r6_8, r8_10
FROM range1 NATURAL JOIN range2 NATURAL JOIN range3 NATURAL JOIN range4 NATURAL JOIN range5;
