DROP TABLE IF EXISTS uowc_help;
CREATE TABLE uowc_help
SELECT
  MIN(id) id,
  competitionId,
  eventId,
  roundTypeId,
  compEndDate,
  SUM(CASE WHEN pos = 1 THEN 1 ELSE 0 END) `count_winners`,
  GROUP_CONCAT((CASE WHEN pos = 1 AND best > 0 THEN personId END) ORDER BY personId) winner,
  SUM(CASE WHEN pos = 1 AND formatId IN ('a','m') THEN average WHEN pos = 1 THEN best END) result,
  formatId,
  GROUP_CONCAT(CASE WHEN pos <> 1 THEN personId END) others
FROM
  wca_stats.results_extra
GROUP BY
  competitionId, eventId, roundTypeId
ORDER BY 
  eventId, MIN(id);

SET @uowc = NULL, @uowcd = '1970-01-01', @e = NULL;
DROP TABLE IF EXISTS uowc_history;
CREATE TABLE uowc_history
(id INT NOT NULL AUTO_INCREMENT, PRIMARY KEY(id))
SELECT
  b.competitionId, b.eventId, b.roundTypeId, b.compEndDate, b.winner, b.result, b.formatId, CAST(b.uowcId AS CHAR(10000) CHARACTER SET utf8) uowcId, b.dateSet
FROM
  (SELECT
    a.*,
    @uowc := 
      IF(@uowc = a.winner OR (a.winner IS NULL AND a.eventId = @e), 
        @uowc, 
        IF(others LIKE CONCAT("%",@uowc,"%"), 
          a.winner, 
          IF(a.compEndDate > DATE_ADD(@uowcd, INTERVAL 1 YEAR), 
            IFNULL((SELECT winner FROM uowc_help WHERE compEndDate = a.compEndDate AND eventId = a.eventId AND roundTypeId IN ('c','f') AND result > 0 ORDER BY (CASE WHEN eventId = '333fm' AND formatId <> 'm' THEN result * 9999 ELSE result END) LIMIT 1), @uowc), 
            IF(a.eventId <> @e,
              (SELECT winner FROM uowc_help WHERE compEndDate = a.compEndDate AND eventId = a.eventId AND result > 0 ORDER BY (CASE WHEN eventId = '333fm' AND formatId <> 'm' THEN result * 9999 ELSE result END) LIMIT 1),
              @uowc
              )
            )
          )
        ) uowcId, 
    @uowcd := IF(winner = @uowc OR (a.compEndDate > DATE_ADD(@uowcd, INTERVAL 1 YEAR) AND (SELECT IFNULL(winner,@uowc) FROM uowc_help WHERE compEndDate = a.compEndDate AND roundTypeId IN ('c','f') AND eventId = a.eventId AND result > 0 ORDER BY (CASE WHEN eventId = '333fm' AND formatId <> 'm' THEN result * 9999 ELSE result END) LIMIT 1) IS NOT NULL), compEndDate, IF(eventId = @e, @uowcd, '1970-01-01')) dateSet,
    @e := eventId
  FROM
    (SELECT * FROM uowc_help ORDER BY eventId, id) a) b;


DROP TABLE uowc_help;
--  removes all rows from uowc_history that are irrelevant (i.e. the UOWC did not compete in that competition or did not otherwise change)
SET @c = 0, @uowc = NULL, @d = '1970-01-01';
DROP TABLE IF EXISTS uowc;
CREATE TABLE uowc
(id INT NOT NULL AUTO_INCREMENT, PRIMARY KEY(id))
SELECT 
  b.uowcId, 
  b.dateSet, 
  b.eventId, 
  b.competitionId, 
  b.roundTypeId,
  b.result, 
  b.formatId 
FROM 
  (SELECT *, @c := IF(a.uowcId = a.winner AND a.uowcId IS NOT NULL, 1, 0) chang,
    @uowc := a.uowcId,
    @d := a.dateSet
    FROM
      (SELECT * FROM uowc_history ORDER BY eventId, id) a
  ORDER BY a.eventId, a.id) b
WHERE b.chang = 1
ORDER BY b.eventId, b.id;