INSERT INTO wca_stats.last_updated VALUES ('registrations_extra', NOW(), NULL, '') ON DUPLICATE KEY UPDATE started=NOW(), completed = NULL;

DROP TABLE IF EXISTS wca_stats.registrations_extra;
CREATE TABLE wca_stats.registrations_extra
(PRIMARY KEY (id),
KEY usercompdate (userId, competitionId, endDate),
KEY compdate (competitionId, endDate))
SELECT
	r.id,
	r.user_id userId,
	u.wca_id personId,
	u.name,
	r.competition_id competitionId,
	c.cityName,
	c.countryId,
	c.start_date startDate,
	c.end_date endDate,
	r.created_at createdAt,
	r.updated_at updatedAt,
	r.guests,
	r.accepted_at acceptedAt,
	au.name acceptedBy,
	r.deleted_at deletedAt,
	du.name deletedBy,
	SUM(CASE WHEN ce.event_id = '333' THEN 1 ELSE 0 END) `333`,
	SUM(CASE WHEN ce.event_id = '222' THEN 1 ELSE 0 END) `222`,
	SUM(CASE WHEN ce.event_id = '444' THEN 1 ELSE 0 END) `444`,
	SUM(CASE WHEN ce.event_id = '555' THEN 1 ELSE 0 END) `555`,
	SUM(CASE WHEN ce.event_id = '666' THEN 1 ELSE 0 END) `666`,
	SUM(CASE WHEN ce.event_id = '777' THEN 1 ELSE 0 END) `777`,
	SUM(CASE WHEN ce.event_id = '333bf' THEN 1 ELSE 0 END) `333bf`,
	SUM(CASE WHEN ce.event_id = '333fm' THEN 1 ELSE 0 END) `333fm`,
	SUM(CASE WHEN ce.event_id = '333oh' THEN 1 ELSE 0 END) `333oh`,
	SUM(CASE WHEN ce.event_id = '333ft' THEN 1 ELSE 0 END) `333ft`,
	SUM(CASE WHEN ce.event_id = 'clock' THEN 1 ELSE 0 END) `clock`,
	SUM(CASE WHEN ce.event_id = 'minx' THEN 1 ELSE 0 END) `minx`,
	SUM(CASE WHEN ce.event_id = 'pyram' THEN 1 ELSE 0 END) `pyram`,
	SUM(CASE WHEN ce.event_id = 'skewb' THEN 1 ELSE 0 END) `skewb`,
	SUM(CASE WHEN ce.event_id = 'sq1' THEN 1 ELSE 0 END) `sq1`,
	SUM(CASE WHEN ce.event_id = '444bf' THEN 1 ELSE 0 END) `444bf`,
	SUM(CASE WHEN ce.event_id = '555bf' THEN 1 ELSE 0 END) `555bf`,
	SUM(CASE WHEN ce.event_id = '333mbf' THEN 1 ELSE 0 END) `333mbf`
FROM
	wca_dev.registrations r 
LEFT JOIN
	wca_dev.registration_competition_events rce 
	ON r.id = rce.registration_id
LEFT JOIN
	wca_dev.competition_events ce 
	ON rce.competition_event_id = ce.id
LEFT JOIN
	wca_dev.competitions c 
	ON r.competition_id = c.id
LEFT JOIN
	wca_dev.users u 
	ON r.user_id = u.id
LEFT JOIN
	wca_dev.users au
	ON r.accepted_by = au.id 
LEFT JOIN
	wca_dev.users du 
	ON r.deleted_by = du.id
GROUP BY r.id;

# ~ 25 secs

UPDATE wca_stats.last_updated SET completed = NOW() WHERE query = 'registrations_extra';
