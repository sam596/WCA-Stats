INSERT INTO wca_stats.last_updated VALUES ('records', NOW(), NULL, '') ON DUPLICATE KEY UPDATE started=NOW(), completed = NULL;

DROP TABLE IF EXISTS National_Records;
CREATE TABLE National_Records
(id INT NOT NULL AUTO_INCREMENT, PRIMARY KEY (id))
SELECT competitionId, date, personId, personName, personCountryId, personContinentId, eventId, 's' format, best 'result', regionalSingleRecord 'record'
	FROM wca_stats.results_extra
	WHERE regionalSingleRecord != ''
UNION ALL
SELECT competitionId, date, personId, personName, personCountryId, personContinentId, eventId, 'a' format, average 'result', regionalAverageRecord 'record'
	FROM wca_stats.results_extra
	WHERE regionalAverageRecord != ''
ORDER BY personCountryId, eventId, format DESC, date ASC;

# <10 secs

DROP TABLE IF EXISTS Continent_Records;
CREATE TABLE Continent_Records
(id INT NOT NULL AUTO_INCREMENT, PRIMARY KEY (id))
SELECT competitionId, date, personId, personName, personCountryId, personContinentId, eventId, 's' format, best 'result', regionalSingleRecord 'record'
	FROM wca_stats.results_extra
	WHERE regionalSingleRecord NOT IN ('','NR')
UNION ALL
SELECT competitionId, date, personId, personName, personCountryId, personContinentId, eventId, 'a' format, average 'result', regionalAverageRecord 'record'
	FROM wca_stats.results_extra
	WHERE regionalAverageRecord NOT IN ('','NR')
ORDER BY personContinentId, eventId, format DESC, date ASC;

# <10 secs

DROP TABLE IF EXISTS World_Records;
CREATE TABLE World_Records
(id INT NOT NULL AUTO_INCREMENT, PRIMARY KEY (id))
SELECT competitionId, date, personId, personName, personCountryId, personContinentId, eventId, 's' format, best 'result', regionalSingleRecord 'record'
	FROM wca_stats.results_extra
	WHERE regionalSingleRecord = 'WR'
UNION ALL
SELECT competitionId, date, personId, personName, personCountryId, personContinentId, eventId, 'a' format, average 'result', regionalAverageRecord 'record'
	FROM wca_stats.results_extra
	WHERE regionalAverageRecord = 'WR'
ORDER BY eventId, format DESC, date ASC;

# <10 secs

UPDATE wca_stats.last_updated SET completed = NOW() WHERE query = 'records';
