
CREATE INDEX idx_rankssingle_personId_eventId ON wca_dev.ranksSingle (personId, eventId);
CREATE INDEX idx_rankssingle_personId_eventId_best ON wca_dev.ranksSingle (personId, eventId, best);
CREATE INDEX idx_results_extra_best_personId_eventId ON wca_stats.results_extra (best, personId, eventId);
DROP TABLE IF EXISTS countryEventsSingle;
CREATE TEMPORARY TABLE countryEventsSingle
SELECT
    c.id AS countryId,
    c.continentId,
    e.id AS eventId,
    IFNULL(MAX(ra.countryRank), 0) + 1 AS countryCount,
    IFNULL(MAX(ra.continentRank), 0) + 1 AS continentCount,
    IFNULL(MAX(ra.worldRank), 0) + 1 AS worldCount
FROM
    wca_dev.countries c
JOIN
    wca_dev.persons p ON p.countryId = c.id AND p.subid = 1
JOIN
    wca_dev.events e ON e.rank < 900
JOIN
    wca_dev.rankssingle ra ON ra.personId = p.wca_id AND ra.eventId = e.id
GROUP BY
    c.id,
    c.continentId,
    e.id;
DROP TABLE IF EXISTS personEventsSingle;
CREATE TEMPORARY TABLE personEventsSingle
    (KEY pe (wca_id, eventId))
SELECT
    p.wca_id,
    p.name,
    p.countryId,
    c.continentId,
    e.id AS eventId
FROM
    wca_dev.persons p
JOIN
    wca_dev.countries c ON c.id = p.countryId
JOIN
    wca_dev.events e ON e.rank < 900
WHERE
    p.subid = 1;
CREATE INDEX idx_personEventssingle_countryId_eventId ON wca_stats.personEventsSingle (countryId, eventId);
CREATE INDEX idx_rankssingle_person_event ON wca_dev.ranksSingle (personId, eventId);
CREATE INDEX idx_personEventssingle_id_event ON wca_stats.personEventsSingle (wca_id, eventId);
CREATE INDEX idx_results_extra_single_person_event_id ON wca_stats.results_extra (best, personId, eventId, id);
CREATE INDEX idx_countryEventssingle_country_event ON wca_stats.countryEventsSingle (countryId, eventId);
DROP TABLE IF EXISTS single_ranks;
CREATE TABLE single_ranks (
    personId VARCHAR(10),
    personName VARCHAR(80),
    countryId VARCHAR(50),
    continentId VARCHAR(24),
    eventId VARCHAR(6),
    format CHAR(1),
    succeeded BOOL,
    result INT,
    worldRank INT,
    continentRank INT,
    countryRank INT,
    competitionId VARCHAR(32),
    roundTypeId CHAR(1),
    compEndDate DATE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


INSERT INTO single_ranks (
    personId,
    personName,
    countryId,
    continentId,
    eventId,
    format,
    succeeded,
    result,
    worldRank,
    continentRank,
    countryRank,
    competitionId,
    roundTypeId,
    compEndDate
)
SELECT
    b.wca_id,
    b.name,
    b.countryId,
    b.continentId,
    b.eventId,
    's' AS format,
    (CASE WHEN a.best IS NOT NULL THEN 1 ELSE 0 END) AS succeeded,
    a.best AS result,
    COALESCE(a.worldRank, d.worldCount) AS worldRank,
    COALESCE(a.continentRank, d.continentCount) AS continentRank,
    COALESCE(a.countryRank, d.countryCount) AS countryRank,
    c.competitionId,
    c.roundTypeId,
    c.compEndDate
FROM
    wca_stats.personEventssingle b
LEFT JOIN
    wca_dev.rankssingle a ON a.personId COLLATE utf8mb4_0900_ai_ci = b.wca_id COLLATE utf8mb4_0900_ai_ci AND a.eventId COLLATE utf8mb4_0900_ai_ci = b.eventId COLLATE utf8mb4_0900_ai_ci
LEFT JOIN
    wca_stats.results_extra c ON c.best COLLATE utf8mb4_0900_ai_ci = a.best COLLATE utf8mb4_0900_ai_ci AND c.personId COLLATE utf8mb4_0900_ai_ci = a.personId COLLATE utf8mb4_0900_ai_ci AND c.eventId COLLATE utf8mb4_0900_ai_ci = a.eventId COLLATE utf8mb4_0900_ai_ci
LEFT JOIN
    wca_stats.countryEventssingle d ON b.countryId COLLATE utf8mb4_0900_ai_ci = d.countryId COLLATE utf8mb4_0900_ai_ci AND b.eventId COLLATE utf8mb4_0900_ai_ci = d.eventId COLLATE utf8mb4_0900_ai_ci
;

CREATE INDEX idx_worldRank ON single_ranks (worldRank);
CREATE INDEX idx_continentId_continentRank ON single_ranks (continentId, continentRank);
CREATE INDEX idx_countryId_countryRank ON single_ranks (countryId, countryRank);
CREATE INDEX idx_subquery_covering ON single_ranks (personId, personName, countryId, continentId, worldRank, continentRank, countryRank);

DROP TABLE IF EXISTS SoR_single;
CREATE TABLE SoR_single (
    personId VARCHAR(10),
    personName VARCHAR(80),
    countryId VARCHAR(50),
    continentId VARCHAR(24),
    worldSor INT,
    worldRank INT,
    continentSor INT,
    continentRank INT,
    countrySor INT,
    countryRank INT,
    PRIMARY KEY (personId)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


INSERT INTO SoR_single (
    personId,
    personName,
    countryId,
    continentId,
    worldSor,
    continentSor,
    countrySor,
    worldRank,
    continentRank,
    countryRank
)
SELECT
    *,
    RANK() OVER (ORDER BY worldSor) `worldRank`,
    RANK() OVER (PARTITION BY continentId ORDER BY continentSor) `continentRank`,
    RANK() OVER (PARTITION BY countryId ORDER BY countrySor) `countryRank`
FROM (
    SELECT 
        personId,
        personName,
        countryId,
        continentId,
        SUM(worldRank) worldSoR,
        SUM(continentRank) continentSoR,
        SUM(countryRank) countrySoR
    FROM 
        (SELECT DISTINCT personId, personName, countryId, continentId, eventId, worldRank, continentRank, countryRank FROM single_ranks) a
    GROUP BY 
    personId
) b
ORDER BY
    worldSoR
;

