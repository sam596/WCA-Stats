CREATE INDEX idx_podiums ON wca_stats.results_extra (roundTypeId, pos);

DROP TABLE IF EXISTS podium_sums;

CREATE TABLE podium_sums (
    competitionId VARCHAR(32),
    eventId VARCHAR(6),
    podiumSum BIGINT,
    worldRank INT,
    continentRank INT,
    countryRank INT,
    personIds CHAR(32),
    personIdCountryId CHAR(50),
    singleCountryRank INT,
    results VARCHAR(32)
);

INSERT INTO podium_sums (
    competitionId,
    eventId,
    podiumSum,
    worldRank,
    continentRank,
    countryRank,
    personIds,
    personIdCountryId,
    results
)
SELECT 
    competitionId, 
    eventId, 
    SUM(result), 
    ROW_NUMBER() OVER (PARTITION BY eventId ORDER BY SUM(result) ASC),
    ROW_NUMBER() OVER (PARTITION BY eventId, compContinentId ORDER BY SUM(result) ASC),
    ROW_NUMBER() OVER (PARTITION BY eventId, compCountryId ORDER BY SUM(result) ASC),
    GROUP_CONCAT(personId ORDER BY pos), 
    IF(COUNT(DISTINCT personCountryId) = 1, MAX(personCountryId), NULL),
    GROUP_CONCAT(result ORDER BY pos)
FROM 
    (SELECT 
        competitionId, 
        eventId, 
        pos, 
        personId, 
        (CASE WHEN formatId REGEXP '[0-9]' THEN best ELSE average END) result,
        compCountryId,
        compContinentId,
        personCountryId
    FROM results_extra
    WHERE (CASE WHEN formatId REGEXP '[0-9]' THEN best ELSE average END) > 0
        AND roundTypeId IN ('c', 'f')
        AND pos <= 3
        AND best > 0
     ) a
WHERE competitionId IS NOT NULL
GROUP BY competitionId, eventId
HAVING COUNT(*) = 3
ORDER BY eventId, SUM(result);

UPDATE podium_sums AS ps
JOIN (
    SELECT competitionId, eventId, personIdCountryId,
           ROW_NUMBER() OVER (PARTITION BY eventId, personIdCountryId ORDER BY podiumSum) AS `rank`
    FROM podium_sums
    WHERE personIdCountryId IS NOT NULL
) AS a ON a.competitionId = ps.competitionId AND a.eventId = ps.eventId
SET ps.singleCountryRank = a.`rank`;