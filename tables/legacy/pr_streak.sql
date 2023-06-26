INSERT INTO wca_stats.last_updated VALUES ('pr_streak', NOW(), NULL, '') ON DUPLICATE KEY UPDATE started=NOW(), completed = NULL;
-- creates a counter that increases every comp if a PR was set
SET @val = 0, @pid = NULL, @scomp = NULL, @ecomp = NULL;
DROP TABLE IF EXISTS pr_streak;
CREATE TABLE pr_streak
(id INT NOT NULL AUTO_INCREMENT, PRIMARY KEY (id),
 KEY pc (personId, competitionId, prStreak),
 KEY ps (personId, prStreak, competitionId))
SELECT a.*, 
        @val := IF(a.PRs = 0, 0, IF(a.personId = @pid, @val + 1, 1)) prStreak,
        @scomp := IF(@val = 0, NULL, IF(@val = 1, competitionId, @scomp)) startComp,
        @ecomp := IF(@val = 0, NULL, competitionId) endComp,
        @pid := personId pidhelp
FROM (SELECT * FROM competition_PRs ORDER BY id ASC) a
GROUP BY a.personId, a.competitionId ORDER BY a.id ASC;

# ~ 25 secs
-- as above excluding FMC only comps
SET @val = 0, @pid = NULL, @scomp = NULL, @ecomp = NULL;
DROP TABLE IF EXISTS pr_streak_exfmc;
CREATE TABLE pr_streak_exfmc
(id INT NOT NULL AUTO_INCREMENT, PRIMARY KEY (id),
 KEY pc (personId, competitionId, prStreak),
 KEY ps (personId, prStreak, competitionId))
SELECT a.*, 
        @val := IF(a.PRs = 0, 0, IF(a.personId = @pid, @val + 1, 1)) prStreak,
        @scomp := IF(@val = 0, NULL, IF(@val = 1, competitionId, @scomp)) startComp,
        @ecomp := IF(@val = 0, NULL, competitionId) endComp,
        @pid := personId pidhelp
FROM (SELECT * FROM competition_PRs_exFMC ORDER BY id ASC) a
GROUP BY a.personId, a.competitionId ORDER BY a.id ASC;

# ~ 25 secs
-- as above excluding FMC and/or BLD only comps
SET @val = 0, @pid = NULL, @scomp = NULL, @ecomp = NULL;
DROP TABLE IF EXISTS pr_streak_exfmcbld;
CREATE TABLE pr_streak_exfmcbld
(id INT NOT NULL AUTO_INCREMENT, PRIMARY KEY (id),
 KEY pc (personId, competitionId, prStreak),
 KEY ps (personId, prStreak, competitionId))
SELECT a.*, 
        @val := IF(a.PRs = 0, 0, IF(a.personId = @pid, @val + 1, 1)) prStreak,
        @scomp := IF(@val = 0, NULL, IF(@val = 1, competitionId, @scomp)) startComp,
        @ecomp := IF(@val = 0, NULL, competitionId) endComp,
        @pid := personId pidhelp
FROM (SELECT * FROM competition_PRs_exFMCBLD ORDER BY id ASC) a
GROUP BY a.personId, a.competitionId ORDER BY a.id ASC;

# ~ 25 secs

UPDATE wca_stats.last_updated SET completed = NOW() WHERE query = 'pr_streak';
