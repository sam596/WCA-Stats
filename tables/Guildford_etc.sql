INSERT INTO wca_stats.last_updated VALUES ('guildford_etc', NOW(), NULL, '') ON DUPLICATE KEY UPDATE started=NOW(), completed = NULL;

DROP TABLE IF EXISTS mini_guildford;
CREATE TABLE mini_guildford
(miniGuildfordRank INT NOT NULL AUTO_INCREMENT,
PRIMARY KEY(personId),
KEY(miniGuildfordRank))
SELECT
	r.personId,
	p.name,
	p.countryId,
	SUM(CASE WHEN s.eventId = '222' THEN best END) `222`,
	SUM(CASE WHEN s.eventId = '333' THEN best END) `333`,
	SUM(CASE WHEN s.eventId = '444' THEN best END) `444`,
	SUM(CASE WHEN s.eventId = '555' THEN best END) `555`,
	SUM(CASE WHEN s.eventId = '333oh' THEN best END) 333oh,
	SUM(CASE WHEN s.eventId = 'clock' THEN best END) clock,
	SUM(CASE WHEN s.eventId = 'minx' THEN best END) minx,
	SUM(CASE WHEN s.eventId = 'pyram' THEN best END) pyram,
	SUM(CASE WHEN s.eventId = 'skewb' THEN best END) skewb,
	SUM(CASE WHEN s.eventId = 'sq1' THEN best END) sq1,
	SEC_TO_TIME(r.miniGuildford/100) `miniGuildford`
FROM
	(SELECT personId, SUM(best) miniGuildford FROM wca_dev.rankssingle WHERE eventId IN ('222','333','444','555','333oh','skewb','minx','pyram','clock','sq1') GROUP BY personId HAVING COUNT(*) = 10) r
INNER JOIN
	(SELECT * FROM wca_dev.rankssingle WHERE eventId IN ('222','333','444','555','333oh','skewb','minx','pyram','clock','sq1')) s
ON	
	r.personId = s.personId
INNER JOIN
	wca_dev.persons p
ON
	r.personId = p.id
	AND
	p.subid = 1
GROUP BY
	r.personId
ORDER BY 
	r.miniGuildford ASC
	;

DROP TABLE IF EXISTS guildford;
CREATE TABLE guildford
(GuildfordRank INT NOT NULL AUTO_INCREMENT,
PRIMARY KEY(personId),
KEY(GuildfordRank))
SELECT
	r.personId,
	p.name,
	p.countryId,
	SUM(CASE WHEN s.eventId = '222' THEN best END) `222`,
	SUM(CASE WHEN s.eventId = '333' THEN best END) `333`,
	SUM(CASE WHEN s.eventId = '444' THEN best END) `444`,
	SUM(CASE WHEN s.eventId = '555' THEN best END) `555`,
	SUM(CASE WHEN s.eventId = '333oh' THEN best END) 333oh,
	SUM(CASE WHEN s.eventId = 'clock' THEN best END) clock,
	SUM(CASE WHEN s.eventId = 'minx' THEN best END) minx,
	SUM(CASE WHEN s.eventId = 'pyram' THEN best END) pyram,
	SUM(CASE WHEN s.eventId = 'skewb' THEN best END) skewb,
	SUM(CASE WHEN s.eventId = 'sq1' THEN best END) sq1,
	SUM(CASE WHEN s.eventId = '666' THEN best END) `666`,
	SUM(CASE WHEN s.eventId = '777' THEN best END) `777`,
	SUM(CASE WHEN s.eventId = '333ft' THEN best END) `333ft`,
	SEC_TO_TIME(r.Guildford/100) `Guildford`
FROM
	(SELECT personId, SUM(best) Guildford FROM wca_dev.rankssingle WHERE eventId IN ('222','333','444','555','333oh','skewb','minx','pyram','clock','sq1','666','777','333ft') GROUP BY personId HAVING COUNT(*) = 13) r
INNER JOIN
	(SELECT * FROM wca_dev.rankssingle WHERE eventId IN ('222','333','444','555','333oh','skewb','minx','pyram','clock','sq1','666','777','333ft')) s
ON	
	r.personId = s.personId
INNER JOIN
	wca_dev.persons p
ON
	r.personId = p.id
	AND
	p.subid = 1
GROUP BY
	r.personId
ORDER BY 
	r.Guildford ASC
	;

DROP TABLE IF EXISTS all_events;
CREATE TABLE all_events
(AllEventsRank INT NOT NULL AUTO_INCREMENT,
PRIMARY KEY(personId),
KEY(AllEventsRank))
SELECT
	r.personId,
	p.name,
	p.countryId,
	SUM(CASE WHEN s.eventId = '222' THEN best END) `222`,
	SUM(CASE WHEN s.eventId = '333' THEN best END) `333`,
	SUM(CASE WHEN s.eventId = '444' THEN best END) `444`,
	SUM(CASE WHEN s.eventId = '555' THEN best END) `555`,
	SUM(CASE WHEN s.eventId = '333oh' THEN best END) 333oh,
	SUM(CASE WHEN s.eventId = 'clock' THEN best END) clock,
	SUM(CASE WHEN s.eventId = 'minx' THEN best END) minx,
	SUM(CASE WHEN s.eventId = 'pyram' THEN best END) pyram,
	SUM(CASE WHEN s.eventId = 'skewb' THEN best END) skewb,
	SUM(CASE WHEN s.eventId = 'sq1' THEN best END) sq1,
	SUM(CASE WHEN s.eventId = '666' THEN best END) `666`,
	SUM(CASE WHEN s.eventId = '777' THEN best END) `777`,
	SUM(CASE WHEN s.eventId = '333ft' THEN best END) `333ft`,
	SUM(CASE WHEN s.eventId = '333bf' THEN best END) `333bf`,
	SUM(CASE WHEN s.eventId = '444bf' THEN best END) `444bf`,
	SUM(CASE WHEN s.eventId = '555bf' THEN best END) `555bf`,
	SEC_TO_TIME(r.AllEvents/100) `AllEvents`
FROM
	(SELECT personId, SUM(best) AllEvents FROM wca_dev.rankssingle WHERE eventId IN ('222','333','444','555','333oh','skewb','minx','pyram','clock','sq1','666','777','333ft','333bf','444bf','555bf') GROUP BY personId HAVING COUNT(*) = 16) r
INNER JOIN
	(SELECT * FROM wca_dev.rankssingle WHERE eventId IN ('222','333','444','555','333oh','skewb','minx','pyram','clock','sq1','666','777','333ft','333bf','444bf','555bf')) s
ON	
	r.personId = s.personId
INNER JOIN
	wca_dev.persons p
ON
	r.personId = p.id
	AND
	p.subid = 1
GROUP BY
	r.personId
ORDER BY 
	r.AllEvents ASC
	;

UPDATE wca_stats.last_updated SET completed = NOW() WHERE query = 'guildford_etc';
