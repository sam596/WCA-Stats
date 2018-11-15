INSERT INTO wca_stats.last_updated VALUES ('seasons', NOW(), NULL, '') ON DUPLICATE KEY UPDATE started=NOW(), completed = NULL;

DROP TABLE IF EXISTS wca_stats.seasons;
CREATE TABLE wca_stats.seasons
SELECT p.id, p.name, p.countryId, r.*
FROM persons_extra p 
JOIN 
  (SELECT personId, YEAR(date) year, 
    MIN(CASE WHEN eventId = '333' AND best > 0 THEN best END) 333s,
    MIN(CASE WHEN eventId = '222' AND best > 0 THEN best END) 222s,
    MIN(CASE WHEN eventId = '444' AND best > 0 THEN best END) 444s,
    MIN(CASE WHEN eventId = '555' AND best > 0 THEN best END) 555s,
    MIN(CASE WHEN eventId = '666' AND best > 0 THEN best END) 666s,
    MIN(CASE WHEN eventId = '777' AND best > 0 THEN best END) 777s,
    MIN(CASE WHEN eventId = '333bf' AND best > 0 THEN best END) 333bfs,
    MIN(CASE WHEN eventId = '333fm' AND best > 0 THEN best END) 333fms,
    MIN(CASE WHEN eventId = '333ft' AND best > 0 THEN best END) 333fts,
    MIN(CASE WHEN eventId = '333oh' AND best > 0 THEN best END) 333ohs,
    MIN(CASE WHEN eventId = 'clock' AND best > 0 THEN best END) clocks,
    MIN(CASE WHEN eventId = 'minx' AND best > 0 THEN best END) minxs,
    MIN(CASE WHEN eventId = 'pyram' AND best > 0 THEN best END) pyrams,
    MIN(CASE WHEN eventId = 'skewb' AND best > 0 THEN best END) skewbs,
    MIN(CASE WHEN eventId = 'sq1' AND best > 0 THEN best END) sq1s,
    MIN(CASE WHEN eventId = '444bf' AND best > 0 THEN best END) 444bfs,
    MIN(CASE WHEN eventId = '555bf' AND best > 0 THEN best END) 555bfs,
    MIN(CASE WHEN eventId = '333mbf' AND best > 0 THEN best END) 333mbfs,
    MIN(CASE WHEN eventId = '333mbo' AND best > 0 THEN best END) 333mbos,
    MIN(CASE WHEN eventId = 'magic' AND best > 0 THEN best END) magics,
    MIN(CASE WHEN eventId = 'mmagic' AND best > 0 THEN best END) mmagics,
    MIN(CASE WHEN eventId = '333' AND average > 0 THEN average END) 333a,
    MIN(CASE WHEN eventId = '222' AND average > 0 THEN average END) 222a,
    MIN(CASE WHEN eventId = '444' AND average > 0 THEN average END) 444a,
    MIN(CASE WHEN eventId = '555' AND average > 0 THEN average END) 555a,
    MIN(CASE WHEN eventId = '666' AND average > 0 THEN average END) 666a,
    MIN(CASE WHEN eventId = '777' AND average > 0 THEN average END) 777a,
    MIN(CASE WHEN eventId = '333bf' AND average > 0 THEN average END) 333bfa,
    MIN(CASE WHEN eventId = '333fm' AND average > 0 THEN average END) 333fma,
    MIN(CASE WHEN eventId = '333ft' AND average > 0 THEN average END) 333fta,
    MIN(CASE WHEN eventId = '333oh' AND average > 0 THEN average END) 333oha,
    MIN(CASE WHEN eventId = 'clock' AND average > 0 THEN average END) clocka,
    MIN(CASE WHEN eventId = 'minx' AND average > 0 THEN average END) minxa,
    MIN(CASE WHEN eventId = 'pyram' AND average > 0 THEN average END) pyrama,
    MIN(CASE WHEN eventId = 'skewb' AND average > 0 THEN average END) skewba,
    MIN(CASE WHEN eventId = 'sq1' AND average > 0 THEN average END) sq1a,
    MIN(CASE WHEN eventId = 'magic' AND average > 0 THEN average END) magica,
    MIN(CASE WHEN eventId = 'mmagic' AND average > 0 THEN average END) mmagica
  FROM results_extra 
  GROUP BY personId, YEAR(date)) r 
ON p.id = r.personId;

#  DROP PROCEDURE IF EXISTS seasonrankupd;
#  DELIMITER ;;
#  CREATE PROCEDURE seasonrankupd(IN eventform VARCHAR(16))
#  BEGIN
#    SET @sql = CONCAT('ALTER TABLE seasons ADD COLUMN ', eventform, 'Rank INT AFTER ', eventform, ';');
#    PREPARE stmt FROM @sql;
#    EXECUTE stmt;
#    DEALLOCATE PREPARE stmt;
#    SET @y = @v = @i = @c = 0;
#    SET @sql = CONCAT('UPDATE seasons JOIN (SELECT *, @i := IF(@y = year,IF(@v = ', eventform, ', @i, @iRank,0) + IFNULL(@c), 1) initrank, @c := IF(@y = year,IF(@v = ', eventform, ', @cRank,0) + IFNULL(1, 1), 1) counter, @y := year, @v := ', eventform, ' val FROM (SELECT * FROM seasons WHERE ', eventform, ' IS NOT NULL ORDER BY year, ', eventform, ', personId) a) rank ON seasons.personId = rank.personId AND seasons.year = rank.year SET seasons.', eventform, 'Rank = rank.initrank;');
#    PREPARE stmt FROM @sql;
#    EXECUTE stmt;
#    DEALLOCATE PREPARE stmt;
#  END;
#  ;;
#  DELIMITER ;

CALL seasonrankupd('333s');
CALL seasonrankupd('222s');
CALL seasonrankupd('444s');
CALL seasonrankupd('555s');
CALL seasonrankupd('666s');
CALL seasonrankupd('777s');
CALL seasonrankupd('333bfs');
CALL seasonrankupd('333fms');
CALL seasonrankupd('333fts');
CALL seasonrankupd('333ohs');
CALL seasonrankupd('clocks');
CALL seasonrankupd('minxs');
CALL seasonrankupd('pyrams');
CALL seasonrankupd('skewbs');
CALL seasonrankupd('sq1s');
CALL seasonrankupd('444bfs');
CALL seasonrankupd('555bfs');
CALL seasonrankupd('333mbfs');
CALL seasonrankupd('333mbos');
CALL seasonrankupd('magics');
CALL seasonrankupd('mmagics');
CALL seasonrankupd('333a');
CALL seasonrankupd('222a');
CALL seasonrankupd('444a');
CALL seasonrankupd('555a');
CALL seasonrankupd('666a');
CALL seasonrankupd('777a');
CALL seasonrankupd('333bfa');
CALL seasonrankupd('333fma');
CALL seasonrankupd('333fta');
CALL seasonrankupd('333oha');
CALL seasonrankupd('clocka');
CALL seasonrankupd('minxa');
CALL seasonrankupd('pyrama');
CALL seasonrankupd('skewba');
CALL seasonrankupd('sq1a');
CALL seasonrankupd('magica');
CALL seasonrankupd('mmagica');

DROP PROCEDURE IF EXISTS seasonranknulls;
DELIMITER ;;
CREATE PROCEDURE seasonranknulls(IN eventform VARCHAR(16))
BEGIN
  SET @sql = CONCAT('UPDATE seasons JOIN (SELECT year, MAX(', eventform, 'rank) max FROM seasons GROUP BY year) max ON seasons.year = max.year SET seasons.', eventform, 'rank = max.max WHERE seasons.', eventform, 'rank IS NULL;');
  PREPARE stmt FROM @sql;
  EXECUTE stmt;
  DEALLOCATE PREPARE stmt;
END;
;;
DELIMITER ;

CALL seasonranknulls('333s');
CALL seasonranknulls('222s');
CALL seasonranknulls('444s');
CALL seasonranknulls('555s');
CALL seasonranknulls('666s');
CALL seasonranknulls('777s');
CALL seasonranknulls('333bfs');
CALL seasonranknulls('333fms');
CALL seasonranknulls('333fts');
CALL seasonranknulls('333ohs');
CALL seasonranknulls('clocks');
CALL seasonranknulls('minxs');
CALL seasonranknulls('pyrams');
CALL seasonranknulls('skewbs');
CALL seasonranknulls('sq1s');
CALL seasonranknulls('444bfs');
CALL seasonranknulls('555bfs');
CALL seasonranknulls('333mbfs');
CALL seasonranknulls('333mbos');
CALL seasonranknulls('magics');
CALL seasonranknulls('mmagics');
CALL seasonranknulls('333a');
CALL seasonranknulls('222a');
CALL seasonranknulls('444a');
CALL seasonranknulls('555a');
CALL seasonranknulls('666a');
CALL seasonranknulls('777a');
CALL seasonranknulls('333bfa');
CALL seasonranknulls('333fma');
CALL seasonranknulls('333fta');
CALL seasonranknulls('333oha');
CALL seasonranknulls('clocka');
CALL seasonranknulls('minxa');
CALL seasonranknulls('pyrama');
CALL seasonranknulls('skewba');
CALL seasonranknulls('sq1a');
CALL seasonranknulls('magica');
CALL seasonranknulls('mmagica');

ALTER TABLE seasons ADD COLUMN sor INT AFTER year, ADD COLUMN sorRank INT AFTER sor;

UPDATE seasons 
  SET sor = (IFNULL(333sRank,0) + IFNULL(222sRank,0) + IFNULL(444sRank,0) + IFNULL(555sRank,0) + IFNULL(666sRank,0) + IFNULL(777sRank,0) + IFNULL(333bfsRank,0) + IFNULL(333fmsRank,0) + IFNULL(333ftsRank,0) + IFNULL(333ohsRank,0) + IFNULL(clocksRank,0) + IFNULL(minxsRank,0) + IFNULL(pyramsRank,0) + IFNULL(skewbsRank,0) + IFNULL(sq1sRank,0) + IFNULL(444bfsRank,0) + IFNULL(555bfsRank,0) + IFNULL(333mbfsRank,0) + IFNULL(333mbosRank,0) + IFNULL(magicsRank,0) + IFNULL(mmagicsRank,0) + IFNULL(333aRank,0) + IFNULL(222aRank,0) + IFNULL(444aRank,0) + IFNULL(555aRank,0) + IFNULL(666aRank,0) + IFNULL(777aRank,0) + IFNULL(333bfaRank,0) + IFNULL(333fmaRank,0) + IFNULL(333ftaRank,0) + IFNULL(333ohaRank,0) + IFNULL(clockaRank,0) + IFNULL(minxaRank,0) + IFNULL(pyramaRank,0) + IFNULL(skewbaRank,0) + IFNULL(sq1aRank,0) + IFNULL(magicaRank,0) + IFNULL(mmagicaRank,0));

SET @y = @v = @i = @c = 0;
UPDATE seasons JOIN 
(SELECT *, 
  @i := IF(@y = year,IF(@v = sor, @i, @i + @c),1) Rank,
  @c := IF(@y = year,IF(@v = sor, @c + 1, 1),1) counter,
  @v := sor,
  @y := year
FROM 
  (SELECT * FROM seasons WHERE sor > 0 ORDER BY year, sor, personId) a) rank 
ON seasons.personId = rank.personId AND seasons.year = rank.year 
SET seasons.sorRank = rank.Rank;

UPDATE wca_stats.last_updated SET completed = NOW() WHERE query = 'seasons';
