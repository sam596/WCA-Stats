DROP TABLE IF EXISTS ranks_all;
CREATE TABLE ranks_all (
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
    INDEX idx_worldSor (worldRank),
    INDEX idx_continentId_continentSor (continentId, continentRank),
    INDEX idx_countryId_countrySor (countryId, countryRank),
    INDEX idx_subquery_covering (personId, personName, countryId, continentId, eventId, worldRank, continentRank, countryRank)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT INTO ranks_all (
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
SELECT * FROM average_ranks
UNION ALL
SELECT * FROM single_ranks
ORDER BY eventId, format, worldrank;

DROP TABLE IF EXISTS SoR_combined;
CREATE TABLE SoR_combined (
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

INSERT INTO SoR_combined (
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
        (SELECT DISTINCT personId, personName, countryId, continentId, worldRank, continentRank, countryRank FROM ranks_all) a
    GROUP BY 
    personId
) b
ORDER BY
    worldSoR
;
