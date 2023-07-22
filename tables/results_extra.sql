DROP TABLE IF EXISTS results_extra;
CREATE TABLE results_extra (
    id INT NOT NULL AUTO_INCREMENT,
    competitionId VARCHAR(32),
    eventId VARCHAR(6),
    roundTypeId CHAR(1),
    formatId CHAR(1),
    personId VARCHAR(10),
    personName VARCHAR(80),
    personCountryId VARCHAR(50),
    personContinentId VARCHAR(24),
    pos SMALLINT,
    best INT,
    average INT,
    value1 INT,
    value2 INT,
    value3 INT,
    value4 INT,
    value5 INT,
    regionalSingleRecord CHAR(3),
    regionalAverageRecord CHAR(3),
    compVenue VARCHAR(240),
    compCityName VARCHAR(50),
    compCountryId VARCHAR(50),
    compContinentId VARCHAR(24),
    compLatitude INT,
    compLongitude INT,
    compStartDate DATE,
    compEndDate DATE,
    compWeekend DATE,
    compWeeksAgo INT,
    finalMisser BOOL,
    PRIMARY KEY (id),
    INDEX idx_results_extra_value1 (value1),
    INDEX idx_results_extra_value2 (value2),
    INDEX idx_results_extra_value3 (value3),
    INDEX idx_results_extra_value4 (value4),
    INDEX idx_results_extra_value5 (value5),
    INDEX idx_results_extra_roundTypeId (roundTypeId),
    INDEX idx_results_extra_single_person_event_id (best, personId, eventId, id),
    INDEX idx_results_extra_average_person_event_id (average, personId, eventId, id),
    INDEX idx_podiums (roundTypeId, pos),
    INDEX idx_results_extra_person_competition_event_round (personId, competitionId, eventId, roundTypeId),
    INDEX idx_results_extra_competition_event_round (competitionId, eventId, roundTypeId),
    INDEX idx_results_extra_pos (pos)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT INTO results_extra (
    competitionId,
    eventId,
    roundTypeId,
    formatId,
    personId,
    personName,
    personCountryId,
    personContinentId,
    pos,
    best,
    average,
    value1,
    value2,
    value3,
    value4,
    value5,
    regionalSingleRecord,
    regionalAverageRecord,
    compVenue,
    compCityName,
    compCountryId,
    compContinentId,
    compLatitude,
    compLongitude,
    compStartDate,
    compEndDate,
    compWeekend,
    compWeeksAgo
)
SELECT
    r.competitionId,
    r.eventId,
    r.roundTypeId,
    r.formatId,
    r.personId,
    r.personName,
    r.countryId AS personCountryId,
    c.continentId AS personContinentId,
    r.pos,
    r.best,
    r.average,
    r.value1,
    r.value2,
    r.value3,
    r.value4,
    r.value5,
    r.regionalSingleRecord,
    r.regionalAverageRecord,
    comps.venue AS compVenue,
    comps.cityName AS compCityName,
    comps.countryId AS compCountryId,
    d.continentId AS compContinentId,
    comps.latitude AS compLatitude,
    comps.longitude AS compLongitude,
    comps.start_date AS compStartDate,
    comps.end_date AS compEndDate,
    comps2.compWeekend,
    comps2.compWeeksAgo
FROM
    wca_dev.results r
    JOIN wca_dev.competitions comps ON comps.id = r.competitionId
    JOIN wca_dev.countries d ON comps.countryId = d.id
    JOIN wca_dev.countries c ON c.id = r.countryId
    JOIN wca_dev.roundTypes rt ON rt.id = r.roundTypeId
    JOIN (
        SELECT id,
            DATE_SUB(comps.end_date, INTERVAL (DAYOFWEEK(comps.end_date) + 2) % 7 DAY) AS compWeekend,
            FLOOR(DATEDIFF(DATE_SUB(CURDATE(), INTERVAL (DAYOFWEEK(CURDATE()) + 2) % 7 DAY), DATE_SUB(comps.end_date, INTERVAL (DAYOFWEEK(comps.end_date) + 2) % 7 DAY)) / 7) AS compWeeksAgo
        FROM wca_dev.competitions
    ) comps2 ON comps2.id = comps.id
ORDER BY
    comps.end_date ASC,
    r.competitionId ASC,
    r.eventId ASC,
    rt.rank ASC,
    r.pos ASC;
