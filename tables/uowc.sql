INSERT INTO wca_stats.last_updated VALUES ('uowc', NOW(), NULL, '') ON DUPLICATE KEY UPDATE started=NOW(), completed = NULL;

-- list of rounds with winner(s) and then all the other competitors in a group_concat
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
  wca_stats.results_extra
GROUP BY
  competitionId, eventId, roundTypeId
ORDER BY 
  eventId, MIN(id);

# 1 min 20 secs
--  if the reigning UOWC is the winner, or there was no winner, the reigning UOWC remains the same. Otherwise, if the UOWC is in the others, then the winner becomes UOWC. Otherwise, if 1 year has passed since the UOWC last competed, pick the best result of the finals that take place in the following weekend. If there was no results in that event that weekend, the UOWC remains. In this case, only FMC means are considered.
SET @uowc = NULL, @uowcd = '1970-01-01', @e = NULL;
DROP TABLE IF EXISTS uowc_history;
CREATE TABLE uowc_history
(id INT NOT NULL AUTO_INCREMENT, PRIMARY KEY(id))
SELECT
  b.competitionId, b.eventId, b.roundTypeId, b.date, b.winner, b.result, b.formatId, b.uowcId, b.dateSet
FROM
  (SELECT
    a.*,
    @uowc := 
      IF(@uowc = a.winner OR (a.winner IS NULL AND a.eventId = @e), 
        @uowc, 
        IF(others LIKE CONCAT("%",@uowc,"%"), 
          a.winner, 
          IF(a.date > DATE_ADD(@uowcd, INTERVAL 1 YEAR), 
            IFNULL((SELECT winner FROM uowc_help WHERE date = a.date AND eventId = a.eventId AND roundTypeId IN ('c','f') AND result > 0 ORDER BY (CASE WHEN eventId = '333fm' AND formatId <> 'm' THEN result * 9999 ELSE result END) LIMIT 1), @uowc), 
            IF(a.eventId <> @e,
              (SELECT winner FROM uowc_help WHERE date = a.date AND eventId = a.eventId AND result > 0 ORDER BY (CASE WHEN eventId = '333fm' AND formatId <> 'm' THEN result * 9999 ELSE result END) LIMIT 1),
              @uowc
              )
            )
          )
        ) uowcId,   
    @uowcd := IF(winner = @uowc OR (a.date > DATE_ADD(@uowcd, INTERVAL 1 YEAR) AND (SELECT IFNULL(winner,@uowc) FROM uowc_help WHERE date = a.date AND roundTypeId IN ('c','f') AND eventId = a.eventId AND result > 0 ORDER BY (CASE WHEN eventId = '333fm' AND formatId <> 'm' THEN result * 9999 ELSE result END) LIMIT 1) IS NOT NULL), date, IF(eventId = @e, @uowcd, '1970-01-01')) dateSet,
    @e := eventId
  FROM
    (SELECT * FROM uowc_help ORDER BY eventId, id) a) b;

# ~ 10 sec

DROP TABLE uowc_help;
--  removes all rows from uowc_history that are irrelevant (i.e. the UOWC did not compete in that competition or did not otherwise change)
SET @c = 0, @uowc = NULL @d = '1970-01-01';
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

# <10 secs

UPDATE wca_stats.last_updated SET completed = NOW() WHERE query = 'uowc';


INSERT INTO wca_stats.last_updated VALUES ('uoukc', NOW(), NULL, '') ON DUPLICATE KEY UPDATE started=NOW(), completed = NULL;
--  creates a clone of results_extra if Boris Johnson got his way
SET @h = 0, @c = '', @e = '', @r = '', @p = 0, @ukpos = 0;
CREATE TEMPORARY TABLE results_extra_uk
SELECT
    id, competitionId, eventId, roundTypeId, date, best, personId, formatId, average,
    @ukpos := IF(@c = competitionId AND @e = eventId AND @r = roundTypeId, @ukpos + @h, 1) pos,
    @h := IF(@c = competitionId AND @e = eventId AND @r = roundTypeId AND @p = pos, @h + 1, 1) h,
    @c := competitionId c,
    @e := eventId e,
    @r := roundTypeId r,
    @p := pos p
  FROM
    (SELECT * FROM wca_stats.results_extra WHERE personcountryId = 'United Kingdom' ORDER BY id) a;
--  code as above, but only on the UK competitors in results_extra_uk
DROP TABLE IF EXISTS uoukc_help;
CREATE TABLE uoukc_help
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
  wca_stats.results_extra_uk
GROUP BY
  competitionId, eventId, roundTypeId
ORDER BY 
  eventId, MIN(id);

# 1 min 20 secs

SET @uoukc = NULL, @uoukcd = '1970-01-01', @e = NULL;
DROP TABLE IF EXISTS uoukc_history;
CREATE TABLE uoukc_history
(id INT NOT NULL AUTO_INCREMENT, PRIMARY KEY(id))
SELECT
  b.competitionId, b.eventId, b.roundTypeId, b.date, b.winner, b.result, b.formatId, b.uoukcId, b.dateSet
FROM
  (SELECT
    a.*,
    @uoukc := 
      IF(@uoukc = a.winner OR (a.winner IS NULL AND a.eventId = @e), 
        @uoukc, 
        IF(others LIKE CONCAT("%",@uoukc,"%"), 
          a.winner, 
          IF(a.date > DATE_ADD(@uoukcd, INTERVAL 1 YEAR), 
            IFNULL((SELECT winner FROM uoukc_help WHERE date = a.date AND eventId = a.eventId AND roundTypeId IN ('c','f') AND result > 0 ORDER BY (CASE WHEN eventId = '333fm' AND formatId <> 'm' THEN result * 9999 ELSE result END) LIMIT 1), @uoukc), 
            IF(a.eventId <> @e,
              (SELECT winner FROM uoukc_help WHERE date = a.date AND eventId = a.eventId AND result > 0 ORDER BY (CASE WHEN eventId = '333fm' AND formatId <> 'm' THEN result * 9999 ELSE result END) LIMIT 1),
              @uoukc
              )
            )
          )
        ) uoukcId,   
    @uoukcd := IF(winner = @uoukc OR (a.date > DATE_ADD(@uoukcd, INTERVAL 1 YEAR) AND (SELECT IFNULL(winner,@uoukc) FROM uoukc_help WHERE date = a.date AND roundTypeId IN ('c','f') AND eventId = a.eventId AND result > 0 ORDER BY (CASE WHEN eventId = '333fm' AND formatId <> 'm' THEN result * 9999 ELSE result END) LIMIT 1) IS NOT NULL), date, IF(eventId = @e, @uoukcd, '1970-01-01')) dateSet,
    @e := eventId
  FROM
    (SELECT * FROM uoukc_help ORDER BY eventId, id) a) b;

# ~ 10 sec

DROP TABLE uoukc_help;

SET @c = 0, @uoukc = NULL @d = '1970-01-01';
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

# <10 secs

UPDATE wca_stats.last_updated SET completed = NOW() WHERE query = 'uoukc';
