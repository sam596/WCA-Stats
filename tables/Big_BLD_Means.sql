DROP TABLE IF EXISTS oj_stats.BigBLDMeanHelp;
CREATE TABLE oj_stats.BigBLDMeanHelp
SELECT a.*, b.recordName
FROM
(SELECT id, personId, personName, personCountryId, personContinentId, competitionId, date, eventId, roundTypeId,
	ROUND((value1+value2+value3)/3) 'average', best, regionalSingleRecord, value1, value2, value3
FROM wca_stats.Results_Extra
WHERE eventId IN ('444bf','555bf') AND value1 > 0 AND value2 > 0 AND value3 > 0) a
JOIN wca_dev.continents b
ON a.personContinentId = b.id
ORDER BY a.eventId, a.date ASC, a.average ASC;

SET @e = NULL, @WR = 0;
DROP TABLE IF EXISTS oj_stats.BigBLDMeanWR;
CREATE TABLE oj_stats.BigBLDMeanWR
SELECT a.*,
	@WR := IF(a.eventId = @e,IF(a.average <= @WR,a.average,@WR),a.average) 'WR',
	@e := a.eventId 'drop1'
FROM oj_stats.BigBLDMeanHelp a;
ALTER TABLE oj_stats.BigBLDMeanWR ORDER BY eventId, personContinentId, date ASC, average ASC;

SET @e = NULL, @c = NULL, @CR = 0;
DROP TABLE IF EXISTS oj_stats.BigBLDMeanCR;
CREATE TABLE oj_stats.BigBLDMeanCR
SELECT a.*,
	@CR := IF(a.eventId = @e AND a.personContinentId = @c,IF(a.average <= @CR,a.average,@CR),a.average) 'CR',
	@e := a.eventId 'drop2', @c := a.personContinentId 'drop3'
FROM oj_stats.BigBLDMeanWR a;
ALTER TABLE oj_stats.BigBLDMeanCR ORDER BY eventId, personCountryId, date ASC, average ASC;

SET @e = NULL, @c = NULL, @NR = 0;
DROP TABLE IF EXISTS oj_stats.BigBLDMeanNR;
CREATE TABLE oj_stats.BigBLDMeanNR
SELECT a.*,
	@NR := IF(a.eventId = @e AND a.personCountryId = @c,IF(a.average <= @NR,a.average,@NR),a.average) 'NR',
	@e := a.eventId 'drop4', @c := a.personCountryId 'drop5'
FROM oj_stats.BigBLDMeanCR a;

DROP TABLE IF EXISTS oj_stats.BigBLDMeans;
CREATE TABLE oj_stats.BigBLDMeans
(id INT NOT NULL AUTO_INCREMENT, PRIMARY KEY (id))
SELECT personId, personName, personCountryId, personContinentId, competitionId, date, eventId, roundTypeId, average, best,
	(CASE WHEN average = WR THEN 'WR' WHEN average = CR THEN recordName WHEN average = NR THEN 'NR' ELSE NULL END) 'regionalAverageRecord',
	regionalSingleRecord, value1, value2, value3
FROM oj_stats.BigBLDMeanNR
ORDER BY id ASC;

DROP TABLE oj_stats.BigBLDMeanHelp;
DROP TABLE oj_stats.BigBLDMeanWR;
DROP TABLE oj_stats.BigBLDMeanCR;
DROP TABLE oj_stats.BigBLDMeanNR;
