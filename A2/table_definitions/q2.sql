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
CREATE VIEW winning_votes AS
SELECT election_id, max(votes) maxVotes
FROM election_result
GROUP BY election_id;

-- Find all election winners and number of times they have won
CREATE VIEW winners AS
SELECT party_id, count(party_id) elec_won
FROM election_result NATURAL JOIN winning_votes
WHERE election_result.votes = winning_votes.maxVotes
GROUP BY party_id;

-- Group the parties by their country
CREATE VIEW winners_by_country AS
SELECT winners.party_id, party.name party_name, winners.elec_won, country.name country_name
FROM winners, party, country
WHERE winners.party_id = party.id AND party.country_id = country.id;

-- Get the sum of total number of parties in a country
CREATE VIEW total_parties
SELECT country.name country_name, count(distinct party.id) total
FROM party, country
WHERE party.country_id = country.id
GROUP BY country_id;

-- Get average winning times for each country
CREATE VIEW winning_avg AS
SELECT country_name, (sum(elec_won)/ total) average
FROM winners_by_country JOIN total_parties USING country_name
GROUP BY country_name, total;

-- Find parties that has won >3*avg
CREATE VIEW win_more3 AS
SELECT party_id, party_name, elec_won, winners_by_country.country_name
FROM winners_by_country NATURAL JOIN winning_avg
WHERE elec_won > (average * 3);

-- Find all election winners with election id and date
CREATE VIEW winners_and_elec AS
SELECT election_id, party_id, e_date
FROM election_result JOIN election JOIN winning_votes
WHERE election_reselt.election_id = election.id AND election_reselt.election_id = winning_vote.election_id AND election_result.votes = winning_votes.maxVotes;

-- Get most recent win dates
CREATE VIEW recent_win_dates AS
SELECT party_id, max(e_date) e_date
FROM winners_and_elec, election
WHERE winners_and_elec.election_id = election.id
GROUP BY party_id;

-- Get all the info on the most recent win
CREATE VIEW recent_win_info AS
SELECT *
FROM winners_and_elec NATURAL JOIN recent_win_dates;


CREATE VIEW valid_winner_info AS
SELECT country_name countryName, party_name partyName, party_family.family partyFamily, elec_won wonElections, election_id mostRecentlyWonElectionId, EXTRACT(year FROM e_date) mostRecentlyWonElectionYear
FROM win_more3 NATURAL JOIN party_family NATURAL JOIN recent_win_info;

-- the answer to the query 

insert into q2 
SELECT *
FROM valid_winner_info;

