INSERT INTO wca_stats.last_updated VALUES ('pbs', NOW(), NULL, '') ON DUPLICATE KEY UPDATE started=NOW(), completed = NULL;

DROP TABLE IF EXISTS pbs;
CREATE TABLE pbs
(id INT NOT NULL AUTO_INCREMENT, PRIMARY KEY(id), KEY pef (personId, eventId, format), KEY pc (personId, competitionId))
SELECT personId, competitionId, date, weekend, eventId, roundTypeId, result, format, `PB`
FROM concise_results
WHERE `PB` = 1;

# ~ 1 min 10 secs

UPDATE wca_stats.last_updated SET completed = NOW() WHERE query = 'PBs';

INSERT INTO wca_stats.last_updated VALUES ('competition_PBs', NOW(), NULL, '') ON DUPLICATE KEY UPDATE started=NOW(), completed = NULL;

DROP TABLE IF EXISTS competition_pbs;
CREATE TABLE competition_pbs
(id INT NOT NULL AUTO_INCREMENT, PRIMARY KEY(id), KEY pc (personId,competitionId), KEY p (personId))
SELECT personId, competitionId, COUNT(CASE WHEN `PB` <> '' THEN 1 END) PBs
FROM concise_results
GROUP BY personId, competitionId 
ORDER BY personId, date ASC;

# ~ 40 secs

DROP TABLE IF EXISTS competition_pbs_exfmc;
CREATE TABLE competition_PBs_exfmc
(id INT NOT NULL AUTO_INCREMENT, PRIMARY KEY(id), KEY pc (personId,competitionId), KEY p (personId))
SELECT personId, competitionId, COUNT(CASE WHEN `PB` <> '' THEN 1 END) PBs
FROM concise_results
WHERE competitionId NOT IN (SELECT competition_id FROM wca_dev.competition_events GROUP BY competition_id HAVING COUNT(*) = 1 AND COUNT(CASE WHEN event_id = '333fm' THEN 1 END) = 1)
GROUP BY personId, competitionId 
ORDER BY personId, date ASC;

# ~ 40 secs

DROP TABLE IF EXISTS competition_pbs_exfmcbld;
CREATE TABLE competition_PBs_exfmcbld
(id INT NOT NULL AUTO_INCREMENT, PRIMARY KEY(id), KEY pc (personId,competitionId), KEY p (personId))
SELECT personId, competitionId, COUNT(CASE WHEN `PB` <> '' THEN 1 END) PBs
FROM concise_results
WHERE competitionId NOT IN (SELECT competition_id FROM wca_dev.competition_events GROUP BY competition_id HAVING COUNT(CASE WHEN (event_id NOT LIKE '%bf' AND event_id <> '333fm') THEN 1 END) = 0)
GROUP BY personId, competitionId 
ORDER BY personId, date ASC;

# ~ 40 secs

UPDATE wca_stats.last_updated SET completed = NOW() WHERE query = 'competition_pbs';
