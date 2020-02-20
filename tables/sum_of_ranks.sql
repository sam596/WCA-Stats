INSERT INTO wca_stats.last_updated VALUES ('average_ranks', NOW(), NULL, '') ON DUPLICATE KEY UPDATE started=NOW(), completed = NULL;

-- Total number of competitors with an average +1 in the event by country, continent and world
DROP TABLE IF EXISTS wca_stats.countryEventsAverage;
CREATE TEMPORARY TABLE wca_stats.countryEventsAverage
(KEY ce (countryId, eventId))
SELECT
c.id countryId,
c.continentId,
e.id eventId,
(SELECT IFNULL(MAX(countryRank),0)+1 FROM wca_dev.ranksAverage WHERE personId IN (SELECT id FROM wca_dev.persons WHERE countryId = c.id AND subid = 1) AND eventId = e.id) countryCount,
(SELECT IFNULL(MAX(continentRank),0)+1 FROM wca_dev.ranksAverage WHERE personId IN (SELECT id FROM wca_dev.persons WHERE continentId = c.continentId AND subid = 1) AND eventId = e.id) continentCount,
(SELECT IFNULL(MAX(worldRank),0)+1 FROM wca_dev.ranksAverage WHERE eventId = e.id) worldCount
FROM
wca_dev.countries c
JOIN
(SELECT * FROM wca_dev.events WHERE rank < 900 AND id != '333mbf') e;

-- ~ 10 mins

-- All Event Average/Person combinations
DROP TABLE IF EXISTS wca_stats.personEventsAverage;
CREATE TEMPORARY TABLE wca_stats.personEventsAverage
(KEY pe (id, eventId))
SELECT
    p.id,
    p.name,
    p.countryId,
    (SELECT continentId FROM wca_dev.countries WHERE id = p.countryId) continentId,
    e.id eventId
  FROM
    (SELECT * FROM wca_dev.persons WHERE subid = 1) p
  JOIN
    (SELECT * FROM wca_dev.events WHERE rank < 900 AND id != '333mbf') e;

-- ~ 30 secs

-- Better RanksAverage, but with the details of the PR and right joined to all possible combinations, so any averages not achieved are given max+1
DROP TABLE IF EXISTS wca_stats.average_ranks;
CREATE TABLE wca_stats.average_ranks
SELECT
	  b.id personId,
	  b.name,
	  b.countryId,
	  b.continentId,
	  b.eventId,
	  'a' format,
	  (CASE WHEN a.best IS NOT NULL THEN 1 ELSE 0 END) succeeded,
	  a.best result,
	  (CASE WHEN a.worldRank IS NULL OR a.worldRank = 0 THEN d.worldCount ELSE a.worldRank END) worldRank,
	  (CASE WHEN a.continentRank IS NULL OR a.continentRank = 0 THEN d.continentCount ELSE a.continentRank END) continentRank,
	  (CASE WHEN a.countryRank IS NULL OR a.countryRank = 0 THEN d.countryCount ELSE a.countryRank END) countryRank,
	  c.competitionId,
	  c.roundTypeId,
	  c.date
	FROM
	  wca_dev.ranksaverage a
	RIGHT JOIN
	  wca_stats.personEventsAverage b
	ON a.personId = b.id AND a.eventId = b.eventId
	LEFT JOIN
	  wca_stats.results_extra c
	ON c.id = (SELECT id FROM wca_stats.results_extra WHERE average = a.best AND personId = a.personId AND eventId = a.eventId ORDER BY id ASC LIMIT 1)
	LEFT JOIN
	  wca_stats.countryEventsAverage d
	ON b.countryId = d.countryId AND b.eventId = d.eventId
	;

-- ~ 2 mins

UPDATE wca_stats.last_updated SET completed = NOW() WHERE query = 'average_ranks';

INSERT INTO wca_stats.last_updated VALUES ('sor_average', NOW(), NULL, '') ON DUPLICATE KEY UPDATE started=NOW(), completed = NULL;
-- sum of average ranks for world, continent and country
DROP TABLE IF EXISTS SoR_average;
CREATE TABLE SoR_average 
(PRIMARY KEY (personId), KEY pwcc (personId, worldSoR, continentSoR, countrySoR))
	SELECT 
		personId,
		name,
		countryId,
		continentId,
		SUM(worldRank) worldSoR,
		SUM(continentRank) continentSoR,
		SUM(countryRank) countrySoR
	FROM 
		average_ranks
	GROUP BY 
		personId
	ORDER BY
		worldSoR
;

-- ~ 1 min
-- adds rank values for average sor for world, continent and country
ALTER TABLE SoR_average 
	ADD COLUMN worldRank INT AFTER worldSoR,
	ADD COLUMN continentRank INT AFTER continentSoR,
	ADD COLUMN countryRank INT AFTER countrySoR;

SET @curr = NULL, @rank = 0, @prev = NULL, @n = 1;
UPDATE wca_stats.SoR_average sora JOIN
(
	SELECT personId, worldSoR,
		@curr := worldSoR curr,
		@rank := IF(@prev = @curr, @rank, @rank + @n) rank,
		@n := IF(@prev = @curr, @n + 1, 1) counter,
		@prev := worldSoR
	FROM SoR_average
	ORDER BY worldSoR ASC) rank
ON sora.personId = rank.personId
SET sora.worldRank = rank.rank;

-- <10 secs

SET @curr = NULL, @rank = 1, @con = NULL, @prev = NULL, @n = 1;
UPDATE wca_stats.SoR_average sora JOIN
(
	SELECT personId, continentSoR,
		@curr := continentSoR curr,
		@rank := IF(@con = continentId,IF(@prev = @curr, @rank, @rank + @n), 1) rank,
		@n := IF(@prev = @curr, @n + 1, 1) counter,
		@prev := continentSoR,
		@con := continentId
	FROM SoR_average
	ORDER BY continentId, continentSoR ASC) rank
ON sora.personId = rank.personId
SET sora.continentRank = rank.rank;

-- <10 secs

SET @curr = NULL, @rank = 1, @coun = NULL, @prev = NULL, @n = 1;
UPDATE wca_stats.SoR_average sora JOIN
(
	SELECT personId, countrySoR,
		@curr := countrySoR curr,
		@rank := IF(@coun = countryId,IF(@prev = @curr, @rank, @rank + @n), 1) rank,
		@n := IF(@prev = @curr, @n + 1, 1) counter,
		@prev := countrySoR,
		@coun := countryId
	FROM SoR_average
	ORDER BY countryId, countrySoR ASC) rank
ON sora.personId = rank.personId
SET sora.countryRank = rank.rank;

-- <10 secs

UPDATE wca_stats.last_updated SET completed = NOW() WHERE query = 'sor_average';

INSERT INTO wca_stats.last_updated VALUES ('single_ranks', NOW(), NULL, '') ON DUPLICATE KEY UPDATE started=NOW(), completed = NULL;
-- Total number of competitors with a success +1 in the event by country, continent and world
DROP TABLE IF EXISTS wca_stats.countryEventsSingle;
CREATE TEMPORARY TABLE wca_stats.countryEventsSingle
(KEY ce (countryId, eventId))
SELECT
    c.id countryId,
    c.continentId,
    e.id eventId,
    (SELECT IFNULL(MAX(countryRank),0)+1 FROM wca_dev.ranksSingle WHERE personId IN (SELECT id FROM wca_dev.persons WHERE countryId = c.id AND subid = 1) AND eventId = e.id) countryCount,
    (SELECT IFNULL(MAX(continentRank),0)+1 FROM wca_dev.ranksSingle WHERE personId IN (SELECT id FROM wca_dev.persons WHERE continentId = c.continentId AND subid = 1) AND eventId = e.id) continentCount,
    (SELECT IFNULL(MAX(worldRank),0)+1 FROM wca_dev.ranksSingle WHERE eventId = e.id) worldCount
  FROM
    wca_dev.countries c
  JOIN
    wca_dev.events e;

-- ~ 11 mins
-- All Event/Person combinations
DROP TABLE IF EXISTS wca_stats.personEventsSingle;
CREATE TEMPORARY TABLE wca_stats.personEventsSingle
(KEY pe (id, eventId))
SELECT
    p.id,
    p.name,
    p.countryId,
    (SELECT continentId FROM wca_dev.countries WHERE id = p.countryId) continentId,
    e.id eventId
  FROM
    (SELECT * FROM wca_dev.persons WHERE subid = 1) p
  JOIN
    (SELECT * FROM wca_dev.events WHERE rank < 900) e;

-- ~ 40 secs
-- Better RanksSingle, but with the details of the PR and right joined to all possible combinations, so any averages not achieved are given max+1
DROP TABLE IF EXISTS wca_stats.single_ranks;
CREATE TABLE wca_stats.single_ranks
SELECT
  b.id personId,
  b.name,
  b.countryId,
  b.continentId,
  b.eventId,
  's' format,
  (CASE WHEN a.best IS NOT NULL THEN 1 ELSE 0 END) succeeded,
  a.best result,
  (CASE WHEN a.worldRank IS NULL OR a.worldRank = 0 THEN d.worldCount ELSE a.worldRank END) worldRank,
  (CASE WHEN a.continentRank IS NULL OR a.continentRank = 0 THEN d.continentCount ELSE a.continentRank END) continentRank,
  (CASE WHEN a.countryRank IS NULL OR a.countryRank = 0 THEN d.countryCount ELSE a.countryRank END) countryRank,
  c.competitionId,
  c.roundTypeId,
  c.date
FROM
  wca_dev.rankssingle a
RIGHT JOIN
  wca_stats.personEventsSingle b
ON a.personId = b.id AND a.eventId = b.eventId
LEFT JOIN
  wca_stats.results_extra c
ON c.id = (SELECT id FROM wca_stats.results_extra WHERE best = a.best AND personId = a.personId AND eventId = a.eventId ORDER BY id ASC LIMIT 1)
LEFT JOIN
  wca_stats.countryEventsSingle d
ON b.countryId = d.countryId AND b.eventId = d.eventId
;

-- ~ 2 mins 15 secs

UPDATE wca_stats.last_updated SET completed = NOW() WHERE query = 'single_ranks';

INSERT INTO wca_stats.last_updated VALUES ('sor_single', NOW(), NULL, '') ON DUPLICATE KEY UPDATE started=NOW(), completed = NULL;
-- sum of single ranks for world, continent and country
DROP TABLE IF EXISTS SoR_single;
CREATE TABLE SoR_single 
(PRIMARY KEY (personId), KEY pwcc (personId, worldSoR, continentSoR, countrySoR))
	SELECT 
		personId,
		name,
		countryId,
		continentId,
		SUM(worldRank) worldSoR,
		SUM(continentRank) continentSoR,
		SUM(countryRank) countrySoR
	FROM 
		single_ranks
	GROUP BY 
		personId
	ORDER BY
		worldSoR
;

-- ~ 1 min
-- adds rank values for single sor for world, continent and country
ALTER TABLE SoR_single 
	ADD COLUMN worldRank INT AFTER worldSoR,
	ADD COLUMN continentRank INT AFTER continentSoR,
	ADD COLUMN countryRank INT AFTER countrySoR;

SET @curr = NULL, @rank = 0, @prev = NULL, @n = 1;
UPDATE wca_stats.SoR_single sora JOIN
(
	SELECT personId, worldSoR,
		@curr := worldSoR curr,
		@rank := IF(@prev = @curr, @rank, @rank + @n) rank,
		@n := IF(@prev = @curr, @n + 1, 1) counter,
		@prev := worldSoR
	FROM SoR_single
	ORDER BY worldSoR ASC) rank
ON sora.personId = rank.personId
SET sora.worldRank = rank.rank;

-- <10 secs

SET @curr = NULL, @rank = 1, @con = NULL, @prev = NULL, @n = 1;
UPDATE wca_stats.SoR_single sora JOIN
(
	SELECT personId, continentSoR,
		@curr := continentSoR curr,
		@rank := IF(@con = continentId,IF(@prev = @curr, @rank, @rank + @n), 1) rank,
		@n := IF(@prev = @curr, @n + 1, 1) counter,
		@prev := continentSoR,
		@con := continentId
	FROM SoR_single
	ORDER BY continentId, continentSoR ASC) rank
ON sora.personId = rank.personId
SET sora.continentRank = rank.rank;

-- <10 secs

SET @curr = NULL, @rank = 1, @coun = NULL, @prev = NULL, @n = 1;
UPDATE wca_stats.SoR_single sora JOIN
(
	SELECT personId, continentSoR,
		@curr := countrySoR curr,
		@rank := IF(@coun = countryId,IF(@prev = @curr, @rank, @rank + @n), 1) rank,
		@n := IF(@prev = @curr, @n + 1, 1) counter,
		@prev := countrySoR,
		@coun := countryId
	FROM SoR_single
	ORDER BY countryId, countrySoR ASC) rank
ON sora.personId = rank.personId
SET sora.countryRank = rank.rank;

-- <10 secs

UPDATE wca_stats.last_updated SET completed = NOW() WHERE query = 'sor_single';

INSERT INTO wca_stats.last_updated VALUES ('sor_combined', NOW(), NULL, '') ON DUPLICATE KEY UPDATE started=NOW(), completed = NULL;
-- unions single and average ranks into one table
DROP TABLE IF EXISTS ranks_all;
CREATE TABLE ranks_all
(id INT NOT NULL AUTO_INCREMENT, PRIMARY KEY (id), KEY pefb (personId, eventId, format, result), KEY pwr (personId, worldRank))
	SELECT * FROM average_ranks
	UNION ALL
	SELECT * FROM single_ranks
	ORDER BY
		eventId, format, worldrank
;

-- ~ 12 mins 30 secs
-- uses new table to create sum of all ranks, single and average
DROP TABLE IF EXISTS sor_combined;
CREATE TABLE sor_combined
(PRIMARY KEY (personId), KEY pwcc (personId, worldSoR, continentSoR, countrySoR))
	SELECT
		personId,
		name,
		countryId,
		continentId,
		SUM(worldRank) worldSoR,
		SUM(continentRank) continentSoR,
		SUM(countryRank) countrySoR
	FROM
		ranks_all
	GROUP BY 
		personId
	ORDER BY
		worldSoR;

-- ~ 50 secs
-- adds ranks as in SoR single and average
ALTER TABLE SoR_combined 
	ADD COLUMN worldRank INT AFTER worldSoR,
	ADD COLUMN continentRank INT AFTER continentSoR,
	ADD COLUMN countryRank INT AFTER countrySoR;

SET @curr = NULL, @rank = 0, @prev = NULL, @n = 1;
UPDATE wca_stats.SoR_combined sora JOIN
(
	SELECT personId, worldSoR,
		@curr := worldSoR curr,
		@rank := IF(@prev = @curr, @rank, @rank + @n) rank,
		@n := IF(@prev = @curr, @n + 1, 1) counter,
		@prev := worldSoR
	FROM SoR_combined
	ORDER BY worldSoR ASC) rank
ON sora.personId = rank.personId
SET sora.worldRank = rank.rank;

-- <10 secs

SET @curr = NULL, @rank = 1, @con = NULL, @prev = NULL, @n = 1;
UPDATE wca_stats.SoR_combined sora JOIN
(
	SELECT personId, continentSoR,
		@curr := continentSoR curr,
		@rank := IF(@con = continentId,IF(@prev = @curr, @rank, @rank + @n), 1) rank,
		@n := IF(@prev = @curr, @n + 1, 1) counter,
		@prev := continentSoR,
		@con := continentId
	FROM SoR_combined
	ORDER BY continentId, continentSoR ASC) rank
ON sora.personId = rank.personId
SET sora.continentRank = rank.rank;

-- <10 secs

SET @curr = NULL, @rank = 1, @coun = NULL, @prev = NULL, @n = 1;
UPDATE wca_stats.SoR_combined sora JOIN
(
	SELECT personId, continentSoR,
		@curr := countrySoR curr,
		@rank := IF(@coun = countryId,IF(@prev = @curr, @rank, @rank + @n), 1) rank,
		@n := IF(@prev = @curr, @n + 1, 1) counter,
		@prev := countrySoR,
		@coun := countryId
	FROM SoR_combined
	ORDER BY countryId, countrySoR ASC) rank
ON sora.personId = rank.personId
SET sora.countryRank = rank.rank;

-- <10 secs

UPDATE wca_stats.last_updated SET completed = NOW() WHERE query = 'sor_combined';
