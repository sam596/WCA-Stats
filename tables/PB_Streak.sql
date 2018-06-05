INSERT INTO wca_stats.last_updated VALUES ('PB_Streak', NOW(), NULL, '') ON DUPLICATE KEY UPDATE started=NOW(), completed = NULL;

SET @val = 0;
SET @pid = NULL;
SET @scomp = NULL;
SET @ecomp = NULL;
DROP TABLE IF EXISTS PB_Streak;
CREATE TABLE PB_Streak
SELECT a.*, 
        @val := IF(a.PBs = 0, 0, IF(a.personId = @pid, @val + 1, 1)) pbStreak,
        @scomp := IF(@val = 0, NULL, IF(@val = 1, competitionId, @scomp)) startComp,
        @ecomp := IF(@val = 0, NULL, competitionId) endComp,
        @pid := personId pidhelp
FROM (SELECT * FROM competition_PBs ORDER BY id ASC) a
GROUP BY a.personId, a.competitionId ORDER BY a.id ASC;

UPDATE wca_stats.last_updated SET completed = NOW() WHERE query = 'PB_Streak';
