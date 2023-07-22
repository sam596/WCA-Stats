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
    compEndDate,
    roundTypeId,
    pos,
    solve,
    result wca_value,
    IF(result > 0,99-LEFT(result,2),NULL) points,
    IF(result > 0,MID(result,4,4),NULL) seconds,
    IF(result > 0,CONVERT(RIGHT(result,2),unsigned),NULL) missed,
    IF(result > 0,99-LEFT(result,2)+(2*RIGHT(result,2)),NULL) attempted,
    IF(result > 0,99-LEFT(result,2)+RIGHT(result,2),NULL) solved,
    FORMAT_RESULT(result,eventId,'s') result
FROM
    all_attempts
WHERE
    eventId = '333mbf';