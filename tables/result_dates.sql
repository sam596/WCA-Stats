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

INSERT INTO wca_stats.last_updated VALUES ('result_dates', NOW(), NULL, '') ON DUPLICATE KEY UPDATE started=NOW(), completed = NULL;

DROP TABLE IF EXISTS result_dates;
CREATE TABLE result_dates 
(id INT NOT NULL AUTO_INCREMENT, 
PRIMARY KEY(id), 
KEY result_dates_person (personId),
KEY result_dates_comp (competitionId),
KEY result_dates_event (eventId),
KEY result_dates_round (roundTypeId),
KEY result_dates_peventavg (personId,eventId,average),
KEY result_dates_peventsgl (personId,eventId,best),
KEY result_dates_avgall (personId,competitionId,eventId,roundTypeId,average),
KEY result_dates_sglall (personId,competitionId,eventId,roundTypeId,best))
  SELECT 
  	r.personId, 
  	r.personName, 
  	r.countryId, 
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

DROP TABLE IF EXISTS wca_stats.podium_sums;
CREATE TABLE wca_stats.podium_sums
SELECT competitionId, eventId, SUM(result), GROUP_CONCAT(personId ORDER BY pos) personIds, GROUP_CONCAT(result ORDER BY pos) results
FROM (SELECT competitionId, eventId, pos, personId, personname, (CASE WHEN eventId LIKE '%bf' THEN best ELSE average END) result
FROM podiums WHERE (CASE WHEN eventId LIKE '%bf' THEN best ELSE average END) > 0) a GROUP BY competitionId, eventId HAVING COUNT(*) = 3;

UPDATE wca_stats.last_updated SET completed = NOW() WHERE query = 'podiums';
