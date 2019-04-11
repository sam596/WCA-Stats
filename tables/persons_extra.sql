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
      s.county ukCounty,
      q.name previousName,
      q.gender previousGender,
      q.countryId previousCountryId,
      r.continentId previousContinentId,
      IF(POSITION(" " IN a.name)=0,a.name,LEFT(a.name,POSITION(" " IN a.name))) firstName,
      c.competitions, 
      c.homeCountryComps, 
      c.foreignCountryComps, 
      c.countries, 
      c.continents, 
      c.eventsAttempted, 
      c.eventsSucceeded, 
      c.eventsAverage, 
      c.speedsolvingEventsAverage,
      c.bldfmcEventsAverage,
      d.completedSolves, 
      d.DNFs, 
      c.finals, 
      c.podiums, 
      c.gold, 
      c.silver, 
      c.bronze, 
      c.eventsPodiumed, 
      c.eventsWon,
      c.currentEventsPodiumed, 
      c.currentEventsWon, 
      c.records, 
      c.WRs, 
      c.CRs, 
      c.NRs, 
      IFNULL(l.wcPodiums,0) wcPodiums, 
      IFNULL(l.wcGold,0) wcGold, 
      IFNULL(l.wcSilver,0) wcSilver, 
      IFNULL(l.wcBronze,0) wcBronze, 
      IFNULL(l.conPodiums,0) conPodiums, 
      IFNULL(l.conGold,0) conGold, 
      IFNULL(l.conSilver,0) conSilver, 
      IFNULL(l.conBronze,0) conBronze, 
      IFNULL(l.natPodiums,0) natPodiums, 
      IFNULL(l.natGold,0) natGold, 
      IFNULL(l.natSilver,0) natSilver, 
      IFNULL(l.natBronze,0) natBronze, 
      c.multipleCountryComps, 
      c.distinctMultipleCountryComps, 
      ea.worldSoR `worldSoRaverage`, 
      ea.worldRank `worldSoRaverageRank`, 
      ea.continentSoR `continentSoRaverage`, 
      ea.continentRank `continentSoRaverageRank`, 
      ea.countrySoR `countrySoRaverage`, 
      ea.countryRank `countrySoRaverageRank`, 
      es.worldSoR `worldSoRSingle`, 
      es.worldRank `worldSoRSingleRank`, 
      es.continentSoR `continentSoRSingle`, 
      es.continentRank `continentSoRSingleRank`, 
      es.countrySoR `countrySoRSingle`, 
      es.countryRank `countrySoRSingleRank`, 
      ec.worldSoR `worldSoRCombined`, 
      ec.worldRank `worldSoRCombinedRank`, 
      ec.continentSoR `continentSoRCombined`, 
      ec.continentRank `continentSoRCombinedRank`, 
      ec.countrySoR `countrySoRCombined`, 
      ec.countryRank `countrySoRCombinedRank`, 
      m.worldKinch,
      m.worldRank worldKinchRank,
      m.continentKinch,
      m.continentRank continentKinchRank,
      m.countryKinch,
      m.countryRank countryKinchRank,
      f.minWorldRank,
      f.minWorldRankEventId,
      f.maxWorldRank,
      f.maxWorldRankEventId,
      n.maxPBStreak,
      n.currentPBStreak,
      (CASE WHEN c.eventsSucceeded = 18 AND c.eventsAverage = 15 AND c.WRs > 0 AND c.CRs > 0 AND l.wcPodiums > 0 THEN 'Platinum' WHEN c.eventsSucceeded = 18 AND c.eventsAverage = 15 AND (c.WRs > 0 OR c.CRs > 0 OR l.wcPodiums > 0) THEN 'Gold' WHEN c.eventsSucceeded = 18 AND c.eventsAverage = 15 THEN 'Silver' WHEN c.eventsSucceeded = 18 THEN 'Bronze' ELSE NULL END) `membership`, 
      @m := (CASE WHEN c.eventsSucceeded <> 18 THEN 0 ELSE 1 + (CASE WHEN c.speedsolvingEventsAverage = 13 THEN 1 ELSE 0 END) + (CASE WHEN c.bldfmcEventsAverage = 4 THEN 1 ELSE 0 END) + (CASE WHEN l.wcPodiums > 0 THEN 1 ELSE 0 END) + (CASE WHEN c.WRs > 0 THEN 1 ELSE 0 END) + (CASE WHEN c.currentEventsWon = 18 THEN 1 ELSE 0 END) END) mhelp,
      (CASE WHEN @m = 0 THEN NULL WHEN @m = 1 THEN 'Bronze' WHEN @m = 2 THEN 'Silver' WHEN @m = 3 THEN 'Gold' WHEN @m = 4 THEN 'Platinum' WHEN @m = 5 THEN 'Opal' WHEN @m = 6 THEN 'Diamond' END) mollerzMembership,
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
        COUNT(DISTINCT (CASE WHEN personCountryId = compCountryId THEN competitionId END)) `homeCountryComps`, 
        COUNT(DISTINCT (CASE WHEN personCountryId != compCountryId AND compCountryId NOT LIKE 'X_' THEN competitionId END)) `foreignCountryComps`, 
        COUNT(DISTINCT (CASE WHEN eventId NOT IN ('333mbo','magic','mmagic') THEN eventId END)) `eventsAttempted`, 
        COUNT(DISTINCT (CASE WHEN best > 0 AND eventId NOT IN ('333mbo','magic','mmagic') THEN eventId END)) `eventsSucceeded`,
        COUNT(DISTINCT (CASE WHEN average > 0 AND eventId NOT IN ('444bf','555bf','333mbo','magic','mmagic') THEN eventId END)) `eventsAverage`,
        COUNT(DISTINCT (CASE WHEN average > 0 AND eventId NOT IN ('333mbo','magic','mmagic','333bf','444bf','555bf','333mbf','333fm') THEN eventId END)) `speedsolvingEventsAverage`,
        COUNT(DISTINCT (CASE WHEN average > 0 AND eventId IN ('333bf','444bf','555bf','333fm') THEN eventId END)) `bldfmcEventsAverage`,
        COUNT(CASE WHEN roundTypeId IN ('c','f') THEN 1 END) `finals`,
        COUNT(CASE WHEN roundTypeId IN ('c','f') AND pos < 4 AND best > 0 THEN 1 END) `podiums`,
        COUNT(CASE WHEN roundTypeId IN ('c','f') AND pos = 1 AND best > 0 THEN 1 END) `gold`,
        COUNT(CASE WHEN roundTypeId IN ('c','f') AND pos = 2 AND best > 0 THEN 1 END) `silver`,
        COUNT(CASE WHEN roundTypeId IN ('c','f') AND pos = 3 AND best > 0 THEN 1 END) `bronze`,
        COUNT(DISTINCT (CASE WHEN roundTypeId IN ('c','f') AND pos < 4 AND best > 0 THEN eventId END)) `eventsPodiumed`,
        COUNT(DISTINCT (CASE WHEN roundTypeId IN ('c','f') AND pos = 1 AND best > 0 THEN eventId END)) `eventsWon`,
        COUNT(DISTINCT (CASE WHEN roundTypeId IN ('c','f') AND pos < 4 AND eventId NOT IN ('333mbo','magic','mmagic')AND best > 0 THEN eventId END)) `currentEventsPodiumed`,
        COUNT(DISTINCT (CASE WHEN roundTypeId IN ('c','f') AND pos = 1 AND eventId NOT IN ('333mbo','magic','mmagic')AND best > 0 THEN eventId END)) `currentEventsWon`,
        COUNT(CASE WHEN regionalaverageRecord != '' THEN 1 END)+COUNT(CASE WHEN regionalSingleRecord != '' THEN 1 END) `records`,
        COUNT(CASE WHEN regionalaverageRecord = 'WR' THEN 1 END)+COUNT(CASE WHEN regionalSingleRecord = 'WR' THEN 1 END) `WRs`,
        COUNT(CASE WHEN regionalaverageRecord IN ('ER','AsR','OcR','AfR','NAR','SAR') THEN 1 END)+COUNT(CASE WHEN regionalSingleRecord IN ('ER','AsR','OcR','AfR','NAR','SAR') THEN 1 END) `CRs`,
        COUNT(CASE WHEN regionalaverageRecord = 'NR' THEN 1 END)+COUNT(CASE WHEN regionalSingleRecord = 'NR' THEN 1 END) `NRs`,
        COUNT(DISTINCT (CASE WHEN b.countryId NOT LIKE 'X_' THEN b.countryId END)) `countries`,
        COUNT(CASE WHEN b.countryId LIKE 'X_' THEN b.countryId END) `multipleCountryComps`,
        COUNT(DISTINCT (CASE WHEN b.countryId LIKE 'X_' THEN b.countryId END)) `distinctMultipleCountryComps`,
        COUNT(DISTINCT countr.continentId) `continents`
      FROM results_extra a
      JOIN wca_dev.competitions b
      ON a.competitionId = b.id
      JOIN wca_dev.countries countr
      ON countr.id = b.countryId
      GROUP BY personId) c
    ON a.id = c.personId
    LEFT JOIN
      (SELECT personId, COUNT(CASE WHEN value > 0 THEN 1 END) completedSolves, COUNT(CASE WHEN value = -1 THEN 1 END) DNFs
      FROM all_attempts 
      GROUP BY personId) d
    ON a.id = d.personId
    LEFT JOIN
      SoR_single es
    ON a.id = es.personId
    LEFT JOIN
      sor_average ea
    ON a.id = ea.personId
    LEFT JOIN
      SoR_combined ec 
    ON a.id = ec.personId
    LEFT JOIN
      (SELECT personId,
        MIN(CASE WHEN succeeded = 1 THEN worldrank END) minWorldRank,
        (SELECT GROUP_CONCAT(CONCAT(eventId,format)) FROM ranks_all WHERE MIN(CASE WHEN a.succeeded = 1 THEN a.worldrank END) = worldrank AND a.personId = personId) minWorldRankEventId,
        MAX(worldrank) maxWorldRank,
        (SELECT GROUP_CONCAT(CONCAT(eventId,format)) FROM ranks_all WHERE MAX(a.worldrank) = worldrank AND a.personId = personId) maxWorldRankEventId
      FROM ranks_all a
      GROUP BY personId) f
    ON a.id = f.personId
    LEFT JOIN
      wca_dev.users g
    ON a.id = g.wca_id
    LEFT JOIN
      (SELECT delegate_id, COUNT(DISTINCT (CASE WHEN competition_id IN (SELECT id FROM wca_dev.competitions WHERE end_date <= NOW()) THEN competition_id END)) competitionsDelegated, COUNT(DISTINCT (CASE WHEN competition_id IN (SELECT id FROM wca_dev.competitions WHERE end_date > NOW()) THEN competition_id END)) competitionsDelegating FROM wca_dev.competition_delegates GROUP BY delegate_id) h
    ON g.id = h.delegate_id
    LEFT JOIN
      (SELECT organizer_id, COUNT(DISTINCT (CASE WHEN competition_id IN (SELECT id FROM wca_dev.competitions WHERE end_date <= NOW()) THEN competition_id END)) competitionsOrganized, COUNT(DISTINCT (CASE WHEN competition_id IN (SELECT id FROM wca_dev.competitions WHERE end_date > NOW()) THEN competition_id END)) competitionsOrganizing FROM wca_dev.competition_organizers GROUP BY organizer_id) j
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
          wca_stats.results_extra 
        WHERE 
          personId = a.personId 
          AND 
          date = MAX(a.date) 
        ORDER BY competitionId DESC 
        LIMIT 1) previousComp, 
        (SELECT 
          competitionId 
        FROM 
          wca_stats.results_extra 
        WHERE 
          personId = a.personId 
          AND 
          date = MIN(a.date) 
        ORDER BY competitionId 
        LIMIT 1) firstComp 
      FROM 
        wca_stats.results_extra a 
      GROUP BY personId) p
    ON a.id = p.personId
    LEFT JOIN (SELECT * FROM wca_dev.persons WHERE subid = 2) q
    ON a.id = q.id
    LEFT JOIN wca_dev.countries r
    ON q.countryId = r.id
    LEFT JOIN wca_stats.county_dir s
    ON a.id = s.personId
    ;
;

ALTER TABLE persons_extra 
  DROP COLUMN mhelp;

# ~ 7 mins 15 secs

UPDATE wca_stats.last_updated SET completed = NOW() WHERE query = 'persons_extra';
