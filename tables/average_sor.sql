DROP TABLE IF EXISTS countryEventsAverage;
CREATE TEMPORARY TABLE countryEventsAverage (
    INDEX idx_countryEventsAverage_country_event (countryId, eventId)
)
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
    wca_dev.events e ON e.rank < 900 AND e.id != '333mbf'
JOIN
    wca_dev.ranksAverage ra ON ra.personId = p.wca_id AND ra.eventId = e.id
GROUP BY
    c.id,
    c.continentId,
    e.id;

DROP TABLE IF EXISTS personEventsAverage;
CREATE TEMPORARY TABLE personEventsAverage (
    KEY pe (wca_id, eventId),
    INDEX idx_personEventsAverage_countryId_eventId (countryId, eventId),
    INDEX idx_personEventsAverage_id_event (wca_id, eventId)
)
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
    wca_dev.events e ON e.rank < 900 AND e.id != '333mbf'
WHERE
    p.subid = 1;
DROP TABLE IF EXISTS average_ranks;
CREATE TABLE average_ranks (
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
    compEndDate DATE,
    INDEX idx_worldRank (worldRank),
    INDEX idx_continentId_continentRank (continentId, continentRank),
    INDEX idx_countryId_countryRank (countryId, countryRank),
    INDEX idx_subquery_covering (personId, personName, countryId, continentId, worldRank, continentRank, countryRank),
    INDEX idx_eventId_format (eventId, format)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT INTO average_ranks (
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
    'a' AS format,
    (CASE WHEN a.best IS NOT NULL THEN 1 ELSE 0 END) AS succeeded,
    a.best AS result,
    COALESCE(a.worldRank, d.worldCount) AS worldRank,
    COALESCE(a.continentRank, d.continentCount) AS continentRank,
    COALESCE(a.countryRank, d.countryCount) AS countryRank,
    c.competitionId,
    c.roundTypeId,
    c.compEndDate
FROM
    wca_stats.personEventsAverage b
LEFT JOIN
    wca_dev.ranksaverage a ON a.personId COLLATE utf8mb4_0900_ai_ci = b.wca_id COLLATE utf8mb4_0900_ai_ci AND a.eventId COLLATE utf8mb4_0900_ai_ci = b.eventId COLLATE utf8mb4_0900_ai_ci
LEFT JOIN
    wca_stats.results_extra c ON c.average COLLATE utf8mb4_0900_ai_ci = a.best COLLATE utf8mb4_0900_ai_ci AND c.personId COLLATE utf8mb4_0900_ai_ci = a.personId COLLATE utf8mb4_0900_ai_ci AND c.eventId COLLATE utf8mb4_0900_ai_ci = a.eventId COLLATE utf8mb4_0900_ai_ci
LEFT JOIN
    wca_stats.countryEventsAverage d ON b.countryId COLLATE utf8mb4_0900_ai_ci = d.countryId COLLATE utf8mb4_0900_ai_ci AND b.eventId COLLATE utf8mb4_0900_ai_ci = d.eventId COLLATE utf8mb4_0900_ai_ci
;

DROP TABLE IF EXISTS SoR_average;
CREATE TABLE SoR_average (
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

INSERT INTO SoR_average (
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
        (SELECT DISTINCT personId, personName, countryId, continentId, eventId, worldRank, continentRank, countryRank FROM average_ranks) a
    GROUP BY 
    personId
) a 
ORDER BY
    worldSoR
;

