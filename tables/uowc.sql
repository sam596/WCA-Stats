INSERT INTO wca_stats.last_updated VALUES ('all_single_results', NOW(), NULL, '') ON DUPLICATE KEY UPDATE started=NOW(), completed = NULL;

DROP TABLE IF EXISTS uowc_help;
CREATE TABLE uowc_help
SELECT
  MIN(id) id,
  competitionId,
  eventId,
  roundTypeId,
  date,
  GROUP_CONCAT((CASE WHEN pos = 1 AND best > 0 THEN personId END) ORDER BY personId) winner,
  SUM(CASE WHEN pos = 1 AND formatId IN ('a','m') THEN average WHEN pos = 1 THEN best END) result,
  formatId,
  GROUP_CONCAT(CASE WHEN pos <> 1 THEN personId END) others
FROM
  wca_stats.result_dates
GROUP BY
  competitionId, eventId, roundTypeId
ORDER BY 
  eventId, MIN(id);

SET @uowc = NULL, @uowcd = '1970-01-01', @e = NULL;
DROP TABLE IF EXISTS uowc_history;
CREATE TABLE uowc_history
SELECT
  b.id, b.competitionId, b.eventId, b.roundTypeId, b.date, b.winner, b.result, b.formatId, b.uowcId, dateSet
FROM
(SELECT
  a.*,
  @uowc := 
    IF(@uowc = a.winner OR a.winner = NULL, 
      @uowc, 
      IF(others LIKE CONCAT("%",@uowc,"%"), 
        a.winner, 
        IF(a.date > DATE_ADD(@uowcd, INTERVAL 1 YEAR), 
          (SELECT IFNULL(winner,@uowc) FROM uowc_help WHERE date = a.date AND roundTypeId IN ('c','f') AND eventId = a.eventId AND result > 0 ORDER BY (CASE WHEN eventId = '333fm' AND formatId <> 'm' THEN result * 9999 ELSE result END) LIMIT 1), 
          IF(a.eventId <> @e,
            (SELECT winner FROM uowc_help WHERE date = a.date AND roundTypeId IN ('c','f') AND eventId = a.eventId AND result > 0 ORDER BY (CASE WHEN eventId = '333fm' AND formatId <> 'm' THEN result * 9999 ELSE result END) LIMIT 1),
            @uowc
            )
          )
        )
      ) uowcId, 
  @uowcd := IF(winner = @uowc OR (a.date > DATE_ADD(@uowcd, INTERVAL 1 YEAR) AND (SELECT IFNULL(winner,@uowc) FROM uowc_help WHERE date = a.date AND roundTypeId IN ('c','f') AND eventId = a.eventId AND result > 0 ORDER BY (CASE WHEN eventId = '333fm' AND formatId <> 'm' THEN result * 9999 ELSE result END) LIMIT 1) IS NOT NULL), date, @uowcd) dateSet,
  @e := eventId
FROM
  (SELECT * FROM wca_stats.uowc_help ORDER BY eventId, id) a) b;

DROP TABLE uowc_help;

DROP TABLE IF EXISTS uowc;
CREATE TABLE uowc
SELECT 
  b.uowcId, 
  p.name, 
  p.countryId, 
  b.dateSet, 
  b.eventId, 
  b.competitionId, 
  b.result, 
  b.formatId 
FROM 
  (SELECT uowcId, dateSet, eventId, MIN(id) FROM uowc_history GROUP BY uowcId, dateSet, eventId) a 
JOIN 
  (SELECT id, uowcId, eventId, dateSet, competitionId, result, formatId FROM uowc_history) b 
  ON a.`MIN(id)` = b.id 
LEFT JOIN wca_dev.persons p 
  ON a.uowcId = p.id AND p.subId = 1
ORDER BY b.eventId, b.id;

UPDATE wca_stats.last_updated SET completed = NOW() WHERE query = 'all_single_results';
