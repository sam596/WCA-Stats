##title Most Sub-{X} Singles without Sub-{X} Average
##desc 
##summary
##valrange range(5,17)
##valfiles sub-{X}
##headers ["Rank", "Person", "Country", "Singles", "Average"]

SELECT p.wca_id personId, p.name personName, p.countryId, a.singles, (SELECT ROUND(best/100,2) FROM wca_dev.ranksaverage WHERE personId = a.personId AND eventId = '333') average
FROM (SELECT personId, COUNT(*) singles FROM wca_stats.all_attempts a
WHERE result > 0 AND result < 1200 AND eventId = '333' AND personId NOT IN (SELECT personId FROM wca_dev.ranksaverage WHERE eventId = '333' AND best <= 1200)
GROUP BY personId ORDER BY singles DESC
LIMIT 250) a
INNER JOIN wca_dev.persons p ON a.personId = p.wca_id AND p.subid = 1
ORDER BY a.singles DESC, Average, p.wca_id;
