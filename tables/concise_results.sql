INSERT INTO wca_stats.last_updated VALUES ('concise_results', NOW(), NULL, '') ON DUPLICATE KEY UPDATE started=NOW(), completed = NULL;

DROP TABLE IF EXISTS concise_results_help;
CREATE TABLE concise_results_help
(id INT NOT NULL AUTO_INCREMENT, PRIMARY KEY(id), KEY pef (personId, eventId, format, result))
SELECT * FROM
(SELECT personId, competitionId, date, weekend, eventId, roundTypeId, average result, 'a' format, formatId FROM results_extra
UNION ALL
SELECT personId, competitionId, date, weekend, eventId, roundTypeId, best result, 's' format, NULL formatId FROM results_extra) a
ORDER BY personId, eventId, format, date, FIELD(roundTypeId,"h","0","d","1","b","2","e","g","3","c","f") ASC;

# ~ 2 min 20 sec

DROP TABLE IF EXISTS concise_results;
CREATE TABLE concise_results
(PRIMARY KEY (id),
KEY pef (personId, eventId, format),
KEY pc (personId, competitionId),
KEY pefpb (personId, eventId, format, `PB`),
KEY pb (`PB`))
SELECT a.*,
    IF(a.result <= IFNULL((SELECT MIN(result) FROM `concise_results_help` r WHERE r.result > 0 AND r.personId = a.personId AND r.eventId = a.eventId AND r.format = a.format AND r.id < a.id),999999999)
    AND a.result > 0, 1, 0) 'PB'
FROM `concise_results_help` a;

# ~ 6 min 30 secs 

DROP TABLE concise_results_help;

UPDATE wca_stats.last_updated SET completed = NOW() WHERE query = 'concise_results';
