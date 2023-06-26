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
	comps.cityName compCityName,
    comps.countryId compCountryId,
	d.continentId compContinentId,
  	r.eventId, 
  	r.roundTypeId, 
  	r.formatId, 
  	r.pos, 
  	IF(r.eventId IN ('444bf','555bf') AND value1 > 0 AND value2 > 0 AND value3 > 0, ROUND((value1+value2+value3)/3,0), r.average) average, 
  	r.best, 
  	r.regionalAverageRecord, 
  	r.regionalSingleRecord,
  	r.value1,
  	r.value2,
  	r.value3,
  	r.value4,
  	r.value5,
	@date := comps.end_date date,
	@weekend := DATE_SUB(@date, INTERVAL (DAYOFWEEK(@date) + 2) % 7 DAY) weekend,
  	@weeksago := FLOOR(DATEDIFF(DATE_SUB(CURDATE(), INTERVAL (DAYOFWEEK(CURDATE()) + 2) % 7 DAY),@weekend)/7) weeksAgo
  FROM 
  	wca_dev.results r
  JOIN 
  	wca_dev.competitions comps 
  ON 
  	comps.id = r.competitionId
  JOIN
  	wca_dev.countries d
  ON
  	comps.countryId = d.id
  JOIN
  	wca_dev.countries c
  ON 
  	c.id = r.countryId
  ORDER BY 
	comps.end_date ASC, 
	r.competitionId ASC,
	r.eventId ASC, 
	(SELECT rank FROM wca_dev.roundTypes WHERE id = r.roundTypeId) ASC, 
	r.pos ASC
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

INSERT INTO wca_stats.last_updated VALUES ('final_missers', NOW(), NULL, '') ON DUPLICATE KEY UPDATE started=NOW(), completed = NULL;

DROP TABLE IF EXISTS wca_stats.final_missers;
SET @a = '', @b = '', @e = '', @c = '';
CREATE TABLE wca_stats.final_missers
SELECT 
	a.* 
FROM results_extra a 
INNER JOIN 
	(SELECT 
		a.*, 
		@a := IF(roundTypeId IN ('c','f') AND eventId = @e AND competitionId = @c, @b, NULL) precedingRound, 
		@b := roundTypeId, 
		@e := eventId, 
		@c := competitionId
	FROM
		(SELECT 
			competitionId, 
			eventId, 
			roundTypeId, 
			COUNT(*) competitors 
		FROM results_extra a 
		GROUP BY competitionId, eventId, roundTypeId 
		ORDER BY competitionId, eventId, (SELECT rank FROM wca_dev.roundTypes WHERE id = a.roundTypeId)
		) a
	) b
ON a.roundTypeId = b.precedingRound AND a.competitionId = b.competitionId AND a.eventId = b.eventId AND a.pos > b.competitors
WHERE personId NOT IN (SELECT personId FROM results_extra WHERE competitionId = a.competitionId AND eventId = a.eventId AND roundTypeId IN ('c','f'));

# ~5-6 mins

UPDATE wca_stats.last_updated SET completed = NOW() WHERE query = 'final_missers';
