DROP TABLE IF EXISTS all_attempts;
CREATE TABLE all_attempts (
    resultId INT,
    competitionId VARCHAR(32),
    eventId VARCHAR(6),
    roundTypeId CHAR(1),
    formatId CHAR(1),
    personId VARCHAR(10),
    personName VARCHAR(80),
    personCountryId VARCHAR(50),
    personContinentId VARCHAR(24),
    result INT,
    solve SMALLINT,
    compVenue VARCHAR(240),
    compCityName VARCHAR(50),
    compCountryId VARCHAR(50),
    compContinentId VARCHAR(24),
    compStartDate DATE,
    compEndDate DATE,
    compWeekend DATE,
    compWeeksAgo INT,
    rtRank INT
);

CREATE INDEX idx_results_extra_value1 ON results_extra (value1);
CREATE INDEX idx_results_extra_value2 ON results_extra (value2);
CREATE INDEX idx_results_extra_value3 ON results_extra (value3);
CREATE INDEX idx_results_extra_value4 ON results_extra (value4);
CREATE INDEX idx_results_extra_value5 ON results_extra (value5);
CREATE INDEX idx_results_extra_roundTypeId ON results_extra (roundTypeId);
CREATE INDEX idx_results_extra_pos ON results_extra (pos);

INSERT INTO all_attempts (
    resultId,
    competitionId,
    eventId,
    roundTypeId,
    rtRank,
    formatId,
    personId,
    personName,
    personCountryId,
    personContinentId,
    result,
    solve,
    compVenue,
    compCityName,
    compCountryId,
    compContinentId,
    compStartDate,
    compEndDate,
    compWeekend,
    compWeeksAgo
)
SELECT
    re.id,
    competitionId,
    eventId,
    roundTypeId,
    rt.rank rtRank,
    formatId,
    personId,
    personName,
    personCountryId,
    personContinentId,
    value1,
    1,
    compVenue,
    compCityName,
    compCountryId,
    compContinentId,
    compStartDate,
    compEndDate,
    compWeekend,
    compWeeksAgo
FROM
    results_extra re
JOIN
    wca_dev.roundTypes rt ON re.roundTypeId COLLATE utf8mb4_unicode_ci = rt.id COLLATE utf8mb4_unicode_ci
WHERE
    value1 NOT IN (0,-2)
ORDER BY
    compEndDate ASC,
    competitionId ASC,
    eventId ASC,
    rt.rank ASC,
    pos ASC;

INSERT INTO all_attempts (
    resultId,
    competitionId,
    eventId,
    roundTypeId,
    rtRank,
    formatId,
    personId,
    personName,
    personCountryId,
    personContinentId,
    result,
    solve,
    compVenue,
    compCityName,
    compCountryId,
    compContinentId,
    compStartDate,
    compEndDate,
    compWeekend,
    compWeeksAgo
)
SELECT
    re.id,
    competitionId,
    eventId,
    roundTypeId,
    rt.rank rtRank,
    formatId,
    personId,
    personName,
    personCountryId,
    personContinentId,
    value2,
    2,
    compVenue,
    compCityName,
    compCountryId,
    compContinentId,
    compStartDate,
    compEndDate,
    compWeekend,
    compWeeksAgo
FROM
    results_extra re
JOIN
    wca_dev.roundTypes rt ON re.roundTypeId COLLATE utf8mb4_unicode_ci = rt.id COLLATE utf8mb4_unicode_ci
WHERE
    value1 NOT IN (0,-2)
ORDER BY
    compEndDate ASC,
    competitionId ASC,
    eventId ASC,
    rt.rank ASC,
    pos ASC;

INSERT INTO all_attempts (
    resultId,
    competitionId,
    eventId,
    roundTypeId,
    rtRank,
    formatId,
    personId,
    personName,
    personCountryId,
    personContinentId,
    result,
    solve,
    compVenue,
    compCityName,
    compCountryId,
    compContinentId,
    compStartDate,
    compEndDate,
    compWeekend,
    compWeeksAgo
)
SELECT
    re.id,
    competitionId,
    eventId,
    roundTypeId,
    rt.rank rtRank,
    formatId,
    personId,
    personName,
    personCountryId,
    personContinentId,
    value3,
    3,
    compVenue,
    compCityName,
    compCountryId,
    compContinentId,
    compStartDate,
    compEndDate,
    compWeekend,
    compWeeksAgo
FROM
    results_extra re
JOIN
    wca_dev.roundTypes rt ON re.roundTypeId COLLATE utf8mb4_unicode_ci = rt.id COLLATE utf8mb4_unicode_ci
WHERE
    value1 NOT IN (0,-2)
ORDER BY
    compEndDate ASC,
    competitionId ASC,
    eventId ASC,
    rt.rank ASC,
    pos ASC;

INSERT INTO all_attempts (
    resultId,
    competitionId,
    eventId,
    roundTypeId,
    rtRank,
    formatId,
    personId,
    personName,
    personCountryId,
    personContinentId,
    result,
    solve,
    compVenue,
    compCityName,
    compCountryId,
    compContinentId,
    compStartDate,
    compEndDate,
    compWeekend,
    compWeeksAgo
)
SELECT
    re.id,
    competitionId,
    eventId,
    roundTypeId,
    rt.rank rtRank,
    formatId,
    personId,
    personName,
    personCountryId,
    personContinentId,
    value4,
    4,
    compVenue,
    compCityName,
    compCountryId,
    compContinentId,
    compStartDate,
    compEndDate,
    compWeekend,
    compWeeksAgo
FROM
    results_extra re
JOIN
    wca_dev.roundTypes rt ON re.roundTypeId COLLATE utf8mb4_unicode_ci = rt.id COLLATE utf8mb4_unicode_ci
WHERE
    value1 NOT IN (0,-2)
ORDER BY
    compEndDate ASC,
    competitionId ASC,
    eventId ASC,
    rt.rank ASC,
    pos ASC;

INSERT INTO all_attempts (
    resultId,
    competitionId,
    eventId,
    roundTypeId,
    rtRank,
    formatId,
    personId,
    personName,
    personCountryId,
    personContinentId,
    result,
    solve,
    compVenue,
    compCityName,
    compCountryId,
    compContinentId,
    compStartDate,
    compEndDate,
    compWeekend,
    compWeeksAgo
)
SELECT
    re.id,
    competitionId,
    eventId,
    roundTypeId,
    rt.rank rtRank,
    formatId,
    personId,
    personName,
    personCountryId,
    personContinentId,
    value5,
    5,
    compVenue,
    compCityName,
    compCountryId,
    compContinentId,
    compStartDate,
    compEndDate,
    compWeekend,
    compWeeksAgo
FROM
    results_extra re
JOIN
    wca_dev.roundTypes rt ON re.roundTypeId COLLATE utf8mb4_unicode_ci = rt.id COLLATE utf8mb4_unicode_ci
WHERE
    value1 NOT IN (0,-2)
ORDER BY
    compEndDate ASC,
    competitionId ASC,
    eventId ASC,
    rt.rank ASC,
    pos ASC;

ALTER TABLE all_attempts
    ORDER BY
        compEndDate ASC,
        competitionId ASC,
        eventId ASC,
        rtRank ASC,
        personId ASC,
        solve ASC;

ALTER TABLE all_attempts 
    ADD id INT PRIMARY KEY AUTO_INCREMENT FIRST;

ALTER TABLE all_attempts
    DROP rtRank;
