INSERT INTO wca_stats.last_updated VALUES ('all_attempts', NOW(), NULL, '') ON DUPLICATE KEY UPDATE started=NOW(), completed = NULL;

DROP TABLE IF EXISTS all_attempts;
CREATE TABLE all_attempts
(id INT NOT NULL AUTO_INCREMENT, 
PRIMARY KEY(id), 
KEY asr_personcompevent (personId,competitionId,eventId,roundTypeId),
KEY asr_event (eventId),
KEY asr_round (competitionId,eventId,roundTypeId),
KEY asr_round2 (roundTypeId),
KEY asr_eventval (eventId,value))
  SELECT * FROM
  (
    SELECT competitionId, compCountryId, compContinentId, date, weekend, weeksago, eventId, roundTypeId, 1 solve, formatId, pos, personId, personName, personCountryId, personContinentId, value1 value FROM results_extra WHERE value1 NOT IN (0,-2)
    UNION ALL
    SELECT competitionId, compCountryId, compContinentId, date, weekend, weeksago, eventId, roundTypeId, 2 solve, formatId, pos, personId, personName, personCountryId, personContinentId, value2 value FROM results_extra WHERE value2 NOT IN (0,-2)
    UNION ALL
    SELECT competitionId, compCountryId, compContinentId, date, weekend, weeksago, eventId, roundTypeId, 3 solve, formatId, pos, personId, personName, personCountryId, personContinentId, value3 value FROM results_extra WHERE value3 NOT IN (0,-2)
    UNION ALL
    SELECT competitionId, compCountryId, compContinentId, date, weekend, weeksago, eventId, roundTypeId, 4 solve, formatId, pos, personId, personName, personCountryId, personContinentId, value4 value FROM results_extra WHERE value4 NOT IN (0,-2)
    UNION ALL
    SELECT competitionId, compCountryId, compContinentId, date, weekend, weeksago, eventId, roundTypeId, 5 solve, formatId, pos, personId, personName, personCountryId, personContinentId, value5 value FROM results_extra WHERE value5 NOT IN (0,-2)
  ) a
  ORDER BY 
    date, 
    competitionId,
    eventId, 
    (SELECT rank FROM wca_dev.roundtypes b WHERE id = a.roundTypeId), 
    solve,
    pos
;

# ~ 26 mins

UPDATE wca_stats.last_updated SET completed = NOW() WHERE query = 'all_attempts';
