/*
if not ran before:
DROP PROCEDURE IF EXISTS FillCalendar;
DROP TABLE IF EXISTS calendar;
CREATE TABLE IF NOT EXISTS calendar(calendar_date DATE NOT NULL PRIMARY KEY);

DELIMITER $$
    CREATE PROCEDURE FillCalendar(start_date DATE, end_date DATE)
    BEGIN
    DECLARE crt_date DATE;
    SET crt_date = start_date;
    WHILE crt_date <= end_date DO
        INSERT IGNORE INTO calendar VALUES(crt_date);
        SET crt_date = ADDDATE(crt_date, INTERVAL 1 DAY);
    END WHILE;
    END$$
DELIMITER;

CALL FillCalendar('2003-01-01', '2020-01-01');
*/

CREATE TABLE personcompdate
SELECT DISTINCT rd.personId, rd.competitionId, c.calendar_date date, YEAR(c.calendar_date) year, MONTH(c.calendar_date) month, DAY(c.calendar_date) day, DAYOFWEEK(c.calendar_date) dow, DAYOFYEAR(c.calendar_date) doy, WEEKOFYEAR(c.calendar_date) week
FROM calendar c
INNER JOIN wca_dev.competitions com
ON c.calendar_date BETWEEN com.start_date AND com.end_date
INNER JOIN wca_stats.result_dates rd
ON com.id = rd.competitionId;

CREATE TABLE months
(id INT NOT NULL AUTO_INCREMENT, PRIMARY KEY(id))
SELECT DISTINCT personId, year, month, (((year%2000)*12)+month) monthabs
FROM personcompdate;

CREATE TABLE months2
(PRIMARY KEY (id),
KEY pam (personId, monthabs))
SELECT a.*,
	IF(monthabs - 1 = IFNULL((SELECT monthabs FROM months WHERE id = a.id - 1),99999999) AND personId = IFNULL((SELECT personid FROM months WHERE id = a.id - 1),99999999), 1, 0) streak
FROM months a;

DROP TABLE months3;
SET @val = 0;
CREATE TABLE months3
SELECT a.*, @val := IF(a.streak = 0, 1, IF(a.personId = b.personId, @val + 1, 1)) streakystreak
FROM months2 a
LEFT JOIN months2 b ON a.id = b.id +1
ORDER BY a.id ASC;

CREATE TABLE monthsbyperson
SELECT personId, name, countryId, MAX(streakystreak) months
FROM months3 a
INNER JOIN wca_dev.persons b ON a.personid = b.id AND b.subid = 1
GROUP BY personId;

CREATE TABLE monthsbycountry
SELECT a.countryId, a.personid, a.name, a.months
FROM monthsbyperson a
INNER JOIN (SELECT countryId, MAX(months) months FROM monthsbyperson GROUP BY countryId) b
ON a.countryId = b.countryId AND a.months = b.months;

DROP TABLE months; DROP TABLE months2;
