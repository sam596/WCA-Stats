INSERT INTO wca_stats.last_updated VALUES ('kinch', NOW(), NULL, '') ON DUPLICATE KEY UPDATE started=NOW(), completed = NULL;

DROP TABLE IF EXISTS kinch_ranks_by_event;
CREATE TABLE kinch_ranks_by_event
    SELECT personId, eventId, countryId, continentId, MAX(worldkinch) worldkinch, MAX(continentkinch) continentkinch, MAX(countrykinch) countrykinch
    FROM  (SELECT a.personId, a.countryId, z.continentId, a.eventId, b.format,
              (CASE WHEN b.best IS NULL 
              THEN 0 ELSE
                  (CASE WHEN a.eventId = '333mbf'
                  THEN (99-LEFT(b.best,2)+1-(MID(b.best,4,4)/3600))/(99-LEFT(c.best,2)+1-(MID(c.best,4,4)/3600))*100 ELSE
                  (c.best * 100 / b.best)
                  END)
              END) AS worldkinch,
              (CASE WHEN b.best IS NULL 
              THEN 0 ELSE
                  (CASE WHEN a.eventId = '333mbf'
                  THEN (99-LEFT(b.best,2)+1-(MID(b.best,4,4)/3600))/(99-LEFT(d.best,2)+1-(MID(d.best,4,4)/3600))*100 ELSE
                  (d.best * 100 / b.best)
                  END)
              END) AS continentkinch,           
              (CASE WHEN b.best IS NULL 
              THEN 0 ELSE
                  (CASE WHEN a.eventId = '333mbf'
                  THEN (99-LEFT(b.best,2)+1-(MID(b.best,4,4)/3600))/(99-LEFT(e.best,2)+1-(MID(e.best,4,4)/3600))*100 ELSE
                  (e.best * 100 / b.best)
                  END)
              END) AS countrykinch
          FROM (SELECT p.id personId, p.countryId, e.id eventId 
            FROM wca_dev.persons p
            JOIN wca_dev.events e
            WHERE e.rank < 900 AND p.subid = 1) a
          LEFT JOIN
            wca_dev.countries z
          ON a.countryId = z.id
          LEFT JOIN
              (SELECT personId, eventId, best, 'a' format
              FROM wca_dev.ranksaverage
              WHERE eventId NOT IN ('333mbf','444bf','555bf')
              UNION ALL
              SELECT personId, eventId, best, 's' format
              FROM wca_dev.rankssingle
              WHERE eventId IN ('333mbf','333fm','333bf','444bf','555bf')) b
          ON a.personId = b.personId AND a.eventId = b.eventId
          LEFT JOIN 
            (SELECT eventId, best, 'a' format 
            FROM wca_dev.ranksaverage
              WHERE eventId NOT IN ('333mbf','444bf','555bf')
                AND worldrank = 1
              UNION ALL
              SELECT eventId, best, 's' format
              FROM wca_dev.rankssingle
              WHERE eventId IN ('333mbf','333fm','333bf','444bf','555bf')
                AND worldrank = 1) c
          ON a.eventID = c.eventId AND b.format = c.format
          LEFT JOIN
            (SELECT personId, eventId, best, 'a' format 
            FROM wca_dev.ranksaverage
              WHERE eventId NOT IN ('333mbf','444bf','555bf')
                AND continentrank = 1
              UNION ALL
              SELECT personId, eventId, best, 's' format
              FROM wca_dev.rankssingle
              WHERE eventId IN ('333mbf','333fm','333bf','444bf','555bf')
                AND continentrank = 1) d
          ON a.eventID = c.eventId AND b.format = c.format AND (SELECT continentid FROM wca_dev.countries WHERE id = (SELECT countryId FROM wca_dev.persons WHERE subid = 1 AND id = d.personId)) = z.continentId
          LEFT JOIN
            (SELECT personId, eventId, best, 'a' format 
            FROM wca_dev.ranksaverage
              WHERE eventId NOT IN ('333mbf','444bf','555bf')
                AND countryrank = 1
              UNION ALL
              SELECT personId, eventId, best, 's' format
              FROM wca_dev.rankssingle
              WHERE eventId IN ('333mbf','333fm','333bf','444bf','555bf')
                AND countryrank = 1) e
          ON a.eventID = c.eventId AND b.format = c.format AND (SELECT countryId FROM wca_dev.persons WHERE subid = 1 AND id = e.personId) = a.countryId) a
    GROUP BY
        personId,
        eventId
;

DROP TABLE IF EXISTS kinch;
CREATE TABLE kinch
    SELECT personId, countryId, continentId, ROUND(AVG(worldkinch),2) worldkinch, ROUND(AVG(continentkinch),2) continentkinch, ROUND(AVG(countrykinch),2) countrykinch
    FROM wca_stats.kinch_ranks_by_event
    GROUP BY personId
    ORDER BY worldkinch DESC
;

UPDATE wca_stats.last_updated SET completed = NOW() WHERE query = 'kinch';
