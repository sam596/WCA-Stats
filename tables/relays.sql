INSERT INTO wca_stats.last_updated VALUES ('relays', NOW(), NULL, '') ON DUPLICATE KEY UPDATE started=NOW(), completed = NULL;

DROP TABLE IF EXISTS mini_guildford;
CREATE TABLE mini_guildford
(miniGuildfordRank INT NOT NULL AUTO_INCREMENT,
PRIMARY KEY(personId),
KEY(miniGuildfordRank))
SELECT
	r.personId,
	p.name,
	p.countryId,
	SUM(CASE WHEN eventId = '333' THEN best END) `333`,
    SUM(CASE WHEN eventId = '222' THEN best END) `222`,
    SUM(CASE WHEN eventId = '444' THEN best END) `444`,
    SUM(CASE WHEN eventId = '555' THEN best END) `555`,
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
	SUM(CASE WHEN eventId = '333' THEN best END) `333`,
	SUM(CASE WHEN eventId = '222' THEN best END) `222`,
	SUM(CASE WHEN eventId = '444' THEN best END) `444`,
	SUM(CASE WHEN eventId = '555' THEN best END) `555`,
	SUM(CASE WHEN eventId = '666' THEN best END) `666`,
	SUM(CASE WHEN eventId = '777' THEN best END) `777`,
	SUM(CASE WHEN eventId = '333oh' THEN best END) `333oh`,
	SUM(CASE WHEN eventId = '333ft' THEN best END) `333ft`,
	SUM(CASE WHEN eventId = 'clock' THEN best END) `clock`,
	SUM(CASE WHEN eventId = 'minx' THEN best END) `minx`,
	SUM(CASE WHEN eventId = 'pyram' THEN best END) `pyram`,
	SUM(CASE WHEN eventId = 'skewb' THEN best END) `skewb`,
	SUM(CASE WHEN eventId = 'sq1' THEN best END) `sq1`,
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

DROP TABLE IF EXISTS all_events_relay;
CREATE TABLE all_events_relay
(AllEventsRank INT NOT NULL AUTO_INCREMENT,
PRIMARY KEY(personId),
KEY(AllEventsRank))
SELECT
	r.personId,
	p.name,
	p.countryId,
	SUM(CASE WHEN eventId = '333' THEN best END) `333`,
    SUM(CASE WHEN eventId = '222' THEN best END) `222`,
    SUM(CASE WHEN eventId = '444' THEN best END) `444`,
    SUM(CASE WHEN eventId = '555' THEN best END) `555`,
    SUM(CASE WHEN eventId = '666' THEN best END) `666`,
    SUM(CASE WHEN eventId = '777' THEN best END) `777`,
    SUM(CASE WHEN eventId = '333bf' THEN best END) `333bf`
    SUM(CASE WHEN eventId = '333oh' THEN best END) `333oh`,
    SUM(CASE WHEN eventId = '333ft' THEN best END) `333ft`,
    SUM(CASE WHEN eventId = 'clock' THEN best END) `clock`,
    SUM(CASE WHEN eventId = 'minx' THEN best END) `minx`,
    SUM(CASE WHEN eventId = 'pyram' THEN best END) `pyram`,
    SUM(CASE WHEN eventId = 'skewb' THEN best END) `skewb`,
    SUM(CASE WHEN eventId = 'sq1' THEN best END) `sq1`,
    SUM(CASE WHEN eventId = '444bf' THEN best END) `444bf`,
    SUM(CASE WHEN eventId = '555bf' THEN best END) `555bf`
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

DROP TABLE IF EXISTS all_events_rank;
CREATE TABLE all_events_rank
(AllEventsRank INT NOT NULL AUTO_INCREMENT,
PRIMARY KEY(personId),
KEY(AllEventsRank))
SELECT
	s.personId,
	p.name,
	p.countryId,
	SUM(CASE WHEN s.eventId = '333' THEN s.best END) `333s`,
	SUM(CASE WHEN s.eventId = '333' THEN s.worldrank END) `333sRank`,
	SUM(CASE WHEN a.eventId = '333' THEN a.best END) `333a`,
	SUM(CASE WHEN a.eventId = '333' THEN a.worldrank END) `333aRank`,
	SUM(CASE WHEN s.eventId = '222' THEN s.best END) `222s`,
	SUM(CASE WHEN s.eventId = '222' THEN s.worldrank END) `222sRank`,
	SUM(CASE WHEN a.eventId = '222' THEN a.best END) `222a`,
	SUM(CASE WHEN a.eventId = '222' THEN a.worldrank END) `222aRank`,
	SUM(CASE WHEN s.eventId = '444' THEN s.best END) `444s`,
	SUM(CASE WHEN s.eventId = '444' THEN s.worldrank END) `444sRank`,
	SUM(CASE WHEN a.eventId = '444' THEN a.best END) `444a`,
	SUM(CASE WHEN a.eventId = '444' THEN a.worldrank END) `444aRank`,
	SUM(CASE WHEN s.eventId = '555' THEN s.best END) `555s`,
	SUM(CASE WHEN s.eventId = '555' THEN s.worldrank END) `555sRank`,
	SUM(CASE WHEN a.eventId = '555' THEN a.best END) `555a`,
	SUM(CASE WHEN a.eventId = '555' THEN a.worldrank END) `555aRank`,
	SUM(CASE WHEN s.eventId = '666' THEN s.best END) `666s`,
	SUM(CASE WHEN s.eventId = '666' THEN s.worldrank END) `666sRank`,
	SUM(CASE WHEN a.eventId = '666' THEN a.best END) `666a`,
	SUM(CASE WHEN a.eventId = '666' THEN a.worldrank END) `666aRank`,
	SUM(CASE WHEN s.eventId = '777' THEN s.best END) `777s`,
	SUM(CASE WHEN s.eventId = '777' THEN s.worldrank END) `777sRank`,
	SUM(CASE WHEN a.eventId = '777' THEN a.best END) `777a`,
	SUM(CASE WHEN a.eventId = '777' THEN a.worldrank END) `777aRank`,
	SUM(CASE WHEN s.eventId = '333bf' THEN s.best END) `333bfs`,
	SUM(CASE WHEN s.eventId = '333bf' THEN s.worldrank END) `333bfsRank`,
	SUM(CASE WHEN a.eventId = '333bf' THEN a.best END) `333bfa`,
	SUM(CASE WHEN a.eventId = '333bf' THEN a.worldrank END) `333bfaRank`,
	SUM(CASE WHEN s.eventId = '333fm' THEN s.best END) `333fms`,
	SUM(CASE WHEN s.eventId = '333fm' THEN s.worldrank END) `333fmsRank`,
	SUM(CASE WHEN a.eventId = '333fm' THEN a.best END) `333fma`,
	SUM(CASE WHEN a.eventId = '333fm' THEN a.worldrank END) `333fmaRank`,
	SUM(CASE WHEN s.eventId = '333oh' THEN s.best END) `333ohs`,
	SUM(CASE WHEN s.eventId = '333oh' THEN s.worldrank END) `333ohsRank`,
	SUM(CASE WHEN a.eventId = '333oh' THEN a.best END) `333oha`,
	SUM(CASE WHEN a.eventId = '333oh' THEN a.worldrank END) `333ohaRank`,
	SUM(CASE WHEN s.eventId = '333ft' THEN s.best END) `333fts`,
	SUM(CASE WHEN s.eventId = '333ft' THEN s.worldrank END) `333ftsRank`,
	SUM(CASE WHEN a.eventId = '333ft' THEN a.best END) `333fta`,
	SUM(CASE WHEN a.eventId = '333ft' THEN a.worldrank END) `333ftaRank`,
	SUM(CASE WHEN s.eventId = 'clock' THEN s.best END) `clocks`,
	SUM(CASE WHEN s.eventId = 'clock' THEN s.worldrank END) `clocksRank`,
	SUM(CASE WHEN a.eventId = 'clock' THEN a.best END) `clocka`,
	SUM(CASE WHEN a.eventId = 'clock' THEN a.worldrank END) `clockaRank`,
	SUM(CASE WHEN s.eventId = 'minx' THEN s.best END) `minxs`,
	SUM(CASE WHEN s.eventId = 'minx' THEN s.worldrank END) `minxsRank`,
	SUM(CASE WHEN a.eventId = 'minx' THEN a.best END) `minxa`,
	SUM(CASE WHEN a.eventId = 'minx' THEN a.worldrank END) `minxaRank`,
	SUM(CASE WHEN s.eventId = 'pyram' THEN s.best END) `pyrams`,
	SUM(CASE WHEN s.eventId = 'pyram' THEN s.worldrank END) `pyramsRank`,
	SUM(CASE WHEN a.eventId = 'pyram' THEN a.best END) `pyrama`,
	SUM(CASE WHEN a.eventId = 'pyram' THEN a.worldrank END) `pyramaRank`,
	SUM(CASE WHEN s.eventId = 'skewb' THEN s.best END) `skewbs`,
	SUM(CASE WHEN s.eventId = 'skewb' THEN s.worldrank END) `skewbsRank`,
	SUM(CASE WHEN a.eventId = 'skewb' THEN a.best END) `skewba`,
	SUM(CASE WHEN a.eventId = 'skewb' THEN a.worldrank END) `skewbaRank`,
	SUM(CASE WHEN s.eventId = 'sq1' THEN s.best END) `sq1s`,
	SUM(CASE WHEN s.eventId = 'sq1' THEN s.worldrank END) `sq1sRank`,
	SUM(CASE WHEN a.eventId = 'sq1' THEN a.best END) `sq1a`,
	SUM(CASE WHEN a.eventId = 'sq1' THEN a.worldrank END) `sq1aRank`,
	SUM(CASE WHEN s.eventId = '444bf' THEN s.best END) `444bfs`,
	SUM(CASE WHEN s.eventId = '444bf' THEN s.worldrank END) `444bfsRank`,
	SUM(CASE WHEN s.eventId = '555bf' THEN s.best END) `555bfs`,
	SUM(CASE WHEN s.eventId = '555bf' THEN s.worldrank END) `555bfsRank`,
	SUM(CASE WHEN s.eventId = '333mbf' THEN s.best END) `333mbfs`,
	SUM(CASE WHEN s.eventId = '333mbf' THEN s.worldrank END) `333mbfsRank`
FROM
	wca_dev.rankssingle s
LEFT JOIN
	wca_dev.ranksaverage a
ON 
	s.personId = a.personId
	AND
	s.eventId = a.eventId
JOIN
	wca_dev.persons p
ON
	s.personId = p.id
	AND
	p.subid = 1
GROUP BY
	s.personId
ORDER BY 
	s.personId ASC
	;

UPDATE wca_stats.last_updated SET completed = NOW() WHERE query = 'relays';
