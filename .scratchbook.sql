-- Stat about people who have beat what the 3x3 average WR was at their first comp since then.

CREATE TEMPORARY TABLE temp1gts100320
SELECT pe.id, pe.name, pe.countryId, pe.firstComp, ce.endDate FROM persons_extra pe JOIN competitions_extra ce ON pe.firstcomp = ce.id ORDER BY ce.endDate, pe.firstComp;

CREATE TEMPORARY TABLE temp2gts100320
SELECT a.*, MIN(wr.result) wr FROM temp1gts100320 a JOIN (SELECT * FROM world_records WHERE eventId = '333' AND format = 'a') wr ON a.endDate > wr.date GROUP BY a.id;

CREATE TABLE sam_stats.gts100320
SELECT a.id, a.name, a.countryId, a.firstComp, a.endDate `date`, a.wr, ra.result currentResult FROM temp2gts100320 a RIGHT JOIN (SELECT personId, result FROM ranks_all WHERE eventId = '333' AND format = 'a') ra ON a.id = ra.personId WHERE ra.result < a.wr ORDER BY a.endDate DESC;

-- all people who have beaten a WR that stood at their first comp.

CREATE TEMPORARY TABLE temp3gts100320
SELECT a.*, e.id eventId, 'a' format FROM temp1gts100320 a CROSS JOIN wca_dev.events e;

CREATE TEMPORARY TABLE temp4gts100320
SELECT a.*, e.id eventId, 's' format FROM temp1gts100320 a CROSS JOIN wca_dev.events e;

CREATE TEMPORARY TABLE temp5gts100320
(KEY t5gts (id, eventId, format),
KEY t5gts2 (endDate,eventId,format))
SELECT * FROM temp3gts100320 UNION ALL SELECT * FROM temp4gts100320;

CREATE TEMPORARY TABLE temp6gts100320
(KEY t6gts (id, eventId, format, wr))
SELECT a.*, MIN(wr.result) wr FROM temp5gts100320 a JOIN world_records wr ON a.endDate > wr.date AND a.eventId = wr.eventId AND a.format = wr.format GROUP BY a.id;

CREATE TEMPORARY TABLE temp7gts100320
SELECT a.id, a.name, a.countryId, a.firstComp, a.endDate `date`, a.eventId, a.format, a.wr, ra.result currentResult FROM temp5gts100320 a RIGHT JOIN (SELECT personId, eventId, format, result FROM ranks_all) ra ON a.id = ra.personId AND a.eventId = ra.eventId AND a.format = ra.format WHERE ra.result < a.wr ORDER BY a.date;

-- 