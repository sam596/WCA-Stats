INSERT INTO wca_stats.last_updated VALUES ('championship_podiums', NOW(), NULL, '') ON DUPLICATE KEY UPDATE started=NOW(), completed = NULL;

DROP TABLE IF EXISTS wca_stats.ChampPodiumHelp;
SET @cPos := 0;
SET @cId = NULL;
SET @champ = NULL;
SET @eId = NULL;
CREATE TABLE wca_stats.ChampPodiumHelp
(id INT NOT NULL AUTO_INCREMENT,
 PRIMARY KEY (id),
 KEY cpos (cPos),
 KEY cphorder (championship_type, competitionId, eventId, cPos))
SELECT a.*,
    @cPos := IF(@cId = a.competitionId AND @champ = a.championship_type AND @eId = a.eventId, @cPos +1, 1) 'cPos',
    @cId := a.competitionId, @champ := a.championship_type, @eId := a.eventId
FROM (SELECT a.competitionId, a.eventId, a.pos, a.best, a.average, a.personId, a.personName, a.countryId, a.formatId, a.value1, a.value2, a.value3, a.value4, a.value5,
        b.championship_type, c.continentId
    FROM (SELECT * FROM wca_dev.results WHERE best > 0 AND roundTypeId IN ('c','f')) a
    JOIN (SELECT * FROM wca_dev.championships) b
    ON a.competitionId = b.competition_id
    JOIN (SELECT * FROM wca_dev.Countries) c
    ON a.countryId = c.id
        AND (b.championship_type = c.iso2 OR b.championship_type = c.continentId OR b.championship_type = 'world' OR (b.championship_type = 'greater_china' AND c.iso2 IN ('CN','HK','MO','TW')))
    ORDER BY competitionId, championship_type, eventId, pos ASC) a;

DROP TABLE IF EXISTS wca_stats.championship_podiums;
CREATE TABLE wca_stats.championship_podiums
(id INT NOT NULL AUTO_INCREMENT,
 PRIMARY KEY (id),
 KEY perstypecpos (personId, championship_type, cPos),
 KEY comp (competitionId))
    SELECT personId, personName, countryId, championship_type, competitionId, eventId, cPos, pos, (CASE WHEN average > 0 AND formatId IN ('a','m') THEN average ELSE best END) 'result', formatId
    FROM wca_stats.ChampPodiumHelp WHERE cPos <= 3
   	ORDER BY championship_type, competitionId, eventId, cPos;
    
DROP TABLE wca_stats.ChampPodiumHelp;    
    
UPDATE wca_stats.last_updated SET completed = NOW() WHERE query = 'championship_podiums';
    
