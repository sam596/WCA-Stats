INSERT INTO wca_stats.last_updated VALUES ('sor_combined', NOW(), NULL, '') ON DUPLICATE KEY UPDATE started=NOW(), completed = NULL;

DROP TABLE IF EXISTS world_ranks_all;
CREATE TABLE world_ranks_all AS
	SELECT 	*,
			'a' `format`
	FROM
		world_average_ranks
	UNION ALL
	SELECT	*,
			's' `format`
	FROM
		world_single_ranks
;

DROP TABLE IF EXISTS sor_combined;
CREATE TABLE sor_combined 
(rank INT NOT NULL AUTO_INCREMENT, 
PRIMARY KEY(rank))
	SELECT 	
		a.personId, 
		a.name,
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
