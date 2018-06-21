INSERT INTO wca_stats.last_updated VALUES ('sor_combined', NOW(), NULL, '') ON DUPLICATE KEY UPDATE started=NOW(), completed = NULL;

DROP TABLE IF EXISTS world_ranks_all;
CREATE TABLE world_ranks_all
(id INT NOT NULL AUTO_INCREMENT, PRIMARY KEY (id), KEY pefb (personId, eventId, format, best), KEY pwr (personId, worldRank))
	SELECT 	personId, name, countryId, continentId, eventId, best, worldrank, competed, competitionId, roundTypeId, date,
			'a' `format`
	FROM
		world_average_ranks
	UNION ALL
	SELECT	personId, name, countryId, continentId, eventId, best, worldrank, competed, competitionId, roundTypeId, date,
			's' `format`
	FROM
		world_single_ranks
	ORDER BY
		eventId, format, worldrank
;

DROP TABLE IF EXISTS sor_combined;
CREATE TABLE sor_combined 
(rank INT NOT NULL AUTO_INCREMENT, 
PRIMARY KEY(rank),
 KEY psor (personId, SoR_combined))
	SELECT 	
		personId, 
		name,
		SUM(CASE WHEN format = 'a' THEN worldrank END) SoR_average,
		SUM(CASE WHEN format = 's' THEN worldrank END) SoR_single,
		SUM(worldrank) SoR_combined
	FROM
		world_ranks_all
	GROUP BY 
		personId
	ORDER BY 
		SoR_combined ASC
;

UPDATE wca_stats.last_updated SET completed = NOW() WHERE query = 'sor_combined';
