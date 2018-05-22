INSERT INTO wca_stats.last_updated VALUES ('SoR_single', NOW(), NULL, '') ON DUPLICATE KEY UPDATE started=NOW(), completed = NULL;

DROP TABLE IF EXISTS SoR_single_be1;
CREATE TEMPORARY TABLE SoR_single_be1 AS 
	SELECT 
		p.id personId, 
		p.name name
		e.id eventId 
	FROM 
		wca_dev.persons p 
	JOIN (
		SELECT * 
		FROM 
			wca_dev.events 
		WHERE 
			id NOT IN ('333mbo','magic','mmagic')
		) e
;


DROP TABLE IF EXISTS world_single_ranks;
CREATE TABLE world_single_ranks AS
	SELECT 
		a.personId, 
		a.name
		a.eventId,
		(CASE WHEN c.worldrank IS NULL THEN NULL ELSE c.best END) best,
		(CASE WHEN c.worldrank IS NULL THEN b.count + 1 ELSE c.worldrank END) worldrank,
		(CASE WHEN c.worldrank IS NULL THEN 0 ELSE 1 END) competed,
		(CASE WHEN c.worldrank IS NULL THEN NULL ELSE d.competitionId END) competitionId,
		(CASE WHEN c.worldrank IS NULL THEN NULL ELSE d.roundTypeId END) roundTypeId,
		(CASE WHEN c.worldrank IS NULL THEN NULL ELSE d.value END) result,
		(CASE WHEN c.worldrank IS NULL THEN NULL ELSE d.date END) date
	FROM 	
		SoR_single_be1 a
	JOIN
		(SELECT 
			eventId, 
			COUNT(*) `count`
		FROM 
			wca_dev.rankssingle
		GROUP BY 
			eventId
		) b
	ON 
		a.eventId=b.eventId
	LEFT JOIN	
		wca_dev.rankssingle c
	ON 
		a.personId = c.personId 
		AND 
		a.eventId = c.eventId
	LEFT JOIN 
		all_single_results d
	ON
		a.personId = d.personId
		AND
		a.eventId = d.eventId
		AND 
		c.best = d.value	
;


DROP TABLE IF EXISTS SoR_single;
CREATE TABLE SoR_single
(rank INT NOT NULL AUTO_INCREMENT, 
PRIMARY KEY(rank))
	SELECT 
		personId,
		name, 
		SUM(worldrank) SoR 
	FROM 
		world_single_ranks 
	GROUP BY 
		personId 
	ORDER BY 
		SoR ASC
;

UPDATE wca_stats.last_updated SET completed = NOW() WHERE query = 'SoR_single';