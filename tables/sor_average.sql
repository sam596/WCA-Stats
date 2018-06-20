INSERT INTO wca_stats.last_updated VALUES ('sor_average', NOW(), NULL, '') ON DUPLICATE KEY UPDATE started=NOW(), completed = NULL;

DROP TABLE IF EXISTS SoR_average_be1;
CREATE TEMPORARY TABLE SoR_average_be1
	SELECT 
		p.id personId,
		p.name,
		p.countryId,
		(SELECT continentId FROM wca_dev.countries WHERE id = p.countryId) continentId, 
		e.id eventId 
	FROM 
		wca_dev.persons p 
	JOIN (
		SELECT * 
		FROM 
			wca_dev.events 
		WHERE 
			id NOT IN ('333mbo','magic','mmagic','444bf','555bf','333mbf')
		) e
;

DROP TABLE IF EXISTS world_average_ranks;
CREATE TABLE world_average_ranks
(id INT NOT NULL AUTO_INCREMENT, PRIMARY KEY (id), KEY pebw (personId, eventId, best, worldrank), KEY cr (competitionId, roundTypeId))
	SELECT 
		a.personId,
		a.name,
		a.countryId, 
		a.continentId,
		a.eventId, 
		(CASE WHEN c.worldrank IS NULL THEN NULL ELSE c.best END) best,
		(CASE WHEN c.worldrank IS NULL THEN b.count + 1 ELSE c.worldrank END) worldrank,
		(CASE WHEN c.worldrank IS NULL THEN 0 ELSE 1 END) competed,
		(CASE WHEN c.worldrank IS NULL THEN NULL ELSE d.competitionId END) competitionId,
		(CASE WHEN c.worldrank IS NULL THEN NULL ELSE d.roundTypeId END) roundTypeId,
		(CASE WHEN c.worldrank IS NULL THEN NULL ELSE d.date END) date
	FROM 	
		SoR_average_be1 a
	JOIN (
		SELECT 
			eventId eventId, 
			COUNT(*) `count`
		FROM 
			wca_dev.ranksaverage
		GROUP BY 
			eventId
		) b
	ON 
		a.eventId = b.eventId
	LEFT JOIN	
		wca_dev.ranksaverage c
	ON 
		a.personId = c.personId 
		AND 
		a.eventId = c.eventId		
	LEFT JOIN
		result_dates d
	ON
		a.personId = d.personId
		AND
		a.eventId = d.eventId
		AND
		c.best = d.average
	ORDER BY 
		a.eventId, worldrank
;

DROP TABLE IF EXISTS SoR_average;
CREATE TABLE SoR_average 
(rank INT NOT NULL AUTO_INCREMENT, 
PRIMARY KEY(rank),
KEY pc (personId, countryId),
KEY psor (personId, SoR))
	SELECT 
		personId,
		name,
		countryId, 
		continentId,
		SUM(worldrank) SoR 
	FROM 
		world_average_ranks
	GROUP BY 
		personId 
	ORDER BY
		SoR ASC
;

UPDATE wca_stats.last_updated SET completed = NOW() WHERE query = 'sor_average';
