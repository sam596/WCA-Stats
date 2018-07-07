INSERT INTO wca_stats.last_updated VALUES ('average_ranks', NOW(), NULL, '') ON DUPLICATE KEY UPDATE started=NOW(), completed = NULL;

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
    wca_dev.events e;

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
    (SELECT * FROM wca_dev.events WHERE rank < 900 AND id NOT IN ('333mbf','444bf','555bf')) e;

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
	  wca_stats.result_dates c
	ON c.id = (SELECT id FROM wca_stats.result_dates WHERE average = a.best AND personId = a.personId AND eventId = a.eventId ORDER BY id ASC LIMIT 1)
	LEFT JOIN
	  wca_stats.countryEventsAverage d
	ON b.countryId = d.countryId AND b.eventId = d.eventId
	;

UPDATE wca_stats.last_updated SET completed = NOW() WHERE query = 'average_ranks';

INSERT INTO wca_stats.last_updated VALUES ('sor_average', NOW(), NULL, '') ON DUPLICATE KEY UPDATE started=NOW(), completed = NULL;

DROP TABLE IF EXISTS SoR_average;
CREATE TABLE SoR_average 
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

ALTER TABLE SoR_average 
	ADD COLUMN worldRank INT AFTER worldSoR,
	ADD COLUMN continentRank INT AFTER continentSoR,
	ADD COLUMN countryRank INT AFTER countrySoR;

SET @curr = NULL, @rank = 1, @prev = NULL, @n = 1;
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

SET @curr = NULL, @rank = 1, @coun = NULL, @prev = NULL, @n = 1;
UPDATE wca_stats.SoR_average sora JOIN
(
	SELECT personId, continentSoR,
		@curr := countrySoR curr,
		@rank := IF(@coun = countryId,IF(@prev = @curr, @rank, @rank + @n), 1) rank,
		@n := IF(@prev = @curr, @n + 1, 1) counter,
		@prev := countrySoR,
		@coun := countryId
	FROM SoR_average
	ORDER BY countryId, countrySoR ASC) rank
ON sora.personId = rank.personId
SET sora.countryRank = rank.rank;

UPDATE wca_stats.last_updated SET completed = NOW() WHERE query = 'sor_average';

INSERT INTO wca_stats.last_updated VALUES ('single_ranks', NOW(), NULL, '') ON DUPLICATE KEY UPDATE started=NOW(), completed = NULL;

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
  wca_stats.result_dates c
ON c.id = (SELECT id FROM wca_stats.result_dates WHERE best = a.best AND personId = a.personId AND eventId = a.eventId ORDER BY id ASC LIMIT 1)
LEFT JOIN
  wca_stats.countryEvents d
ON b.countryId = d.countryId AND b.eventId = d.eventId
;

UPDATE wca_stats.last_updated SET completed = NOW() WHERE query = 'single_ranks';

INSERT INTO wca_stats.last_updated VALUES ('sor_single', NOW(), NULL, '') ON DUPLICATE KEY UPDATE started=NOW(), completed = NULL;

DROP TABLE IF EXISTS SoR_single;
CREATE TABLE SoR_single 
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

ALTER TABLE SoR_single 
	ADD COLUMN worldRank INT AFTER worldSoR,
	ADD COLUMN continentRank INT AFTER continentSoR,
	ADD COLUMN countryRank INT AFTER countrySoR;

SET @curr = NULL, @rank = 1, @prev = NULL, @n = 1;
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

UPDATE wca_stats.last_updated SET completed = NOW() WHERE query = 'sor_single';

INSERT INTO wca_stats.last_updated VALUES ('sor_combined', NOW(), NULL, '') ON DUPLICATE KEY UPDATE started=NOW(), completed = NULL;

DROP TABLE IF EXISTS ranks_all;
CREATE TABLE ranks_all
(id INT NOT NULL AUTO_INCREMENT, PRIMARY KEY (id), KEY pefb (personId, eventId, format, best), KEY pwr (personId, worldRank))
	SELECT * FROM world_average_ranks
	UNION ALL
	SELECT * FROM world_single_ranks
	ORDER BY
		eventId, format, worldrank
;

SET @curr = NULL, @rank = 1, @prev = NULL, @n = 1;
DROP TABLE IF EXISTS sor_combined;
CREATE TABLE sor_combined
(KEY psor (personId, worldSoR))
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

ALTER TABLE SoR_combined 
	ADD COLUMN worldRank INT AFTER worldSoR,
	ADD COLUMN continentRank INT AFTER continentSoR,
	ADD COLUMN countryRank INT AFTER countrySoR;

SET @curr = NULL, @rank = 1, @prev = NULL, @n = 1;
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

UPDATE wca_stats.last_updated SET completed = NOW() WHERE query = 'sor_combined';