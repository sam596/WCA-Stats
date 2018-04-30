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