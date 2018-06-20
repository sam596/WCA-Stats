INSERT INTO wca_stats.last_updated VALUES ('result_dates', NOW(), NULL, '') ON DUPLICATE KEY UPDATE started=NOW(), completed = NULL;

DROP TABLE IF EXISTS result_dates;
CREATE TABLE result_dates 
(id INT NOT NULL AUTO_INCREMENT, 
PRIMARY KEY(id), 
KEY result_dates_person (personId),
KEY result_dates_comp (competitionId),
KEY result_dates_event (eventId),
KEY result_dates_round (roundTypeId),
KEY result_dates_eventavg (eventId,average),
KEY result_dates_eventsgl (eventId,best),
KEY result_dates_avgall (personId,competitionId,eventId,roundTypeId,average),
KEY result_dates_sglall (personId,competitionId,eventId,roundTypeId,best))
  SELECT 
  	r.personId, 
  	r.personName, 
  	r.CountryId, 
  	c.continentId, 
  	r.competitionId, 
  	r.eventId, 
  	r.roundTypeId, 
  	r.formatId, 
  	r.pos, 
  	r.average, 
  	r.best, 
  	r.regionalAverageRecord, 
  	r.regionalSingleRecord,
  	r.value1,
  	r.value2,
  	r.value3,
  	r.value4,
  	r.value5,
  	@date := DATE(CONCAT(year, '-', month, '-', day)) date,
 	@weekend := DATE_SUB(@date, INTERVAL (DAYOFWEEK(@date) + 2) % 7 DAY) weekend
  FROM 
  	wca_dev.results r
  JOIN 
  	wca_dev.competitions comps 
  ON 
  	comps.id = r.competitionId
  JOIN (
  	SELECT 
  		Countries.id, 
  		Continents.recordName continentId 
  	FROM 
  		wca_dev.Countries 
  	LEFT JOIN 
  		wca_dev.Continents 
  	ON 
  		Countries.continentid = Continents.id
  	) c 
  ON 
  	c.id = r.countryId
  ORDER BY 
	date ASC, 
	competitionId ASC,
	eventId ASC, 
	FIELD(roundTypeId,"h","0","d","1","b","2","e","g","3","c","f") ASC, 
	pos ASC
;

UPDATE wca_stats.last_updated SET completed = NOW() WHERE query = 'result_dates';

INSERT INTO wca_stats.last_updated VALUES ('podiums', NOW(), NULL, '') ON DUPLICATE KEY UPDATE started=NOW(), completed = NULL;

DROP TABLE IF EXISTS podiums;
CREATE TABLE podiums 
(id INT NOT NULL AUTO_INCREMENT, 
PRIMARY KEY(id), 
KEY result_dates_person (personId),
KEY result_dates_comp (competitionId),
KEY result_dates_event (eventId),
KEY result_dates_round (roundTypeId),
KEY result_dates_eventavg (eventId,average),
KEY result_dates_eventsgl (eventId,best),
KEY result_dates_avgall (personId,competitionId,eventId,roundTypeId,average),
KEY result_dates_sglall (personId,competitionId,eventId,roundTypeId,best))
SELECT * FROM result_dates WHERE roundTypeId IN ('c','f') AND pos <= 3 AND best > 0;

DROP TABLE IF EXISTS wca_stats.podiumsums;
CREATE TABLE wca_stats.podiumsums
SELECT competitionId, eventId, SUM(result), GROUP_CONCAT(personId ORDER BY pos) personIds, GROUP_CONCAT(result ORDER BY pos) results
FROM (SELECT competitionId, eventId, pos, personId, personname, (CASE WHEN eventId LIKE '%bf' THEN best ELSE average END) result
FROM podiums WHERE (CASE WHEN eventId LIKE '%bf' THEN best ELSE average END) > 0) a GROUP BY competitionId, eventId HAVING COUNT(*) = 3;

UPDATE wca_stats.last_updated SET completed = NOW() WHERE query = 'podiums';
