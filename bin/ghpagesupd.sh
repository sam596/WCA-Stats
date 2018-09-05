#!/bin/bash

#reset incase of any changes in the meantime
cd ~/pages/WCA-Stats/ && git reset --hard && git pull origin gh-pages

# Link to mysql password
source ~/.mysqlpw/mysql.conf

# bestaveragewithoutsubxsingle

declare -a arr=(5 6 7 8 9 10)

for i in "${arr[@]}"
do
	echo "Best Average without Sub ${i} Single"
	mysql -u sam -p"$mysqlpw" wca_dev -e "SET @i = 1, @c = 0, @v = 0, @r = NULL;
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
done

# bestpodiums

mapfile -t arr < <(mysql --batch -u sam -p$mysqlpw -se "SELECT id FROM wca_dev.Events WHERE rank < 900")

for i in "${arr[@]}"
do
	echo "Best ${i} Podiums"
	mysql -u sam -p"$mysqlpw" wca_stats -e "SET @i = 1, @c = 0, @v = 0, @r = NULL;
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
done

#pbstreaks

declare -a arr=(pb_streak pb_streak_exfmc pb_streak_exfmcbld)

for i in "${arr[@]}"
do
	if [ "$i" = "pb_streak" ]; then text=$(echo "PB Streak")
	elif [ "$i" = "pb_streak_exfmc" ]; then text=$(echo "PB Streak excluding FMC-Only Comps")
	elif [ "$i" = "pb_streak_exfmcbld" ]; then text=$(echo "PB Streak excluding FMC-and-BLD-Only Comps")
	fi
	echo "Longest ${i}"
	mysql -u sam -p"$mysqlpw" wca_stats -e "SET @i = 1, @c = 0, @v = 0, @r = NULL;
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
done

#mostsubxsinglewithoutsubxaverage

declare -a arr=(6 7 8 9 10 11 12 13 14 15)

for i in "${arr[@]}"
do
	echo "Most Sub-${i} Singles without a Sub-${i} Average"
	mysql -u sam -p"$mysqlpw" wca_stats -e "SET @i = 1, @c = 0, @v = 0, @r = NULL;
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
			ORDER BY COUNT(*) DESC, Average 
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
done

#registrationslist

declare -a arr=(name competitionId)

for i in "${arr[@]}"
do
	echo "Registration List ordered by ${i}"
	mysql -u sam -p"$mysqlpw" wca_stats -e "
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
done

#sumofbesttimesatcompetition

declare -a arr=(all ex45bf)

for i in "${arr[@]}"
do
	echo "Sum of times at competition ${i}"
	if [ "$i" = "all" ]; 
		then 
			text=$(echo "All competitions excluding MBLD and FMC")
			mysql -u sam -p"$mysqlpw" wca_dev -e "SET @i = 1, @c = 0, @v = 0, @r = NULL;
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
			mysql -u sam -p"$mysqlpw" wca_dev -e "SET @i = 1, @c = 0, @v = 0, @r = NULL;
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
done

#uowc

mapfile -t arr < <(mysql --batch -u sam -p$mysqlpw -se "SELECT id FROM wca_dev.Events WHERE rank < 900")

for i in "${arr[@]}"
do
	echo "Unofficial-Official ${i} World Champions"
	mysql -u sam -p"$mysqlpw" wca_stats -e "SET @s = 0, @sr = NULL, @sd = NULL, @e = NULL, @p = NULL;
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
done

d=$(date +%Y-%m-%d)
cd ~/pages/WCA-Stats/ && git add -A && git commit -m "${d} update" && git push origin gh-pages
