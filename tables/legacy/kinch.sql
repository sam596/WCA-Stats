INSERT INTO wca_stats.last_updated VALUES ('kinch', NOW(), NULL, '') ON DUPLICATE KEY UPDATE started=NOW(), completed = NULL;

-- list of persons with their best averages in most events, best single in mbld and both 3-5bld and fmc
DROP TABLE IF EXISTS wca_stats.kinchhelpcountry;
CREATE TEMPORARY TABLE wca_stats.kinchhelpcountry
(id INT NOT NULL AUTO_INCREMENT, PRIMARY KEY(id))
SELECT personId, name, continentId, countryId, eventId, format, succeeded, result
FROM wca_stats.ranks_all 
WHERE 
((format = 'a' AND eventId IN ('333','222','444','555','333oh','minx','pyram','clock','skewb','sq1','666','777')) 
OR 
(format = 's' AND eventId = '333mbf') 
OR
(eventId IN ('333bf','444bf','555bf','333fm')))
ORDER BY countryId, eventId, format, succeeded DESC, result;

# ~ 2 mins 30 secs

-- calculate country kinch for each person/event pair
SET @Nkinch = 100, @eId = NULL, @format = NULL, @cunId = NULL, @NR = 0;
DROP TABLE IF EXISTS wca_stats.kinch_country_event;
CREATE TABLE wca_stats.kinch_country_event
SELECT personId, name, continentId, countryId, eventId, result, format, MAX(countryKinch) countryKinch
FROM  
  (SELECT a.*,
    @Nkinch := 
    IF(a.succeeded = 0, 
      0, 
      IF(a.eventId = @eId AND a.format = @format AND a.countryId = @cunId, 
        IF(a.eventId = '333mbf',
          ROUND((99-LEFT(a.result,2)+1-(MID(a.result,4,4)/3600))/(99-LEFT(@NR,2)+1-(MID(@NR,4,4)/3600))*100,2),
          ROUND((@NR/a.result)*100,2)),
        100)) countryKinch,
    @NR := IF(a.eventId = @eId AND a.format = @format AND a.countryId = @cunId, @NR, a.result) NR,
    @eId := a.eventId eid,
    @format := a.format formatH,
    @cunId := a.countryId cunId
  FROM (SELECT * FROM wca_stats.kinchhelpcountry ORDER BY id ASC) a ORDER BY countryKinch DESC) kinch
GROUP BY personId, eventId;

# ~ 2 mins 45 secs

-- averages country kinch for each person/event pair to be one value for each person
SET @curr=NULL, @rank=1, @cunId=NULL, @prev=NULL, @n=1;
DROP TABLE IF EXISTS wca_stats.kinch_country;
CREATE TABLE wca_stats.kinch_country
(PRIMARY KEY (personId))
SELECT 
  @curr := a.countryKinch curr,
  @rank := IF(@cunId = a.countryId, IF(@prev = @curr, @rank, @rank + @n), 1) rank,
  @n := IF(@cunId = a.countryId, IF(@prev = @curr, @n + 1, 1), 1) counter,
  a.*, 
  @cunId := a.countryId cunId, 
  @prev := a.countryKinch prev
FROM 
  (SELECT personId, name, continentId, countryId, ROUND(AVG(countryKinch),2) countryKinch,
      SUM(CASE WHEN eventId = '333' THEN countryKinch END) `333`,
      SUM(CASE WHEN eventId = '222' THEN countryKinch END) `222`,
      SUM(CASE WHEN eventId = '444' THEN countryKinch END) `444`,
      SUM(CASE WHEN eventId = '555' THEN countryKinch END) `555`,
      SUM(CASE WHEN eventId = '666' THEN countryKinch END) `666`,
      SUM(CASE WHEN eventId = '777' THEN countryKinch END) `777`,
      SUM(CASE WHEN eventId = '333bf' THEN countryKinch END) `333bf`,
      SUM(CASE WHEN eventId = '333fm' THEN countryKinch END) `333fm`,
      SUM(CASE WHEN eventId = '333oh' THEN countryKinch END) `333oh`,
      SUM(CASE WHEN eventId = 'clock' THEN countryKinch END) `clock`,
      SUM(CASE WHEN eventId = 'minx' THEN countryKinch END) `minx`,
      SUM(CASE WHEN eventId = 'pyram' THEN countryKinch END) `pyram`,
      SUM(CASE WHEN eventId = 'skewb' THEN countryKinch END) `skewb`,
      SUM(CASE WHEN eventId = 'sq1' THEN countryKinch END) `sq1`,
      SUM(CASE WHEN eventId = '444bf' THEN countryKinch END) `444bf`,
      SUM(CASE WHEN eventId = '555bf' THEN countryKinch END) `555bf`,
      SUM(CASE WHEN eventId = '333mbf' THEN countryKinch END) `333mbf`
    FROM wca_stats.kinch_country_event
    GROUP BY personId
    ORDER BY countryId, countryKinch DESC) a;
ALTER TABLE wca_stats.kinch_country DROP curr, DROP cunId, DROP prev, DROP counter;
-- all information in kinch_country_event is in kinch_country so this can be deleted
DROP TABLE wca_stats.kinch_country_event;
# ~ 1 min 50 secs

-- same again but per continent

DROP TABLE IF EXISTS wca_stats.kinchhelpcontinent;
CREATE TEMPORARY TABLE wca_stats.kinchhelpcontinent
(id INT NOT NULL AUTO_INCREMENT, PRIMARY KEY(id))
SELECT personId, name, continentId, countryId, eventId, format, succeeded, result
FROM wca_stats.ranks_all 
WHERE 
((format = 'a' AND eventId IN ('333','222','444','555','333oh','minx','pyram','clock','skewb','sq1','666','777')) 
OR 
(format = 's' AND eventId = '333mbf') 
OR
(eventId IN ('333bf','444bf','555bf','333fm')))
ORDER BY continentId, eventId, format, succeeded DESC, result;

# ~ 2 mins 20 secs

SET @Ckinch = 100, @eId = NULL, @format = NULL, @conId = NULL, @CR = 0;
DROP TABLE IF EXISTS wca_stats.kinch_continent_event;
CREATE TABLE wca_stats.kinch_continent_event
(id INT NOT NULL AUTO_INCREMENT, PRIMARY KEY (id), KEY event (eventId), KEY person (personId), KEY continentkinch (continentId, continentKinch))
SELECT personId, name, continentId, countryId, eventId, result, format, MAX(continentKinch) continentKinch
FROM
  (SELECT a.*,
    @Ckinch := 
    IF(a.succeeded = 0, 
      0, 
      IF(a.eventId = @eId AND a.format = @format AND a.continentId = @conId, 
        IF(a.eventId = '333mbf',
          ROUND((99-LEFT(a.result,2)+1-(MID(a.result,4,4)/3600))/(99-LEFT(@CR,2)+1-(MID(@CR,4,4)/3600))*100,2),
          ROUND((@CR/a.result)*100,2)),
        100)) continentKinch,
    @CR := IF(a.eventId = @eId AND a.format = @format AND a.continentId = @conId, @CR, a.result) CR,
    @eId := a.eventId eid,
    @format := a.format formatH,
    @conId := a.continentId conId
  FROM (SELECT * FROM wca_stats.kinchhelpcontinent ORDER BY id ASC) a ORDER BY continentKinch DESC) kinch
GROUP BY personId, eventId;

# 3 mins 20 secs

SET @curr=NULL, @rank=1, @conId=NULL, @prev=NULL, @n=1;
DROP TABLE IF EXISTS wca_stats.kinch_continent;
CREATE TABLE wca_stats.kinch_continent
(PRIMARY KEY (personId))
SELECT 
  @curr := a.continentKinch curr,
  @rank := IF(@conId = a.continentId, IF(@prev = @curr, @rank, @rank + @n), 1) rank,
  @n := IF(@cunId = a.continentId, IF(@prev = @curr, @n + 1, 1), 1) counter,
  a.*, 
  @conId := a.continentId conId, 
  @prev := a.continentKinch prev
FROM 
  (SELECT personId, name, continentId, countryId, ROUND(AVG(continentKinch),2) continentKinch,
      SUM(CASE WHEN eventId = '333' THEN continentKinch END) `333`,
      SUM(CASE WHEN eventId = '222' THEN continentKinch END) `222`,
      SUM(CASE WHEN eventId = '444' THEN continentKinch END) `444`,
      SUM(CASE WHEN eventId = '555' THEN continentKinch END) `555`,
      SUM(CASE WHEN eventId = '666' THEN continentKinch END) `666`,
      SUM(CASE WHEN eventId = '777' THEN continentKinch END) `777`,
      SUM(CASE WHEN eventId = '333bf' THEN continentKinch END) `333bf`,
      SUM(CASE WHEN eventId = '333fm' THEN continentKinch END) `333fm`,
      SUM(CASE WHEN eventId = '333oh' THEN continentKinch END) `333oh`,
      SUM(CASE WHEN eventId = 'clock' THEN continentKinch END) `clock`,
      SUM(CASE WHEN eventId = 'minx' THEN continentKinch END) `minx`,
      SUM(CASE WHEN eventId = 'pyram' THEN continentKinch END) `pyram`,
      SUM(CASE WHEN eventId = 'skewb' THEN continentKinch END) `skewb`,
      SUM(CASE WHEN eventId = 'sq1' THEN continentKinch END) `sq1`,
      SUM(CASE WHEN eventId = '444bf' THEN continentKinch END) `444bf`,
      SUM(CASE WHEN eventId = '555bf' THEN continentKinch END) `555bf`,
      SUM(CASE WHEN eventId = '333mbf' THEN continentKinch END) `333mbf`
    FROM wca_stats.kinch_continent_event
    GROUP BY personId
    ORDER BY continentId, continentKinch DESC) a;
ALTER TABLE wca_stats.kinch_continent DROP curr, DROP conId, DROP prev, DROP counter;
DROP TABLE kinch_continent_event;
# ~ 25 secs

-- same again but whole world

DROP TABLE IF EXISTS wca_stats.kinchhelpworld;
CREATE TEMPORARY TABLE wca_stats.kinchhelpworld
(id INT NOT NULL AUTO_INCREMENT, PRIMARY KEY(id))
SELECT personId, name, continentId, countryId, eventId, format, succeeded, result
FROM wca_stats.ranks_all 
WHERE 
((format = 'a' AND eventId IN ('333','222','444','555','333oh','333ft','minx','pyram','clock','skewb','sq1','666','777')) 
OR 
(format = 's' AND eventId = '333mbf') 
OR
(eventId IN ('333bf','444bf','555bf','333fm')))
ORDER BY eventId, format, succeeded DESC, result;

# ~ 25 secs

SET @Wkinch = 100, @eId = NULL, @format = NULL, @WR = 0;
DROP TABLE IF EXISTS wca_stats.kinch_world_event;
CREATE TABLE wca_stats.kinch_world_event
(id INT NOT NULL AUTO_INCREMENT, PRIMARY KEY (id), KEY event (eventId), KEY person (personId), KEY worldkinch (worldKinch))
SELECT personId, name, continentId, countryId, eventId, result, format, MAX(worldKinch) worldKinch
FROM
  (SELECT a.*,
    @Wkinch := 
    IF(a.succeeded = 0, 
      0, 
      IF(a.eventId = @eId AND a.format = @format, 
        IF(a.eventId = '333mbf',
          ROUND((99-LEFT(a.result,2)+1-(MID(a.result,4,4)/3600))/(99-LEFT(@WR,2)+1-(MID(@WR,4,4)/3600))*100,2),
          ROUND((@WR/a.result)*100,2)),
        100)) worldKinch,
    @WR := IF(a.eventId = @eId AND a.format = @format, @WR, a.result) WR,
    @eId := a.eventId eid,
    @format := a.format formatH
  FROM (SELECT * FROM wca_stats.kinchhelpworld ORDER BY id ASC) a ORDER BY worldKinch DESC) kinch
GROUP BY personId, eventId;

# ~ 3 mins 

SET @curr=NULL, @rank=1, @prev=NULL, @n=1;
DROP TABLE IF EXISTS wca_stats.kinch_world;
CREATE TABLE wca_stats.kinch_world
(PRIMARY KEY (personId))
SELECT 
  @curr := a.worldKinch curr,
  @rank := IF(@prev = @curr, @rank, @rank + @n) rank,
  @n := IF(@prev = @curr, @n + 1, 1) counter,
  a.*,
  @prev := a.worldKinch prev
FROM 
  (SELECT personId, name, continentId, countryId, ROUND(AVG(worldKinch),2) worldKinch,
      SUM(CASE WHEN eventId = '333' THEN worldKinch END) `333`,
      SUM(CASE WHEN eventId = '222' THEN worldKinch END) `222`,
      SUM(CASE WHEN eventId = '444' THEN worldKinch END) `444`,
      SUM(CASE WHEN eventId = '555' THEN worldKinch END) `555`,
      SUM(CASE WHEN eventId = '666' THEN worldKinch END) `666`,
      SUM(CASE WHEN eventId = '777' THEN worldKinch END) `777`,
      SUM(CASE WHEN eventId = '333bf' THEN worldKinch END) `333bf`,
      SUM(CASE WHEN eventId = '333fm' THEN worldKinch END) `333fm`,
      SUM(CASE WHEN eventId = '333oh' THEN worldKinch END) `333oh`,
      SUM(CASE WHEN eventId = '333ft' THEN worldKinch END) `333ft`,
      SUM(CASE WHEN eventId = 'clock' THEN worldKinch END) `clock`,
      SUM(CASE WHEN eventId = 'minx' THEN worldKinch END) `minx`,
      SUM(CASE WHEN eventId = 'pyram' THEN worldKinch END) `pyram`,
      SUM(CASE WHEN eventId = 'skewb' THEN worldKinch END) `skewb`,
      SUM(CASE WHEN eventId = 'sq1' THEN worldKinch END) `sq1`,
      SUM(CASE WHEN eventId = '444bf' THEN worldKinch END) `444bf`,
      SUM(CASE WHEN eventId = '555bf' THEN worldKinch END) `555bf`,
      SUM(CASE WHEN eventId = '333mbf' THEN worldKinch END) `333mbf`
    FROM wca_stats.kinch_world_event
    GROUP BY personId
    ORDER BY worldKinch DESC) a;
ALTER TABLE wca_stats.kinch_world DROP curr, DROP prev, DROP counter;
DROP TABLE kinch_world_event;
# ~ 25 secs
-- summarises the ranks of everyone by country, continent and world.
DROP TABLE IF EXISTS kinch;
CREATE TABLE kinch 
(PRIMARY KEY (personId)) 
SELECT w.personId, w.name, w.continentId, w.countryId, worldKinch, w.rank worldRank, continentKinch, con.rank continentRank, countryKinch, cun.rank countryRank 
FROM kinch_world w 
JOIN kinch_continent con 
  ON w.personId = con.personId 
JOIN kinch_country cun 
  ON w.personId = cun.personId;

# <10 secs

UPDATE wca_stats.last_updated SET completed = NOW() WHERE query = 'kinch';
