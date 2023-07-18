##title Best Average without Sub-{X} Single
##desc 
##summary
##valrange range(4,16)
##valfiles sub-{X}
##headers ["Rank", "Person", "Country", "Average", "Single"]

SELECT RANK() OVER (ORDER BY ra.best ASC) `Rank`, p.wca_id `personId`, p.name `personName`, p.countryId `Country`, ra.best `Average`, rs.best `Single`
FROM wca_dev.persons p
JOIN wca_dev.ranksaverage ra ON p.wca_id = ra.personId AND ra.eventId = '333'
LEFT JOIN wca_dev.rankssingle rs ON p.wca_id = rs.personId AND rs.eventId = '333' AND rs.best > {best}
WHERE p.subId = 1 AND rs.best IS NOT NULL
ORDER BY ra.best
LIMIT 100;