## End of Year Stats for WCT

*Last updated using WCA Developer Export from today_date*

*The [World Cube Association](https://www.worldcubeassociation.org) is the source and owner of this information. This published information is not actual information, the actual information can be found [here](https://www.worldcubeassociation.org/results).*

#	Most solves of the years
```sql
SELECT personId, personName, personCountryId, COUNT(*) FROM all_attempts WHERE value > 0 AND YEAR(date) = 2018 GROUP BY personId ORDER BY COUNT(*) DESC LIMIT 10;
```

aaaaa


#	Most countries competed in (excludes Multiple-Country comps)
```sql
SELECT personId, personName, personCountryId, COUNT(DISTINCT compCountryId) FROM results_extra WHERE YEAR(date) = 2018 AND compCountryId NOT LIKE 'X_' GROUP BY personId ORDER BY COUNT(DISTINCT compCountryId) DESC LIMIT 10;
```

bbbbb


#	Most gold
```sql
SELECT personId, personName, personCountryId, COUNT(*) FROM results_extra WHERE YEAR(date) = 2018 AND roundTypeId IN ('c','f') AND pos = 1 AND best > 0 GROUP BY personID ORDER BY COUNT(*) DESC LIMIT 10;
```

ccccc


#	Most silver
```sql
SELECT personId, personName, personCountryId, COUNT(*) FROM results_extra WHERE YEAR(date) = 2018 AND roundTypeId IN ('c','f') AND pos = 2 AND best > 0 GROUP BY personID ORDER BY COUNT(*) DESC LIMIT 10;
```

ddddd


#	Most bronze
```sql
SELECT personId, personName, personCountryId, COUNT(*) FROM results_extra WHERE YEAR(date) = 2018 AND roundTypeId IN ('c','f') AND pos = 3 AND best > 0 GROUP BY personID ORDER BY COUNT(*) DESC LIMIT 10;
```

eeeee


#	Most podiums
```sql
SELECT personId, personName, personCountryId, COUNT(*) FROM results_extra WHERE YEAR(date) = 2018 AND roundTypeId IN ('c','f') AND pos <= 3 AND best > 0 GROUP BY personID ORDER BY COUNT(*) DESC LIMIT 10;
```

fffff


#	Most competitions organized (regional orgs/individuals)
```sql
SELECT u.name, COUNT(*) FROM wca_dev.competition_organizers co JOIN wca_dev.users u ON co.organizer_id = u.id WHERE competition_id LIKE '%2018' GROUP BY co.organizer_id ORDER BY COUNT(*) DESC LIMIT 10;
```

ggggg


#	New countries in WCA this year
```sql
SELECT countryId FROM competitions_extra GROUP BY countryId HAVING MIN(YEAR(endDate)) = 2018;
```

hhhhh


#	City with the most competitions
```sql
SELECT cityName, COUNT(*) FROM competitions_extra WHERE YEAR(endDate) = 2018 GROUP BY cityName ORDER BY COUNT(*) DESC LIMIT 10;
```

iiiii


#	City with the most competitions
```sql
SELECT countryId, COUNT(*) FROM competitions_extra WHERE YEAR(endDate) = 2018 GROUP BY countryId ORDER BY COUNT(*) DESC LIMIT 10;
```

jjjjj


#	Most DNFs
```sql
SELECT personId, personName, personCountryId, COUNT(*) FROM all_attempts WHERE value = -1 AND YEAR(date) = 2018 GROUP BY personId ORDER BY COUNT(*) DESC LIMIT 10;
```

kkkkk


#	Most 3x3 blindfolded successes
```sql
SELECT personId, personName, personCountryId, COUNT(*) FROM all_attempts WHERE value > 0 AND YEAR(date) = 2018 AND eventId = '333bf' GROUP BY personId ORDER BY COUNT(*) DESC LIMIT 10;
```

lllll


#	Most 3x3 Blindfolded successes in a row
```sql
SET @a = 0, @p = ''; SELECT personId, personName, personCountryId, MAX(streak) FROM (SELECT *, @a := IF(@p = personId AND value > 0, @a + 1, 1) streak, @p := personId FROM (SELECT personId, personName, personCountryId, value, id FROM all_attempts WHERE YEAR(date) = 2018 AND eventId = '333bf' ORDER BY personId, id) a ORDER BY personId, id) b GROUP BY personId ORDER BY MAX(streak) DESC LIMIT 10;
```

mmmmm


#	Most competitions competed in 
```sql
SELECT personId, personName, personCountryId, COUNT(DISTINCT competitionId) FROM results_extra WHERE YEAR(date) = 2018 GROUP BY personId ORDER BY COUNT(DISTINCT competitionId) DESC LIMIT 10;
```

nnnnn


#	Potentially seen world records
```sql
SELECT pce.personId, pce.personName, pce.personCountryId, SUM(ce.WRs) FROM person_comps_extra pce JOIN competitions_extra ce ON pce.competitionId = ce.id WHERE YEAR(ce.endDate) = 2018 GROUP BY pce.personId ORDER BY SUM(ce.WRs) DESC LIMIT 10;
```

ooooo


#	New Platinum/Gold/Silver members
```sql
SELECT a.id, a.name, a.countryId, b.membership `2017`, a.membership `2018` FROM persons_extra a INNER JOIN persons_extra_2017 b ON a.id = b.id WHERE a.membership <> b.membership ORDER BY FIELD(a.membership,'Platinum','Gold','Silver','Bronze','None'), FIELD(b.membership,'Platinum','Gold','Silver','Bronze','None'), a.id;
```

ppppp


#	Smallest competition
```sql
SELECT name, competitors FROM competitions_extra WHERE YEAR(endDate) = 2018 AND competitors > 0 ORDER BY competitors ASC LIMIT 10;
```

qqqqq


#	PB streak
```sql
SELECT p.id, p.name, p.countryId, MAX(pbStreak) FROM (SELECT a.*, @val := IF(a.PBs = 0, 0, IF(a.personId = @pid, @val + 1, 1)) pbStreak, @scomp := IF(@val = 0, NULL, IF(@val = 1, competitionId, @scomp)) startComp, @ecomp := IF(@val = 0, NULL, competitionId) endComp, @pid := personId pidhelp FROM (SELECT * FROM competition_PBs WHERE competitionId LIKE '%2018' ORDER BY id ASC) a GROUP BY a.personId, a.competitionId ORDER BY a.id ASC) pbs JOIN persons_extra p ON pbs.personid = p.id GROUP BY p.id ORDER BY MAX(pbStreak) DESC LIMIT 10;
```

rrrrr


#	Most PBs at a single competition
```sql
SELECT p.id, p.name, p.countryId, pbs.pbs, pbs.competitionId FROM competition_pbs pbs JOIN persons_extra p ON pbs.personId = p.id WHERE competitionId IN (SELECT id FROM competitions_extra WHERE YEAR(endDate) = 2018) ORDER BY PBs DESC LIMIT 10;
```

sssss


#	Most competitions delegated
```sql
SELECT u.name, COUNT(*) FROM wca_dev.competition_delegates co JOIN wca_dev.users u ON co.delegate_id = u.id WHERE competition_id LIKE '%2018' GROUP BY co.delegate_id ORDER BY COUNT(*) DESC LIMIT 10;
```

ttttt

