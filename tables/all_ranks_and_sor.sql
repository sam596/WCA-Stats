CREATE INDEX idx_eventId_format ON average_ranks (eventId, format);
CREATE INDEX idx_eventId_format ON single_ranks (eventId, format);

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
    compEndDate DATE
);

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

CREATE INDEX idx_worldSor ON ranks_all (worldRank);
CREATE INDEX idx_continentId_continentSor ON ranks_all (continentId, continentRank);
CREATE INDEX idx_countryId_countrySor ON ranks_all (countryId, countryRank);
CREATE INDEX idx_subquery_covering ON ranks_all (personId, personName, countryId, continentId, eventId, worldRank, continentRank, countryRank);


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
);

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
