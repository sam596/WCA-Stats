CREATE INDEX idx_persons_country_subid ON wca_dev.persons (countryId, subid);
CREATE INDEX idx_ranksAverage_personId_eventId ON wca_dev.ranksAverage (personId, eventId);
CREATE INDEX idx_events_rank_id ON wca_dev.events (`rank`, id);
CREATE INDEX idx_countries_id ON wca_dev.countries (id);
CREATE INDEX idx_ranksaverage_personId_eventId_best ON wca_dev.ranksaverage (personId, eventId, best);
CREATE INDEX idx_results_extra_average_personId_eventId ON wca_stats.results_extra (average, personId, eventId);
DROP TABLE IF EXISTS countryEventsAverage;
CREATE TEMPORARY TABLE countryEventsAverage
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
    wca_dev.ranksAverage ra ON ra.personId = p.id AND ra.eventId = e.id
GROUP BY
    c.id,
    c.continentId,
    e.id;
DROP TABLE IF EXISTS personEventsAverage;
CREATE TEMPORARY TABLE personEventsAverage
    (KEY pe (id, eventId))
SELECT
    p.id,
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
CREATE INDEX idx_personEventsAverage_countryId_eventId ON wca_stats.personEventsAverage (countryId, eventId);
CREATE INDEX idx_ranksaverage_person_event ON wca_dev.ranksaverage (personId, eventId);
CREATE INDEX idx_personEventsAverage_id_event ON wca_stats.personEventsAverage (id, eventId);
CREATE INDEX idx_results_extra_average_person_event_id ON wca_stats.results_extra (average, personId, eventId, id);
CREATE INDEX idx_countryEventsAverage_country_event ON wca_stats.countryEventsAverage (countryId, eventId);
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
    compEndDate DATE
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
    b.id,
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
    wca_dev.ranksaverage a ON a.personId COLLATE utf8mb4_0900_ai_ci = b.id COLLATE utf8mb4_0900_ai_ci AND a.eventId COLLATE utf8mb4_0900_ai_ci = b.eventId COLLATE utf8mb4_0900_ai_ci
LEFT JOIN
    wca_stats.results_extra c ON c.average COLLATE utf8mb4_0900_ai_ci = a.best COLLATE utf8mb4_0900_ai_ci AND c.personId COLLATE utf8mb4_0900_ai_ci = a.personId COLLATE utf8mb4_0900_ai_ci AND c.eventId COLLATE utf8mb4_0900_ai_ci = a.eventId COLLATE utf8mb4_0900_ai_ci
LEFT JOIN
    wca_stats.countryEventsAverage d ON b.countryId COLLATE utf8mb4_0900_ai_ci = d.countryId COLLATE utf8mb4_0900_ai_ci AND b.eventId COLLATE utf8mb4_0900_ai_ci = d.eventId COLLATE utf8mb4_0900_ai_ci
;

CREATE INDEX idx_worldRank ON average_ranks (worldRank);
CREATE INDEX idx_continentId_continentRank ON average_ranks (continentId, continentRank);
CREATE INDEX idx_countryId_countryRank ON average_ranks (countryId, countryRank);
CREATE INDEX idx_subquery_covering ON average_ranks (personId, personName, countryId, continentId, worldRank, continentRank, countryRank);

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

