#!/bin/bash

# Link to mysql password
source ~/.mysqlpw/mysql.conf

# bestaveragewithoutsubxsingle
mysql -u sam -p"$mysqlpw" wca_dev -e "SELECT CONCAT('[',p.name,'](https://www.worldcubeassociation.org/persons/',a.personId,')') Name, p.countryId Country, (SELECT best FROM rankssingle WHERE eventId = '333' AND personId = a.personId) Single, a.best Average FROM ranksaverage a INNER JOIN persons p ON p.subid = 1 AND a.personId = p.id WHERE a.eventId = '333' AND personId NOT IN (SELECT personId FROM rankssingle WHERE eventId = '333' AND best < 500) ORDER BY average ASC LIMIT 25;" > ~/mysqloutput/original && \
	sed 's/\t/|/g' ~/mysqloutput/original > ~/mysqloutput/output5 && \
	sed -i.bak '2i\
	--|--|--|--\' ~/mysqloutput/output5

mysql -u sam -p"$mysqlpw" wca_dev -e "SELECT CONCAT('[',p.name,'](https://www.worldcubeassociation.org/persons/',a.personId,')') Name, p.countryId Country, (SELECT best FROM rankssingle WHERE eventId = '333' AND personId = a.personId) Single, a.best Average FROM ranksaverage a INNER JOIN persons p ON p.subid = 1 AND a.personId = p.id WHERE a.eventId = '333' AND personId NOT IN (SELECT personId FROM rankssingle WHERE eventId = '333' AND best < 600) ORDER BY average ASC LIMIT 25;" > ~/mysqloutput/original && \
	sed 's/\t/|/g' ~/mysqloutput/original > ~/mysqloutput/output6 && \
	sed -i.bak '2i\
	--|--|--|--\' ~/mysqloutput/output6

mysql -u sam -p"$mysqlpw" wca_dev -e "SELECT CONCAT('[',p.name,'](https://www.worldcubeassociation.org/persons/',a.personId,')') Name, p.countryId Country, (SELECT best FROM rankssingle WHERE eventId = '333' AND personId = a.personId) Single, a.best Average FROM ranksaverage a INNER JOIN persons p ON p.subid = 1 AND a.personId = p.id WHERE a.eventId = '333' AND personId NOT IN (SELECT personId FROM rankssingle WHERE eventId = '333' AND best < 700) ORDER BY average ASC LIMIT 25;" > ~/mysqloutput/original && \
	sed 's/\t/|/g' ~/mysqloutput/original > ~/mysqloutput/output7 && \
	sed -i.bak '2i\
	--|--|--|--\' ~/mysqloutput/output7

mysql -u sam -p"$mysqlpw" wca_dev -e "SELECT CONCAT('[',p.name,'](https://www.worldcubeassociation.org/persons/',a.personId,')') Name, p.countryId Country, (SELECT best FROM rankssingle WHERE eventId = '333' AND personId = a.personId) Single, a.best Average FROM ranksaverage a INNER JOIN persons p ON p.subid = 1 AND a.personId = p.id WHERE a.eventId = '333' AND personId NOT IN (SELECT personId FROM rankssingle WHERE eventId = '333' AND best < 800) ORDER BY average ASC LIMIT 25;" > ~/mysqloutput/original && \
	sed 's/\t/|/g' ~/mysqloutput/original > ~/mysqloutput/output8 && \
	sed -i.bak '2i\
	--|--|--|--\' ~/mysqloutput/output8

mysql -u sam -p"$mysqlpw" wca_dev -e "SELECT CONCAT('[',p.name,'](https://www.worldcubeassociation.org/persons/',a.personId,')') Name, p.countryId Country, (SELECT best FROM rankssingle WHERE eventId = '333' AND personId = a.personId) Single, a.best Average FROM ranksaverage a INNER JOIN persons p ON p.subid = 1 AND a.personId = p.id WHERE a.eventId = '333' AND personId NOT IN (SELECT personId FROM rankssingle WHERE eventId = '333' AND best < 900) ORDER BY average ASC LIMIT 25;" > ~/mysqloutput/original && \
	sed 's/\t/|/g' ~/mysqloutput/original > ~/mysqloutput/output9 && \
	sed -i.bak '2i\
	--|--|--|--\' ~/mysqloutput/output9

mysql -u sam -p"$mysqlpw" wca_dev -e "SELECT CONCAT('[',p.name,'](https://www.worldcubeassociation.org/persons/',a.personId,')') Name, p.countryId Country, (SELECT best FROM rankssingle WHERE eventId = '333' AND personId = a.personId) Single, a.best Average FROM ranksaverage a INNER JOIN persons p ON p.subid = 1 AND a.personId = p.id WHERE a.eventId = '333' AND personId NOT IN (SELECT personId FROM rankssingle WHERE eventId = '333' AND best < 1000) ORDER BY average ASC LIMIT 25;" > ~/mysqloutput/original && \
	sed 's/\t/|/g' ~/mysqloutput/original > ~/mysqloutput/output10 && \
	sed -i.bak '2i\
	--|--|--|--\' ~/mysqloutput/output10

output5=$(cat ~/mysqloutput/output5)
output6=$(cat ~/mysqloutput/output6)
output7=$(cat ~/mysqloutput/output7)
output8=$(cat ~/mysqloutput/output8)
output9=$(cat ~/mysqloutput/output9)
output10=$(cat ~/mysqloutput/output10)
date=$(date -r ~/databasedownload/wca-developer-database-dump.zip +"%a %b %d - %H%Mh")

awk -v r="$output5" '{gsub(/sub5table/,r)}1' ~/WCA-Stats-docs-auto/WCA-Stats/docs/templates/bestaveragewithoutsubxsingle.md > ~/WCA-Stats-docs-auto/WCA-Stats/docs/bestaveragewithoutsubxsingle.tmp && \
awk -v r="$output6" '{gsub(/sub6table/,r)}1' ~/WCA-Stats-docs-auto/WCA-Stats/docs/bestaveragewithoutsubxsingle.tmp  > ~/WCA-Stats-docs-auto/WCA-Stats/docs/bestaveragewithoutsubxsingle.tmp2 && \
awk -v r="$output7" '{gsub(/sub7table/,r)}1' ~/WCA-Stats-docs-auto/WCA-Stats/docs/bestaveragewithoutsubxsingle.tmp2 > ~/WCA-Stats-docs-auto/WCA-Stats/docs/bestaveragewithoutsubxsingle.tmp3 && \
awk -v r="$output8" '{gsub(/sub8table/,r)}1' ~/WCA-Stats-docs-auto/WCA-Stats/docs/bestaveragewithoutsubxsingle.tmp3 > ~/WCA-Stats-docs-auto/WCA-Stats/docs/bestaveragewithoutsubxsingle.tmp4 && \
awk -v r="$output9" '{gsub(/sub9table/,r)}1' ~/WCA-Stats-docs-auto/WCA-Stats/docs/bestaveragewithoutsubxsingle.tmp4 > ~/WCA-Stats-docs-auto/WCA-Stats/docs/bestaveragewithoutsubxsingle.tmp5 && \
awk -v r="$output10" '{gsub(/sub10table/,r)}1' ~/WCA-Stats-docs-auto/WCA-Stats/docs/bestaveragewithoutsubxsingle.tmp5 > ~/WCA-Stats-docs-auto/WCA-Stats/docs/bestaveragewithoutsubxsingle.tmp6 && \
awk -v r="$date" '{gsub(/today_date/,r)}1' ~/WCA-Stats-docs-auto/WCA-Stats/docs/bestaveragewithoutsubxsingle.tmp6 > ~/WCA-Stats-docs-auto/WCA-Stats/docs/bestaveragewithoutsubxsingle.md 

rm ~/WCA-Stats-docs-auto/WCA-Stats/docs/bestaveragewithoutsubxsingle.tmp*

# 3x3 Podiums
mysql -u sam -p"$mysqlpw" wca_dev -e "SET @rank = 0; SELECT @rank := @rank + 1, a.* FROM (SELECT CONCAT("[",competitionId,"](https://www.worldcubeassociation.org/competitions/",competitionId,")") competition, IF(SUM(result) >= 360000, LEFT(TIME_FORMAT(SEC_TO_TIME(SUM(result/100)),"%H:%i:%s.%f"),11), IF(SUM(result) >= 6000, IF(SUM(result) < 60000, RIGHT(LEFT(TIME_FORMAT(SEC_TO_TIME(SUM(result/100)),"%i:%s.%f"),8),7), LEFT(TIME_FORMAT(SEC_TO_TIME(SUM(result/100)),"%i:%s.%f"),8)), IF(SUM(result) < 1000, RIGHT(LEFT(TIME_FORMAT(SEC_TO_TIME(SUM(result/100)),"%s.%f"),5),4), LEFT(TIME_FORMAT(SEC_TO_TIME(SUM(result/100)),"%s.%f"),5)))) sum, GROUP_CONCAT(CONCAT("[",p.name,"](https://www.worldcubeassociation.org/persons/",personId,")") SEPARATOR ', ') podiummers, GROUP_CONCAT(IF(result >= 360000,LEFT(TIME_FORMAT(SEC_TO_TIME(result/100),"%H:%i:%s.%f"),11),IF(result >= 6000,IF(result < 60000,RIGHT(LEFT(TIME_FORMAT(SEC_TO_TIME(result/100),"%i:%s.%f"),8),7),LEFT(TIME_FORMAT(SEC_TO_TIME(result/100),"%i:%s.%f"),8)),IF(result < 1000,RIGHT(LEFT(TIME_FORMAT(SEC_TO_TIME(result/100),"%s.%f"),5),4),LEFT(TIME_FORMAT(SEC_TO_TIME(result/100),"%s.%f"),5)))) SEPARATOR ', ') results FROM (SELECT competitionId, eventId, pos, personId, personname, (CASE WHEN eventId LIKE '%bf' THEN best ELSE average END) result FROM podiums WHERE (CASE WHEN eventId LIKE '%bf' THEN best ELSE average END) > 0) a JOIN wca_dev.persons p ON a.personId = p.id AND p.subid = 1 WHERE eventId = '333' GROUP BY competitionId, eventId HAVING COUNT(*) = 3 ORDER BY SUM(result)) a LIMIT 100" > ~/mysqloutput/original && \
	sed 's/\t/|/g' ~/mysqloutput/original > ~/mysqloutput/output && \
	sed -i.bak '2i\
	--|--|--|--\' ~/mysqloutput/output

	output=$(cat ~/mysqloutput/output)

	awk -v r="$output" '{gsub(/podiumtable/,r)}1' ~/WCA-Stats-docs-auto/WCA-Stats/docs/templates/best3x3podiums.md > ~/WCA-Stats-docs-auto/WCA-Stats/docs/best3x3podiums.md
