INSERT INTO wca_stats.last_updated VALUES ('all_single_results', NOW(), NULL, '') ON DUPLICATE KEY UPDATE started=NOW(), completed = NULL;

DROP TABLE IF EXISTS all_single_results;
CREATE TABLE all_single_results
(id INT NOT NULL AUTO_INCREMENT, 
PRIMARY KEY(id), 
KEY asr_personcompevent (personId,competitionId,eventId),
KEY asr_person (personId),
KEY asr_comp (competitionId),
KEY asr_event (eventId),
KEY asr_round (roundTypeId),
KEY asr_eventval (eventId,value),
KEY asr_sglall (personId,competitionId,eventId,roundTypeId,value))
  SELECT * FROM
  (
    SELECT competitionId, date, eventId, roundTypeId, 1 solve, pos, personId, personName, value1 value FROM result_dates WHERE value1 != 0 AND value1 != -2
    UNION ALL
    SELECT competitionId, date, eventId, roundTypeId, 2 solve, pos, personId, personName, value2 value FROM result_dates WHERE value2 != 0 AND value2 != -2
    UNION ALL
    SELECT competitionId, date, eventId, roundTypeId, 3 solve, pos, personId, personName, value3 value FROM result_dates WHERE value3 != 0 AND value3 != -2
    UNION ALL
    SELECT competitionId, date, eventId, roundTypeId, 4 solve, pos, personId, personName, value4 value FROM result_dates WHERE value4 != 0 AND value4 != -2
    UNION ALL
    SELECT competitionId, date, eventId, roundTypeId, 5 solve, pos, personId, personName, value5 value FROM result_dates WHERE value5 != 0 AND value5 != -2
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
