INSERT INTO wca_stats.last_updated VALUES ('PBs', NOW(), NULL, '') ON DUPLICATE KEY UPDATE started=NOW(), completed = NULL;

DROP TABLE IF EXISTS PBs;
CREATE TABLE PBs
(id INT NOT NULL AUTO_INCREMENT, PRIMARY KEY(id), KEY pef (personId, eventId, format))
SELECT personId, competitionId, date, eventId, roundTypeId, result, format, `PB`
FROM concise_results
WHERE `PB` = 1;

UPDATE wca_stats.last_updated SET completed = NOW() WHERE query = 'PBs';

INSERT INTO wca_stats.last_updated VALUES ('competition_PBs', NOW(), NULL, '') ON DUPLICATE KEY UPDATE started=NOW(), completed = NULL;

DROP TABLE IF EXISTS competition_PBs;
CREATE TABLE competition_PBs
(id INT NOT NULL AUTO_INCREMENT, PRIMARY KEY(id), KEY pc (personId,competitionId), KEY p (personId))
SELECT personId, competitionId, COUNT(CASE WHEN `PB` <> '' THEN 1 END) PBs
FROM concise_results
GROUP BY personId, competitionId 
ORDER BY personId, date ASC;

DROP TABLE IF EXISTS competition_PBs_exFMC;
CREATE TABLE competition_PBs_exFMC
(id INT NOT NULL AUTO_INCREMENT, PRIMARY KEY(id), KEY pc (personId,competitionId), KEY p (personId))
SELECT personId, competitionId, COUNT(CASE WHEN `PB` <> '' THEN 1 END) PBs
FROM concise_results
WHERE competitionId NOT IN (SELECT competition_id FROM wca_dev.competition_events GROUP BY competition_id HAVING COUNT(*) = 1 AND COUNT(CASE WHEN event_id = '333fm' THEN 1 END) = 1)
GROUP BY personId, competitionId 
ORDER BY personId, date ASC;

UPDATE wca_stats.last_updated SET completed = NOW() WHERE query = 'competition_PBs';
