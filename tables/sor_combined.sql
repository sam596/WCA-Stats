INSERT INTO wca_stats.last_updated VALUES ('SoR_Combined', NOW(), NULL, '') ON DUPLICATE KEY UPDATE started=NOW(), completed = NULL;

DROP TABLE IF EXISTS SoR_Combined;
CREATE TABLE SoR_Combined 
(rank INT NOT NULL AUTO_INCREMENT, 
PRIMARY KEY(rank))
	SELECT 	
		a.personId, 
		a.name,
		a.SoR `SoR_average`, 
		a.rank `SoR_average_rank`, 
		b.SoR `SoR_single`, 
		b.rank `SoR_single_rank`, 
		a.SoR+b.SoR `Combined_SoR` 
	FROM 
		SoR_average a 
	JOIN 
		SoR_single b 
	ON 
		a.personId = b.personId
	ORDER BY 
		`Combined_SoR` ASC
;

UPDATE wca_stats.last_updated SET completed = NOW() WHERE query = 'SoR_Combined';

INSERT INTO wca_stats.last_updated VALUES ('world_ranks_all', NOW(), NULL, '') ON DUPLICATE KEY UPDATE started=NOW(), completed = NULL;

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

UPDATE wca_stats.last_updated SET completed = NOW() WHERE query = 'world_ranks_all';
