#!/bin/bash

#reset incase of any changes in the meantime
cd ~/pages/WCA-Stats/ && git reset --hard && git pull origin gh-pages
CHECK_MARK="\033[0;32m\xE2\x9C\x94\033[0m"

clear
echo -e "\n\e[4mCurrently executing:\e[0m"

# bestaveragewithoutsubxsingle

declare -a arr=(5 6 7 8 9 10)

for i in "${arr[@]}"
do
	start=$(date +%s%N | cut -b1-13)
	echo -n "Best Average without Sub ${i} Single"
	mysql --login-path=local wca_dev -e "SET @i = 1, @c = 0, @v = 0, @r = NULL;
	SELECT Rank, Name, Country, Single, Average
	FROM
		(SELECT
			@i := IF(@v = Average, @i, @i + @c) initrank,
			@c := IF(@v = Average, @c + 1, 1) counter,
			@r := IF(@v = Average, '=', @i) Rank,
			@v := Average val,
			b.*
		FROM	
			(SELECT 
				CONCAT('[',p.name,'](https://www.worldcubeassociation.org/persons/',a.personId,')') Name, 
				p.countryId Country, 
				(SELECT ROUND(best/100,2) FROM rankssingle WHERE eventId = '333' AND personId = a.personId) Single, 
				ROUND(a.best/100,2) Average
			FROM ranksaverage a 
			INNER JOIN persons p 
				ON p.subid = 1 AND a.personId = p.id 
			WHERE 
				a.eventId = '333' AND 
				personId NOT IN (SELECT personId FROM rankssingle WHERE eventId = '333' AND best < ${i}00) 
			ORDER BY average ASC, single ASC, p.name ASC 
			LIMIT 250) b
		) c;" > ~/mysqloutput/original && \
	sed 's/\t/|/g' ~/mysqloutput/original > ~/mysqloutput/output && \
	sed -i.bak '2i\
--|--|--|--|--\' ~/mysqloutput/output
	sed -i.bak 's/^/|/' ~/mysqloutput/output
	sed -i.bak 's/$/|  /' ~/mysqloutput/output
	output=$(cat ~/mysqloutput/output)
	date=$(date -r ~/databasedownload/wca-developer-database-dump.zip +"%a %b %d at %H%MUTC")
	cp ~/pages/WCA-Stats/templates/bestaveragewithoutsubxsingle.md ~/pages/WCA-Stats/bestaveragewithoutsubxsingle/sub$i.md.tmp
	cat ~/mysqloutput/output >> ~/pages/WCA-Stats/bestaveragewithoutsubxsingle/sub$i.md.tmp
	awk -v r="$i" '{gsub(/xxx/,r)}1' ~/pages/WCA-Stats/bestaveragewithoutsubxsingle/sub$i.md.tmp > ~/pages/WCA-Stats/bestaveragewithoutsubxsingle/sub$i.md.tmp2 && \
	awk -v r="$date" '{gsub(/today_date/,r)}1' ~/pages/WCA-Stats/bestaveragewithoutsubxsingle/sub$i.md.tmp2 > ~/pages/WCA-Stats/bestaveragewithoutsubxsingle/sub$i.md
	rm ~/pages/WCA-Stats/bestaveragewithoutsubxsingle/*.tmp*
	let finish=($(date +%s%N | cut -b1-13)-$start)
	echo -e "\\r${CHECK_MARK} Best Average without Sub ${i} Single (${finish}ms)"
done

# bestpodiums

mapfile -t arr < <(mysql --login-path=local --batch -se "SELECT id FROM wca_dev.Events WHERE rank < 900")

for i in "${arr[@]}"
do
	start=$(date +%s%N | cut -b1-13)
	echo -n "Best ${i} Podiums"
	mysql --login-path=local wca_stats -e "SET @i = 1, @c = 0, @v = 0, @r = NULL;
	SELECT Rank, Competition, Country, Sum, Podiummers, Results
	FROM	
		(SELECT
				@i := IF(CAST(@v AS CHAR) = CAST(sum AS CHAR), @i, @i + @c) initrank,
				@c := IF(CAST(@v AS CHAR) = CAST(sum AS CHAR), @c + 1, 1) counter,
				@r := IF(CAST(@v AS CHAR) = CAST(sum AS CHAR), '=', @i) Rank,
				@v := CAST(sum AS CHAR) val,
				a.*	
			FROM
				(SELECT 
					CONCAT('[',competitionId,'](https://www.worldcubeassociation.org/competitions/',competitionId,')') Competition,
					com.countryId Country, 
					IF('${i}' = '333mbf', CONCAT(297-SUM(LEFT(result,2))+SUM(RIGHT(result,2)),'/',297-SUM(LEFT(result,2))+(2*SUM(RIGHT(result,2))),' ',LEFT(TIME_FORMAT(SEC_TO_TIME(SUM(MID(result,4,4))),'%H:%i:%s'),8)), IF('${i}' = '333fm',SUM(ROUND(result/100,2)),IF( SUM(result) >= 360000, LEFT(TIME_FORMAT(SEC_TO_TIME(SUM(result/100)),'%H:%i:%s.%f'),11), IF( SUM(result) >= 6000, IF( SUM(result) < 60000, RIGHT(LEFT(TIME_FORMAT(SEC_TO_TIME(SUM(result/100)),'%i:%s.%f'),8),7), LEFT(TIME_FORMAT(SEC_TO_TIME(SUM(result/100)),'%i:%s.%f'),8)), IF( SUM(result) < 1000, RIGHT(LEFT(TIME_FORMAT(SEC_TO_TIME(SUM(result/100)),'%s.%f'),5),4), LEFT(TIME_FORMAT(SEC_TO_TIME(SUM(result/100)),'%s.%f'),5)))))) sum,
					GROUP_CONCAT(CONCAT('[',p.name,'](https://www.worldcubeassociation.org/persons/',personId,')') SEPARATOR ', ') Podiummers,
					GROUP_CONCAT(IF('${i}'='333mbf',CONCAT(99-LEFT(result,2)+RIGHT(result,2),'/',99-LEFT(result,2)+(2*RIGHT(result,2)),' ',LEFT(TIME_FORMAT(SEC_TO_TIME(MID(result,4,4)),'%H:%i:%s'),8)),IF( result >= 360000, LEFT(TIME_FORMAT(SEC_TO_TIME(result/100),'%H:%i:%s.%f'),11), IF( result >= 6000, IF( result < 60000, RIGHT(LEFT(TIME_FORMAT(SEC_TO_TIME(result/100),'%i:%s.%f'),8),7), LEFT(TIME_FORMAT(SEC_TO_TIME(result/100),'%i:%s.%f'),8)), IF(result < 1000, RIGHT(LEFT(TIME_FORMAT(SEC_TO_TIME(result/100),'%s.%f'),5),4), LEFT(TIME_FORMAT(SEC_TO_TIME(result/100),'%s.%f'),5))))) SEPARATOR ', ') Results
				FROM 
					(SELECT 
						competitionId, 
						eventId, 
						pos, 
						personId, 
						personname, 
						(CASE WHEN eventId LIKE '%bf' THEN best ELSE average END) result 
					FROM podiums 
					WHERE (CASE WHEN eventId LIKE '%bf' THEN best ELSE average END) > 0) a 
				JOIN wca_dev.persons p 
					ON a.personId = p.id AND p.subid = 1
				JOIN wca_dev.competitions com 
					ON a.competitionid = com.id
				WHERE eventId = '${i}'
				GROUP BY competitionId, eventId HAVING COUNT(*) = 3
				ORDER BY SUM(result), com.start_date LIMIT 1000) a
			) b;" > ~/mysqloutput/original && \
	sed 's/\t/|/g' ~/mysqloutput/original > ~/mysqloutput/output && \
    sed -i.bak '2i\
--|--|--|--|--|--\' ~/mysqloutput/output
	sed -i.bak 's/^/|/' ~/mysqloutput/output
	sed -i.bak 's/$/|  /' ~/mysqloutput/output
    date=$(date -r ~/databasedownload/wca-developer-database-dump.zip +"%a %b %d at %H%MUTC")
    cp ~/pages/WCA-Stats/templates/bestpodiums.md ~/pages/WCA-Stats/bestpodiums/"$i".md.tmp
	cat ~/mysqloutput/output >> ~/pages/WCA-Stats/bestpodiums/"$i".md.tmp
	awk -v r="$i" '{gsub(/xxx/,r)}1' ~/pages/WCA-Stats/bestpodiums/"$i".md.tmp > ~/pages/WCA-Stats/bestpodiums/"$i".md.tmp2 && \
	awk -v r="$date" '{gsub(/today_date/,r)}1' ~/pages/WCA-Stats/bestpodiums/"$i".md.tmp2 > ~/pages/WCA-Stats/bestpodiums/"$i".md && \
	rm ~/pages/WCA-Stats/bestpodiums/*.tmp*
	let finish=($(date +%s%N | cut -b1-13)-$start)
	echo -e "\\r${CHECK_MARK} Best ${i} Podiums (${finish}ms)"
done

#pbstreaks

declare -a arr=(pb_streak pb_streak_exfmc pb_streak_exfmcbld)

for i in "${arr[@]}"
do
	start=$(date +%s%N | cut -b1-13)
	if [ "$i" = "pb_streak" ]; then text=$(echo "PB Streak")
	elif [ "$i" = "pb_streak_exfmc" ]; then text=$(echo "PB Streak excluding FMC-Only Comps")
	elif [ "$i" = "pb_streak_exfmcbld" ]; then text=$(echo "PB Streak excluding FMC-and-BLD-Only Comps")
	fi
	echo -n "Longest ${i}"
	mysql --login-path=local wca_stats -e "SET @i = 1, @c = 0, @v = 0, @r = NULL;
	SELECT
		Rank, Name, \`PB Streak\`, \`Start Comp\`, \`End Comp\`
	FROM	
		(SELECT
				@i := IF(@v = \`PB Streak\`, @i, @i + @c) initrank,
				@c := IF(@v = \`PB Streak\`, @c + 1, 1) counter,
				@r := IF(@v = \`PB Streak\`, '=', @i) Rank,
				@v := \`PB Streak\` val,
				a.*
			FROM	
				(SELECT 
						CONCAT('[',p.name,'](https://www.worldcubeassociation.org/persons/',a.personId,')') name, 
						a.pbStreak \`PB Streak\`, 
						CONCAT('[',a.startcomp,'](https://www.worldcubeassociation.org/competitions/',a.startcomp,')') \`Start Comp\`, 
						IF((SELECT id FROM ${i} WHERE personId = a.personId AND endcomp = a.endComp)=(SELECT MAX(id) FROM ${i} WHERE personId = a.personId),'',CONCAT('[',(SELECT competitionId FROM ${i} WHERE id = a.id + 1),'](https://www.worldcubeassociation.org/competitions/',(SELECT competitionId FROM ${i} WHERE id = a.id + 1),')' )) \`End Comp\` 
					FROM ${i} a 
					INNER JOIN (SELECT personId, startcomp, MAX(pbStreak) maxpbs FROM ${i} GROUP BY personId, startcomp) b 
						ON a.personId = b.personId AND 
						a.startcomp = b.startcomp AND 
						b.maxpbs = a.pbstreak 
					JOIN wca_dev.persons p 
						ON a.personId = p.id AND p.subid = 1
					ORDER BY a.pbStreak DESC, p.name 
					LIMIT 1000) a
			) b;" > ~/mysqloutput/original && \
	sed 's/\t/|/g' ~/mysqloutput/original > ~/mysqloutput/output && \
	sed -i.bak '2i\
--|--|--|--|--\' ~/mysqloutput/output
	sed -i.bak 's/^/|/' ~/mysqloutput/output
	sed -i.bak 's/$/|  /' ~/mysqloutput/output
	date=$(date -r ~/databasedownload/wca-developer-database-dump.zip +"%a %b %d at %H%MUTC")
    cp ~/pages/WCA-Stats/templates/pbstreak.md ~/pages/WCA-Stats/pbstreaks/"$i".md.tmp
    cat ~/mysqloutput/output >> ~/pages/WCA-Stats/pbstreaks/"$i".md.tmp
    awk -v r="$text" '{gsub(/xxx/,r)}1' ~/pages/WCA-Stats/pbstreaks/"$i".md.tmp > ~/pages/WCA-Stats/pbstreaks/"$i".md.tmp2 && \
	awk -v r="$date" '{gsub(/today_date/,r)}1' ~/pages/WCA-Stats/pbstreaks/"$i".md.tmp2 > ~/pages/WCA-Stats/pbstreaks/"$i".md && \
	rm ~/pages/WCA-Stats/pbstreaks/*.tmp*
	let finish=($(date +%s%N | cut -b1-13)-$start)
	echo -e "\\r${CHECK_MARK} Longest ${i} (${finish}ms)"
done

#mostsubxsinglewithoutsubxaverage

declare -a arr=(6 7 8 9 10 11 12 13 14 15)

for i in "${arr[@]}"
do
	start=$(date +%s%N | cut -b1-13)
	echo -n "Most Sub-${i} Singles without a Sub-${i} Average"
	mysql --login-path=local wca_stats -e "SET @i = 1, @c = 0, @v = 0, @r = NULL;
	SELECT Rank, Name, \`Sub-${i}s\`, Average
	FROM
		(SELECT
			@i := IF(@v = \`Sub-${i}s\`, @i, @i + @c) initrank,
			@c := IF(@v = \`Sub-${i}s\`, @c + 1, 1) counter,
			@r := IF(@v = \`Sub-${i}s\`, '=', @i) Rank,
			@v := \`Sub-${i}s\` val,
			a.*
		FROM	
			(SELECT 
				CONCAT('[',personname,'](https://www.worldcubeassociation.org/persons/',personId,')') Name, 
				COUNT(*) \`Sub-${i}s\`, 
				(SELECT ROUND(best/100,2) FROM wca_dev.ranksaverage WHERE personId = a.personId AND eventId = '333') Average 
			FROM wca_stats.all_attempts a 
			WHERE 
				value > 0 AND 
				value < ${i}00 AND 
				eventId = '333' AND 
				personId NOT IN (SELECT personId FROM wca_dev.ranksaverage WHERE eventId = '333' AND best < ${i}00) 
			GROUP BY personId 
			ORDER BY COUNT(*) DESC, Average, personId 
			LIMIT 250) a
		) b;" > ~/mysqloutput/original && \
	sed 's/\t/|/g' ~/mysqloutput/original > ~/mysqloutput/output && \
	sed -i.bak '2i\
--|--|--|--\' ~/mysqloutput/output
	sed -i.bak 's/^/|/' ~/mysqloutput/output
	sed -i.bak 's/$/|  /' ~/mysqloutput/output
	date=$(date -r ~/databasedownload/wca-developer-database-dump.zip +"%a %b %d at %H%MUTC")
	cp ~/pages/WCA-Stats/templates/mostsubxsinglewithoutsubxaverage.md ~/pages/WCA-Stats/mostsubxsinglewithoutsubxaverage/"$i".md.tmp
	cat ~/mysqloutput/output >> ~/pages/WCA-Stats/mostsubxsinglewithoutsubxaverage/"$i".md.tmp
    awk -v r="$i" '{gsub(/xxx/,r)}1' ~/pages/WCA-Stats/mostsubxsinglewithoutsubxaverage/"$i".md.tmp > ~/pages/WCA-Stats/mostsubxsinglewithoutsubxaverage/"$i".md.tmp2 && \
	awk -v r="$date" '{gsub(/today_date/,r)}1' ~/pages/WCA-Stats/mostsubxsinglewithoutsubxaverage/"$i".md.tmp2 > ~/pages/WCA-Stats/mostsubxsinglewithoutsubxaverage/"$i".md && \
	rm ~/pages/WCA-Stats/mostsubxsinglewithoutsubxaverage/*.tmp*
	let finish=($(date +%s%N | cut -b1-13)-$start)
	echo -e "\\r${CHECK_MARK} Most Sub-${i} Singles without a Sub-${i} Average (${finish}ms)"
done

#registrationslist

declare -a arr=(name competitionId)

for i in "${arr[@]}"
do
	start=$(date +%s%N | cut -b1-13)
	echo -n "Registration List ordered by ${i}"
	mysql --login-path=local wca_stats -e "
	SELECT Name, Country, Competition, Registration_Status, LEFT(Events, LENGTH(Events)-1) Events
	FROM
		(SELECT
				IF(a.personId IS NULL,a.name,CONCAT('[',a.name,'](https://www.worldcubeassociation.org/persons/',a.personId,')')) Name,
				p.countryId Country,
				CONCAT('[',a.competitionId,'](https://www.worldcubeassociation.org/competitions/',a.competitionId,')') Competition,
				(CASE 
					WHEN acceptedAt IS NULL AND deletedAt IS NULL THEN 'Pending' 
					WHEN acceptedAt IS NOT NULL AND deletedAt IS NULL THEN 'Accepted'  
					WHEN deletedAt IS NOT NULL THEN 'Deleted' 
					ELSE 'Error' END) Registration_Status,  
				CONCAT(
					CASE WHEN a.333 = 1 THEN '333,' ELSE '' END,
					CASE WHEN a.222 = 1 THEN '222,' ELSE '' END,
					CASE WHEN a.444 = 1 THEN '444,' ELSE '' END,
					CASE WHEN a.555 = 1 THEN '555,' ELSE '' END,
					CASE WHEN a.666 = 1 THEN '666,' ELSE '' END,
					CASE WHEN a.777 = 1 THEN '777,' ELSE '' END,
					CASE WHEN a.333bf = 1 THEN '333bf,' ELSE '' END,
					CASE WHEN a.333fm = 1 THEN '333fm,' ELSE '' END,
					CASE WHEN a.333ft = 1 THEN '333ft,' ELSE '' END,
					CASE WHEN a.333oh = 1 THEN '333oh,' ELSE '' END,
					CASE WHEN a.clock = 1 THEN 'clock,' ELSE '' END,
					CASE WHEN a.minx = 1 THEN 'minx,' ELSE '' END,
					CASE WHEN a.pyram = 1 THEN 'pyram,' ELSE '' END,
					CASE WHEN a.skewb = 1 THEN 'skewb,' ELSE '' END,
					CASE WHEN a.sq1 = 1 THEN 'sq1,' ELSE '' END,
					CASE WHEN a.444bf = 1 THEN '444bf,' ELSE '' END,
					CASE WHEN a.555bf = 1 THEN '555bf,' ELSE '' END,
					CASE WHEN a.333mbf = 1 THEN '333mbf,' ELSE '' END) Events
			FROM registrations_extra a
			LEFT JOIN wca_dev.persons p 
				ON a.personId = p.id AND p.subid = 1
			WHERE a.endDate >= CURDATE() 
			ORDER BY ${i}, a.name, a.startDate, a.endDate) a;"> ~/mysqloutput/original && \
	sed 's/\t/|/g' ~/mysqloutput/original > ~/mysqloutput/output && \
	sed -i.bak '2i\
--|--|--|--|--\' ~/mysqloutput/output
	sed -i.bak 's/^/|/' ~/mysqloutput/output
	sed -i.bak 's/$/|  /' ~/mysqloutput/output
	date=$(date -r ~/databasedownload/wca-developer-database-dump.zip +"%a %b %d at %H%MUTC")
    cp ~/pages/WCA-Stats/templates/registrations.md ~/pages/WCA-Stats/registrations/"$i".md.tmp
    cat ~/mysqloutput/output >> ~/pages/WCA-Stats/registrations/"$i".md.tmp
    awk -v r="$i" '{gsub(/xxx/,r)}1' ~/pages/WCA-Stats/registrations/"$i".md.tmp > ~/pages/WCA-Stats/registrations/"$i".md.tmp2 && \
	awk -v r="$date" '{gsub(/today_date/,r)}1' ~/pages/WCA-Stats/registrations/"$i".md.tmp2 > ~/pages/WCA-Stats/registrations/"$i".md && \
	rm ~/pages/WCA-Stats/registrations/*.tmp*
	let finish=($(date +%s%N | cut -b1-13)-$start)
	echo -e "\\r${CHECK_MARK} Registration List ordered by ${i} (${finish}ms)"
done

#sumofbesttimesatcompetition

declare -a arr=(all ex45bf)

for i in "${arr[@]}"
do
	start=$(date +%s%N | cut -b1-13)
	echo -n "Sum of times at competition ${i}"
	if [ "$i" = "all" ]; 
		then 
			text=$(echo "All competitions excluding MBLD and FMC")
			mysql --login-path=local wca_dev -e "SET @i = 1, @c = 0, @v = 0, @r = NULL;
			SELECT Rank, Competition, Country, \`Sum\`
			FROM
				(SELECT
					@i := IF(CAST(@v AS CHAR) = CAST(\`Sum\` AS CHAR), @i, @i + @c) initrank,
					@c := IF(CAST(@v AS CHAR) = CAST(\`Sum\` AS CHAR), @c + 1, 1) counter,
					@r := IF(CAST(@v AS CHAR) = CAST(\`Sum\` AS CHAR), '=', @i) Rank,
					@v := \`Sum\` val,
					a.*
				FROM	
					(SELECT 
						CONCAT('[',competitionId,'](https://www.worldcubeassociation.org/competitions/',competitionId,')') Competition, 
						(SELECT countryId FROM competitions WHERE id = a.competitionId) Country, 
						LEFT(TIME_FORMAT(SEC_TO_TIME(SUM(best)/100),'%H:%i:%s.%f'),11) \`Sum\` 
					FROM 
						(SELECT 
							competitionId, 
							eventId, 
							MIN(best) best 
						FROM results 
						WHERE 
							competitionId IN 
								(SELECT competitionId 
								FROM results 
								WHERE 
									eventId IN ('333','222','444','555','666','777','333oh','333bf','333ft','clock','skewb','pyram','minx','sq1','444bf','555bf') AND 
									best > 0 
								GROUP BY competitionId 
									HAVING COUNT(DISTINCT eventId) = 16) AND 
							best > 0 AND 
							eventId NOT IN ('333mbf','333fm') 
						GROUP BY competitionId, eventId) a 
					GROUP BY competitionId 
					ORDER BY SUM(best) ASC, competitionId 
					LIMIT 500) a
				) b;" > ~/mysqloutput/original
		else 
			text=$(echo "All competitions excluding MBLD, FMC, 4BLD and 5BLD")
			mysql --login-path=local wca_dev -e "SET @i = 1, @c = 0, @v = 0, @r = NULL;
			SELECT Rank, Competition, Country, \`Sum\`
			FROM
				(SELECT
					@i := IF(CAST(@v AS CHAR) = CAST(\`Sum\` AS CHAR), @i, @i + @c) initrank,
					@c := IF(CAST(@v AS CHAR) = CAST(\`Sum\` AS CHAR), @c + 1, 1) counter,
					@r := IF(CAST(@v AS CHAR) = CAST(\`Sum\` AS CHAR), '=', @i) Rank,
					@v := \`Sum\` val,
					a.*
				FROM	
					(SELECT 
						CONCAT('[',competitionId,'](https://www.worldcubeassociation.org/competitions/',competitionId,')') Competition, 
						(SELECT countryId FROM competitions WHERE id = a.competitionId) Country, 
						LEFT(TIME_FORMAT(SEC_TO_TIME(SUM(best)/100),'%H:%i:%s.%f'),11) \`Sum\` 
					FROM 
						(SELECT 
							competitionId, 
							eventId, 
							MIN(best) best 
						FROM results 
						WHERE 
							competitionId IN 
								(SELECT competitionId 
								FROM results 
								WHERE 
									eventId IN ('333','222','444','555','666','777','333oh','333bf','333ft','clock','skewb','pyram','minx','sq1') AND 
									best > 0 
								GROUP BY competitionId 
									HAVING COUNT(DISTINCT eventId) = 14) AND 
							best > 0 AND 
							eventId NOT IN ('333mbf','333fm','444bf','555bf') 
						GROUP BY competitionId, eventId) a 
					GROUP BY competitionId 
					ORDER BY SUM(best) ASC, competitionId 
					LIMIT 500) a
				) b;" > ~/mysqloutput/original
	fi
	sed 's/\t/|/g' ~/mysqloutput/original > ~/mysqloutput/output
	sed -i.bak '2i\
--|--|--|--\' ~/mysqloutput/output
	sed -i.bak 's/^/|/' ~/mysqloutput/output
	sed -i.bak 's/$/|  /' ~/mysqloutput/output
	date=$(date -r ~/databasedownload/wca-developer-database-dump.zip +"%a %b %d at %H%MUTC")
	cp ~/pages/WCA-Stats/templates/sumbesttime.md ~/pages/WCA-Stats/sumbesttime/"$i".md.tmp
	cat ~/mysqloutput/output >> ~/pages/WCA-Stats/sumbesttime/"$i".md.tmp
	awk -v r="$text" '{gsub(/xxx/,r)}1' ~/pages/WCA-Stats/sumbesttime/"$i".md.tmp > ~/pages/WCA-Stats/sumbesttime/"$i".md.tmp2
	awk -v r="$date" '{gsub(/today_date/,r)}1' ~/pages/WCA-Stats/sumbesttime/"$i".md.tmp2 > ~/pages/WCA-Stats/sumbesttime/"$i".md
	rm ~/pages/WCA-Stats/sumbesttime/*.tmp*
	let finish=($(date +%s%N | cut -b1-13)-$start)
	echo -e "\\r${CHECK_MARK} Sum of times at competition ${i} (${finish}ms)"
done

#uowc

mapfile -t arr < <(mysql --login-path=local --batch -se "SELECT id FROM wca_dev.Events WHERE rank < 900")

for i in "${arr[@]}"
do
	start=$(date +%s%N | cut -b1-13)
	echo -n "Unofficial-Official ${i} World Champions"
	mysql --login-path=local wca_stats -e "SET @s = 0, @sr = NULL, @sd = NULL, @e = NULL, @p = NULL;
	SELECT
	  CONCAT('[',p.name,'](https://www.worldcubeassociation.org/persons/',b.uowcId,')') Name, 
	  p.countryId Country, 
	  b.startDate \`Date Set\`, 
	  CONCAT('[',b.startComp,' - ', rs.name,'](https://www.worldcubeassociation.org/competitions/',b.startComp,'/results/all#e',b.eventId,'_',b.startRound,')') \`Started At\`, 
	  IFNULL(IF(b.endComp = '1 year','1 year passed',CONCAT('[',b.endComp,' - ', re.name,'](https://www.worldcubeassociation.org/competitions/',b.endComp,'/results/all#e',b.eventId,'_',b.endRound,')')),'Ongoing') \`Ended At\`, 
	  IF(b.endComp IS NULL,DATEDIFF(CURDATE(),(SELECT end_date FROM wca_dev.competitions WHERE id = b.startComp)),IFNULL(DATEDIFF((SELECT end_date FROM wca_dev.competitions WHERE id = b.endComp),(SELECT end_date FROM wca_dev.competitions WHERE id = b.startComp)),365)) \`Days Held\`
	FROM
	  (SELECT a.*,
	    @s := IF(a.uowcId = @p, @s, competitionId) startComp,
	    @sr := IF(a.uowcId = @p, @sr, roundTypeId) startRound,
	    @sd := IF(a.uowcId = @p, @sd, dateSet) startDate,
	    @e := IF((SELECT uowcId FROM uowc WHERE id = a.id + 1 AND eventId = a.eventId) = a.uowcId, '',  IF((SELECT dateSet FROM uowc WHERE id = a.id + 1 AND eventId = a.eventId) > DATE_ADD(a.dateSet, INTERVAL 1 YEAR),'1 year',
		(SELECT competitionId FROM uowc WHERE id = a.id + 1 AND eventId = a.eventId))) endComp,
	    @er := IF((SELECT uowcId FROM uowc WHERE id = a.id + 1 AND eventId = a.eventId) = a.uowcId, '',  IF((SELECT dateSet FROM uowc WHERE id = a.id + 1 AND eventId = a.eventId) > DATE_ADD(a.dateSet, INTERVAL 1 YEAR),'1 year',
		(SELECT roundTypeId FROM uowc WHERE id = a.id + 1 AND eventId = a.eventId))) endRound,
	    @p := a.uowcId
	  FROM uowc a
	  WHERE eventId = '${i}') b
	LEFT JOIN wca_dev.roundtypes rs ON b.startRound = rs.id
	LEFT JOIN wca_dev.roundtypes re ON b.endRound = re.id
	LEFT JOIN wca_dev.persons p ON b.uowcId = p.id AND p.subid = 1
	WHERE (b.endComp <> '' OR b.endComp IS NULL) AND b.uowcId IS NOT NULL
	ORDER BY b.id;
	" > ~/mysqloutput/original && \
	sed 's/\t/|/g' ~/mysqloutput/original > ~/mysqloutput/output && \
	sed -i.bak '2i\
--|--|--|--|--|--\' ~/mysqloutput/output
	sed -i.bak 's/^/|/' ~/mysqloutput/output
	sed -i.bak 's/$/|  /' ~/mysqloutput/output
	date=$(date -r ~/databasedownload/wca-developer-database-dump.zip +"%a %b %d at %H%MUTC")
	cp ~/pages/WCA-Stats/templates/uowc.md ~/pages/WCA-Stats/uowc/"$i".md.tmp
	cat ~/mysqloutput/output >> ~/pages/WCA-Stats/uowc/"$i".md.tmp
    awk -v r="$i" '{gsub(/xxx/,r)}1' ~/pages/WCA-Stats/uowc/"$i".md.tmp > ~/pages/WCA-Stats/uowc/"$i".md.tmp2 && \
	awk -v r="$date" '{gsub(/today_date/,r)}1' ~/pages/WCA-Stats/uowc/"$i".md.tmp2 > ~/pages/WCA-Stats/uowc/"$i".md && \
	rm ~/pages/WCA-Stats/uowc/*.tmp*
	let finish=($(date +%s%N | cut -b1-13)-$start)
	echo -e "\\r${CHECK_MARK} Unofficial-Official ${i} World Champions (${finish}ms)"
done

#alleventsrelay

start=$(date +%s%N | cut -b1-13)
echo -n "All Events Relay"
mysql --login-path=local wca_stats -e "SET @i = 1, @c = 0, @v = 0, @r = NULL;
SELECT
  Rank, Name, Country, \`Relay Time\`, \`222\`, \`333\`, \`333bf\`, \`333ft\`, \`333oh\`, \`444\`, \`444bf\`, \`555\`, \`555bf\`, \`666\`, \`777\`, \`clock\`, \`minx\`, \`pyram\`, \`skewb\`, \`sq1\`
FROM
  (SELECT 
    @i := IF(CAST(@v AS CHAR) = CAST(\`Relay Time\` AS CHAR), @i, @i + @c) initrank,
    @c := IF(CAST(@v AS CHAR) = CAST(\`Relay Time\` AS CHAR), @c + 1, 1) counter,
    @r := IF(CAST(@v AS CHAR) = CAST(\`Relay Time\` AS CHAR), '=', @i) Rank,
    @v := \`Relay Time\` val,
    a.*
  FROM 
    (SELECT
      CONCAT('[',name,'](https://www.worldcubeassociation.org/persons/',personId,')') Name, 
      countryId Country, 
      CONCAT('**',CentisecondToTime(\`222s\`+\`333s\`+\`333bfs\`+\`333fts\`+\`333ohs\`+\`444s\`+\`444bfs\`+\`555s\`+\`555bfs\`+\`666s\`+\`777s\`+\`clocks\`+\`minxs\`+\`pyrams\`+\`skewbs\`+\`sq1s\`),'**') \`Relay Time\`,
      CentisecondToTime(\`222s\`) \`222\`,
      CentisecondToTime(\`333s\`) \`333\`,
      CentisecondToTime(\`333bfs\`) \`333bf\`,
      CentisecondToTime(\`333fts\`) \`333ft\`,
      CentisecondToTime(\`333ohs\`) \`333oh\`,
      CentisecondToTime(\`444s\`) \`444\`,
      CentisecondToTime(\`444bfs\`) \`444bf\`,
      CentisecondToTime(\`555s\`) \`555\`,
      CentisecondToTime(\`555bfs\`) \`555bf\`,
      CentisecondToTime(\`666s\`) \`666\`,
      CentisecondToTime(\`777s\`) \`777\`,
      CentisecondToTime(\`clocks\`) \`clock\`,
      CentisecondToTime(\`minxs\`) \`minx\`,
      CentisecondToTime(\`pyrams\`) \`pyram\`,
      CentisecondToTime(\`skewbs\`) \`skewb\`,
      CentisecondToTime(\`sq1s\`) \`sq1\`
    FROM
      all_events_rank
    WHERE
    personId IN 
      (SELECT personId FROM wca_dev.rankssingle WHERE eventId IN ('222','333','444','555','333oh','skewb','minx','pyram','clock','sq1','666','777','333ft','333bf','444bf','555bf') GROUP BY personId HAVING COUNT(*) = 16)
    ORDER BY \`222s\`+\`333s\`+\`333bfs\`+\`333fts\`+\`333ohs\`+\`444s\`+\`444bfs\`+\`555s\`+\`555bfs\`+\`666s\`+\`777s\`+\`clocks\`+\`minxs\`+\`pyrams\`+\`skewbs\`+\`sq1s\` LIMIT 1000) a) b;
" > ~/mysqloutput/all_events_relay
let finish=($(date +%s%N | cut -b1-13)-$start)
echo -e "\\r${CHECK_MARK} All Events Relay (${finish}ms)"

#guildford

start=$(date +%s%N | cut -b1-13)
echo -n "Guildford Relay"
mysql --login-path=local wca_stats -e "SET @i = 1, @c = 0, @v = 0, @r = NULL;
SELECT
  Rank, Name, Country, \`Relay Time\`, \`222\`, \`333\`, \`333ft\`, \`333oh\`, \`444\`, \`555\`, \`666\`, \`777\`, \`clock\`, \`minx\`, \`pyram\`, \`skewb\`, \`sq1\`
FROM
  (SELECT 
    @i := IF(CAST(@v AS CHAR) = CAST(\`Relay Time\` AS CHAR), @i, @i + @c) initrank,
    @c := IF(CAST(@v AS CHAR) = CAST(\`Relay Time\` AS CHAR), @c + 1, 1) counter,
    @r := IF(CAST(@v AS CHAR) = CAST(\`Relay Time\` AS CHAR), '=', @i) Rank,
    @v := \`Relay Time\` val,
    a.*
  FROM 
    (SELECT
      CONCAT('[',name,'](https://www.worldcubeassociation.org/persons/',personId,')') Name, 
      countryId Country, 
      CONCAT('**',CentisecondToTime(\`222s\`+\`333s\`+\`333fts\`+\`333ohs\`+\`444s\`+\`555s\`+\`666s\`+\`777s\`+\`clocks\`+\`minxs\`+\`pyrams\`+\`skewbs\`+\`sq1s\`),'**') \`Relay Time\`,
      CentisecondToTime(\`222s\`) \`222\`,
      CentisecondToTime(\`333s\`) \`333\`,
      CentisecondToTime(\`333fts\`) \`333ft\`,
      CentisecondToTime(\`333ohs\`) \`333oh\`,
      CentisecondToTime(\`444s\`) \`444\`,
      CentisecondToTime(\`555s\`) \`555\`,
      CentisecondToTime(\`666s\`) \`666\`,
      CentisecondToTime(\`777s\`) \`777\`,
      CentisecondToTime(\`clocks\`) \`clock\`,
      CentisecondToTime(\`minxs\`) \`minx\`,
      CentisecondToTime(\`pyrams\`) \`pyram\`,
      CentisecondToTime(\`skewbs\`) \`skewb\`,
      CentisecondToTime(\`sq1s\`) \`sq1\`
    FROM
      all_events_rank
    WHERE
    personId IN 
      (SELECT personId FROM wca_dev.rankssingle WHERE eventId IN ('222','333','444','555','333oh','skewb','minx','pyram','clock','sq1','666','777','333ft') GROUP BY personId HAVING COUNT(*) = 13)
    ORDER BY \`222s\`+\`333s\`+\`333fts\`+\`333ohs\`+\`444s\`+\`555s\`+\`666s\`+\`777s\`+\`clocks\`+\`minxs\`+\`pyrams\`+\`skewbs\`+\`sq1s\` LIMIT 1000) a) b;
" > ~/mysqloutput/guildford
let finish=($(date +%s%N | cut -b1-13)-$start)
echo -e "\\r${CHECK_MARK} Guildford Relay (${finish}ms)"

#miniguildford

start=$(date +%s%N | cut -b1-13)
echo -n "Mini-Guildford Relay"
mysql --login-path=local wca_stats -e "SET @i = 1, @c = 0, @v = 0, @r = NULL;
SELECT
  Rank, Name, Country, \`Relay Time\`, \`222\`, \`333\`, \`333oh\`, \`444\`, \`555\`, \`clock\`, \`minx\`, \`pyram\`, \`skewb\`, \`sq1\`
FROM
  (SELECT 
    @i := IF(CAST(@v AS CHAR) = CAST(\`Relay Time\` AS CHAR), @i, @i + @c) initrank,
    @c := IF(CAST(@v AS CHAR) = CAST(\`Relay Time\` AS CHAR), @c + 1, 1) counter,
    @r := IF(CAST(@v AS CHAR) = CAST(\`Relay Time\` AS CHAR), '=', @i) Rank,
    @v := \`Relay Time\` val,
    a.*
  FROM 
    (SELECT
      CONCAT('[',name,'](https://www.worldcubeassociation.org/persons/',personId,')') Name, 
      countryId Country, 
      CONCAT('**',CentisecondToTime(\`222s\`+\`333s\`+\`333ohs\`+\`444s\`+\`555s\`+\`clocks\`+\`minxs\`+\`pyrams\`+\`skewbs\`+\`sq1s\`),'**') \`Relay Time\`,
      CentisecondToTime(\`222s\`) \`222\`,
      CentisecondToTime(\`333s\`) \`333\`,
      CentisecondToTime(\`333ohs\`) \`333oh\`,
      CentisecondToTime(\`444s\`) \`444\`,
      CentisecondToTime(\`555s\`) \`555\`,
      CentisecondToTime(\`clocks\`) \`clock\`,
      CentisecondToTime(\`minxs\`) \`minx\`,
      CentisecondToTime(\`pyrams\`) \`pyram\`,
      CentisecondToTime(\`skewbs\`) \`skewb\`,
      CentisecondToTime(\`sq1s\`) \`sq1\`
    FROM
      all_events_rank
    WHERE
    personId IN 
      (SELECT personId FROM wca_dev.rankssingle WHERE eventId IN ('222','333','444','555','333oh','skewb','minx','pyram','clock','sq1') GROUP BY personId HAVING COUNT(*) = 10)
    ORDER BY \`222s\`+\`333s\`+\`333ohs\`+\`444s\`+\`555s\`+\`clocks\`+\`minxs\`+\`pyrams\`+\`skewbs\`+\`sq1s\` LIMIT 1000) a) b;
" > ~/mysqloutput/mini_guildford
let finish=($(date +%s%N | cut -b1-13)-$start)
echo -e "\\r${CHECK_MARK} Mini-Guildford Relay (${finish}ms)"

#234567

start=$(date +%s%N | cut -b1-13)
echo -n "2-7 Relay"
mysql --login-path=local wca_stats -e "SET @i = 1, @c = 0, @v = 0, @r = NULL;
SELECT
  Rank, Name, Country, \`Relay Time\`, \`222\`, \`333\`, \`444\`, \`555\`, \`666\`, \`777\`
FROM
  (SELECT 
    @i := IF(CAST(@v AS CHAR) = CAST(\`Relay Time\` AS CHAR), @i, @i + @c) initrank,
    @c := IF(CAST(@v AS CHAR) = CAST(\`Relay Time\` AS CHAR), @c + 1, 1) counter,
    @r := IF(CAST(@v AS CHAR) = CAST(\`Relay Time\` AS CHAR), '=', @i) Rank,
    @v := \`Relay Time\` val,
    a.*
  FROM 
    (SELECT
      CONCAT('[',name,'](https://www.worldcubeassociation.org/persons/',personId,')') Name, 
      countryId Country, 
      CONCAT('**',CentisecondToTime(\`222s\`+\`333s\`+\`444s\`+\`555s\`+\`666s\`+\`777s\`),'**') \`Relay Time\`,
      CentisecondToTime(\`222s\`) \`222\`,
      CentisecondToTime(\`333s\`) \`333\`,
      CentisecondToTime(\`444s\`) \`444\`,
      CentisecondToTime(\`555s\`) \`555\`,
      CentisecondToTime(\`666s\`) \`666\`,
      CentisecondToTime(\`777s\`) \`777\`
    FROM
      all_events_rank
    WHERE
    personId IN 
      (SELECT personId FROM wca_dev.rankssingle WHERE eventId IN ('222','333','444','555','666','777') GROUP BY personId HAVING COUNT(*) = 6)
    ORDER BY \`222s\`+\`333s\`+\`444s\`+\`555s\`+\`666s\`+\`777s\` LIMIT 1000) a) b;
" > ~/mysqloutput/234567
let finish=($(date +%s%N | cut -b1-13)-$start)
echo -e "\\r${CHECK_MARK} 2-7 Relay (${finish}ms)"

#23456

start=$(date +%s%N | cut -b1-13)
echo -n "2-6 Relay"
mysql --login-path=local wca_stats -e "SET @i = 1, @c = 0, @v = 0, @r = NULL;
SELECT
  Rank, Name, Country, \`Relay Time\`, \`222\`, \`333\`, \`444\`, \`555\`, \`666\`
FROM
  (SELECT 
    @i := IF(CAST(@v AS CHAR) = CAST(\`Relay Time\` AS CHAR), @i, @i + @c) initrank,
    @c := IF(CAST(@v AS CHAR) = CAST(\`Relay Time\` AS CHAR), @c + 1, 1) counter,
    @r := IF(CAST(@v AS CHAR) = CAST(\`Relay Time\` AS CHAR), '=', @i) Rank,
    @v := \`Relay Time\` val,
    a.*
  FROM 
    (SELECT
      CONCAT('[',name,'](https://www.worldcubeassociation.org/persons/',personId,')') Name, 
      countryId Country, 
      CONCAT('**',CentisecondToTime(\`222s\`+\`333s\`+\`444s\`+\`555s\`+\`666s\`),'**') \`Relay Time\`,
      CentisecondToTime(\`222s\`) \`222\`,
      CentisecondToTime(\`333s\`) \`333\`,
      CentisecondToTime(\`444s\`) \`444\`,
      CentisecondToTime(\`555s\`) \`555\`,
      CentisecondToTime(\`666s\`) \`666\`
    FROM
      all_events_rank
    WHERE
    personId IN 
      (SELECT personId FROM wca_dev.rankssingle WHERE eventId IN ('222','333','444','555','666') GROUP BY personId HAVING COUNT(*) = 5)
    ORDER BY \`222s\`+\`333s\`+\`444s\`+\`555s\`+\`666s\` LIMIT 1000) a) b;
" > ~/mysqloutput/23456
let finish=($(date +%s%N | cut -b1-13)-$start)
echo -e "\\r${CHECK_MARK} 2-6 Relay (${finish}ms)"

#2345

start=$(date +%s%N | cut -b1-13)
echo -n "2-5 Relay"
mysql --login-path=local wca_stats -e "SET @i = 1, @c = 0, @v = 0, @r = NULL;
SELECT
  Rank, Name, Country, \`Relay Time\`, \`222\`, \`333\`, \`444\`, \`555\`
FROM
  (SELECT 
    @i := IF(CAST(@v AS CHAR) = CAST(\`Relay Time\` AS CHAR), @i, @i + @c) initrank,
    @c := IF(CAST(@v AS CHAR) = CAST(\`Relay Time\` AS CHAR), @c + 1, 1) counter,
    @r := IF(CAST(@v AS CHAR) = CAST(\`Relay Time\` AS CHAR), '=', @i) Rank,
    @v := \`Relay Time\` val,
    a.*
  FROM 
    (SELECT
      CONCAT('[',name,'](https://www.worldcubeassociation.org/persons/',personId,')') Name, 
      countryId Country, 
      CONCAT('**',CentisecondToTime(\`222s\`+\`333s\`+\`444s\`+\`555s\`),'**') \`Relay Time\`,
      CentisecondToTime(\`222s\`) \`222\`,
      CentisecondToTime(\`333s\`) \`333\`,
      CentisecondToTime(\`444s\`) \`444\`,
      CentisecondToTime(\`555s\`) \`555\`
    FROM
      all_events_rank
    WHERE
    personId IN 
      (SELECT personId FROM wca_dev.rankssingle WHERE eventId IN ('222','333','444','555') GROUP BY personId HAVING COUNT(*) = 4)
    ORDER BY \`222s\`+\`333s\`+\`444s\`+\`555s\` LIMIT 1000) a) b;
" > ~/mysqloutput/2345
let finish=($(date +%s%N | cut -b1-13)-$start)
echo -e "\\r${CHECK_MARK} 2-5 Relay (${finish}ms)"

#234

start=$(date +%s%N | cut -b1-13)
echo -n "2-4 Relay"
mysql --login-path=local wca_stats -e "SET @i = 1, @c = 0, @v = 0, @r = NULL;
SELECT
  Rank, Name, Country, \`Relay Time\`, \`222\`, \`333\`, \`444\`
FROM
  (SELECT 
    @i := IF(CAST(@v AS CHAR) = CAST(\`Relay Time\` AS CHAR), @i, @i + @c) initrank,
    @c := IF(CAST(@v AS CHAR) = CAST(\`Relay Time\` AS CHAR), @c + 1, 1) counter,
    @r := IF(CAST(@v AS CHAR) = CAST(\`Relay Time\` AS CHAR), '=', @i) Rank,
    @v := \`Relay Time\` val,
    a.*
  FROM 
    (SELECT
      CONCAT('[',name,'](https://www.worldcubeassociation.org/persons/',personId,')') Name, 
      countryId Country, 
      CONCAT('**',CentisecondToTime(\`222s\`+\`333s\`+\`444s\`),'**') \`Relay Time\`,
      CentisecondToTime(\`222s\`) \`222\`,
      CentisecondToTime(\`333s\`) \`333\`,
      CentisecondToTime(\`444s\`) \`444\`
    FROM
      all_events_rank
    WHERE
    personId IN 
      (SELECT personId FROM wca_dev.rankssingle WHERE eventId IN ('222','333','444') GROUP BY personId HAVING COUNT(*) = 3)
    ORDER BY \`222s\`+\`333s\`+\`444s\` LIMIT 1000) a) b;
" > ~/mysqloutput/234
let finish=($(date +%s%N | cut -b1-13)-$start)
echo -e "\\r${CHECK_MARK} 2-4 Relay (${finish}ms)"

#333events

start=$(date +%s%N | cut -b1-13)
echo -n "3x3 Events Relay"
mysql --login-path=local wca_stats -e "SET @i = 1, @c = 0, @v = 0, @r = NULL;
SELECT
  Rank, Name, Country, \`Relay Time\`, \`333\`, \`333bf\`, \`333ft\`, \`333oh\`
FROM
  (SELECT 
    @i := IF(CAST(@v AS CHAR) = CAST(\`Relay Time\` AS CHAR), @i, @i + @c) initrank,
    @c := IF(CAST(@v AS CHAR) = CAST(\`Relay Time\` AS CHAR), @c + 1, 1) counter,
    @r := IF(CAST(@v AS CHAR) = CAST(\`Relay Time\` AS CHAR), '=', @i) Rank,
    @v := \`Relay Time\` val,
    a.*
  FROM 
    (SELECT
      CONCAT('[',name,'](https://www.worldcubeassociation.org/persons/',personId,')') Name, 
      countryId Country, 
      CONCAT('**',CentisecondToTime(\`333s\`+\`333bfs\`+\`333fts\`+\`333ohs\`),'**') \`Relay Time\`,
      CentisecondToTime(\`333s\`) \`333\`,
      CentisecondToTime(\`333bfs\`) \`333bf\`,
      CentisecondToTime(\`333fts\`) \`333ft\`,
      CentisecondToTime(\`333ohs\`) \`333oh\`
    FROM
      all_events_rank
    WHERE
    personId IN 
      (SELECT personId FROM wca_dev.rankssingle WHERE eventId IN ('333','333bf','333ft','333oh') GROUP BY personId HAVING COUNT(*) = 4)
    ORDER BY \`333s\`+\`333bfs\`+\`333fts\`+\`333ohs\` LIMIT 1000) a) b;
" > ~/mysqloutput/333events
let finish=($(date +%s%N | cut -b1-13)-$start)
echo -e "\\r${CHECK_MARK} 3x3 Events Relay (${finish}ms)"

#333eventsnofeet

start=$(date +%s%N | cut -b1-13)
echo -n "3x3 OH BLD Relay"
mysql --login-path=local wca_stats -e "SET @i = 1, @c = 0, @v = 0, @r = NULL;
SELECT
  Rank, Name, Country, \`Relay Time\`, \`333\`, \`333bf\`, \`333oh\`
FROM
  (SELECT 
    @i := IF(CAST(@v AS CHAR) = CAST(\`Relay Time\` AS CHAR), @i, @i + @c) initrank,
    @c := IF(CAST(@v AS CHAR) = CAST(\`Relay Time\` AS CHAR), @c + 1, 1) counter,
    @r := IF(CAST(@v AS CHAR) = CAST(\`Relay Time\` AS CHAR), '=', @i) Rank,
    @v := \`Relay Time\` val,
    a.*
  FROM 
    (SELECT
      CONCAT('[',name,'](https://www.worldcubeassociation.org/persons/',personId,')') Name, 
      countryId Country, 
      CONCAT('**',CentisecondToTime(\`333s\`+\`333bfs\`+\`333ohs\`),'**') \`Relay Time\`,
      CentisecondToTime(\`333s\`) \`333\`,
      CentisecondToTime(\`333bfs\`) \`333bf\`,
      CentisecondToTime(\`333ohs\`) \`333oh\`
    FROM
      all_events_rank
    WHERE
    personId IN 
      (SELECT personId FROM wca_dev.rankssingle WHERE eventId IN ('333','333bf','333oh') GROUP BY personId HAVING COUNT(*) = 3)
    ORDER BY \`333s\`+\`333bfs\`+\`333ohs\` LIMIT 1000) a) b;
" > ~/mysqloutput/333eventsnofeet
let finish=($(date +%s%N | cut -b1-13)-$start)
echo -e "\\r${CHECK_MARK} 3x3 OH BLD Relay (${finish}ms)"

#bldevents

start=$(date +%s%N | cut -b1-13)
echo -n "BLD Events Relay"
mysql --login-path=local wca_stats -e "SET @i = 1, @c = 0, @v = 0, @r = NULL;
SELECT
  Rank, Name, Country, \`Relay Time\`, \`333bf\`, \`444bf\`, \`555bf\`
FROM
  (SELECT 
    @i := IF(CAST(@v AS CHAR) = CAST(\`Relay Time\` AS CHAR), @i, @i + @c) initrank,
    @c := IF(CAST(@v AS CHAR) = CAST(\`Relay Time\` AS CHAR), @c + 1, 1) counter,
    @r := IF(CAST(@v AS CHAR) = CAST(\`Relay Time\` AS CHAR), '=', @i) Rank,
    @v := \`Relay Time\` val,
    a.*
  FROM 
    (SELECT
      CONCAT('[',name,'](https://www.worldcubeassociation.org/persons/',personId,')') Name, 
      countryId Country, 
      CONCAT('**',CentisecondToTime(\`333bfs\`+\`444bfs\`+\`555bfs\`),'**') \`Relay Time\`,
      CentisecondToTime(\`333bfs\`) \`333bf\`,
      CentisecondToTime(\`444bfs\`) \`444bf\`,
      CentisecondToTime(\`555bfs\`) \`555bf\`
    FROM
      all_events_rank
    WHERE
    personId IN 
      (SELECT personId FROM wca_dev.rankssingle WHERE eventId IN ('333bf','444bf','555bf') GROUP BY personId HAVING COUNT(*) = 3)
    ORDER BY \`333bfs\`+\`444bfs\`+\`555bfs\` LIMIT 1000) a) b;
" > ~/mysqloutput/bld
let finish=($(date +%s%N | cut -b1-13)-$start)
echo -e "\\r${CHECK_MARK} BLD Events Relay (${finish}ms)"

#sideevents

start=$(date +%s%N | cut -b1-13)
echo -n "Side Events Relay"
mysql --login-path=local wca_stats -e "SET @i = 1, @c = 0, @v = 0, @r = NULL;
SELECT
  Rank, Name, Country, \`Relay Time\`, \`clock\`, \`minx\`, \`pyram\`, \`skewb\`, \`sq1\`
FROM
  (SELECT 
    @i := IF(CAST(@v AS CHAR) = CAST(\`Relay Time\` AS CHAR), @i, @i + @c) initrank,
    @c := IF(CAST(@v AS CHAR) = CAST(\`Relay Time\` AS CHAR), @c + 1, 1) counter,
    @r := IF(CAST(@v AS CHAR) = CAST(\`Relay Time\` AS CHAR), '=', @i) Rank,
    @v := \`Relay Time\` val,
    a.*
  FROM 
    (SELECT
      CONCAT('[',name,'](https://www.worldcubeassociation.org/persons/',personId,')') Name, 
      countryId Country, 
      CONCAT('**',CentisecondToTime(\`clocks\`+\`minxs\`+\`pyrams\`+\`skewbs\`+\`sq1s\`),'**') \`Relay Time\`,
      CentisecondToTime(\`clocks\`) \`clock\`,
      CentisecondToTime(\`minxs\`) \`minx\`,
      CentisecondToTime(\`pyrams\`) \`pyram\`,
      CentisecondToTime(\`skewbs\`) \`skewb\`,
      CentisecondToTime(\`sq1s\`) \`sq1\`
    FROM
      all_events_rank
    WHERE
    personId IN 
      (SELECT personId FROM wca_dev.rankssingle WHERE eventId IN ('clock','minx','pyram','skewb','sq1') GROUP BY personId HAVING COUNT(*) = 5)
    ORDER BY \`clocks\`+\`minxs\`+\`pyrams\`+\`skewbs\`+\`sq1s\` LIMIT 1000) a) b;
" > ~/mysqloutput/side
let finish=($(date +%s%N | cut -b1-13)-$start)
echo -e "\\r${CHECK_MARK} Side Events Relay (${finish}ms)"

#fastevents

start=$(date +%s%N | cut -b1-13)
echo -n "Fast Events Relay"
mysql --login-path=local wca_stats -e "SET @i = 1, @c = 0, @v = 0, @r = NULL;
SELECT
  Rank, Name, Country, \`Relay Time\`, \`222\`, \`pyram\`, \`skewb\`
FROM
  (SELECT 
    @i := IF(CAST(@v AS CHAR) = CAST(\`Relay Time\` AS CHAR), @i, @i + @c) initrank,
    @c := IF(CAST(@v AS CHAR) = CAST(\`Relay Time\` AS CHAR), @c + 1, 1) counter,
    @r := IF(CAST(@v AS CHAR) = CAST(\`Relay Time\` AS CHAR), '=', @i) Rank,
    @v := \`Relay Time\` val,
    a.*
  FROM 
    (SELECT
      CONCAT('[',name,'](https://www.worldcubeassociation.org/persons/',personId,')') Name, 
      countryId Country, 
      CONCAT('**',CentisecondToTime(\`222s\`+\`pyrams\`+\`skewbs\`),'**') \`Relay Time\`,
      CentisecondToTime(\`222s\`) \`222\`,
      CentisecondToTime(\`pyrams\`) \`pyram\`,
      CentisecondToTime(\`skewbs\`) \`skewb\`
    FROM
      all_events_rank
    WHERE
    personId IN 
      (SELECT personId FROM wca_dev.rankssingle WHERE eventId IN ('222','pyram','skewb') GROUP BY personId HAVING COUNT(*) = 3)
    ORDER BY \`222s\`+\`pyrams\`+\`skewbs\` LIMIT 1000) a) b;
" > ~/mysqloutput/fast
let finish=($(date +%s%N | cut -b1-13)-$start)
echo -e "\\r${CHECK_MARK} Fast Events Relay (${finish}ms)"

declare -a arr=(all_events_relay guildford mini_guildford 234 2345 23456 234567 333events 333eventsnofeet bld side fast)

for i in "${arr[@]}"
do
	start=$(date +%s%N | cut -b1-13)
	echo -n "${i} Relay formatinng"
	sed 's/\t/|/g' ~/mysqloutput/"${i}" > ~/mysqloutput/"${i}"output && \
	sed -i.bak '2i\
--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--\' ~/mysqloutput/"${i}"output
	sed -i.bak 's/^/|/' ~/mysqloutput/"${i}"output
	sed -i.bak 's/$/|  /' ~/mysqloutput/"${i}"output
	date=$(date -r ~/databasedownload/wca-developer-database-dump.zip +"%a %b %d at %H%MUTC")
	cp ~/pages/WCA-Stats/templates/relays.md ~/pages/WCA-Stats/relays/"$i".md.tmp
	cat ~/mysqloutput/"${i}"output >> ~/pages/WCA-Stats/relays/"$i".md.tmp
    awk -v r="$i" '{gsub(/xxx/,r)}1' ~/pages/WCA-Stats/relays/"$i".md.tmp > ~/pages/WCA-Stats/relays/"$i".md.tmp2 && \
	awk -v r="$date" '{gsub(/today_date/,r)}1' ~/pages/WCA-Stats/relays/"$i".md.tmp2 > ~/pages/WCA-Stats/relays/"$i".md && \
	rm ~/pages/WCA-Stats/relays/*.tmp*
	let finish=($(date +%s%N | cut -b1-13)-$start)
	echo -e "\\r${CHECK_MARK} ${i} Relay Formatting (${finish}ms)"
done

#Kinch

declare -a arr=(WorldKinch ContinentKinch CountryKinch)

for i in "${arr[@]}"
do
	start=$(date +%s%N | cut -b1-13)
	echo -n "${i}"
	mysql --login-path=local wca_stats -e "SET @i = 1, @c = 0, @v = 0, @r = NULL;
	SELECT Rank, Name, Country, ${i}
	FROM
	(SELECT 
			@i := IF(@v = ${i}, @i, @i + @c) initrank,
			@c := IF(@v = ${i}, @c + 1, 1) counter,
			@r := IF(@v = ${i}, '=', @i) Rank,
			@v := ${i} val,
			a.*
		FROM
		(SELECT CONCAT('[',name,'](https://www.worldcubeassociation.org/persons/',personId,')') Name, countryId Country, ${i} FROM kinch ORDER BY ${i} DESC LIMIT 1000) a) b;" > ~/mysqloutput/original && \
	sed 's/\t/|/g' ~/mysqloutput/original > ~/mysqloutput/output && \
	sed -i.bak '2i\
--|--|--|--|--\' ~/mysqloutput/output
	sed -i.bak 's/^/|/' ~/mysqloutput/output
	sed -i.bak 's/$/|  /' ~/mysqloutput/output
	date=$(date -r ~/databasedownload/wca-developer-database-dump.zip +"%a %b %d at %H%MUTC")
    cp ~/pages/WCA-Stats/templates/kinch.md ~/pages/WCA-Stats/kinch/"$i".md.tmp
    cat ~/mysqloutput/output >> ~/pages/WCA-Stats/kinch/"$i".md.tmp
    awk -v r="$i" '{gsub(/xxx/,r)}1' ~/pages/WCA-Stats/kinch/"$i".md.tmp > ~/pages/WCA-Stats/kinch/"$i".md.tmp2 && \
	awk -v r="$date" '{gsub(/today_date/,r)}1' ~/pages/WCA-Stats/kinch/"$i".md.tmp2 > ~/pages/WCA-Stats/kinch/"$i".md && \
	rm ~/pages/WCA-Stats/kinch/*.tmp*
	let finish=($(date +%s%N | cut -b1-13)-$start)
	echo -e "\\r${CHECK_MARK} ${i} (${finish}ms)"
done

#KinchNoPodium

start=$(date +%s%N | cut -b1-13)
echo -n "Kinch No Podium"
mysql --login-path=local wca_stats -e "SET @i = 1, @c = 0, @v = 0, @r = NULL;
SELECT Rank, Name, Country, worldKinch Kinch, worldRank \`Overall Rank\`
FROM
(SELECT 
		@i := IF(@v = worldKinch, @i, @i + @c) initrank,
		@c := IF(@v = worldKinch, @c + 1, 1) counter,
		@r := IF(@v = worldKinch, '=', @i) Rank,
		@v := worldKinch val,
		a.*
	FROM
	(SELECT CONCAT('[',name,'](https://www.worldcubeassociation.org/persons/',personId,')') Name, countryId Country, worldKinch, worldRank FROM kinch WHERE personId NOT IN (SELECT id FROM persons_extra WHERE podiums > 0) ORDER BY worldKinch DESC LIMIT 1000) a) b;" > ~/mysqloutput/original && \
sed 's/\t/|/g' ~/mysqloutput/original > ~/mysqloutput/output && \
sed -i.bak '2i\
--|--|--|--|--\' ~/mysqloutput/output
sed -i.bak 's/^/|/' ~/mysqloutput/output
sed -i.bak 's/$/|  /' ~/mysqloutput/output
date=$(date -r ~/databasedownload/wca-developer-database-dump.zip +"%a %b %d at %H%MUTC")
cp ~/pages/WCA-Stats/templates/kinch.md ~/pages/WCA-Stats/kinch/nopod.md.tmp
cat ~/mysqloutput/output >> ~/pages/WCA-Stats/kinch/nopod.md.tmp
awk -v r=Kinch\ No\ Podium '{gsub(/xxx/,r)}1' ~/pages/WCA-Stats/kinch/nopod.md.tmp > ~/pages/WCA-Stats/kinch/nopod.md.tmp2 && \
awk -v r="$date" '{gsub(/today_date/,r)}1' ~/pages/WCA-Stats/kinch/nopod.md.tmp2 > ~/pages/WCA-Stats/kinch/nopod.md && \
rm ~/pages/WCA-Stats/kinch/*.tmp*
let finish=($(date +%s%N | cut -b1-13)-$start)
echo -e "\\r${CHECK_MARK} Kinch No Podium (${finish}ms)"

#KinchNoWin

start=$(date +%s%N | cut -b1-13)
echo -n "Kinch No Win"
mysql --login-path=local wca_stats -e "SET @i = 1, @c = 0, @v = 0, @r = NULL;
SELECT Rank, Name, Country, worldKinch Kinch, worldRank \`Overall Rank\`
FROM
(SELECT 
		@i := IF(@v = worldKinch, @i, @i + @c) initrank,
		@c := IF(@v = worldKinch, @c + 1, 1) counter,
		@r := IF(@v = worldKinch, '=', @i) Rank,
		@v := worldKinch val,
		a.*
	FROM
	(SELECT CONCAT('[',name,'](https://www.worldcubeassociation.org/persons/',personId,')') Name, countryId Country, worldKinch, worldRank FROM kinch WHERE personId NOT IN (SELECT id FROM persons_extra WHERE gold > 0) ORDER BY worldKinch DESC LIMIT 1000) a) b;" > ~/mysqloutput/original && \
sed 's/\t/|/g' ~/mysqloutput/original > ~/mysqloutput/output && \
sed -i.bak '2i\
--|--|--|--|--\' ~/mysqloutput/output
sed -i.bak 's/^/|/' ~/mysqloutput/output
sed -i.bak 's/$/|  /' ~/mysqloutput/output
date=$(date -r ~/databasedownload/wca-developer-database-dump.zip +"%a %b %d at %H%MUTC")
cp ~/pages/WCA-Stats/templates/kinch.md ~/pages/WCA-Stats/kinch/nowin.md.tmp
cat ~/mysqloutput/output >> ~/pages/WCA-Stats/kinch/nowin.md.tmp
awk -v r=Kinch\ No\ Win '{gsub(/xxx/,r)}1' ~/pages/WCA-Stats/kinch/nowin.md.tmp > ~/pages/WCA-Stats/kinch/nowin.md.tmp2 && \
awk -v r="$date" '{gsub(/today_date/,r)}1' ~/pages/WCA-Stats/kinch/nowin.md.tmp2 > ~/pages/WCA-Stats/kinch/nowin.md && \
rm ~/pages/WCA-Stats/kinch/*.tmp*
let finish=($(date +%s%N | cut -b1-13)-$start)
echo -e "\\r${CHECK_MARK} Kinch No Win (${finish}ms)"

#KinchNoNR

start=$(date +%s%N | cut -b1-13)
echo -n "Kinch No NR"
mysql --login-path=local wca_stats -e "SET @i = 1, @c = 0, @v = 0, @r = NULL;
SELECT Rank, Name, Country, worldKinch Kinch, worldRank \`Overall Rank\`
FROM
(SELECT 
		@i := IF(@v = worldKinch, @i, @i + @c) initrank,
		@c := IF(@v = worldKinch, @c + 1, 1) counter,
		@r := IF(@v = worldKinch, '=', @i) Rank,
		@v := worldKinch val,
		a.*
	FROM
	(SELECT CONCAT('[',name,'](https://www.worldcubeassociation.org/persons/',personId,')') Name, countryId Country, worldKinch, worldRank FROM kinch WHERE personId NOT IN (SELECT id FROM persons_extra WHERE NRs > 0 OR CRs > 0 OR WRs > 0) ORDER BY worldKinch DESC LIMIT 1000) a) b;" > ~/mysqloutput/original && \
sed 's/\t/|/g' ~/mysqloutput/original > ~/mysqloutput/output && \
sed -i.bak '2i\
--|--|--|--|--\' ~/mysqloutput/output
sed -i.bak 's/^/|/' ~/mysqloutput/output
sed -i.bak 's/$/|  /' ~/mysqloutput/output
date=$(date -r ~/databasedownload/wca-developer-database-dump.zip +"%a %b %d at %H%MUTC")
cp ~/pages/WCA-Stats/templates/kinch.md ~/pages/WCA-Stats/kinch/nonr.md.tmp
cat ~/mysqloutput/output >> ~/pages/WCA-Stats/kinch/nonr.md.tmp
awk -v r=Kinch\ No\ NR '{gsub(/xxx/,r)}1' ~/pages/WCA-Stats/kinch/nonr.md.tmp > ~/pages/WCA-Stats/kinch/nonr.md.tmp2 && \
awk -v r="$date" '{gsub(/today_date/,r)}1' ~/pages/WCA-Stats/kinch/nonr.md.tmp2 > ~/pages/WCA-Stats/kinch/nonr.md && \
rm ~/pages/WCA-Stats/kinch/*.tmp*
let finish=($(date +%s%N | cut -b1-13)-$start)
echo -e "\\r${CHECK_MARK} Kinch No NR (${finish}ms)"

#KinchNoCR

start=$(date +%s%N | cut -b1-13)
echo -n "Kinch No CR"
mysql --login-path=local wca_stats -e "SET @i = 1, @c = 0, @v = 0, @r = NULL;
SELECT Rank, Name, Country, worldKinch Kinch, worldRank \`Overall Rank\`
FROM
(SELECT 
		@i := IF(@v = worldKinch, @i, @i + @c) initrank,
		@c := IF(@v = worldKinch, @c + 1, 1) counter,
		@r := IF(@v = worldKinch, '=', @i) Rank,
		@v := worldKinch val,
		a.*
	FROM
	(SELECT CONCAT('[',name,'](https://www.worldcubeassociation.org/persons/',personId,')') Name, countryId Country, worldKinch, worldRank FROM kinch WHERE personId NOT IN (SELECT id FROM persons_extra WHERE CRs > 0 OR WRs > 0) ORDER BY worldKinch DESC LIMIT 1000) a) b;" > ~/mysqloutput/original && \
sed 's/\t/|/g' ~/mysqloutput/original > ~/mysqloutput/output && \
sed -i.bak '2i\
--|--|--|--|--\' ~/mysqloutput/output
sed -i.bak 's/^/|/' ~/mysqloutput/output
sed -i.bak 's/$/|  /' ~/mysqloutput/output
date=$(date -r ~/databasedownload/wca-developer-database-dump.zip +"%a %b %d at %H%MUTC")
cp ~/pages/WCA-Stats/templates/kinch.md ~/pages/WCA-Stats/kinch/nocr.md.tmp
cat ~/mysqloutput/output >> ~/pages/WCA-Stats/kinch/nocr.md.tmp
awk -v r=Kinch\ No\ CR '{gsub(/xxx/,r)}1' ~/pages/WCA-Stats/kinch/nocr.md.tmp > ~/pages/WCA-Stats/kinch/nocr.md.tmp2 && \
awk -v r="$date" '{gsub(/today_date/,r)}1' ~/pages/WCA-Stats/kinch/nocr.md.tmp2 > ~/pages/WCA-Stats/kinch/nocr.md && \
rm ~/pages/WCA-Stats/kinch/*.tmp*
let finish=($(date +%s%N | cut -b1-13)-$start)
echo -e "\\r${CHECK_MARK} Kinch No CR (${finish}ms)"

#KinchNoWR

start=$(date +%s%N | cut -b1-13)
echo -n "Kinch No WR"
mysql --login-path=local wca_stats -e "SET @i = 1, @c = 0, @v = 0, @r = NULL;
SELECT Rank, Name, Country, worldKinch Kinch, worldRank \`Overall Rank\`
FROM
(SELECT 
		@i := IF(@v = worldKinch, @i, @i + @c) initrank,
		@c := IF(@v = worldKinch, @c + 1, 1) counter,
		@r := IF(@v = worldKinch, '=', @i) Rank,
		@v := worldKinch val,
		a.*
	FROM
	(SELECT CONCAT('[',name,'](https://www.worldcubeassociation.org/persons/',personId,')') Name, countryId Country, worldKinch, worldRank FROM kinch WHERE personId NOT IN (SELECT id FROM persons_extra WHERE WRs > 0) ORDER BY worldKinch DESC LIMIT 1000) a) b;" > ~/mysqloutput/original && \
sed 's/\t/|/g' ~/mysqloutput/original > ~/mysqloutput/output && \
sed -i.bak '2i\
--|--|--|--|--\' ~/mysqloutput/output
sed -i.bak 's/^/|/' ~/mysqloutput/output
sed -i.bak 's/$/|  /' ~/mysqloutput/output
date=$(date -r ~/databasedownload/wca-developer-database-dump.zip +"%a %b %d at %H%MUTC")
cp ~/pages/WCA-Stats/templates/kinch.md ~/pages/WCA-Stats/kinch/nowr.md.tmp
cat ~/mysqloutput/output >> ~/pages/WCA-Stats/kinch/nowr.md.tmp
awk -v r=Kinch\ No\ WR '{gsub(/xxx/,r)}1' ~/pages/WCA-Stats/kinch/nowr.md.tmp > ~/pages/WCA-Stats/kinch/nowr.md.tmp2 && \
awk -v r="$date" '{gsub(/today_date/,r)}1' ~/pages/WCA-Stats/kinch/nowr.md.tmp2 > ~/pages/WCA-Stats/kinch/nowr.md && \
rm ~/pages/WCA-Stats/kinch/*.tmp*
let finish=($(date +%s%N | cut -b1-13)-$start)
echo -e "\\r${CHECK_MARK} Kinch No WR (${finish}ms)"

#SoR

declare -a arr=(single average combined)

for i in "${arr[@]}"
do
	start=$(date +%s%N | cut -b1-13)
	echo -n "Sum of ${i} Ranks"
	mysql --login-path=local wca_stats -e "SET @i = 1, @c = 0, @v = 0, @r = NULL;
	SELECT Rank, Name, Country, worldSor \`Sum of Ranks\`
	FROM
	(SELECT 
			@i := IF(@v = worldSor, @i, @i + @c) initrank,
			@c := IF(@v = worldSor, @c + 1, 1) counter,
			@r := IF(@v = worldSor, '=', @i) Rank,
			@v := worldSor val,
			a.*
		FROM
		(SELECT CONCAT('[',name,'](https://www.worldcubeassociation.org/persons/',personId,')') Name, countryId Country, worldSor FROM sor_${i} ORDER BY worldSor ASC LIMIT 1000) a) b;" > ~/mysqloutput/original && \
	sed 's/\t/|/g' ~/mysqloutput/original > ~/mysqloutput/output && \
	sed -i.bak '2i\
--|--|--|--\' ~/mysqloutput/output
	sed -i.bak 's/^/|/' ~/mysqloutput/output
	sed -i.bak 's/$/|  /' ~/mysqloutput/output
	date=$(date -r ~/databasedownload/wca-developer-database-dump.zip +"%a %b %d at %H%MUTC")
    cp ~/pages/WCA-Stats/templates/sor.md ~/pages/WCA-Stats/sor/"$i".md.tmp
    cat ~/mysqloutput/output >> ~/pages/WCA-Stats/sor/"$i".md.tmp
    awk -v r="Sum of $i Ranks" '{gsub(/xxx/,r)}1' ~/pages/WCA-Stats/sor/"$i".md.tmp > ~/pages/WCA-Stats/sor/"$i".md.tmp2 && \
	awk -v r="$date" '{gsub(/today_date/,r)}1' ~/pages/WCA-Stats/sor/"$i".md.tmp2 > ~/pages/WCA-Stats/sor/"$i".md && \
	rm ~/pages/WCA-Stats/sor/*.tmp*
	let finish=($(date +%s%N | cut -b1-13)-$start)
	echo -e "\\r${CHECK_MARK} Sum of ${i} Ranks (${finish}ms)"
done

#sornopod

declare -a arr=(single average combined)

for i in "${arr[@]}"
do
	start=$(date +%s%N | cut -b1-13)
	echo -n "SoR $i No Podium"
	mysql --login-path=local wca_stats -e "SET @i = 1, @c = 0, @v = 0, @r = NULL;
	SELECT Rank, Name, Country, worldSor \`Sum of Ranks\`, worldRank \`Overall Rank\`
	FROM
	(SELECT 
			@i := IF(@v = worldSor, @i, @i + @c) initrank,
			@c := IF(@v = worldSor, @c + 1, 1) counter,
			@r := IF(@v = worldSor, '=', @i) Rank,
			@v := worldSor val,
			a.*
		FROM
		(SELECT CONCAT('[',name,'](https://www.worldcubeassociation.org/persons/',personId,')') Name, countryId Country, worldSor, worldRank FROM sor_${i} WHERE personId NOT IN (SELECT id FROM persons_extra WHERE podiums > 0) ORDER BY worldSor ASC LIMIT 1000) a) b;" > ~/mysqloutput/original && \
	sed 's/\t/|/g' ~/mysqloutput/original > ~/mysqloutput/output && \
	sed -i.bak '2i\
--|--|--|--|--\' ~/mysqloutput/output
	sed -i.bak 's/^/|/' ~/mysqloutput/output
	sed -i.bak 's/$/|  /' ~/mysqloutput/output
	date=$(date -r ~/databasedownload/wca-developer-database-dump.zip +"%a %b %d at %H%MUTC")
    cp ~/pages/WCA-Stats/templates/sor.md ~/pages/WCA-Stats/sor/nopod"$i".md.tmp
    cat ~/mysqloutput/output >> ~/pages/WCA-Stats/sor/nopod"$i".md.tmp
    awk -v r="SoR $i No Podium" '{gsub(/xxx/,r)}1' ~/pages/WCA-Stats/sor/nopod"$i".md.tmp > ~/pages/WCA-Stats/sor/nopod"$i".md.tmp2 && \
	awk -v r="$date" '{gsub(/today_date/,r)}1' ~/pages/WCA-Stats/sor/nopod"$i".md.tmp2 > ~/pages/WCA-Stats/sor/nopod"$i".md && \
	rm ~/pages/WCA-Stats/sor/*.tmp*
	let finish=($(date +%s%N | cut -b1-13)-$start)
	echo -e "\\r${CHECK_MARK} SoR $i No Podium (${finish}ms)"
done

#sornowin

declare -a arr=(single average combined)

for i in "${arr[@]}"
do
	start=$(date +%s%N | cut -b1-13)
	echo -n "SoR $i No Win"
	mysql --login-path=local wca_stats -e "SET @i = 1, @c = 0, @v = 0, @r = NULL;
	SELECT Rank, Name, Country, worldSor \`Sum of Ranks\`, worldRank \`Overall Rank\`
	FROM
	(SELECT 
			@i := IF(@v = worldSor, @i, @i + @c) initrank,
			@c := IF(@v = worldSor, @c + 1, 1) counter,
			@r := IF(@v = worldSor, '=', @i) Rank,
			@v := worldSor val,
			a.*
		FROM
		(SELECT CONCAT('[',name,'](https://www.worldcubeassociation.org/persons/',personId,')') Name, countryId Country, worldSor, worldRank FROM sor_${i} WHERE personId NOT IN (SELECT id FROM persons_extra WHERE gold > 0) ORDER BY worldSor ASC LIMIT 1000) a) b;" > ~/mysqloutput/original && \
	sed 's/\t/|/g' ~/mysqloutput/original > ~/mysqloutput/output && \
	sed -i.bak '2i\
--|--|--|--|--\' ~/mysqloutput/output
	sed -i.bak 's/^/|/' ~/mysqloutput/output
	sed -i.bak 's/$/|  /' ~/mysqloutput/output
	date=$(date -r ~/databasedownload/wca-developer-database-dump.zip +"%a %b %d at %H%MUTC")
    cp ~/pages/WCA-Stats/templates/sor.md ~/pages/WCA-Stats/sor/nowin"$i".md.tmp
    cat ~/mysqloutput/output >> ~/pages/WCA-Stats/sor/nowin"$i".md.tmp
    awk -v r="SoR $i No Win" '{gsub(/xxx/,r)}1' ~/pages/WCA-Stats/sor/nowin"$i".md.tmp > ~/pages/WCA-Stats/sor/nowin"$i".md.tmp2 && \
	awk -v r="$date" '{gsub(/today_date/,r)}1' ~/pages/WCA-Stats/sor/nowin"$i".md.tmp2 > ~/pages/WCA-Stats/sor/nowin"$i".md && \
	rm ~/pages/WCA-Stats/sor/*.tmp*
	let finish=($(date +%s%N | cut -b1-13)-$start)
	echo -e "\\r${CHECK_MARK} SoR $i No Win (${finish}ms)"
done

#sornonr

declare -a arr=(single average combined)

for i in "${arr[@]}"
do
	start=$(date +%s%N | cut -b1-13)
	echo -n "SoR $i No NR"
	mysql --login-path=local wca_stats -e "SET @i = 1, @c = 0, @v = 0, @r = NULL;
	SELECT Rank, Name, Country, worldSor \`Sum of Ranks\`, worldRank \`Overall Rank\`
	FROM
	(SELECT 
			@i := IF(@v = worldSor, @i, @i + @c) initrank,
			@c := IF(@v = worldSor, @c + 1, 1) counter,
			@r := IF(@v = worldSor, '=', @i) Rank,
			@v := worldSor val,
			a.*
		FROM
		(SELECT CONCAT('[',name,'](https://www.worldcubeassociation.org/persons/',personId,')') Name, countryId Country, worldSor, worldRank FROM sor_${i} WHERE personId NOT IN (SELECT id FROM persons_extra WHERE NRs > 0 OR CRs > 0 OR WRs > 0) ORDER BY worldSor ASC LIMIT 1000) a) b;" > ~/mysqloutput/original && \
	sed 's/\t/|/g' ~/mysqloutput/original > ~/mysqloutput/output && \
	sed -i.bak '2i\
--|--|--|--|--\' ~/mysqloutput/output
	sed -i.bak 's/^/|/' ~/mysqloutput/output
	sed -i.bak 's/$/|  /' ~/mysqloutput/output
	date=$(date -r ~/databasedownload/wca-developer-database-dump.zip +"%a %b %d at %H%MUTC")
    cp ~/pages/WCA-Stats/templates/sor.md ~/pages/WCA-Stats/sor/nonr"$i".md.tmp
    cat ~/mysqloutput/output >> ~/pages/WCA-Stats/sor/nonr"$i".md.tmp
    awk -v r="SoR $i No NR" '{gsub(/xxx/,r)}1' ~/pages/WCA-Stats/sor/nonr"$i".md.tmp > ~/pages/WCA-Stats/sor/nonr"$i".md.tmp2 && \
	awk -v r="$date" '{gsub(/today_date/,r)}1' ~/pages/WCA-Stats/sor/nonr"$i".md.tmp2 > ~/pages/WCA-Stats/sor/nonr"$i".md && \
	rm ~/pages/WCA-Stats/sor/*.tmp*
	let finish=($(date +%s%N | cut -b1-13)-$start)
	echo -e "\\r${CHECK_MARK} SoR $i No NR (${finish}ms)"
done

#sornocr

declare -a arr=(single average combined)

for i in "${arr[@]}"
do
	start=$(date +%s%N | cut -b1-13)
	echo -n "SoR $i No CR"
	mysql --login-path=local wca_stats -e "SET @i = 1, @c = 0, @v = 0, @r = NULL;
	SELECT Rank, Name, Country, worldSor \`Sum of Ranks\`, worldRank \`Overall Rank\`
	FROM
	(SELECT 
			@i := IF(@v = worldSor, @i, @i + @c) initrank,
			@c := IF(@v = worldSor, @c + 1, 1) counter,
			@r := IF(@v = worldSor, '=', @i) Rank,
			@v := worldSor val,
			a.*
		FROM
		(SELECT CONCAT('[',name,'](https://www.worldcubeassociation.org/persons/',personId,')') Name, countryId Country, worldSor, worldRank FROM sor_${i} WHERE personId NOT IN (SELECT id FROM persons_extra WHERE CRs > 0 OR WRs > 0) ORDER BY worldSor ASC LIMIT 1000) a) b;" > ~/mysqloutput/original && \
	sed 's/\t/|/g' ~/mysqloutput/original > ~/mysqloutput/output && \
	sed -i.bak '2i\
--|--|--|--|--\' ~/mysqloutput/output
	sed -i.bak 's/^/|/' ~/mysqloutput/output
	sed -i.bak 's/$/|  /' ~/mysqloutput/output
	date=$(date -r ~/databasedownload/wca-developer-database-dump.zip +"%a %b %d at %H%MUTC")
    cp ~/pages/WCA-Stats/templates/sor.md ~/pages/WCA-Stats/sor/nocr"$i".md.tmp
    cat ~/mysqloutput/output >> ~/pages/WCA-Stats/sor/nocr"$i".md.tmp
    awk -v r="SoR $i No CR" '{gsub(/xxx/,r)}1' ~/pages/WCA-Stats/sor/nocr"$i".md.tmp > ~/pages/WCA-Stats/sor/nocr"$i".md.tmp2 && \
	awk -v r="$date" '{gsub(/today_date/,r)}1' ~/pages/WCA-Stats/sor/nocr"$i".md.tmp2 > ~/pages/WCA-Stats/sor/nocr"$i".md && \
	rm ~/pages/WCA-Stats/sor/*.tmp*
	let finish=($(date +%s%N | cut -b1-13)-$start)
	echo -e "\\r${CHECK_MARK} SoR $i No CR (${finish}ms)"
done

#sornowr

declare -a arr=(single average combined)

for i in "${arr[@]}"
do
	start=$(date +%s%N | cut -b1-13)
	echo -n "SoR $i No WR"
	mysql --login-path=local wca_stats -e "SET @i = 1, @c = 0, @v = 0, @r = NULL;
	SELECT Rank, Name, Country, worldSor \`Sum of Ranks\`, worldRank \`Overall Rank\`
	FROM
	(SELECT 
			@i := IF(@v = worldSor, @i, @i + @c) initrank,
			@c := IF(@v = worldSor, @c + 1, 1) counter,
			@r := IF(@v = worldSor, '=', @i) Rank,
			@v := worldSor val,
			a.*
		FROM
		(SELECT CONCAT('[',name,'](https://www.worldcubeassociation.org/persons/',personId,')') Name, countryId Country, worldSor, worldRank FROM sor_${i} WHERE personId NOT IN (SELECT id FROM persons_extra WHERE WRs > 0) ORDER BY worldSor ASC LIMIT 1000) a) b;" > ~/mysqloutput/original && \
	sed 's/\t/|/g' ~/mysqloutput/original > ~/mysqloutput/output && \
	sed -i.bak '2i\
--|--|--|--|--\' ~/mysqloutput/output
	sed -i.bak 's/^/|/' ~/mysqloutput/output
	sed -i.bak 's/$/|  /' ~/mysqloutput/output
	date=$(date -r ~/databasedownload/wca-developer-database-dump.zip +"%a %b %d at %H%MUTC")
    cp ~/pages/WCA-Stats/templates/sor.md ~/pages/WCA-Stats/sor/nowr"$i".md.tmp
    cat ~/mysqloutput/output >> ~/pages/WCA-Stats/sor/nowr"$i".md.tmp
    awk -v r="SoR $i No WR" '{gsub(/xxx/,r)}1' ~/pages/WCA-Stats/sor/nowr"$i".md.tmp > ~/pages/WCA-Stats/sor/nowr"$i".md.tmp2 && \
	awk -v r="$date" '{gsub(/today_date/,r)}1' ~/pages/WCA-Stats/sor/nowr"$i".md.tmp2 > ~/pages/WCA-Stats/sor/nowr"$i".md && \
	rm ~/pages/WCA-Stats/sor/*.tmp*
	let finish=($(date +%s%N | cut -b1-13)-$start)
	echo -e "\\r${CHECK_MARK} SoR $i No WR (${finish}ms)"
done

#worstsinglewithsubxaverage

declare -a arr=(6 7 8 9 10 11 12 13 14 15)

for i in "${arr[@]}"
do
	start=$(date +%s%N | cut -b1-13)
	echo -n "Worst Single with Sub ${i} Average"
	mysql --login-path=local wca_dev -e "SET @i = 1, @c = 0, @v = 0, @r = NULL;
	SELECT Rank, Name, Country, Average, Single
	FROM
		(SELECT
			@i := IF(@v = Average, @i, @i + @c) initrank,
			@c := IF(@v = Average, @c + 1, 1) counter,
			@r := IF(@v = Average, '=', @i) Rank,
			@v := Average val,
			b.*
		FROM	
			(SELECT 
				CONCAT('[',p.name,'](https://www.worldcubeassociation.org/persons/',a.personId,')') Name, 
				p.countryId Country, 
				ROUND(a.best/100,2) Single,
				(SELECT ROUND(best/100,2) FROM ranksaverage WHERE eventId = '333' AND personId = a.personId) Average
			FROM rankssingle a 
			INNER JOIN persons p 
				ON p.subid = 1 AND a.personId = p.id 
			WHERE 
				a.eventId = '333' AND 
				personId IN (SELECT personId FROM ranksaverage WHERE eventId = '333' AND best < ${i}00) 
			ORDER BY single DESC, single ASC, p.name ASC 
			LIMIT 250) b
		) c;" > ~/mysqloutput/original && \
	sed 's/\t/|/g' ~/mysqloutput/original > ~/mysqloutput/output && \
	sed -i.bak '2i\
--|--|--|--|--\' ~/mysqloutput/output
	sed -i.bak 's/^/|/' ~/mysqloutput/output
	sed -i.bak 's/$/|  /' ~/mysqloutput/output
	output=$(cat ~/mysqloutput/output)
	date=$(date -r ~/databasedownload/wca-developer-database-dump.zip +"%a %b %d at %H%MUTC")
	cp ~/pages/WCA-Stats/templates/worstsinglewithsubxaverage.md ~/pages/WCA-Stats/worstsinglewithsubxaverage/sub$i.md.tmp
	cat ~/mysqloutput/output >> ~/pages/WCA-Stats/worstsinglewithsubxaverage/sub$i.md.tmp
	awk -v r="$i" '{gsub(/xxx/,r)}1' ~/pages/WCA-Stats/worstsinglewithsubxaverage/sub$i.md.tmp > ~/pages/WCA-Stats/worstsinglewithsubxaverage/sub$i.md.tmp2 && \
	awk -v r="$date" '{gsub(/today_date/,r)}1' ~/pages/WCA-Stats/worstsinglewithsubxaverage/sub$i.md.tmp2 > ~/pages/WCA-Stats/worstsinglewithsubxaverage/sub$i.md
	rm ~/pages/WCA-Stats/worstsinglewithsubxaverage/*.tmp*
	let finish=($(date +%s%N | cut -b1-13)-$start)
	echo -e "\\r${CHECK_MARK} Worst Single with Sub ${i} Average (${finish}ms)"
done

#medianrankings

mapfile -t arr < <(mysql --login-path=local --batch -se "SELECT id FROM wca_dev.Events WHERE rank < 900")

for i in "${arr[@]}"
do
	start=$(date +%s%N | cut -b1-13)
	echo -n "${i} Median Rankings"
	mysql --login-path=local wca_stats -e "SET @i = 1, @c = 0, @v = 0, @r = NULL;
	SELECT Rank, Name, Country, Median
	FROM	
		(SELECT
				@i := IF(CAST(@v AS CHAR) = CAST(Median AS CHAR), @i, @i + @c) initrank,
				@c := IF(CAST(@v AS CHAR) = CAST(Median AS CHAR), @c + 1, 1) counter,
				@r := IF(CAST(@v AS CHAR) = CAST(Median AS CHAR), '=', @i) Rank,
				@v := CAST(Median AS CHAR) val,
				a.*	
			FROM
				(SELECT CONCAT('[',p.name,'](https://www.worldcubeassociation.org/persons/',a.personId,')') Name, 
       				p.countryId Country, 
        			IF(eventId = '333fm',ROUND(a.median,1),IF(eventId = '333mbf',CONCAT(99-LEFT(a.median,2)+RIGHT(a.median,2),' points'),CENTISECONDTOTIME(a.median))) Median
				FROM median a
				JOIN persons_extra p
				  ON a.personId = p.id
				WHERE eventId = '${i}'
				ORDER BY a.median LIMIT 1000) a
			) b;" > ~/mysqloutput/original
	sed 's/\t/|/g' ~/mysqloutput/original > ~/mysqloutput/output
    sed -i.bak '2i\
--|--|--|--\' ~/mysqloutput/output
	sed -i.bak 's/^/|/' ~/mysqloutput/output
	sed -i.bak 's/$/|  /' ~/mysqloutput/output
    date=$(date -r ~/databasedownload/wca-developer-database-dump.zip +"%a %b %d at %H%MUTC")
    cp ~/pages/WCA-Stats/templates/median.md ~/pages/WCA-Stats/median/"$i".md.tmp
	cat ~/mysqloutput/output >> ~/pages/WCA-Stats/median/"$i".md.tmp
	awk -v r="$i" '{gsub(/xxx/,r)}1' ~/pages/WCA-Stats/median/"$i".md.tmp > ~/pages/WCA-Stats/median/"$i".md.tmp2 && \
	awk -v r="$date" '{gsub(/today_date/,r)}1' ~/pages/WCA-Stats/median/"$i".md.tmp2 > ~/pages/WCA-Stats/median/"$i".md && \
	rm ~/pages/WCA-Stats/median/*.tmp*
	let finish=($(date +%s%N | cut -b1-13)-$start)
	echo -e "\\r${CHECK_MARK} ${i} Median Rankings (${finish}ms)"
done

rm ~/mysqloutput/*

d=$(date +%Y-%m-%d)
cd ~/pages/WCA-Stats/ && git add -A && git commit -m "${d} update" && git push origin gh-pages
