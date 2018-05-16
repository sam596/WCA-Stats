INSERT INTO wca_stats.last_updated VALUES ('persons_extra', NOW(), NULL, '') ON DUPLICATE KEY UPDATE started=NOW(), completed = NULL;

DROP TABLE IF EXISTS persons_extra;
CREATE TABLE persons_extra	
		SELECT
			a.id, g.id user_id, a.name, a.gender, a.countryId, b.continentId, c.competitions, c.eventsAttempted, c.eventsSucceeded, c.eventsAverage, c.finals, c.podiums, c.gold, c.silver, c.bronze, c.eventsPodiumed, c.eventsWon, c.wcPodium, c.wChampion, c.records, c.WRs, c.CRs, c.NRs, c.countries, c.continents, c.multipleCountryComps, c.distinctMultipleCountryComps, d.completedSolves, d.DNFs, e.SoR_average `sorAverage`, e.SoR_average_rank `sorAverageRank`, e.SoR_single `sorSingle`, e.SoR_single_rank `sorSingleRank`, e.Combined_SoR `sorCombined`, e.rank `sorCombinedRank`, f.minWorldRank, (CASE WHEN c.eventsSucceeded = 18 AND c.eventsAverage = 15 AND c.WRs > 0 AND c.CRs > 0 AND c.wcPodium > 0 THEN 'Platinum' WHEN c.eventsSucceeded = 18 AND c.eventsAverage = 15 AND (c.WRs > 0 OR c.CRs > 0 OR c.wcPodium > 0) THEN 'Gold' WHEN c.eventsSucceeded = 18 AND c.eventsAverage = 15 THEN 'Silver' WHEN c.eventsSucceeded = 18 THEN 'Bronze' ELSE NULL END) `membership`, g.delegate_status delegateStatus, g.region, g.location_description location, IF(h.competitionsDelegated IS NULL AND g.delegate_status IS NOT NULL, 0, h.competitionsDelegated) competitionsDelegated, IFNULL(j.competitionsOrganized,0) competitionsOrganized, k.wcaTeam
		FROM (SELECT * FROM wca_dev.persons WHERE subid = 1) a
		LEFT JOIN wca_dev.Countries b
			ON a.countryId = b.id
		LEFT JOIN 
			(SELECT personId, 
				COUNT(DISTINCT competitionId) `competitions`, 
				COUNT(DISTINCT (CASE WHEN eventId NOT IN ('333mbo','magic','mmagic') THEN eventId END)) `eventsAttempted`, 
				COUNT(DISTINCT (CASE WHEN best > 0 AND eventId NOT IN ('333mbo','magic','mmagic') THEN eventId END)) `eventsSucceeded`,
				COUNT(DISTINCT (CASE WHEN average > 0 AND eventId NOT IN ('333mbo','magic','mmagic') THEN eventId END)) `eventsAverage`,
				COUNT(CASE WHEN roundTypeId IN ('c','f') THEN 1 END) `finals`,
				COUNT(CASE WHEN roundTypeId IN ('c','f') AND pos < 4 AND best > 0 THEN 1 END) `podiums`,
				COUNT(CASE WHEN roundTypeId IN ('c','f') AND pos = 1 AND best > 0 THEN 1 END) `gold`,
				COUNT(CASE WHEN roundTypeId IN ('c','f') AND pos = 2 AND best > 0 THEN 1 END) `silver`,
				COUNT(CASE WHEN roundTypeId IN ('c','f') AND pos = 3 AND best > 0 THEN 1 END) `bronze`,
				COUNT(DISTINCT (CASE WHEN roundTypeId IN ('c','f') AND pos < 4 AND best > 0 THEN eventId END)) `eventsPodiumed`,
				COUNT(DISTINCT (CASE WHEN roundTypeId IN ('c','f') AND pos = 1 AND best > 0 THEN eventId END)) `eventsWon`,
				COUNT(CASE WHEN roundTypeId IN ('c','f') AND pos < 4 AND best > 0 AND competitionId IN (SELECT competition_id FROM wca_dev.championships WHERE championship_type = 'world') THEN 1 END) `wcPodium`,
				COUNT(CASE WHEN roundTypeId IN ('c','f') AND pos = 1 AND best > 0 AND competitionId IN (SELECT competition_id FROM wca_dev.championships WHERE championship_type = 'world') THEN 1 END) `wChampion`,
				COUNT(CASE WHEN regionalSingleRecord != '' THEN 1 END)+COUNT(CASE WHEN regionalAverageRecord != '' THEN 1 END) `records`,
				COUNT(CASE WHEN regionalSingleRecord = 'WR' THEN 1 END)+COUNT(CASE WHEN regionalAverageRecord = 'WR' THEN 1 END) `WRs`,
				COUNT(CASE WHEN regionalSingleRecord IN ('ER','AsR','OcR','AfR','NAR','SAR') THEN 1 END)+COUNT(CASE WHEN regionalAverageRecord IN ('ER','AsR','OcR','AfR','NAR','SAR') THEN 1 END) `CRs`,
				COUNT(CASE WHEN regionalSingleRecord = 'NR' THEN 1 END)+COUNT(CASE WHEN regionalAverageRecord = 'NR' THEN 1 END) `NRs`,
				COUNT(DISTINCT (CASE WHEN b.countryId NOT LIKE 'X_' THEN b.countryId END)) `countries`,
				COUNT(CASE WHEN b.countryId LIKE 'X_' THEN b.countryId END) `multipleCountryComps`,
				COUNT(DISTINCT (CASE WHEN b.countryId LIKE 'X_' THEN b.countryId END)) `distinctMultipleCountryComps`,
				COUNT(DISTINCT a.continentId) `continents`
			FROM result_dates a
			JOIN wca_dev.competitions b
			ON a.competitionId = b.id
			GROUP BY personId) c
		ON a.id = c.personId
		LEFT JOIN
			(SELECT personId, COUNT(CASE WHEN value > 0 THEN 1 END) completedSolves, COUNT(CASE WHEN value = -1 THEN 1 END) DNFs
			FROM all_single_results	
			GROUP BY personId) d
		ON a.id = d.personId
		LEFT JOIN
			SoR_combined e
		ON a.id = e.personId
		LEFT JOIN
			(SELECT personId,
				MIN(worldrank) minWorldRank
			FROM world_ranks_all
			WHERE competed = 1
			GROUP BY personId) f
		ON a.id = f.personId
		LEFT JOIN
			wca_dev.users g
		ON a.id = g.wca_id
		LEFT JOIN
			(SELECT delegate_id, COUNT(DISTINCT competition_id) competitionsDelegated FROM wca_dev.competition_delegates GROUP BY delegate_id) h
		ON g.id = h.delegate_id
		LEFT JOIN
			(SELECT organizer_id, COUNT(DISTINCT competition_id) competitionsOrganized FROM wca_dev.competition_organizers GROUP BY organizer_id) j
		ON g.id = j.organizer_id
		LEFT JOIN
			(SELECT tm.user_id, GROUP_CONCAT(t.friendly_id ORDER BY t.id ASC) wcaTeam FROM wca_dev.team_members tm JOIN wca_dev.teams t ON tm.team_id = t.id GROUP BY tm.user_id) k 
		ON g.id = k.user_id
		;

UPDATE wca_stats.last_updated SET completed = NOW() WHERE query = 'persons_extra';