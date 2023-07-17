INSERT INTO wca_stats.last_updated VALUES ('relays', NOW(), NULL, '') ON DUPLICATE KEY UPDATE started=NOW(), completed = NULL;
-- relay of mini_guildford (all ao5 events)
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
	r.personId = p.wca_id
	AND
	p.subid = 1
GROUP BY
	r.personId
ORDER BY 
	r.miniGuildford ASC
	;

# <10 secs
-- guildford relay (all wca non-bld events)
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
	SUM(CASE WHEN eventId = 'clock' THEN best END) `clock`,
	SUM(CASE WHEN eventId = 'minx' THEN best END) `minx`,
	SUM(CASE WHEN eventId = 'pyram' THEN best END) `pyram`,
	SUM(CASE WHEN eventId = 'skewb' THEN best END) `skewb`,
	SUM(CASE WHEN eventId = 'sq1' THEN best END) `sq1`,
	SEC_TO_TIME(r.Guildford/100) `Guildford`
FROM
	(SELECT personId, SUM(best) Guildford FROM wca_dev.rankssingle WHERE eventId IN ('222','333','444','555','333oh','skewb','minx','pyram','clock','sq1','666','777') GROUP BY personId HAVING COUNT(*) = 12) r
INNER JOIN
	(SELECT * FROM wca_dev.rankssingle WHERE eventId IN ('222','333','444','555','333oh','skewb','minx','pyram','clock','sq1','666','777')) s
ON	
	r.personId = s.personId
INNER JOIN
	wca_dev.persons p
ON
	r.personId = p.wca_id
	AND
	p.subid = 1
GROUP BY
	r.personId
ORDER BY 
	r.Guildford ASC
	;

# <10 secs
-- relay of all events (only timed events - i.e. FMC and MBLD)
DROP TABLE IF EXISTS all_events_relay;
CREATE TABLE all_events_relay
(AllEventsRank INT NOT NULL AUTO_INCREMENT,
PRIMARY KEY(personId),
KEY(AllEventsRank))
SELECT
	r.personId,
	p.name,
	p.countryId,
	SEC_TO_TIME(r.AllEvents/100) `Sum`,
	SUM(CASE WHEN eventId = '333' THEN best END) `333`,
    SUM(CASE WHEN eventId = '222' THEN best END) `222`,
    SUM(CASE WHEN eventId = '444' THEN best END) `444`,
    SUM(CASE WHEN eventId = '555' THEN best END) `555`,
    SUM(CASE WHEN eventId = '666' THEN best END) `666`,
    SUM(CASE WHEN eventId = '777' THEN best END) `777`,
    SUM(CASE WHEN eventId = '333bf' THEN best END) `333bf`,
    SUM(CASE WHEN eventId = '333oh' THEN best END) `333oh`,
    SUM(CASE WHEN eventId = 'clock' THEN best END) `clock`,
    SUM(CASE WHEN eventId = 'minx' THEN best END) `minx`,
    SUM(CASE WHEN eventId = 'pyram' THEN best END) `pyram`,
    SUM(CASE WHEN eventId = 'skewb' THEN best END) `skewb`,
    SUM(CASE WHEN eventId = 'sq1' THEN best END) `sq1`,
    SUM(CASE WHEN eventId = '444bf' THEN best END) `444bf`,
    SUM(CASE WHEN eventId = '555bf' THEN best END) `555bf`
FROM
	(SELECT personId, SUM(best) AllEvents FROM wca_dev.rankssingle WHERE eventId IN ('222','333','444','555','333oh','skewb','minx','pyram','clock','sq1','666','777','333bf','444bf','555bf') GROUP BY personId HAVING COUNT(*) = 15) r
INNER JOIN
	(SELECT * FROM wca_dev.rankssingle WHERE eventId IN ('222','333','444','555','333oh','skewb','minx','pyram','clock','sq1','666','777','333bf','444bf','555bf')) s
ON	
	r.personId = s.personId
INNER JOIN
	wca_dev.persons p
ON
	r.personId = p.wca_id
	AND
	p.subid = 1
GROUP BY
	r.personId
ORDER BY 
	r.AllEvents ASC
	;

# <10 secs
-- one row for every person. each row contains their PR single and averages and the relevant worldRank
DROP TABLE IF EXISTS all_events_rank;
CREATE TABLE all_events_rank
(AllEventsRank INT NOT NULL AUTO_INCREMENT,
PRIMARY KEY(personId),
KEY(AllEventsRank))
SELECT
	s.personId,
	p.name,
	p.countryId,
	c.continentId,
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
	s.personId = p.wca_id
	AND
	p.subid = 1
JOIN
	wca_dev.countries c
ON
	p.countryId = c.id
GROUP BY
	s.personId
ORDER BY 
	s.personId ASC
	;

# ~ 50 secs

CREATE INDEX 333s ON all_events_rank (333s);
CREATE INDEX 333a ON all_events_rank (333a);
CREATE INDEX 222s ON all_events_rank (222s);
CREATE INDEX 222a ON all_events_rank (222a);
CREATE INDEX 444s ON all_events_rank (444s);
CREATE INDEX 444a ON all_events_rank (444a);
CREATE INDEX 555s ON all_events_rank (555s);
CREATE INDEX 555a ON all_events_rank (555a);
CREATE INDEX 666s ON all_events_rank (666s);
CREATE INDEX 666a ON all_events_rank (666a);
CREATE INDEX 777s ON all_events_rank (777s);
CREATE INDEX 777a ON all_events_rank (777a);
CREATE INDEX 333bfs ON all_events_rank (333bfs);
CREATE INDEX 333bfa ON all_events_rank (333bfa);
CREATE INDEX 333fms ON all_events_rank (333fms);
CREATE INDEX 333fma ON all_events_rank (333fma);
CREATE INDEX 333ohs ON all_events_rank (333ohs);
CREATE INDEX 333oha ON all_events_rank (333oha);
CREATE INDEX clocks ON all_events_rank (clocks);
CREATE INDEX clocka ON all_events_rank (clocka);
CREATE INDEX minxs ON all_events_rank (minxs);
CREATE INDEX minxa ON all_events_rank (minxa);
CREATE INDEX pyrams ON all_events_rank (pyrams);
CREATE INDEX pyrama ON all_events_rank (pyrama);
CREATE INDEX skewbs ON all_events_rank (skewbs);
CREATE INDEX skewba ON all_events_rank (skewba);
CREATE INDEX sq1s ON all_events_rank (sq1s);
CREATE INDEX sq1a ON all_events_rank (sq1a);
CREATE INDEX 444bfs ON all_events_rank (444bfs);
CREATE INDEX 555bfs ON all_events_rank (555bfs);
CREATE INDEX 333mbfs ON all_events_rank (333mbfs);

# 1 sec each

UPDATE wca_stats.last_updated SET completed = NOW() WHERE query = 'relays';
