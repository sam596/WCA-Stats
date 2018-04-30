INSERT INTO wca_stats.last_updated VALUES ('records', NOW(), NULL, '') ON DUPLICATE KEY UPDATE started=NOW(), completed = NULL;

CREATE TABLE records
(id INT NOT NULL AUTO_INCREMENT, PRIMARY KEY(id))
SELECT * FROM
(SELECT competitionId, date, eventId, countryId, personId, average, best, 'a' record FROM result_dates WHERE regionalAverageRecord <> ''
UNION ALL 
SELECT competitionId, date, eventId, countryId, personId, average, best, 's' record FROM result_dates WHERE regionalSingleRecord <> '') a
ORDER BY countryId, eventId, record, date ASC;

UPDATE wca_stats.last_updated SET completed = NOW() WHERE query = 'records';