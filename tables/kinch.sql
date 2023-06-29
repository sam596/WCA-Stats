DROP TABLE IF EXISTS kinch_event;
CREATE TABLE kinch_event (
    personId VARCHAR(10),
    personName VARCHAR(80),
    countryId VARCHAR(50),
    continentId VARCHAR(24),
    eventId VARCHAR(6),
    countryKinch DECIMAL(5,2),
    continentKinch DECIMAL(5,2),
    worldKinch DECIMAL(5,2)
    );

INSERT INTO kinch_event (
    personId,
    personName,
    countryId,
    continentId,
    eventId,
    countryKinch,
    continentKinch,
    worldKinch
)
SELECT personId, personName, countryId, continentId, eventId, MAX(countryKinch) countryKinch, MAX(continentKinch) continentKinch, MAX(worldKinch) worldKinch
FROM (
    SELECT ra.*, nrs.result nr,
    CASE 
        WHEN ra.succeeded = FALSE THEN 0
        WHEN ra.eventId = '333mbf' THEN ROUND((99-LEFT(ra.result,2)+1-(MID(ra.result,4,4)/3600))/(99-LEFT(nrs.result,2)+1-(MID(nrs.result,4,4)/3600))*100,2)
        ELSE ROUND((nrs.result/ra.result)*100,2)
    END `countryKinch`,
    CASE 
        WHEN ra.succeeded = FALSE THEN 0
        WHEN ra.eventId = '333mbf' THEN ROUND((99-LEFT(ra.result,2)+1-(MID(ra.result,4,4)/3600))/(99-LEFT(crs.result,2)+1-(MID(crs.result,4,4)/3600))*100,2)
        ELSE ROUND((crs.result/ra.result)*100,2)
    END `continentKinch`,
    CASE 
        WHEN ra.succeeded = FALSE THEN 0
        WHEN ra.eventId = '333mbf' THEN ROUND((99-LEFT(ra.result,2)+1-(MID(ra.result,4,4)/3600))/(99-LEFT(wrs.result,2)+1-(MID(wrs.result,4,4)/3600))*100,2)
        ELSE ROUND((wrs.result/ra.result)*100,2)
    END `worldKinch`
    FROM ranks_all ra
    LEFT JOIN current_nrs nrs
        ON ra.countryId = nrs.countryId
        AND ra.eventId = nrs.eventId
        AND ra.format = nrs.format
    LEFT JOIN current_crs crs
        ON ra.continentId = crs.continentId
        AND ra.eventId = crs.eventId
        AND ra.format = crs.format
    LEFT JOIN current_wrs wrs
        ON ra.eventId = wrs.eventId
        AND ra.format = wrs.format
    WHERE (
        ra.format = 'a'
        OR ra.eventId IN ('333bf','444bf','555bf','333fm','333mbf')
    )
) a
GROUP BY personId, personName, countryId, continentId, eventId;

DROP TABLE IF EXISTS kinch;
CREATE TABLE kinch (
    personId VARCHAR(10),
    personName VARCHAR(80),
    countryId VARCHAR(50),
    continentId VARCHAR(24),
    countryKinch DECIMAL(5,2),
    countryKinchRank INT,
    continentKinch DECIMAL(5,2),
    continentKinchRank INT,
    worldKinch DECIMAL(5,2),
    worldKinchRank INT
);
INSERT INTO kinch (
    personId,
    personName,
    countryId,
    continentId,
    countryKinch,
    continentKinch,
    worldKinch,
    countryKinchRank,
    continentKinchRank,
    worldKinchRank
)
SELECT *, RANK() OVER (PARTITION BY countryId ORDER BY countryKinch DESC) countryKinchRank, RANK() OVER (PARTITION BY continentId ORDER BY continentKinch DESC) continentKinchRank, RANK() OVER (ORDER BY worldKinch DESC) worldKinchRank
FROM (
    SELECT
        personId,
        personName,
        countryId,
        continentId,
        AVG(countryKinch) countryKinch,
        AVG(continentKinch) continentKinch,
        AVG(worldKinch) worldKinch
    FROM
        kinch_event
    GROUP BY
        personId
) a;