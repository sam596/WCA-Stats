INSERT INTO wca_stats.last_updated VALUES ('persons_extra', NOW(), NULL, '') ON DUPLICATE KEY UPDATE started=NOW(), completed = NULL;

DROP TABLE IF EXISTS persons_extra;
CREATE TABLE persons_extra
(PRIMARY KEY (id))
    SELECT
      a.id, 
      g.id user_id, 
      a.name, 
      a.gender, 
      a.countryId, 
      b.continentId, 
      c.competitions, 
      c.countries, 
      c.continents, 
      c.eventsAttempted, 
      c.eventsSucceeded, 
      c.eventsAverage, 
      d.completedSolves, 
      d.DNFs, 
      c.finals, 
      c.podiums, 
      c.gold, 
      c.silver, 
      c.bronze, 
      c.eventsPodiumed, 
      c.eventsWon, 
      c.records, 
      c.WRs, 
      c.CRs, 
      c.NRs, 
      l.wcPodiums, 
      l.wcGold, 
      l.wcSilver, 
      l.wcBronze, 
      l.conPodiums, 
      l.conGold, 
      l.conSilver, 
      l.conBronze, 
      l.natPodiums, 
      l.natGold, 
      l.natSilver, 
      l.natBronze, 
      c.multipleCountryComps, 
      c.distinctMultipleCountryComps, 
      e.SoR_average `sorAverage`, 
      e.SoR_single `sorSingle`, 
      e.SoR_combined `sorCombined`, 
      m.worldKinch,
      m.worldRank worldKinchRank,
      m.continentKinch,
      m.continentRank continentKinchRank,
      m.countryKinch,
      m.countryRank countryKinchRank,
      f.minWorldRank, 
      n.maxPBStreak,
      n.currentPBStreak,
      (CASE WHEN c.eventsSucceeded = 18 AND c.eventsAverage = 15 AND c.WRs > 0 AND c.CRs > 0 AND l.wcPodiums > 0 THEN 'Platinum' WHEN c.eventsSucceeded = 18 AND c.eventsAverage = 15 AND (c.WRs > 0 OR c.CRs > 0 OR l.wcPodiums > 0) THEN 'Gold' WHEN c.eventsSucceeded = 18 AND c.eventsAverage = 15 THEN 'Silver' WHEN c.eventsSucceeded = 18 THEN 'Bronze' ELSE NULL END) `membership`, 
      p.firstComp,
      p.previousComp,
      o.upcomingComps,
      o.acceptedComps upcomingCompsAccepted,
      o.nextComp,
      g.delegate_status delegateStatus, 
      g.region, 
      g.location_description location, 
      IFNULL(h.competitionsDelegated,0) competitionsDelegated,
      IFNULL(h.competitionsDelegating,0) competitionsDelegating,
      IFNULL(j.competitionsOrganized,0) competitionsOrganized,
      IFNULL(j.competitionsOrganizing,0) competitionsOrganizing,
      k.wcaTeam
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
        COUNT(CASE WHEN regionalSingleRecord != '' THEN 1 END)+COUNT(CASE WHEN regionalAverageRecord != '' THEN 1 END) `records`,
        COUNT(CASE WHEN regionalSingleRecord = 'WR' THEN 1 END)+COUNT(CASE WHEN regionalAverageRecord = 'WR' THEN 1 END) `WRs`,
        COUNT(CASE WHEN regionalSingleRecord IN ('ER','AsR','OcR','AfR','NAR','SAR') THEN 1 END)+COUNT(CASE WHEN regionalAverageRecord IN ('ER','AsR','OcR','AfR','NAR','SAR') THEN 1 END) `CRs`,
        COUNT(CASE WHEN regionalSingleRecord = 'NR' THEN 1 END)+COUNT(CASE WHEN regionalAverageRecord = 'NR' THEN 1 END) `NRs`,
        COUNT(DISTINCT (CASE WHEN b.countryId NOT LIKE 'X_' THEN b.countryId END)) `countries`,
        COUNT(CASE WHEN b.countryId LIKE 'X_' THEN b.countryId END) `multipleCountryComps`,
        COUNT(DISTINCT (CASE WHEN b.countryId LIKE 'X_' THEN b.countryId END)) `distinctMultipleCountryComps`,
        COUNT(DISTINCT countr.continentId) `continents`
      FROM result_dates a
      JOIN wca_dev.competitions b
      ON a.competitionId = b.id
      JOIN wca_dev.countries countr
      ON countr.id = b.countryId
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
      (SELECT tm.user_id, GROUP_CONCAT(t.friendly_id ORDER BY t.id ASC) wcaTeam FROM wca_dev.team_members tm JOIN wca_dev.teams t ON tm.team_id = t.id WHERE tm.end_date IS NULL GROUP BY tm.user_id) k 
    ON g.id = k.user_id
    LEFT JOIN
      (SELECT personId, 
        SUM(CASE WHEN championship_type = 'world' THEN 1 ELSE 0 END) wcPodiums, 
        SUM(CASE WHEN championship_type = 'world' AND Cpos = 1 THEN 1 ELSE 0 END) wcGold, 
        SUM(CASE WHEN championship_type = 'world' AND Cpos = 2 THEN 1 ELSE 0 END) wcSilver,
        SUM(CASE WHEN championship_type = 'world' AND Cpos = 3 THEN 1 ELSE 0 END) wcBronze,
        SUM(CASE WHEN championship_type LIKE '\_%' THEN 1 ELSE 0 END) conPodiums,
        SUM(CASE WHEN championship_type LIKE '\_%' AND Cpos = 1 THEN 1 ELSE 0 END) conGold,
        SUM(CASE WHEN championship_type LIKE '\_%' AND Cpos = 2 THEN 1 ELSE 0 END) conSilver,
        SUM(CASE WHEN championship_type LIKE '\_%' AND Cpos = 3 THEN 1 ELSE 0 END) conBronze,
        SUM(CASE WHEN championship_type NOT LIKE '\_%' AND championship_type <> 'world' THEN 1 ELSE 0 END) natPodiums,
        SUM(CASE WHEN championship_type NOT LIKE '\_%' AND championship_type <> 'world' AND Cpos = 1 THEN 1 ELSE 0 END) natGold,
        SUM(CASE WHEN championship_type NOT LIKE '\_%' AND championship_type <> 'world' AND Cpos = 2 THEN 1 ELSE 0 END) natSilver,
        SUM(CASE WHEN championship_type NOT LIKE '\_%' AND championship_type <> 'world' AND Cpos = 3 THEN 1 ELSE 0 END) natBronze
      FROM wca_stats.championship_podiums GROUP BY personId) l 
    ON a.id = l.personId
    LEFT JOIN
      kinch m
    ON a.id = m.personId
    LEFT JOIN
      (SELECT personId, MAX(pbStreak) maxPBStreak, (SELECT pbStreak FROM pb_streak WHERE id = MAX(a.id)) currentPBStreak FROM pb_streak a GROUP BY personId) n
    ON a.id = n.personId
    LEFT JOIN
      (SELECT 
        userId, 
        COUNT(DISTINCT (CASE WHEN deletedAt IS NULL THEN competitionId END)) upcomingComps, 
        COUNT(DISTINCT (CASE WHEN acceptedAt IS NOT NULL AND deletedAt IS NULL THEN competitionId END)) acceptedComps, 
        (SELECT competitionId FROM registrations_extra WHERE endDate = MIN(re.endDate) AND userId = re.userId ORDER BY startDate, competitionId LIMIT 1) nextComp
      FROM registrations_extra re 
      WHERE endDate > NOW() 
      GROUP BY userId) o
    ON g.id = o.userId
    LEFT JOIN
      (SELECT 
        personId, 
        (SELECT 
          competitionId 
        FROM 
          wca_stats.result_dates 
        WHERE 
          personId = a.personId 
          AND 
          date = MAX(a.date) 
        ORDER BY competitionId DESC 
        LIMIT 1) previousComp, 
        (SELECT 
          competitionId 
        FROM 
          wca_stats.result_dates 
        WHERE 
          personId = a.personId 
          AND 
          date = MIN(a.date) 
        ORDER BY competitionId 
        LIMIT 1) firstComp 
      FROM 
        wca_stats.result_dates a 
      GROUP BY personId) p
    ON a.id = p.personId
    ;

UPDATE wca_stats.last_updated SET completed = NOW() WHERE query = 'persons_extra';
