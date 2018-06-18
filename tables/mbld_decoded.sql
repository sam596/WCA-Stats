INSERT INTO wca_stats.last_updated VALUES ('mbld_decoded', NOW(), NULL, '') ON DUPLICATE KEY UPDATE started=NOW(), completed = NULL;

DROP TABLE IF EXISTS mbld_decoded;
CREATE TABLE mbld_decoded
SELECT
    personId,
    personName,
    competitionId,
    date,
    roundTypeId,
    solve,
    pos,
    value wca_value,
    99-LEFT(value,2) points,
    MID(value,4,4) seconds,
    CONVERT(RIGHT(value,2),unsigned) missed,
    99-LEFT(value,2)+(2*RIGHT(value,2)) attempted,
    99-LEFT(value,2)+RIGHT(value,2) solved
FROM
    all_single_results
WHERE
    eventId = '333mbf'
    AND
    value > 0;
    
UPDATE wca_stats.last_updated SET completed = NOW() WHERE query = 'mbld_decoded';
