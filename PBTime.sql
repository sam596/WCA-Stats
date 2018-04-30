SET @personId = '2015SCHO05', @eventId = 'skewb', @format = 'a';

SELECT a.*, 
	(SELECT COUNT(DISTINCT personId)+1 
		FROM concise_results
		WHERE weekend <= a.weekend 
			AND personId != @personId 
			AND eventId = @eventId 
			AND format = @format 
			AND result > 0 
			AND result < a.PB) 'worldrank' 
	FROM (SELECT a.weekend, @personId, @eventId, @format, 
			(SELECT MIN(result) 
				FROM concise_results 
				WHERE weekend <= a.weekend 
					AND personId = @personId 
					AND eventId = @eventId 
					AND format = @format 
					AND result > 0) 'PB' 
			FROM  
				(SELECT weekend 
					FROM concise_results 
					GROUP BY weekend 
					ORDER BY weekend) a 
			) a 
	WHERE a.PB IS NOT NULL
INTO OUTFILE '/var/lib/mysql-files/worldrankovertime.csv' FIELDS TERMINATED BY ',';
