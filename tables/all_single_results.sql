INSERT INTO wca_stats.last_updated VALUES ('all_single_results', NOW(), NULL, '') ON DUPLICATE KEY UPDATE started=NOW(), completed = NULL;

DROP TABLE IF EXISTS all_single_results;
CREATE TABLE all_single_results
(id INT NOT NULL AUTO_INCREMENT, 
PRIMARY KEY(id), 
KEY asr_personcompevent (personId,competitionId,eventId,roundTypeId),
KEY asr_event (eventId),
KEY asr_round (competitionId,eventId,roundTypeId),
KEY asr_round2 (roundTypeId),
KEY asr_eventval (eventId,value))
  SELECT * FROM
  (
    SELECT competitionId, date, eventId, roundTypeId, 1 solve, pos, personId, personName, countryId, continentId, value1 value FROM result_dates WHERE value1 NOT IN (0,-2)
    UNION ALL
    SELECT competitionId, date, eventId, roundTypeId, 2 solve, pos, personId, personName, countryId, continentId, value2 value FROM result_dates WHERE value2 NOT IN (0,-2)
    UNION ALL
    SELECT competitionId, date, eventId, roundTypeId, 3 solve, pos, personId, personName, countryId, continentId, value3 value FROM result_dates WHERE value3 NOT IN (0,-2)
    UNION ALL
    SELECT competitionId, date, eventId, roundTypeId, 4 solve, pos, personId, personName, countryId, continentId, value4 value FROM result_dates WHERE value4 NOT IN (0,-2)
    UNION ALL
    SELECT competitionId, date, eventId, roundTypeId, 5 solve, pos, personId, personName, countryId, continentId, value5 value FROM result_dates WHERE value5 NOT IN (0,-2)
  ) a
  ORDER BY 
    date ASC, 
    competitionId ASC,
    eventId ASC, 
    FIELD(roundTypeId,"h","0","d","1","b","2","e","g","3","c","f") ASC, 
    solve ASC,
    pos ASC
;

UPDATE wca_stats.last_updated SET completed = NOW() WHERE query = 'all_single_results';
