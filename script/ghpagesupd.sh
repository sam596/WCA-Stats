#!/bin/bash

# Link to mysql password
source ~/.mysqlpw/mysql.conf

# bestaveragewithoutsubxsingle

declare -a arr=(5 6 7 8 9 10)

for i in "${arr[@]}"
do
	echo "Best Average without Sub ${i} Single"
	mysql -u sam -p"$mysqlpw" wca_dev -e "SELECT CONCAT('[',p.name,'](https://www.worldcubeassociation.org/persons/',a.personId,')') Name, p.countryId Country, (SELECT ROUND(best/100,2) FROM rankssingle WHERE eventId = '333' AND personId = a.personId) Single, ROUND(a.best/100,2) Average FROM ranksaverage a INNER JOIN persons p ON p.subid = 1 AND a.personId = p.id WHERE a.eventId = '333' AND personId NOT IN (SELECT personId FROM rankssingle WHERE eventId = '333' AND best < ${i}00) ORDER BY average ASC LIMIT 25;" > ~/mysqloutput/original && \
	sed 's/\t/|/g' ~/mysqloutput/original > ~/mysqloutput/output && \
	sed -i.bak '2i\
--|--|--|--\' ~/mysqloutput/output
	output=$(cat ~/mysqloutput/output)
	date=$(date -r ~/databasedownload/wca-developer-database-dump.zip +"%a %b %d at %H%MUTC")
	rm ~/mysqloutput/*
	awk -v r="$output" '{gsub(/subtable/,r)}1' ~/pages/WCA-Stats/templates/bestaveragewithoutsubxsingle.md > ~/pages/WCA-Stats/bestaveragewithoutsubxsingle/sub$i.md.tmp && \
	awk -v r="$i" '{gsub(/xxx/,r)}1' ~/pages/WCA-Stats/bestaveragewithoutsubxsingle/sub$i.md.tmp > ~/pages/WCA-Stats/bestaveragewithoutsubxsingle/sub$i.md.tmp2 && \
	awk -v r="$date" '{gsub(/today_date/,r)}1' ~/pages/WCA-Stats/bestaveragewithoutsubxsingle/sub$i.md.tmp2 > ~/pages/WCA-Stats/bestaveragewithoutsubxsingle/sub$i.md
	rm ~/pages/WCA-Stats/bestaveragewithoutsubxsingle/*.tmp*
done

# bestpodiums

declare -a arr=(333 222 444 555 666 777 333bf 333fm 333oh 333ft clock minx pyram skewb sq1 444bf 555bf 333mbf)

for i in "${arr[@]}"
do
	echo "Best ${i} Podiums"
	mysql -u sam -p"$mysqlpw" wca_stats -e "SELECT CONCAT('[',competitionId,'](https://www.worldcubeassociation.org/competitions/',competitionId,')') Competition, \
com.countryId Country, \
IF('${i}' = '333mbf', CONCAT(SUM(99-LEFT(result,2)),' points'), IF('${i}' = '333fm',SUM(result),IF( SUM(result) >= 360000, LEFT(TIME_FORMAT(SEC_TO_TIME(SUM(result/100)),'%H:%i:%s.%f'),11), IF( SUM(result) >= 6000, IF( SUM(result) < 60000, RIGHT(LEFT(TIME_FORMAT(SEC_TO_TIME(SUM(result/100)),'%i:%s.%f'),8),7), LEFT(TIME_FORMAT(SEC_TO_TIME(SUM(result/100)),'%i:%s.%f'),8)), IF( SUM(result) < 1000, RIGHT(LEFT(TIME_FORMAT(SEC_TO_TIME(SUM(result/100)),'%s.%f'),5),4), LEFT(TIME_FORMAT(SEC_TO_TIME(SUM(result/100)),'%s.%f'),5)))))) sum, \
GROUP_CONCAT(CONCAT('[',p.name,'](https://www.worldcubeassociation.org/persons/',personId,')') SEPARATOR ', ') Podiummers, \
GROUP_CONCAT(IF( result >= 360000, LEFT(TIME_FORMAT(SEC_TO_TIME(result/100),'%H:%i:%s.%f'),11), IF( result >= 6000, IF( result < 60000, RIGHT(LEFT(TIME_FORMAT(SEC_TO_TIME(result/100),'%i:%s.%f'),8),7), LEFT(TIME_FORMAT(SEC_TO_TIME(result/100),'%i:%s.%f'),8)), IF(result < 1000, RIGHT(LEFT(TIME_FORMAT(SEC_TO_TIME(result/100),'%s.%f'),5),4), LEFT(TIME_FORMAT(SEC_TO_TIME(result/100),'%s.%f'),5)))) SEPARATOR ', ') Results \
FROM (SELECT competitionId, eventId, pos, personId, personname, (CASE WHEN eventId LIKE '%bf' THEN best ELSE average END) result FROM podiums WHERE (CASE WHEN eventId LIKE '%bf' THEN best ELSE average END) > 0) a \
JOIN wca_dev.persons p ON a.personId = p.id AND p.subid = 1 \
JOIN wca_dev.competitions com ON a.competitionid = com.id \
WHERE eventId = '${i}' \
GROUP BY competitionId, eventId HAVING COUNT(*) = 3 \
ORDER BY SUM(result) LIMIT 100;" > ~/mysqloutput/original && \
	sed 's/\t/|/g' ~/mysqloutput/original > ~/mysqloutput/output && \
    sed -i.bak '2i\
--|--|--|--\' ~/mysqloutput/output
	output=$(cat ~/mysqloutput/output)
    date=$(date -r ~/databasedownload/wca-developer-database-dump.zip +"%a %b %d at %H%MUTC")
    awk -v r="$output" '{gsub(/podiumtable/,r)}1' ~/pages/WCA-Stats/templates/bestpodiums.md > ~/pages/WCA-Stats/bestpodiums/$i.md.tmp && \
	awk -v r="$i" '{gsub(/xxx/,r)}1' ~/pages/WCA-Stats/bestpodiums/$i.md.tmp > ~/pages/WCA-Stats/bestpodiums/$i.md.tmp2 && \
	awk -v r="$date" '{gsub(/today_date/,r)}1' ~/pages/WCA-Stats/bestpodiums/$i.md.tmp2 > ~/pages/WCA-Stats/bestpodiums/$i.md && \
	rm ~/pages/WCA-Stats/bestpodiums/*.tmp*
done

#pbstreaks

declare -a arr=(pb_streak pb_streak_exfmc pb_streak_exfmcbld)

for i in "${arr[@]}"
do
	if [ "$i" = "pb_streak" ]; then text=$(echo "PB Streak")
	elif [ "$i" = "pb_streak_exfmc" ]; then text=$(echo "PB Streak excluding FMC-Only Comps")
	elif [ "$i" = "pb_streak_exfmcbld"]; then text=$(echo "PB Streak excluding FMC-and-BLD-Only Comps")
	fi
	echo "Longest ${i}"
	mysql -u sam -p"$mysqlpw" wca_stats -e "SELECT CONCAT('[',p.name,'](https://www.worldcubeassociation.org/persons/',a.personId,')') name, a.pbStreak \`PB Streak\`, CONCAT('[',a.startcomp,'](https://www.worldcubeassociation.org/competitions/',a.startcomp,')') \`Start Comp\`, IF((SELECT id FROM ${i} WHERE personId = a.personId AND endcomp = a.endComp)=(SELECT MAX(id) FROM ${i} WHERE personId = a.personId),'',CONCAT('[',(SELECT competitionId FROM ${i} WHERE id = a.id + 1),'](https://www.worldcubeassociation.org/competitions/',(SELECT competitionId FROM ${i} WHERE id = a.id + 1),')' )) \`End Comp\` FROM ${i} a INNER JOIN (SELECT personId, startcomp, MAX(pbStreak) maxpbs FROM ${i} GROUP BY personId, startcomp) b ON a.personId = b.personId and a.startcomp = b.startcomp and b.maxpbs = a.pbstreak JOIN wca_dev.persons p ON a.personId = p.id ORDER BY a.pbStreak DESC LIMIT 100;" > ~/mysqloutput/original && \
	sed 's/\t/|/g' ~/mysqloutput/original > ~/mysqloutput/output && \
	sed -i.bak '2i\
--|--|--|--\' ~/mysqloutput/output
	output=$(cat ~/mysqloutput/output)
    date=$(date -r ~/databasedownload/wca-developer-database-dump.zip +"%a %b %d at %H%MUTC")
    awk -v r="$output" '{gsub(/pbstreaktable	/,r)}1' ~/pages/WCA-Stats/templates/pbstreak.md > ~/pages/WCA-Stats/pbstreaks/$i.md.tmp && \
    awk -v r="$text" '{gsub(/xxx/,r)}1' ~/pages/WCA-Stats/pbstreaks/$i.md.tmp > ~/pages/WCA-Stats/pbstreaks/$i.md.tmp2 && \
	awk -v r="$date" '{gsub(/today_date/,r)}1' ~/pages/WCA-Stats/pbstreaks/$i.md.tmp2 > ~/pages/WCA-Stats/pbstreaks/$i.md && \
	rm ~/pages/WCA-Stats/pbstreaks/*.tmp*
done

d=$(date +%Y-%m-%d)
cd ~/pages/WCA-Stats/ && git add -A && git commit -m "${d} update" && git push origin gh-pages
