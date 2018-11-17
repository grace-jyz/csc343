-- Winners

SET SEARCH_PATH TO parlgov;
drop table if exists q2 cascade;

-- You must not change this table definition.

create table q2(
countryName VARCHaR(100),
partyName VARCHaR(100),
partyFamily VARCHaR(100),
wonElections INT,
mostRecentlyWonElectionId INT,
mostRecentlyWonElectionYear INT
);


-- You may find it convenient to do this for each of the views
-- that define your intermediate steps.  (But give them better names!)
DROP VIEW IF EXISTS intermediate_step CASCADE;

-- Define views for your intermediate steps here.

-- Find the winning votes for the elections
CREATE VIEW winning AS
SELECT election_id, max(votes) maxVotes
FROM election_results
GROUP BY election_id;

-- Find all election winners and number of times they have won
CREATE VIEW winners AS
SELECT party_id, count(party_id) elec_won
FROM election_result, winning
WHERE election_result.election_id = winning.election_id AND election_result.votes = winning.maxVotes
GROUP BY party_id;

-- Group the parties by their country
CREATE VIEW winners_by_country AS
SELECT winners.party_id, winners.elec_won, country.name country_name
FROM winners, party, country
WHERE winners.party_id = party.id AND party.country_id = country.id

-- Get the sum of total number of parties in a country
CREATE VIEW total_parties
SELECT country.name country_name, sum(distinct party.id) total
FROM party, country
WHERE party.country_id = country.id
GROUP BY country_id

-- Get average winning times for each country
CREATE VIEW winning_avg AS
SELECT country_name, (sum(elec_won)/ total) average
FROM winners_by_country JOIN total_parties USING country_name
GROUP BY country_name, total

-- Find parties that has won >3*avg
CREATE VIEW win_more3 AS
SELECT party_id, elec_won, winners_by_country.country_name
FROM winners_by_country, winning_avg
WHERE winners_by_country.country_name = winning_avg.country_name AND elec_won > (average * 3)



-- the answer to the query 

insert into q2 


