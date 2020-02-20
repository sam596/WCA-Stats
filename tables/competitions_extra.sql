INSERT INTO wca_stats.last_updated VALUES ('competitions_extra', NOW(), NULL, '') ON DUPLICATE KEY UPDATE started=NOW(), completed = NULL;

SET @@group_concat_max_len = 1000000;
DROP TABLE IF EXISTS compdele;
CREATE TEMPORARY TABLE compdele
SELECT
	a.competition_id, COUNT(DISTINCT a.delegate_id) delegates, GROUP_CONCAT(DISTINCT CONCAT(b.name,IFNULL(CONCAT(" (",b.wca_id,")"),""))) delegateList
FROM
	wca_dev.competition_delegates a
LEFT JOIN
	wca_dev.users b ON a.delegate_id = b.id
GROUP BY a.competition_id;

DROP TABLE IF EXISTS comporg;
CREATE TEMPORARY TABLE comporg
SELECT
	a.competition_id, COUNT(DISTINCT a.organizer_id) organisers, GROUP_CONCAT(DISTINCT CONCAT(b.name,IFNULL(CONCAT(" (",b.wca_id,")"),""))) organiserList
FROM
	wca_dev.competition_organizers a
LEFT JOIN
	wca_dev.users b ON a.organizer_id = b.id
GROUP BY a.competition_id;

DROP TABLE IF EXISTS compchamp;
CREATE TEMPORARY TABLE compchamp
SELECT competition_id, GROUP_CONCAT(championship_type ORDER BY championship_type) championship FROM wca_dev.championships GROUP BY competition_id;

DROP TABLE IF EXISTS compresults;
CREATE TEMPORARY TABLE compresults
SELECT competitionId, 
		COUNT(DISTINCT personId) competitors, 
		SUM((CASE WHEN regionalSingleRecord = 'WR' THEN 1 ELSE 0 END)+(CASE WHEN regionalAverageRecord = 'WR' THEN 1 ELSE 0 END)) WRs,
		SUM((CASE WHEN regionalSingleRecord NOT IN ('','NR','WR') THEN 1 ELSE 0 END)+(CASE WHEN regionalAverageRecord NOT IN ('','NR','WR') THEN 1 ELSE 0 END)) CRs,
		SUM((CASE WHEN regionalSingleRecord = 'NR' THEN 1 ELSE 0 END)+(CASE WHEN regionalAverageRecord = 'NR' THEN 1 ELSE 0 END)) NRs,
		COUNT(DISTINCT eventId) events,
		COUNT(DISTINCT (CASE WHEN eventId = '333' THEN roundTypeId END)) 333Rounds,
		COUNT(DISTINCT (CASE WHEN eventId = '333' THEN personId END)) 333Competitors,
		COUNT(DISTINCT (CASE WHEN eventId = '222' THEN roundTypeId END)) 222Rounds,
		COUNT(DISTINCT (CASE WHEN eventId = '222' THEN personId END)) 222Competitors,
		COUNT(DISTINCT (CASE WHEN eventId = '444' THEN roundTypeId END)) 444Rounds,
		COUNT(DISTINCT (CASE WHEN eventId = '444' THEN personId END)) 444Competitors,
		COUNT(DISTINCT (CASE WHEN eventId = '555' THEN roundTypeId END)) 555Rounds,
		COUNT(DISTINCT (CASE WHEN eventId = '555' THEN personId END)) 555Competitors,
		COUNT(DISTINCT (CASE WHEN eventId = '666' THEN roundTypeId END)) 666Rounds,
		COUNT(DISTINCT (CASE WHEN eventId = '666' THEN personId END)) 666Competitors,
		COUNT(DISTINCT (CASE WHEN eventId = '777' THEN roundTypeId END)) 777Rounds,
		COUNT(DISTINCT (CASE WHEN eventId = '777' THEN personId END)) 777Competitors,
		COUNT(DISTINCT (CASE WHEN eventId = '333bf' THEN roundTypeId END)) 333bfRounds,
		COUNT(DISTINCT (CASE WHEN eventId = '333bf' THEN personId END)) 333bfCompetitors,
		COUNT(DISTINCT (CASE WHEN eventId = '333fm' THEN roundTypeId END)) 333fmRounds,
		COUNT(DISTINCT (CASE WHEN eventId = '333fm' AND value1 != 0 THEN roundTypeId END))+COUNT(DISTINCT (CASE WHEN eventId = '333fm' AND value2 != 0 THEN roundTypeId END))+COUNT(DISTINCT (CASE WHEN eventId = '333fm' AND value3 != 0 THEN roundTypeId END)) 333fmAttempts,
		COUNT(DISTINCT (CASE WHEN eventId = '333fm' THEN personId END)) 333fmCompetitors,
		COUNT(DISTINCT (CASE WHEN eventId = '333ft' THEN roundTypeId END)) 333ftRounds,
		COUNT(DISTINCT (CASE WHEN eventId = '333ft' THEN personId END)) 333ftCompetitors,
		COUNT(DISTINCT (CASE WHEN eventId = '333oh' THEN roundTypeId END)) 333ohRounds,
		COUNT(DISTINCT (CASE WHEN eventId = '333oh' THEN personId END)) 333ohCompetitors,
		COUNT(DISTINCT (CASE WHEN eventId = 'clock' THEN roundTypeId END)) clockRounds,
		COUNT(DISTINCT (CASE WHEN eventId = 'clock' THEN personId END)) clockCompetitors,
		COUNT(DISTINCT (CASE WHEN eventId = 'minx' THEN roundTypeId END)) minxRounds,
		COUNT(DISTINCT (CASE WHEN eventId = 'minx' THEN personId END)) minxCompetitors,
		COUNT(DISTINCT (CASE WHEN eventId = 'pyram' THEN roundTypeId END)) pyramRounds,
		COUNT(DISTINCT (CASE WHEN eventId = 'pyram' THEN personId END)) pyramCompetitors,
		COUNT(DISTINCT (CASE WHEN eventId = 'skewb' THEN roundTypeId END)) skewbRounds,
		COUNT(DISTINCT (CASE WHEN eventId = 'skewb' THEN personId END)) skewbCompetitors,
		COUNT(DISTINCT (CASE WHEN eventId = 'sq1' THEN roundTypeId END)) sq1Rounds,
		COUNT(DISTINCT (CASE WHEN eventId = 'sq1' THEN personId END)) sq1Competitors,
		COUNT(DISTINCT (CASE WHEN eventId = '444bf' THEN roundTypeId END)) 444bfRounds,
		COUNT(DISTINCT (CASE WHEN eventId = '444bf' THEN personId END)) 444bfCompetitors,
		COUNT(DISTINCT (CASE WHEN eventId = '555bf' THEN roundTypeId END)) 555bfRounds,
		COUNT(DISTINCT (CASE WHEN eventId = '555bf' THEN personId END)) 555bfCompetitors,
		COUNT(DISTINCT (CASE WHEN eventId = '333mbf' THEN roundTypeId END)) 333mbfRounds,
		COUNT(DISTINCT (CASE WHEN eventId = '333mbf' AND value1 != 0 THEN roundTypeId END))+COUNT(DISTINCT (CASE WHEN eventId = '333mbf' AND value2 != 0 THEN roundTypeId END))+COUNT(DISTINCT (CASE WHEN eventId = '333mbf' AND value3 != 0 THEN roundTypeId END)) 333mbfAttempts,
		COUNT(DISTINCT (CASE WHEN eventId = '333mbf' THEN personId END)) 333mbfCompetitors,
		COUNT(DISTINCT (CASE WHEN eventId = 'magic' THEN roundTypeId END)) magicRounds,
		COUNT(DISTINCT (CASE WHEN eventId = 'magic' THEN personId END)) magicCompetitors,
		COUNT(DISTINCT (CASE WHEN eventId = 'mmagic' THEN roundTypeId END)) mmagicRounds,
		COUNT(DISTINCT (CASE WHEN eventId = 'mmagic' THEN personId END)) mmagicCompetitors,
		COUNT(DISTINCT (CASE WHEN eventId = '333mbo' THEN roundTypeId END)) 333mboRounds,
		COUNT(DISTINCT (CASE WHEN eventId = '333mbo' THEN personId END)) 333mboCompetitors
	FROM wca_dev.results GROUP BY competitionId;

# ~ 1 min

DROP TABLE IF EXISTS compperson;
CREATE TEMPORARY TABLE compperson
SELECT firstComp, COUNT(*) firstTimers FROM wca_stats.persons_extra GROUP BY firstComp;

DROP TABLE IF EXISTS compevent;
CREATE TEMPORARY TABLE compevent
SELECT competition_id, COUNT(DISTINCT event_id) events FROM wca_dev.competition_events GROUP BY competition_id;

DROP TABLE IF EXISTS wca_stats.competitions_extra;
CREATE TABLE wca_stats.competitions_extra
(PRIMARY KEY(id))
SELECT
	a.id,
	a.name,
	a.cityName,
	a.countryId,
	b.continentId,
	a.start_date startDate,
	a.end_date endDate,
	DATEDIFF(a.end_date,a.start_date)+1 days,
	@weekend := DATE_SUB(a.start_date, INTERVAL (DAYOFWEEK(a.start_date) + 2) % 7 DAY) weekend,
	a.venue,
	a.latitude,
	a.longitude,
	e.timezone_id timeZoneId,
	a.announced_at announcedAt,
	a.results_posted_at resultsPostedAt,
	IF(DATEDIFF(a.start_date,CURDATE()) >0, 1, 0) upcoming,
	IF(a.competitor_limit_enabled IS NULL, NULL, a.competitor_limit) competitorLimit,
	g.competitors,
	IFNULL(h.firstTimers,IF(DATEDIFF(a.start_date,CURDATE()) < 0,0,NULL)) firstTimers,
	i.events,
	c.delegates,
	c.delegateList,
	d.organisers,
	d.organiserList,
	f.championship,
	g.WRs,
	g.CRs,
	g.NRs,
	g.333Competitors,
	g.333Rounds,
	g.222Competitors,
	g.222Rounds,
	g.444Competitors,
	g.444Rounds,
	g.555Competitors,
	g.555Rounds,
	g.666Competitors,
	g.666Rounds,
	g.777Competitors,
	g.777Rounds,
	g.333bfCompetitors,
	g.333bfRounds,
	g.333fmCompetitors,
	g.333fmRounds,
	g.333fmAttempts,
	g.333ftCompetitors,
	g.333ftRounds,
	g.333ohCompetitors,
	g.333ohRounds,
	g.clockCompetitors,
	g.clockRounds,
	g.minxCompetitors,
	g.minxRounds,
	g.pyramCompetitors,
	g.pyramRounds,
	g.skewbCompetitors,
	g.skewbRounds,
	g.sq1Competitors,
	g.sq1Rounds,
	g.444bfCompetitors,
	g.444bfRounds,
	g.555bfCompetitors,
	g.555bfRounds,
	g.333mbfCompetitors,
	g.333mbfRounds,
	g.333mbfAttempts,
	g.magicCompetitors,
	g.magicRounds,
	g.mmagicCompetitors,
	g.mmagicRounds,
	g.333mboCompetitors,
	g.333mboRounds
FROM wca_dev.competitions a
LEFT JOIN wca_dev.countries b ON a.countryId = b.id
LEFT JOIN compdele c ON a.id = c.competition_id
LEFT JOIN comporg d ON a.id = d.competition_id
LEFT JOIN wca_dev.competition_venues e ON a.id = e.competition_id
LEFT JOIN compchamp f ON a.id = f.competition_id
LEFT JOIN compresults g ON a.id = g.competitionId
LEFT JOIN compperson h ON a.id = h.firstComp
LEFT JOIN compevent i ON i.competition_id = a.id
GROUP BY a.id;

# ~ 1 min

UPDATE wca_stats.last_updated SET completed = NOW() WHERE query = 'competitions_extra';
