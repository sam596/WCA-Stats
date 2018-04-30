INSERT INTO wca_stats.last_updated VALUES ('PB_Streak', NOW(), NULL, '') ON DUPLICATE KEY UPDATE started=NOW(), completed = NULL;

SET @val = 0;

drop table if exists PB_Streak;
CREATE TABLE PB_Streak
SELECT a.*, @val := IF(a.PBs = 0, 0, IF(a.personId = b.personId, @val + 1, 1)) pbStreak
FROM competition_PBs a
LEFT JOIN competition_PBs b ON a.id = b.id +1
GROUP BY a.personId, a.competitionId ORDER BY a.id ASC;

UPDATE wca_stats.last_updated SET completed = NOW() WHERE query = 'concise_results';
