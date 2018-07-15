INSERT INTO wca_stats.last_updated VALUES ('records', NOW(), NULL, '') ON DUPLICATE KEY UPDATE started=NOW(), completed = NULL;

DROP TABLE IF EXISTS National_Records;
CREATE TABLE National_Records
(id INT NOT NULL AUTO_INCREMENT, PRIMARY KEY (id))
SELECT competitionId, date, personId, personName, countryId, continentId, eventId, 's' format, best 'result', regionalSingleRecord 'record'
	FROM wca_stats.Result_Dates
	WHERE regionalSingleRecord != ''
UNION ALL
SELECT competitionId, date, personId, personName, countryId, continentId, eventId, 'a' format, average 'result', regionalAverageRecord 'record'
	FROM wca_stats.Result_Dates
	WHERE regionalAverageRecord != ''
ORDER BY countryId, eventId, format DESC, date ASC;

DROP TABLE IF EXISTS Continent_Records;
CREATE TABLE Continent_Records
(id INT NOT NULL AUTO_INCREMENT, PRIMARY KEY (id))
SELECT competitionId, date, personId, personName, countryId, continentId, eventId, 's' format, best 'result', regionalSingleRecord 'record'
	FROM wca_stats.Result_Dates
	WHERE regionalSingleRecord NOT IN ('','NR')
UNION ALL
SELECT competitionId, date, personId, personName, countryId, continentId, eventId, 'a' format, average 'result', regionalAverageRecord 'record'
	FROM wca_stats.Result_Dates
	WHERE regionalAverageRecord NOT IN ('','NR')
ORDER BY continentId, eventId, format DESC, date ASC;

DROP TABLE IF EXISTS World_Records;
CREATE TABLE World_Records
(id INT NOT NULL AUTO_INCREMENT, PRIMARY KEY (id))
SELECT competitionId, date, personId, personName, countryId, continentId, eventId, 's' format, best 'result', regionalSingleRecord 'record'
	FROM wca_stats.Result_Dates
	WHERE regionalSingleRecord = 'WR'
UNION ALL
SELECT competitionId, date, personId, personName, countryId, continentId, eventId, 'a' format, average 'result', regionalAverageRecord 'record'
	FROM wca_stats.Result_Dates
	WHERE regionalAverageRecord = 'WR'
ORDER BY eventId, format DESC, date ASC;

UPDATE wca_stats.last_updated SET completed = NOW() WHERE query = 'records';
