DROP TABLE IF EXISTS person_Comps_Extra;
SET @p = NULL, @c = 0, @dd = NULL, @d = NULL;
CREATE TABLE person_Comps_Extra
SELECT a.*,
	@c := IF(a.personId = @p,@c+1,1) 'compNumber',
	@dd := IF(a.personId = @p,DATEDIFF(a.date,@d),NULL) 'daysLastComp',
	@p := a.personId 'drop1',
	@d := a.date 'drop2'
FROM
	(SELECT a.*, b.PBs, a.singlePBs, a.averagePBs
	FROM
		(SELECT personId, personName, personCountryId, personContinentId, competitionId, compCountryId, compContinentId, date, weekend,
				COUNT(DISTINCT (CASE WHEN eventId NOT IN ('magic','mmagic','333mbo') THEN eventId END)) 'eventsAttempted',
				COUNT(DISTINCT (CASE WHEN best > 0 AND eventId NOT IN ('magic','mmagic','333mbo') THEN eventId END)) 'eventsSucceeded',
				COUNT(DISTINCT (CASE WHEN average > 0 AND eventId NOT IN ('magic','mmagic','333mbo') THEN eventId END)) 'eventsAverage',
				COUNT(DISTINCT (CASE WHEN eventId IN ('magic','mmagic','333mbo') THEN eventId END)) 'oldEventsAttempted',
				COUNT(DISTINCT (CASE WHEN best > 0 AND eventId IN ('magic','mmagic','333mbo') THEN eventId END)) 'oldEventsSucceeded',
				COUNT(DISTINCT (CASE WHEN average > 0 AND eventId IN ('magic','mmagic','333mbo') THEN eventId END)) 'oldEventsAverage',
				COUNT(CASE WHEN value1 NOT IN (0,-2) THEN 1 END)+COUNT(CASE WHEN value2 NOT IN (0,-2) THEN 1 END)+COUNT(CASE WHEN value3 NOT IN (0,-2) THEN 1 END)+COUNT(CASE WHEN value4 NOT IN (0,-2) THEN 1 END)+COUNT(CASE WHEN value5 NOT IN (0,-2) THEN 1 END) 'attempts',
				COUNT(CASE WHEN value1 > 0 THEN 1 END)+COUNT(CASE WHEN value2 > 0 THEN 1 END)+COUNT(CASE WHEN value3 > 0 THEN 1 END)+COUNT(CASE WHEN value4 > 0 THEN 1 END)+COUNT(CASE WHEN value5 > 0 THEN 1 END) 'completedSolves',
				COUNT(CASE WHEN value1 = -1 THEN 1 END)+COUNT(CASE WHEN value2 = -1 THEN 1 END)+COUNT(CASE WHEN value3 = -1 THEN 1 END)+COUNT(CASE WHEN value4 = -1 THEN 1 END)+COUNT(CASE WHEN value5 = -1 THEN 1 END) 'DNFs',
				COUNT(CASE WHEN roundTypeId IN ('c','f') THEN 1 END) 'finals',
				COUNT(CASE WHEN roundTypeId IN ('c','f') AND pos <= 3 AND best > 0 THEN 1 END) 'podiums',
				COUNT(CASE WHEN roundTypeId IN ('c','f') AND pos = 1 AND best > 0 THEN 1 END) 'gold',
				COUNT(CASE WHEN roundTypeId IN ('c','f') AND pos = 2 AND best > 0 THEN 1 END) 'silver',
				COUNT(CASE WHEN roundTypeId IN ('c','f') AND pos = 3 AND best > 0 THEN 1 END) 'bronze',
				COUNT(CASE WHEN regionalSingleRecord != '' THEN 1 END)+COUNT(CASE WHEN regionalAverageRecord != '' THEN 1 END) 'records',
				COUNT(CASE WHEN regionalSingleRecord = 'WR' THEN 1 END)+COUNT(CASE WHEN regionalAverageRecord = 'WR' THEN 1 END) 'WRs',
				COUNT(CASE WHEN regionalSingleRecord NOT IN ('','NR','WR') THEN 1 END)+COUNT(CASE WHEN regionalAverageRecord NOT IN ('','NR','WR') THEN 1 END) 'CRs',
				COUNT(CASE WHEN regionalSingleRecord = 'NR' THEN 1 END)+COUNT(CASE WHEN regionalAverageRecord = 'NR' THEN 1 END) 'NRs',
				MIN(CASE WHEN best > 0 THEN pos END) 'bestPos',
				MAX(pos) 'worstPos'
		FROM results_extra
		GROUP BY personId, competitionId) a
	JOIN
		(SELECT personId, competitionId, COUNT(*) 'PBs', COUNT(CASE WHEN format = 's' THEN 1 END) 'singlePBs', COUNT(CASE WHEN format = 'a' THEN 1 END) 'averagePBs'
		FROM pbs
		GROUP BY personId, competitionId) b
	ON a.personId = b.personId AND a.competitionId = b.competitionId
	ORDER BY a.personId, date, a.competitionId) a;

ALTER TABLE personCompsExtra DROP drop1, DROP drop2;
