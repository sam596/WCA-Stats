##title Best Single without Sub-{X} Average
##desc 
##summary
##valrange range(5,17)
##valfiles sub-{X}
##headers ["Rank", "Person", "Country", "Single", "Average"]

SELECT RANK() OVER (ORDER BY rs.best ASC) `Rank`, p.id `personId`, p.name `personName`, p.countryId `Country`, ra.best `Average`, rs.best `Single`
FROM wca_dev.persons p
JOIN wca_dev.rankssingle rs ON p.id = rs.personId AND rs.eventId = '333'
LEFT JOIN wca_dev.ranksaverage ra ON p.id = ra.personId AND ra.eventId = '333' AND ra.best > {best}
WHERE p.subId = 1 AND ra.best IS NOT NULL
ORDER BY rs.best
LIMIT 100;