INSERT INTO wca_stats.last_updated VALUES ('concise_results', NOW(), NULL, '') ON DUPLICATE KEY UPDATE started=NOW(), completed = NULL;
-- concise version of results with one row for single, one for average at every round of every comp.
DROP TABLE IF EXISTS concise_results_help;
CREATE TABLE concise_results_help
(id INT NOT NULL AUTO_INCREMENT, PRIMARY KEY(id), KEY pef (personId, eventId, format, result))
SELECT * FROM
(SELECT id reId, personId, competitionId, compEndDate, compWeekend, eventId, roundTypeId, average result, 'a' format, formatId FROM results_extra
UNION ALL
SELECT id reId, personId, competitionId, compEndDate, compWeekend, eventId, roundTypeId, best result, 's' format, NULL formatId FROM results_extra) a
ORDER BY personId, eventId, format, reId;

-- checks if result is a PR or not
DROP TABLE IF EXISTS concise_results;
CREATE TABLE concise_results 
(PRIMARY KEY (id),
KEY pef (personId, eventId, format),
KEY pc (personId, competitionId),
KEY pefpr (personId, eventId, format, `PR`),
KEY pr (`PR`))
SELECT a.*,
    IF(a.result <= IFNULL((SELECT MIN(result) FROM `concise_results_help` r WHERE r.result > 0 AND r.personId = a.personId AND r.eventId = a.eventId AND r.format = a.format AND r.id < a.id),999999999)
    AND a.result > 0, 1, 0) 'PR'
FROM `concise_results_help` a;

DROP TABLE concise_results_help;

UPDATE wca_stats.last_updated SET completed = NOW() WHERE query = 'concise_results';
