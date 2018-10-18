/*First of all, this is for WFC's dues project, which I allow them access to the server for.*/
DROP TABLE IF EXISTS wfc_dues.competitions;
CREATE TABLE wfc_dues.competitions
SELECT a.id, a.name, a.countryId, e.continentId, a.start_date, a.end_date, a.announced_at, a.results_posted_at, CONCAT("https://www.worldcubeassociation.org/competitions/",a.id) WCAlink, b.number_of_competitors, GROUP_CONCAT(DISTINCT d.name SEPARATOR ", ") delegates
FROM wca_dev.Competitions as a 
LEFT JOIN (SELECT competitionId, COUNT(DISTINCT personId) number_of_competitors FROM wca_dev.Results GROUP BY competitionId) as b on a.id=b.competitionId
LEFT JOIN wca_dev.competition_delegates c ON a.id = c.competition_id
LEFT JOIN (SELECT id, name FROM wca_dev.users WHERE id IN (SELECT delegate_id FROM wca_dev.competition_delegates)) d ON c.delegate_id = d.id
LEFT JOIN wca_dev.Countries e ON a.countryId = e.id
WHERE year>0 GROUP BY a.id ORDER BY start_date;

# ~ 15 seconds

INSERT INTO wca_stats.last_updated VALUES ('results_extra', NOW(), NULL, '') ON DUPLICATE KEY UPDATE started=NOW(), completed = NULL;

DROP TABLE IF EXISTS results_extra;
CREATE TABLE results_extra 
(id INT NOT NULL AUTO_INCREMENT, 
PRIMARY KEY(id), 
KEY results_extra_person (personId),
KEY results_extra_comp (competitionId),
KEY results_extra_event (eventId),
KEY results_extra_round (roundTypeId),
KEY results_extra_peventavg (personId,eventId,average),
KEY results_extra_peventsgl (personId,eventId,best),
KEY results_extra_avgall (personId,competitionId,eventId,roundTypeId,average),
KEY results_extra_sglall (personId,competitionId,eventId,roundTypeId,best))
  SELECT 
  	r.personId, 
  	r.personName, 
  	r.countryId personCountryId, 
  	c.continentId personContinentId, 
  	r.competitionId, 
    	comps.countryId compCountryId,
	comps.continentId compContinentId,
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
  	wca_stats.competitions_extra comps 
  ON 
  	comps.id = r.competitionId
  JOIN
  	wca_dev.countries c
  ON 
  	c.id = r.countryId
  ORDER BY 
	date ASC, 
	competitionId ASC,
	eventId ASC, 
	FIELD(roundTypeId,"h","0","d","1","b","2","e","g","3","c","f") ASC, 
	pos ASC
;

# ~ 10 mins

UPDATE wca_stats.last_updated SET completed = NOW() WHERE query = 'results_extra';

INSERT INTO wca_stats.last_updated VALUES ('podiums', NOW(), NULL, '') ON DUPLICATE KEY UPDATE started=NOW(), completed = NULL;

DROP TABLE IF EXISTS podiums;
CREATE TABLE podiums 
(id INT NOT NULL AUTO_INCREMENT, 
PRIMARY KEY(id), 
KEY results_extra_person (personId),
KEY results_extra_comp (competitionId),
KEY results_extra_event (eventId),
KEY results_extra_round (roundTypeId),
KEY results_extra_eventavg (eventId,average),
KEY results_extra_eventsgl (eventId,best),
KEY results_extra_avgall (personId,competitionId,eventId,roundTypeId,average),
KEY results_extra_sglall (personId,competitionId,eventId,roundTypeId,best))
SELECT * FROM results_extra WHERE roundTypeId IN ('c','f') AND pos <= 3 AND best > 0;

# 20 secs

DROP TABLE IF EXISTS wca_stats.podium_sums;
CREATE TABLE wca_stats.podium_sums
SELECT competitionId, eventId, SUM(result), GROUP_CONCAT(personId ORDER BY pos) personIds, GROUP_CONCAT(result ORDER BY pos) results
FROM (SELECT competitionId, eventId, pos, personId, personname, (CASE WHEN eventId LIKE '%bf' THEN best ELSE average END) result
FROM podiums WHERE (CASE WHEN eventId LIKE '%bf' THEN best ELSE average END) > 0) a GROUP BY competitionId, eventId HAVING COUNT(*) = 3;

# <5 secs

UPDATE wca_stats.last_updated SET completed = NOW() WHERE query = 'podiums';
