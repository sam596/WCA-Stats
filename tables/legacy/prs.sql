INSERT INTO wca_stats.last_updated VALUES ('prs', NOW(), NULL, '') ON DUPLICATE KEY UPDATE started=NOW(), completed = NULL;

-- drops all rows from concise_results where a PR was not achieved
DROP TABLE IF EXISTS prs;
CREATE TABLE prs
(id INT NOT NULL AUTO_INCREMENT, PRIMARY KEY(id), KEY pef (personId, eventId, format), KEY pc (personId, competitionId))
SELECT personId, competitionId, date, weekend, eventId, roundTypeId, result, format
FROM concise_results
WHERE `PR` = 1;

# ~ 1 min 10 secs

UPDATE wca_stats.last_updated SET completed = NOW() WHERE query = 'PRs';

INSERT INTO wca_stats.last_updated VALUES ('competition_PRs', NOW(), NULL, '') ON DUPLICATE KEY UPDATE started=NOW(), completed = NULL;

-- counts the number of PRs a competitor achieved at every comp
DROP TABLE IF EXISTS competition_prs;
CREATE TABLE competition_prs
(id INT NOT NULL AUTO_INCREMENT, PRIMARY KEY(id), KEY pc (personId,competitionId), KEY p (personId))
SELECT personId, competitionId, COUNT(CASE WHEN `PR` <> '' THEN 1 END) PRs
FROM concise_results
GROUP BY personId, competitionId 
ORDER BY personId, date ASC;

# ~ 40 secs

-- counts the number of PRs a competitor achieved at every comp, excluding comps holding only FMC events
DROP TABLE IF EXISTS competition_prs_exfmc;
CREATE TABLE competition_prs_exfmc
(id INT NOT NULL AUTO_INCREMENT, PRIMARY KEY(id), KEY pc (personId,competitionId), KEY p (personId))
SELECT personId, competitionId, COUNT(CASE WHEN `PR` <> '' THEN 1 END) PRs
FROM concise_results
WHERE competitionId NOT IN (SELECT competition_id FROM wca_dev.competition_events GROUP BY competition_id HAVING COUNT(*) = 1 AND COUNT(CASE WHEN event_id = '333fm' THEN 1 END) = 1)
GROUP BY personId, competitionId 
ORDER BY personId, date ASC;

# ~ 40 secs
-- counts the number of PRs a competitor achieved at every comp, excluding comps holding only FMC and/or BLD events
DROP TABLE IF EXISTS competition_prs_exfmcbld;
CREATE TABLE competition_PRs_exfmcbld
(id INT NOT NULL AUTO_INCREMENT, PRIMARY KEY(id), KEY pc (personId,competitionId), KEY p (personId))
SELECT personId, competitionId, COUNT(CASE WHEN `PR` <> '' THEN 1 END) PRs
FROM concise_results
WHERE competitionId NOT IN (SELECT competition_id FROM wca_dev.competition_events GROUP BY competition_id HAVING COUNT(CASE WHEN (event_id NOT LIKE '%bf' AND event_id <> '333fm') THEN 1 END) = 0)
GROUP BY personId, competitionId 
ORDER BY personId, date ASC;

# ~ 40 secs

UPDATE wca_stats.last_updated SET completed = NOW() WHERE query = 'competition_prs';
