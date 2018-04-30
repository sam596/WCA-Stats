INSERT INTO wca_stats.last_updated VALUES ('PBs', NOW(), NULL, '') ON DUPLICATE KEY UPDATE started=NOW(), completed = NULL;

drop table if exists PBs;
CREATE TABLE PBs
(id INT NOT NULL AUTO_INCREMENT, PRIMARY KEY(id), KEY pef (personId, eventId, format))
SELECT personId, competitionId, date, eventId, roundTypeId, result, format, `PB`
FROM concise_results
WHERE `PB` = 1;

UPDATE wca_stats.last_updated SET completed = NOW() WHERE query = 'PBs';

INSERT INTO wca_stats.last_updated VALUES ('competition_PBs', NOW(), NULL, '') ON DUPLICATE KEY UPDATE started=NOW(), completed = NULL;

drop table if exists competition_PBs;
CREATE TABLE competition_PBs
(id INT NOT NULL AUTO_INCREMENT, PRIMARY KEY(id), KEY pc (personId,competitionId), KEY p (personId))
SELECT personId, competitionId, COUNT(CASE WHEN `PB` <> '' THEN 1 END) PBs
FROM concise_results
GROUP BY personId, competitionId 
ORDER BY personId, date ASC;

UPDATE wca_stats.last_updated SET completed = NOW() WHERE query = 'competition_PBs';
