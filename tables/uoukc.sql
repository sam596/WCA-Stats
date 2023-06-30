SET @h = 0, @c = '', @e = '', @r = '', @p = 0, @ukpos = 0;
DROP TABLE IF EXISTS results_extra_uk;
SET NAMES utf8mb4 COLLATE utf8mb4_0900_ai_ci;
CREATE TEMPORARY TABLE results_extra_uk
SELECT
    id, competitionId, eventId, roundTypeId, compEndDate, best, personId, formatId, average,
    @ukpos := IF(@c = competitionId COLLATE utf8mb4_0900_ai_ci 
                 AND @e = eventId COLLATE utf8mb4_0900_ai_ci
                 AND @r = roundTypeId COLLATE utf8mb4_0900_ai_ci,
                 @ukpos + @h, 1) pos,
    @h := IF(@c = competitionId COLLATE utf8mb4_0900_ai_ci
             AND @e = eventId COLLATE utf8mb4_0900_ai_ci
             AND @r = roundTypeId COLLATE utf8mb4_0900_ai_ci
             AND @p = pos COLLATE utf8mb4_0900_ai_ci,
             @h + 1, 1) h,
    @c := competitionId COLLATE utf8mb4_0900_ai_ci c,
    @e := eventId COLLATE utf8mb4_0900_ai_ci e,
    @r := roundTypeId COLLATE utf8mb4_0900_ai_ci r,
    @p := pos COLLATE utf8mb4_0900_ai_ci p
FROM
    (SELECT * FROM wca_stats.results_extra WHERE personcountryId = 'United Kingdom' COLLATE utf8mb4_0900_ai_ci ORDER BY id) a;



DROP TABLE IF EXISTS uoukc_help;
CREATE TABLE uoukc_help
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
  wca_stats.results_extra_uk
GROUP BY
  competitionId, eventId, roundTypeId
ORDER BY 
  eventId, MIN(id);

SET @uoukc = NULL, @uoukcd = '1970-01-01', @e = NULL;
DROP TABLE IF EXISTS uoukc_history;
CREATE TABLE uoukc_history
(id INT NOT NULL AUTO_INCREMENT, PRIMARY KEY(id))
SELECT
  b.competitionId, b.eventId, b.roundTypeId, b.compEndDate, b.winner, b.result, b.formatId, CAST(b.uoukcId AS CHAR(10000) CHARACTER SET utf8) uoukcId, b.dateSet
FROM
  (SELECT
    a.*,
    @uoukc := 
      IF(@uoukc = a.winner OR (a.winner IS NULL AND a.eventId COLLATE utf8mb4_0900_ai_ci = @e), 
        @uoukc, 
        IF(others LIKE CONCAT("%",@uoukc,"%"), 
          a.winner, 
          IF(a.compEndDate > DATE_ADD(@uoukcd, INTERVAL 1 YEAR), 
            IFNULL((SELECT winner FROM uoukc_help WHERE compEndDate = a.compEndDate AND eventId = a.eventId AND roundTypeId IN ('c','f') AND result > 0 ORDER BY (CASE WHEN eventId = '333fm' AND formatId <> 'm' THEN result * 9999 ELSE result END) LIMIT 1), @uoukc), 
            IF(a.eventId COLLATE utf8mb4_0900_ai_ci <> @e,
              (SELECT winner FROM uoukc_help WHERE compEndDate = a.compEndDate AND eventId = a.eventId AND result > 0 ORDER BY (CASE WHEN eventId = '333fm' AND formatId <> 'm' THEN result * 9999 ELSE result END) LIMIT 1) COLLATE utf8mb4_0900_ai_ci,
              @uoukc
              )
            )
          )
        ) uoukcId, 
    @uoukcd := IF(winner = @uoukc OR (a.compEndDate > DATE_ADD(@uoukcd, INTERVAL 1 YEAR) AND (SELECT IFNULL(winner,@uoukc) FROM uoukc_help WHERE compEndDate = a.compEndDate AND roundTypeId IN ('c','f') AND eventId = a.eventId AND result > 0 ORDER BY (CASE WHEN eventId = '333fm' AND formatId <> 'm' THEN result * 9999 ELSE result END) LIMIT 1) IS NOT NULL), compEndDate, IF(eventId COLLATE utf8mb4_0900_ai_ci = @e, @uoukcd, '1970-01-01')) dateSet,
    @e := eventId COLLATE utf8mb4_0900_ai_ci
  FROM
    (SELECT * FROM uoukc_help ORDER BY eventId, id) a) b;


DROP TABLE uoukc_help;
--  removes all rows from uoukc_history that are irrelevant (i.e. the uoukc did not compete in that competition or did not otherwise change)
SET @c = 0, @uoukc = NULL, @d = '1970-01-01';
DROP TABLE IF EXISTS uoukc;
CREATE TABLE uoukc
(id INT NOT NULL AUTO_INCREMENT, PRIMARY KEY(id))
SELECT 
  b.uoukcId, 
  b.dateSet, 
  b.eventId, 
  b.competitionId, 
  b.roundTypeId,
  b.result, 
  b.formatId 
FROM 
  (SELECT *, @c := IF(a.uoukcId = a.winner AND a.uoukcId IS NOT NULL, 1, 0) chang,
    @uoukc := a.uoukcId,
    @d := a.dateSet
    FROM
      (SELECT * FROM uoukc_history ORDER BY eventId, id) a
  ORDER BY a.eventId, a.id) b
WHERE b.chang = 1
ORDER BY b.eventId, b.id;