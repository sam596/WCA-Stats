DROP TABLE IF EXISTS current_nrs;
DROP TABLE IF EXISTS current_crs;
DROP TABLE IF EXISTS current_wrs;

CREATE TABLE current_nrs (
    personId VARCHAR(10),
    personName VARCHAR(80),
    countryId VARCHAR(50),
    continentId VARCHAR(24),
    eventId VARCHAR(6),
    format CHAR(1),
    result INT,
    worldRank INT,
    continentRank INT,
    competitionId VARCHAR(32),
    roundTypeId CHAR(1),
    compEndDate DATE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT INTO current_nrs (
    personId,
    personName,
    countryId,
    continentId,
    eventId,
    format,
    result,
    worldRank,
    continentRank,
    competitionId,
    roundTypeId,
    compEndDate
)
SELECT 
    personId,
    personName,
    countryId,
    continentId,
    eventId,
    format,
    result,
    worldRank,
    continentRank,
    competitionId,
    roundTypeId,
    compEndDate
FROM ranks_all 
WHERE countryRank = 1 
    AND succeeded;

CREATE TABLE current_crs (
    personId VARCHAR(10),
    personName VARCHAR(80),
    countryId VARCHAR(50),
    continentId VARCHAR(24),
    eventId VARCHAR(6),
    format CHAR(1),
    result INT,
    worldRank INT,
    competitionId VARCHAR(32),
    roundTypeId CHAR(1),
    compEndDate DATE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT INTO current_crs (
    personId,
    personName,
    countryId,
    continentId,
    eventId,
    format,
    result,
    worldRank,
    competitionId,
    roundTypeId,
    compEndDate
)
SELECT 
    personId,
    personName,
    countryId,
    continentId,
    eventId,
    format,
    result,
    worldRank,
    competitionId,
    roundTypeId,
    compEndDate
FROM ranks_all 
WHERE continentRank = 1 
    AND succeeded;

CREATE TABLE current_wrs (
    personId VARCHAR(10),
    personName VARCHAR(80),
    countryId VARCHAR(50),
    continentId VARCHAR(24),
    eventId VARCHAR(6),
    format CHAR(1),
    result INT,
    competitionId VARCHAR(32),
    roundTypeId CHAR(1),
    compEndDate DATE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT INTO current_wrs (
    personId,
    personName,
    countryId,
    continentId,
    eventId,
    format,
    result,
    competitionId,
    roundTypeId,
    compEndDate
)
SELECT 
    personId,
    personName,
    countryId,
    continentId,
    eventId,
    format,
    result,
    competitionId,
    roundTypeId,
    compEndDate
FROM ranks_all 
WHERE worldRank = 1 
    AND succeeded;
