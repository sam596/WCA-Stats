INSERT INTO wca_stats.last_updated VALUES ('mbld_decoded', NOW(), NULL, '') ON DUPLICATE KEY UPDATE started=NOW(), completed = NULL;

DROP TABLE IF EXISTS mbld_decoded;
CREATE TABLE mbld_decoded
(id INT NOT NULL AUTO_INCREMENT,
 PRIMARY KEY (id),
 KEY pcr (personId, competitionId, roundTypeId, solve),
 KEY pts (points))
SELECT
    personId,
    personName,
    competitionId,
    date,
    roundTypeId,
    solve,
    pos,
    value wca_value,
    IF(value > 0,99-LEFT(value,2),NULL) points,
    IF(value > 0,MID(value,4,4),NULL) seconds,
    IF(value > 0,CONVERT(RIGHT(value,2),unsigned),NULL) missed,
    IF(value > 0,99-LEFT(value,2)+(2*RIGHT(value,2)),NULL) attempted,
    IF(value > 0,99-LEFT(value,2)+RIGHT(value,2),NULL) solved,
    IF(value > 0,CONCAT(99-LEFT(value,2)+RIGHT(value,2),"/",99-LEFT(value,2)+(2*RIGHT(value,2))),'DNF') result
FROM
    all_attempts
WHERE
    eventId = '333mbf';

UPDATE wca_stats.last_updated SET completed = NOW() WHERE query = 'mbld_decoded';
