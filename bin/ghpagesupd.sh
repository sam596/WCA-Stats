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

mapfile -t arr < <(mysql --login-path=local --batch -se "SELECT id FROM wca_dev.Events")

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
          CONCAT('[',com.name,'](https://www.worldcubeassociation.org/competitions/',com.id,')') Competition,
          cou.name Country, 
          IF(eventId = '333mbf', 
            CONCAT(297-SUM(LEFT(result,2))+SUM(RIGHT(result,2)),'/',297-SUM(LEFT(result,2))+(2*SUM(RIGHT(result,2))),' ',LEFT(TIME_FORMAT(SEC_TO_TIME(SUM(MID(result,4,4))),'%H:%i:%s'),8)),
            FORMAT_RESULT(SUM(a.result),a.eventId,a.format)) sum,
          GROUP_CONCAT(CONCAT('[',p.name,'](https://www.worldcubeassociation.org/persons/',personId,')') SEPARATOR ', ') Podiummers,
          GROUP_CONCAT(FORMAT_RESULT(a.result,a.eventId,a.format) SEPARATOR ', ') Results
        FROM 
          (SELECT 
            competitionId, 
            eventId, 
            pos, 
            personId, 
            personname, 
            (CASE WHEN eventId LIKE '%bf' THEN best ELSE average END) result,
            (CASE WHEN eventId LIKE '%bf' THEN 's' ELSE 'a' END) format 
          FROM podiums 
          WHERE (CASE WHEN eventId LIKE '%bf' THEN best ELSE average END) > 0) a 
        JOIN wca_dev.persons p 
          ON a.personId = p.id AND p.subid = 1
        JOIN wca_dev.competitions com 
          ON a.competitionid = com.id
        JOIN wca_dev.Countries cou
          ON com.countryId = cou.id
        WHERE eventId = '${i}'
        GROUP BY competitionId, eventId HAVING COUNT(*) = 3
        ORDER BY SUM(result), com.start_date LIMIT 100) a
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

declare -a arr=(pb_streak pb_streak_exfmc pb_streak_exfmcbld current_pb_streak current_pb_streak_exfmc current_pb_streak_exfmcbld)

for i in "${arr[@]}"
do
	start=$(date +%s%N | cut -b1-13)
	if [ "$i" = "pb_streak" ]; then text=$(echo "PB Streak")
	elif [ "$i" = "pb_streak_exfmc" ]; then text=$(echo "PB Streak excluding FMC-Only Comps")
	elif [ "$i" = "pb_streak_exfmcbld" ]; then text=$(echo "PB Streak excluding FMC-and-BLD-Only Comps")
	elif [ "$i" = "current_pb_streak" ]; then text=$(echo "Current PB Streak")
	elif [ "$i" = "current_pb_streak_exfmc" ]; then text=$(echo "Current PB Streak excluding FMC-Only Comps")
	elif [ "$i" = "current_pb_streak_exfmcbld" ]; then text=$(echo "Current PB Streak excluding FMC-and-BLD-Only Comps")
	fi
	echo -n "Longest ${i}"
	if [[ $i == *"current_"* ]]; then 
		j=$(echo $i | sed -e "s/^current_//")
		k=" WHERE (SELECT id FROM ${j} WHERE personId = a.personId AND endcomp = a.endComp)=(SELECT MAX(id) FROM ${j} WHERE personId = a.personId) "
	else 
		j=$i
		k=" WHERE 1 = 1 "
	fi
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
						IF((SELECT id FROM ${j} WHERE personId = a.personId AND endcomp = a.endComp)=(SELECT MAX(id) FROM ${j} WHERE personId = a.personId),'',CONCAT('[',(SELECT competitionId FROM ${j} WHERE id = a.id + 1),'](https://www.worldcubeassociation.org/competitions/',(SELECT competitionId FROM ${j} WHERE id = a.id + 1),')' )) \`End Comp\` 
					FROM ${j} a 
					INNER JOIN (SELECT personId, startcomp, MAX(pbStreak) maxpbs FROM ${j} GROUP BY personId, startcomp) b 
						ON a.personId = b.personId AND 
						a.startcomp = b.startcomp AND 
						b.maxpbs = a.pbstreak 
					JOIN wca_dev.persons p 
						ON a.personId = p.id AND p.subid = 1
					${k}
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
			SELECT Rank, Competition, Country, \`Sum\`, 3x3, 2x2, 4x4, 5x5, 6x6, 7x7, 3BLD, Feet, OH, Clock, Mega, Pyra, Skewb, \`SQ-1\`, 4BLD, 5BLD
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
						wca_stats.FORMAT_RESULT(SUM(best),'333','s') \`Sum\`,
						wca_stats.FORMAT_RESULT(SUM(CASE WHEN eventId = '333' THEN best END),'333','s') \`3x3\`,
						wca_stats.FORMAT_RESULT(SUM(CASE WHEN eventId = '222' THEN best END),'222','s') \`2x2\`,
						wca_stats.FORMAT_RESULT(SUM(CASE WHEN eventId = '444' THEN best END),'444','s') \`4x4\`,
						wca_stats.FORMAT_RESULT(SUM(CASE WHEN eventId = '555' THEN best END),'555','s') \`5x5\`,
						wca_stats.FORMAT_RESULT(SUM(CASE WHEN eventId = '666' THEN best END),'666','s') \`6x6\`,
						wca_stats.FORMAT_RESULT(SUM(CASE WHEN eventId = '777' THEN best END),'777','s') \`7x7\`,
						wca_stats.FORMAT_RESULT(SUM(CASE WHEN eventId = '333bf' THEN best END),'333bf','s') \`3BLD\`,
						wca_stats.FORMAT_RESULT(SUM(CASE WHEN eventId = '333ft' THEN best END),'333ft','s') \`Feet\`,
						wca_stats.FORMAT_RESULT(SUM(CASE WHEN eventId = '333oh' THEN best END),'333oh','s') \`OH\`,
						wca_stats.FORMAT_RESULT(SUM(CASE WHEN eventId = 'clock' THEN best END),'clock','s') \`Clock\`,
						wca_stats.FORMAT_RESULT(SUM(CASE WHEN eventId = 'minx' THEN best END),'minx','s') \`Mega\`,
						wca_stats.FORMAT_RESULT(SUM(CASE WHEN eventId = 'pyram' THEN best END),'pyram','s') \`Pyra\`,
						wca_stats.FORMAT_RESULT(SUM(CASE WHEN eventId = 'skewb' THEN best END),'skewb','s') \`Skewb\`,
						wca_stats.FORMAT_RESULT(SUM(CASE WHEN eventId = 'sq1' THEN best END),'sq1','s') \`SQ-1\`,
						wca_stats.FORMAT_RESULT(SUM(CASE WHEN eventId = '444bf' THEN best END),'444bf','s') \`4BLD\`,
						wca_stats.FORMAT_RESULT(SUM(CASE WHEN eventId = '555bf' THEN best END),'555bf','s') \`5BLD\`
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
			SELECT Rank, Competition, Country, \`Sum\`, 3x3, 2x2, 4x4, 5x5, 6x6, 7x7, 3BLD, Feet, OH, Clock, Mega, Pyra, Skewb, \`SQ-1\`
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
						wca_stats.FORMAT_RESULT(SUM(best),'333','s') \`Sum\`,
						wca_stats.FORMAT_RESULT(SUM(CASE WHEN eventId = '333' THEN best END),'333','s') \`3x3\`,
						wca_stats.FORMAT_RESULT(SUM(CASE WHEN eventId = '222' THEN best END),'222','s') \`2x2\`,
						wca_stats.FORMAT_RESULT(SUM(CASE WHEN eventId = '444' THEN best END),'444','s') \`4x4\`,
						wca_stats.FORMAT_RESULT(SUM(CASE WHEN eventId = '555' THEN best END),'555','s') \`5x5\`,
						wca_stats.FORMAT_RESULT(SUM(CASE WHEN eventId = '666' THEN best END),'666','s') \`6x6\`,
						wca_stats.FORMAT_RESULT(SUM(CASE WHEN eventId = '777' THEN best END),'777','s') \`7x7\`,
						wca_stats.FORMAT_RESULT(SUM(CASE WHEN eventId = '333bf' THEN best END),'333bf','s') \`3BLD\`,
						wca_stats.FORMAT_RESULT(SUM(CASE WHEN eventId = '333ft' THEN best END),'333ft','s') \`Feet\`,
						wca_stats.FORMAT_RESULT(SUM(CASE WHEN eventId = '333oh' THEN best END),'333oh','s') \`OH\`,
						wca_stats.FORMAT_RESULT(SUM(CASE WHEN eventId = 'clock' THEN best END),'clock','s') \`Clock\`,
						wca_stats.FORMAT_RESULT(SUM(CASE WHEN eventId = 'minx' THEN best END),'minx','s') \`Mega\`,
						wca_stats.FORMAT_RESULT(SUM(CASE WHEN eventId = 'pyram' THEN best END),'pyram','s') \`Pyra\`,
						wca_stats.FORMAT_RESULT(SUM(CASE WHEN eventId = 'skewb' THEN best END),'skewb','s') \`Skewb\`,
						wca_stats.FORMAT_RESULT(SUM(CASE WHEN eventId = 'sq1' THEN best END),'sq1','s') \`SQ-1\`
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
	if [ "$i" = "all" ]; 
		then 
			sed -i.bak '2i\
--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--\' ~/mysqloutput/output
		else
			sed -i.bak '2i\
--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--\' ~/mysqloutput/output
	fi
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
	  IFNULL(IF(b.endComp LIKE '1 year after [%',b.endComp,CONCAT('[',b.endComp,' - ', re.name,'](https://www.worldcubeassociation.org/competitions/',b.endComp,'/results/all#e',b.eventId,'_',b.endRound,')')),'Ongoing') \`Ended At\`, 
	  IF(b.endComp IS NULL,DATEDIFF(CURDATE(),(SELECT end_date FROM wca_dev.competitions WHERE id = b.startComp)),IFNULL(DATEDIFF((SELECT end_date FROM wca_dev.competitions WHERE id = b.endComp),(SELECT end_date FROM wca_dev.competitions WHERE id = b.startComp)),DATEDIFF((SELECT DATE_ADD(end_date, INTERVAL 1 YEAR) FROM wca_dev.competitions WHERE id = b.competitionId),(SELECT end_date FROM wca_dev.competitions WHERE id = b.startComp)))) \`Days Held\`
	FROM
	  (SELECT a.*,
	    @s := IF(a.uowcId = @p, @s, competitionId) startComp,
	    @sr := IF(a.uowcId = @p, @sr, roundTypeId) startRound,
	    @sd := IF(a.uowcId = @p, @sd, dateSet) startDate,
	    @e := IF((SELECT uowcId FROM uowc WHERE id = a.id + 1 AND eventId = a.eventId) = a.uowcId, '',  IF((SELECT dateSet FROM uowc WHERE id = a.id + 1 AND eventId = a.eventId) > DATE_ADD(a.dateSet, INTERVAL 1 YEAR),CONCAT(CONCAT('1 year after [',competitionId,'](https://www.worldcubeassociation.org/competitions/',competitionId,'/results/all#e',eventId,'_',roundTypeId,')')),
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

#uoukc

mapfile -t arr < <(mysql --login-path=local --batch -se "SELECT id FROM wca_dev.Events WHERE rank < 900")

for i in "${arr[@]}"
do
	start=$(date +%s%N | cut -b1-13)
	echo -n "Unofficial-Official ${i} UK Champions"
	mysql --login-path=local wca_stats -e "SET @s = 0, @sr = NULL, @sd = NULL, @e = NULL, @p = NULL;
	SELECT
	  CONCAT('[',p.name,'](https://www.worldcubeassociation.org/persons/',b.uoukcId,')') Name, 
	  p.countryId Country, 
	  b.startDate \`Date Set\`, 
	  CONCAT('[',b.startComp,' - ', rs.name,'](https://www.worldcubeassociation.org/competitions/',b.startComp,'/results/all#e',b.eventId,'_',b.startRound,')') \`Started At\`, 
	  IFNULL(IF(b.endComp LIKE '1 year after [%',b.endComp,CONCAT('[',b.endComp,' - ', re.name,'](https://www.worldcubeassociation.org/competitions/',b.endComp,'/results/all#e',b.eventId,'_',b.endRound,')')),'Ongoing') \`Ended At\`, 
	  IF(b.endComp IS NULL,DATEDIFF(CURDATE(),(SELECT end_date FROM wca_dev.competitions WHERE id = b.startComp)),IFNULL(DATEDIFF((SELECT end_date FROM wca_dev.competitions WHERE id = b.endComp),(SELECT end_date FROM wca_dev.competitions WHERE id = b.startComp)),DATEDIFF((SELECT DATE_ADD(end_date, INTERVAL 1 YEAR) FROM wca_dev.competitions WHERE id = b.competitionId),(SELECT end_date FROM wca_dev.competitions WHERE id = b.startComp)))) \`Days Held\`
	FROM
	  (SELECT a.*,
	    @s := IF(a.uoukcId = @p, @s, competitionId) startComp,
	    @sr := IF(a.uoukcId = @p, @sr, roundTypeId) startRound,
	    @sd := IF(a.uoukcId = @p, @sd, dateSet) startDate,
	    @e := IF((SELECT uoukcId FROM uoukc WHERE id = a.id + 1 AND eventId = a.eventId) = a.uoukcId, '',  IF((SELECT dateSet FROM uoukc WHERE id = a.id + 1 AND eventId = a.eventId) > DATE_ADD(a.dateSet, INTERVAL 1 YEAR),CONCAT(CONCAT('1 year after [',competitionId,'](https://www.worldcubeassociation.org/competitions/',competitionId,'/results/all#e',eventId,'_',roundTypeId,')')),
	  (SELECT competitionId FROM uoukc WHERE id = a.id + 1 AND eventId = a.eventId))) endComp,
	    @er := IF((SELECT uoukcId FROM uoukc WHERE id = a.id + 1 AND eventId = a.eventId) = a.uoukcId, '',  IF((SELECT dateSet FROM uoukc WHERE id = a.id + 1 AND eventId = a.eventId) > DATE_ADD(a.dateSet, INTERVAL 1 YEAR),'1 year',
	  (SELECT roundTypeId FROM uoukc WHERE id = a.id + 1 AND eventId = a.eventId))) endRound,
	    @p := a.uoukcId
	  FROM uoukc a
	  WHERE eventId = '${i}') b
	LEFT JOIN wca_dev.roundtypes rs ON b.startRound = rs.id
	LEFT JOIN wca_dev.roundtypes re ON b.endRound = re.id
	LEFT JOIN wca_dev.persons p ON b.uoukcId = p.id AND p.subid = 1
	WHERE (b.endComp <> '' OR b.endComp IS NULL) AND b.uoukcId IS NOT NULL
	ORDER BY b.id;
	" > ~/mysqloutput/original && \
	sed 's/\t/|/g' ~/mysqloutput/original > ~/mysqloutput/output && \
	sed -i.bak '2i\
--|--|--|--|--|--\' ~/mysqloutput/output
	sed -i.bak 's/^/|/' ~/mysqloutput/output
	sed -i.bak 's/$/|  /' ~/mysqloutput/output
	date=$(date -r ~/databasedownload/wca-developer-database-dump.zip +"%a %b %d at %H%MUTC")
	cp ~/pages/WCA-Stats/templates/uoukc.md ~/pages/WCA-Stats/uoukc/"$i".md.tmp
	cat ~/mysqloutput/output >> ~/pages/WCA-Stats/uoukc/"$i".md.tmp
    awk -v r="$i" '{gsub(/xxx/,r)}1' ~/pages/WCA-Stats/uoukc/"$i".md.tmp > ~/pages/WCA-Stats/uoukc/"$i".md.tmp2 && \
	awk -v r="$date" '{gsub(/today_date/,r)}1' ~/pages/WCA-Stats/uoukc/"$i".md.tmp2 > ~/pages/WCA-Stats/uoukc/"$i".md && \
	rm ~/pages/WCA-Stats/uoukc/*.tmp*
	let finish=($(date +%s%N | cut -b1-13)-$start)
	echo -e "\\r${CHECK_MARK} Unofficial-Official ${i} UK Champions (${finish}ms)"
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
      CONCAT('**',FORMAT_RESULT(\`222s\`+\`333s\`+\`333bfs\`+\`333fts\`+\`333ohs\`+\`444s\`+\`444bfs\`+\`555s\`+\`555bfs\`+\`666s\`+\`777s\`+\`clocks\`+\`minxs\`+\`pyrams\`+\`skewbs\`+\`sq1s\`,'333','s'),'**') \`Relay Time\`,
      FORMAT_RESULT(\`222s\`,'333','s') \`222\`,
      FORMAT_RESULT(\`333s\`,'333','s') \`333\`,
      FORMAT_RESULT(\`333bfs\`,'333','s') \`333bf\`,
      FORMAT_RESULT(\`333fts\`,'333','s') \`333ft\`,
      FORMAT_RESULT(\`333ohs\`,'333','s') \`333oh\`,
      FORMAT_RESULT(\`444s\`,'333','s') \`444\`,
      FORMAT_RESULT(\`444bfs\`,'333','s') \`444bf\`,
      FORMAT_RESULT(\`555s\`,'333','s') \`555\`,
      FORMAT_RESULT(\`555bfs\`,'333','s') \`555bf\`,
      FORMAT_RESULT(\`666s\`,'333','s') \`666\`,
      FORMAT_RESULT(\`777s\`,'333','s') \`777\`,
      FORMAT_RESULT(\`clocks\`,'333','s') \`clock\`,
      FORMAT_RESULT(\`minxs\`,'333','s') \`minx\`,
      FORMAT_RESULT(\`pyrams\`,'333','s') \`pyram\`,
      FORMAT_RESULT(\`skewbs\`,'333','s') \`skewb\`,
      FORMAT_RESULT(\`sq1s\`,'333','s') \`sq1\`
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
      CONCAT('**',FORMAT_RESULT(\`222s\`+\`333s\`+\`333fts\`+\`333ohs\`+\`444s\`+\`555s\`+\`666s\`+\`777s\`+\`clocks\`+\`minxs\`+\`pyrams\`+\`skewbs\`+\`sq1s\`,'333','s'),'**') \`Relay Time\`,
      FORMAT_RESULT(\`222s\`,'333','s') \`222\`,
      FORMAT_RESULT(\`333s\`,'333','s') \`333\`,
      FORMAT_RESULT(\`333fts\`,'333','s') \`333ft\`,
      FORMAT_RESULT(\`333ohs\`,'333','s') \`333oh\`,
      FORMAT_RESULT(\`444s\`,'333','s') \`444\`,
      FORMAT_RESULT(\`555s\`,'333','s') \`555\`,
      FORMAT_RESULT(\`666s\`,'333','s') \`666\`,
      FORMAT_RESULT(\`777s\`,'333','s') \`777\`,
      FORMAT_RESULT(\`clocks\`,'333','s') \`clock\`,
      FORMAT_RESULT(\`minxs\`,'333','s') \`minx\`,
      FORMAT_RESULT(\`pyrams\`,'333','s') \`pyram\`,
      FORMAT_RESULT(\`skewbs\`,'333','s') \`skewb\`,
      FORMAT_RESULT(\`sq1s\`,'333','s') \`sq1\`
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
      CONCAT('**',FORMAT_RESULT(\`222s\`+\`333s\`+\`333ohs\`+\`444s\`+\`555s\`+\`clocks\`+\`minxs\`+\`pyrams\`+\`skewbs\`+\`sq1s\`,'333','s'),'**') \`Relay Time\`,
      FORMAT_RESULT(\`222s\`,'333','s') \`222\`,
      FORMAT_RESULT(\`333s\`,'333','s') \`333\`,
      FORMAT_RESULT(\`333ohs\`,'333','s') \`333oh\`,
      FORMAT_RESULT(\`444s\`,'333','s') \`444\`,
      FORMAT_RESULT(\`555s\`,'333','s') \`555\`,
      FORMAT_RESULT(\`clocks\`,'333','s') \`clock\`,
      FORMAT_RESULT(\`minxs\`,'333','s') \`minx\`,
      FORMAT_RESULT(\`pyrams\`,'333','s') \`pyram\`,
      FORMAT_RESULT(\`skewbs\`,'333','s') \`skewb\`,
      FORMAT_RESULT(\`sq1s\`,'333','s') \`sq1\`
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
      CONCAT('**',FORMAT_RESULT(\`222s\`+\`333s\`+\`444s\`+\`555s\`+\`666s\`+\`777s\`,'333','s'),'**') \`Relay Time\`,
      FORMAT_RESULT(\`222s\`,'333','s') \`222\`,
      FORMAT_RESULT(\`333s\`,'333','s') \`333\`,
      FORMAT_RESULT(\`444s\`,'333','s') \`444\`,
      FORMAT_RESULT(\`555s\`,'333','s') \`555\`,
      FORMAT_RESULT(\`666s\`,'333','s') \`666\`,
      FORMAT_RESULT(\`777s\`,'333','s') \`777\`
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
      CONCAT('**',FORMAT_RESULT(\`222s\`+\`333s\`+\`444s\`+\`555s\`+\`666s\`,'333','s'),'**') \`Relay Time\`,
      FORMAT_RESULT(\`222s\`,'333','s') \`222\`,
      FORMAT_RESULT(\`333s\`,'333','s') \`333\`,
      FORMAT_RESULT(\`444s\`,'333','s') \`444\`,
      FORMAT_RESULT(\`555s\`,'333','s') \`555\`,
      FORMAT_RESULT(\`666s\`,'333','s') \`666\`
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
      CONCAT('**',FORMAT_RESULT(\`222s\`+\`333s\`+\`444s\`+\`555s\`,'333','s'),'**') \`Relay Time\`,
      FORMAT_RESULT(\`222s\`,'333','s') \`222\`,
      FORMAT_RESULT(\`333s\`,'333','s') \`333\`,
      FORMAT_RESULT(\`444s\`,'333','s') \`444\`,
      FORMAT_RESULT(\`555s\`,'333','s') \`555\`
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
      CONCAT('**',FORMAT_RESULT(\`222s\`+\`333s\`+\`444s\`,'333','s'),'**') \`Relay Time\`,
      FORMAT_RESULT(\`222s\`,'333','s') \`222\`,
      FORMAT_RESULT(\`333s\`,'333','s') \`333\`,
      FORMAT_RESULT(\`444s\`,'333','s') \`444\`
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
      CONCAT('**',FORMAT_RESULT(\`333s\`+\`333bfs\`+\`333fts\`+\`333ohs\`,'333','s'),'**') \`Relay Time\`,
      FORMAT_RESULT(\`333s\`,'333','s') \`333\`,
      FORMAT_RESULT(\`333bfs\`,'333','s') \`333bf\`,
      FORMAT_RESULT(\`333fts\`,'333','s') \`333ft\`,
      FORMAT_RESULT(\`333ohs\`,'333','s') \`333oh\`
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
      CONCAT('**',FORMAT_RESULT(\`333s\`+\`333bfs\`+\`333ohs\`,'333','s'),'**') \`Relay Time\`,
      FORMAT_RESULT(\`333s\`,'333','s') \`333\`,
      FORMAT_RESULT(\`333bfs\`,'333','s') \`333bf\`,
      FORMAT_RESULT(\`333ohs\`,'333','s') \`333oh\`
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
      CONCAT('**',FORMAT_RESULT(\`333bfs\`+\`444bfs\`+\`555bfs\`,'333','s'),'**') \`Relay Time\`,
      FORMAT_RESULT(\`333bfs\`,'333','s') \`333bf\`,
      FORMAT_RESULT(\`444bfs\`,'333','s') \`444bf\`,
      FORMAT_RESULT(\`555bfs\`,'333','s') \`555bf\`
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
      CONCAT('**',FORMAT_RESULT(\`clocks\`+\`minxs\`+\`pyrams\`+\`skewbs\`+\`sq1s\`,'333','s'),'**') \`Relay Time\`,
      FORMAT_RESULT(\`clocks\`,'333','s') \`clock\`,
      FORMAT_RESULT(\`minxs\`,'333','s') \`minx\`,
      FORMAT_RESULT(\`pyrams\`,'333','s') \`pyram\`,
      FORMAT_RESULT(\`skewbs\`,'333','s') \`skewb\`,
      FORMAT_RESULT(\`sq1s\`,'333','s') \`sq1\`
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
      CONCAT('**',FORMAT_RESULT(\`222s\`+\`pyrams\`+\`skewbs\`,'333','s'),'**') \`Relay Time\`,
      FORMAT_RESULT(\`222s\`,'333','s') \`222\`,
      FORMAT_RESULT(\`pyrams\`,'333','s') \`pyram\`,
      FORMAT_RESULT(\`skewbs\`,'333','s') \`skewb\`
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

#bestsinglewithoutsubxaverage

declare -a arr=(6 7 8 9 10 11 12 13 14 15)

for i in "${arr[@]}"
do
	start=$(date +%s%N | cut -b1-13)
	echo -n "Best Single without Sub ${i} Average"
	mysql --login-path=local wca_dev -e "SET @i = 1, @c = 0, @v = 0, @r = NULL;
	SELECT Rank, Name, Country, Single, Average
	FROM
		(SELECT
			@i := IF(@v = Single, @i, @i + @c) initrank,
			@c := IF(@v = Single, @c + 1, 1) counter,
			@r := IF(@v = Single, '=', @i) Rank,
			@v := Single val,
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
				personId NOT IN (SELECT personId FROM ranksaverage WHERE eventId = '333' AND best < ${i}00) 
			ORDER BY single ASC, p.name ASC 
			LIMIT 500) b
		) c;" > ~/mysqloutput/original && \
	sed 's/\t/|/g' ~/mysqloutput/original > ~/mysqloutput/output && \
	sed -i.bak '2i\
--|--|--|--|--\' ~/mysqloutput/output
	sed -i.bak 's/^/|/' ~/mysqloutput/output
	sed -i.bak 's/$/|  /' ~/mysqloutput/output
	output=$(cat ~/mysqloutput/output)
	date=$(date -r ~/databasedownload/wca-developer-database-dump.zip +"%a %b %d at %H%MUTC")
	cp ~/pages/WCA-Stats/templates/bestsinglewithoutsubxaverage.md ~/pages/WCA-Stats/bestsinglewithoutsubxaverage/sub$i.md.tmp
	cat ~/mysqloutput/output >> ~/pages/WCA-Stats/bestsinglewithoutsubxaverage/sub$i.md.tmp
	awk -v r="$i" '{gsub(/xxx/,r)}1' ~/pages/WCA-Stats/bestsinglewithoutsubxaverage/sub$i.md.tmp > ~/pages/WCA-Stats/bestsinglewithoutsubxaverage/sub$i.md.tmp2 && \
	awk -v r="$date" '{gsub(/today_date/,r)}1' ~/pages/WCA-Stats/bestsinglewithoutsubxaverage/sub$i.md.tmp2 > ~/pages/WCA-Stats/bestsinglewithoutsubxaverage/sub$i.md
	rm ~/pages/WCA-Stats/bestsinglewithoutsubxaverage/*.tmp*
	let finish=($(date +%s%N | cut -b1-13)-$start)
	echo -e "\\r${CHECK_MARK} Best Single without Sub ${i} Average (${finish}ms)"
done

#currentao5

mapfile -t arr < <(mysql --login-path=local --batch -se "SELECT id FROM wca_dev.Events WHERE rank < 900 AND id <> '333mbf'")

for i in "${arr[@]}"
do
	start=$(date +%s%N | cut -b1-13)
	echo -n "${i} Current Ao5"
	mysql --login-path=local wca_stats -e "SET @i = 1, @c = 0, @v = 0, @r = NULL;
	SELECT Rank, Name, countryId Country, IF(eventId = '333fm',ROUND(ao5,2),FORMAT_RESULT(ao5,eventId,'s')) Average, Times 
	FROM 
		(SELECT 
			@i := IF(@v = ao5, @i, @i + @c) initrank, 
			@c := IF(@v = ao5, @c + 1, 1) counter, 
			@r := IF(@v = ao5, '=', @i) Rank, 
			@v := ao5 val, 
			a.*  
		FROM 
			(SELECT 
				CONCAT('[',name,'](https://www.worldcubeassociation.org/persons/',personId,')') Name,
				countryId,
				ao5,
				times,
				eventId
			FROM current_ao5 
			JOIN persons_extra ON current_ao5.personid = persons_extra.id
			WHERE ao5 > 0 AND eventId = '${i}'
			ORDER BY current_ao5.ao5, personId
			LIMIT 250) a) b;" > ~/mysqloutput/original
	sed 's/\t/|/g' ~/mysqloutput/original > ~/mysqloutput/output
    sed -i.bak '2i\
--|--|--|--|--\' ~/mysqloutput/output
	sed -i.bak 's/^/|/' ~/mysqloutput/output
	sed -i.bak 's/$/|  /' ~/mysqloutput/output
    date=$(date -r ~/databasedownload/wca-developer-database-dump.zip +"%a %b %d at %H%MUTC")
    cp ~/pages/WCA-Stats/templates/currentao5.md ~/pages/WCA-Stats/currentao5/"$i".md.tmp
	cat ~/mysqloutput/output >> ~/pages/WCA-Stats/currentao5/"$i".md.tmp
	awk -v r="$i" '{gsub(/xxx/,r)}1' ~/pages/WCA-Stats/currentao5/"$i".md.tmp > ~/pages/WCA-Stats/currentao5/"$i".md.tmp2 && \
	awk -v r="$date" '{gsub(/today_date/,r)}1' ~/pages/WCA-Stats/currentao5/"$i".md.tmp2 > ~/pages/WCA-Stats/currentao5/"$i".md && \
	rm ~/pages/WCA-Stats/currentao5/*.tmp*
	let finish=($(date +%s%N | cut -b1-13)-$start)
	echo -e "\\r${CHECK_MARK} ${i} Current Ao5 (${finish}ms)"
done

#currentao12

mapfile -t arr < <(mysql --login-path=local --batch -se "SELECT id FROM wca_dev.Events WHERE rank < 900 AND id <> '333mbf'")

for i in "${arr[@]}"
do
	start=$(date +%s%N | cut -b1-13)
	echo -n "${i} Current ao12"
	mysql --login-path=local wca_stats -e "SET @i = 1, @c = 0, @v = 0, @r = NULL;
	SELECT Rank, Name, countryId Country, IF(eventId = '333fm',ROUND(ao12,2),FORMAT_RESULT(ao12,eventId,'s')) Average, Times 
	FROM 
		(SELECT 
			@i := IF(@v = ao12, @i, @i + @c) initrank, 
			@c := IF(@v = ao12, @c + 1, 1) counter, 
			@r := IF(@v = ao12, '=', @i) Rank, 
			@v := ao12 val, 
			a.*  
		FROM 
			(SELECT 
				CONCAT('[',name,'](https://www.worldcubeassociation.org/persons/',personId,')') Name,
				countryId,
				ao12,
				times,
				eventId
			FROM current_ao12 
			JOIN persons_extra ON current_ao12.personid = persons_extra.id
			WHERE ao12 > 0 AND eventId = '${i}'
			ORDER BY current_ao12.ao12, personId
			LIMIT 250) a) b;" > ~/mysqloutput/original
	sed 's/\t/|/g' ~/mysqloutput/original > ~/mysqloutput/output
    sed -i.bak '2i\
--|--|--|--|--\' ~/mysqloutput/output
	sed -i.bak 's/^/|/' ~/mysqloutput/output
	sed -i.bak 's/$/|  /' ~/mysqloutput/output
    date=$(date -r ~/databasedownload/wca-developer-database-dump.zip +"%a %b %d at %H%MUTC")
    cp ~/pages/WCA-Stats/templates/currentao12.md ~/pages/WCA-Stats/currentao12/"$i".md.tmp
	cat ~/mysqloutput/output >> ~/pages/WCA-Stats/currentao12/"$i".md.tmp
	awk -v r="$i" '{gsub(/xxx/,r)}1' ~/pages/WCA-Stats/currentao12/"$i".md.tmp > ~/pages/WCA-Stats/currentao12/"$i".md.tmp2 && \
	awk -v r="$date" '{gsub(/today_date/,r)}1' ~/pages/WCA-Stats/currentao12/"$i".md.tmp2 > ~/pages/WCA-Stats/currentao12/"$i".md && \
	rm ~/pages/WCA-Stats/currentao12/*.tmp*
	let finish=($(date +%s%N | cut -b1-13)-$start)
	echo -e "\\r${CHECK_MARK} ${i} Current ao12 (${finish}ms)"
done

#currentao25

mapfile -t arr < <(mysql --login-path=local --batch -se "SELECT id FROM wca_dev.Events WHERE rank < 900 AND id <> '333mbf'")

for i in "${arr[@]}"
do
	start=$(date +%s%N | cut -b1-13)
	echo -n "${i} Current ao25"
	mysql --login-path=local wca_stats -e "SET @i = 1, @c = 0, @v = 0, @r = NULL;
	SELECT Rank, Name, countryId Country, IF(eventId = '333fm',ROUND(ao25,2),FORMAT_RESULT(ao25,eventId,'s')) Average, Times 
	FROM 
		(SELECT 
			@i := IF(@v = ao25, @i, @i + @c) initrank, 
			@c := IF(@v = ao25, @c + 1, 1) counter, 
			@r := IF(@v = ao25, '=', @i) Rank, 
			@v := ao25 val, 
			a.*  
		FROM 
			(SELECT 
				CONCAT('[',name,'](https://www.worldcubeassociation.org/persons/',personId,')') Name,
				countryId,
				ao25,
				times,
				eventId
			FROM current_ao25 
			JOIN persons_extra ON current_ao25.personid = persons_extra.id
			WHERE ao25 > 0 AND eventId = '${i}'
			ORDER BY current_ao25.ao25, personId
			LIMIT 250) a) b;" > ~/mysqloutput/original
	sed 's/\t/|/g' ~/mysqloutput/original > ~/mysqloutput/output
    sed -i.bak '2i\
--|--|--|--|--\' ~/mysqloutput/output
	sed -i.bak 's/^/|/' ~/mysqloutput/output
	sed -i.bak 's/$/|  /' ~/mysqloutput/output
    date=$(date -r ~/databasedownload/wca-developer-database-dump.zip +"%a %b %d at %H%MUTC")
    cp ~/pages/WCA-Stats/templates/currentao25.md ~/pages/WCA-Stats/currentao25/"$i".md.tmp
	cat ~/mysqloutput/output >> ~/pages/WCA-Stats/currentao25/"$i".md.tmp
	awk -v r="$i" '{gsub(/xxx/,r)}1' ~/pages/WCA-Stats/currentao25/"$i".md.tmp > ~/pages/WCA-Stats/currentao25/"$i".md.tmp2 && \
	awk -v r="$date" '{gsub(/today_date/,r)}1' ~/pages/WCA-Stats/currentao25/"$i".md.tmp2 > ~/pages/WCA-Stats/currentao25/"$i".md && \
	rm ~/pages/WCA-Stats/currentao25/*.tmp*
	let finish=($(date +%s%N | cut -b1-13)-$start)
	echo -e "\\r${CHECK_MARK} ${i} Current ao25 (${finish}ms)"
done

#currentao50

mapfile -t arr < <(mysql --login-path=local --batch -se "SELECT id FROM wca_dev.Events WHERE rank < 900 AND id <> '333mbf'")

for i in "${arr[@]}"
do
	start=$(date +%s%N | cut -b1-13)
	echo -n "${i} Current ao50"
	mysql --login-path=local wca_stats -e "SET @i = 1, @c = 0, @v = 0, @r = NULL;
	SELECT Rank, Name, countryId Country, IF(eventId = '333fm',ROUND(ao50,2),FORMAT_RESULT(ao50,eventId,'s')) Average, Times 
	FROM 
		(SELECT 
			@i := IF(@v = ao50, @i, @i + @c) initrank, 
			@c := IF(@v = ao50, @c + 1, 1) counter, 
			@r := IF(@v = ao50, '=', @i) Rank, 
			@v := ao50 val, 
			a.*  
		FROM 
			(SELECT 
				CONCAT('[',name,'](https://www.worldcubeassociation.org/persons/',personId,')') Name,
				countryId,
				ao50,
				times,
				eventId
			FROM current_ao50 
			JOIN persons_extra ON current_ao50.personid = persons_extra.id
			WHERE ao50 > 0 AND eventId = '${i}'
			ORDER BY current_ao50.ao50, personId
			LIMIT 250) a) b;" > ~/mysqloutput/original
	sed 's/\t/|/g' ~/mysqloutput/original > ~/mysqloutput/output
    sed -i.bak '2i\
--|--|--|--|--\' ~/mysqloutput/output
	sed -i.bak 's/^/|/' ~/mysqloutput/output
	sed -i.bak 's/$/|  /' ~/mysqloutput/output
    date=$(date -r ~/databasedownload/wca-developer-database-dump.zip +"%a %b %d at %H%MUTC")
    cp ~/pages/WCA-Stats/templates/currentao50.md ~/pages/WCA-Stats/currentao50/"$i".md.tmp
	cat ~/mysqloutput/output >> ~/pages/WCA-Stats/currentao50/"$i".md.tmp
	awk -v r="$i" '{gsub(/xxx/,r)}1' ~/pages/WCA-Stats/currentao50/"$i".md.tmp > ~/pages/WCA-Stats/currentao50/"$i".md.tmp2 && \
	awk -v r="$date" '{gsub(/today_date/,r)}1' ~/pages/WCA-Stats/currentao50/"$i".md.tmp2 > ~/pages/WCA-Stats/currentao50/"$i".md && \
	rm ~/pages/WCA-Stats/currentao50/*.tmp*
	let finish=($(date +%s%N | cut -b1-13)-$start)
	echo -e "\\r${CHECK_MARK} ${i} Current ao50 (${finish}ms)"
done

#currentao100

mapfile -t arr < <(mysql --login-path=local --batch -se "SELECT id FROM wca_dev.Events WHERE rank < 900 AND id <> '333mbf'")

for i in "${arr[@]}"
do
	start=$(date +%s%N | cut -b1-13)
	echo -n "${i} Current ao100"
	mysql --login-path=local wca_stats -e "SET @i = 1, @c = 0, @v = 0, @r = NULL;
	SELECT Rank, Name, countryId Country, IF(eventId = '333fm',ROUND(ao100,2),FORMAT_RESULT(ao100,eventId,'s')) Average, Times 
	FROM 
		(SELECT 
			@i := IF(@v = ao100, @i, @i + @c) initrank, 
			@c := IF(@v = ao100, @c + 1, 1) counter, 
			@r := IF(@v = ao100, '=', @i) Rank, 
			@v := ao100 val, 
			a.*  
		FROM 
			(SELECT 
				CONCAT('[',name,'](https://www.worldcubeassociation.org/persons/',personId,')') Name,
				countryId,
				ao100,
				times,
				eventId
			FROM current_ao100 
			JOIN persons_extra ON current_ao100.personid = persons_extra.id
			WHERE ao100 > 0 AND eventId = '${i}'
			ORDER BY current_ao100.ao100, personId
			LIMIT 250) a) b;" > ~/mysqloutput/original
	sed 's/\t/|/g' ~/mysqloutput/original > ~/mysqloutput/output
    sed -i.bak '2i\
--|--|--|--|--\' ~/mysqloutput/output
	sed -i.bak 's/^/|/' ~/mysqloutput/output
	sed -i.bak 's/$/|  /' ~/mysqloutput/output
    date=$(date -r ~/databasedownload/wca-developer-database-dump.zip +"%a %b %d at %H%MUTC")
    cp ~/pages/WCA-Stats/templates/currentao100.md ~/pages/WCA-Stats/currentao100/"$i".md.tmp
	cat ~/mysqloutput/output >> ~/pages/WCA-Stats/currentao100/"$i".md.tmp
	awk -v r="$i" '{gsub(/xxx/,r)}1' ~/pages/WCA-Stats/currentao100/"$i".md.tmp > ~/pages/WCA-Stats/currentao100/"$i".md.tmp2 && \
	awk -v r="$date" '{gsub(/today_date/,r)}1' ~/pages/WCA-Stats/currentao100/"$i".md.tmp2 > ~/pages/WCA-Stats/currentao100/"$i".md && \
	rm ~/pages/WCA-Stats/currentao100/*.tmp*
	let finish=($(date +%s%N | cut -b1-13)-$start)
	echo -e "\\r${CHECK_MARK} ${i} Current ao100 (${finish}ms)"
done

#bestworstrank

i="bestworstrank"
start=$(date +%s%N | cut -b1-13)
echo -n "bestworstrank"
mysql --login-path=local wca_stats -e "SET @i = 1, @c = 0, @v = 0, @r = NULL;
  SELECT Rank, Name, countryId Country, maxWorldRank \`Max World Rank\`, maxWorldRankEventId Event
  FROM
  (SELECT 
      @i := IF(@v = maxWorldRank, @i, @i + @c) initrank,
      @c := IF(@v = maxWorldRank, @c + 1, 1) counter,
      @r := IF(@v = maxWorldRank, '=', @i) Rank,
      @v := maxWorldRank val,
      a.*
    FROM
      (SELECT CONCAT('[',name,'](https://www.worldcubeassociation.org/persons/',id,')') name, countryId, maxWorldRank, maxWorldRankEventId 
        FROM persons_extra
        ORDER BY maxWorldRank ASC LIMIT 1000) a) b;" > ~/mysqloutput/original
sed 's/\t/|/g' ~/mysqloutput/original > ~/mysqloutput/output
sed -i.bak '2i\
--|--|--|--|--\' ~/mysqloutput/output
sed -i.bak 's/^/|/' ~/mysqloutput/output
sed -i.bak 's/$/|  /' ~/mysqloutput/output
date=$(date -r ~/databasedownload/wca-developer-database-dump.zip +"%a %b %d at %H%MUTC")
cp ~/pages/WCA-Stats/templates/bestworstrank.md ~/pages/WCA-Stats/bestworstrank/"$i".md.tmp
cat ~/mysqloutput/output >> ~/pages/WCA-Stats/bestworstrank/"$i".md.tmp
awk -v r="$i" '{gsub(/xxx/,r)}1' ~/pages/WCA-Stats/bestworstrank/"$i".md.tmp > ~/pages/WCA-Stats/bestworstrank/"$i".md.tmp2 && \
awk -v r="$date" '{gsub(/today_date/,r)}1' ~/pages/WCA-Stats/bestworstrank/"$i".md.tmp2 > ~/pages/WCA-Stats/bestworstrank/"$i".md && \
rm ~/pages/WCA-Stats/bestworstrank/*.tmp*
let finish=($(date +%s%N | cut -b1-13)-$start)
echo -e "\\r${CHECK_MARK} Best Worst Rank (${finish}ms)"

#bestworstresult

mapfile -t arr < <(mysql --login-path=local --batch -se "SELECT id FROM wca_dev.Events WHERE rank < 900")

for i in "${arr[@]}"
do
	start=$(date +%s%N | cut -b1-13)
	echo -n "${i} Best Worst Single"
	mysql --login-path=local wca_stats -e "SET @i = 1, @c = 0, @v = 0, @r = NULL;
SELECT Rank, Name, countryId Country, worst \`Worst Single\`
FROM
(SELECT 
    @i := IF(@v = worstorder, @i, @i + @c) initrank,
    @c := IF(@v = worstorder, @c + 1, 1) counter,
    @r := IF(@v = worstorder, '=', @i) Rank,
    @v := worstorder val,
    c.*
FROM
  (SELECT CONCAT('[',b.name,'](https://www.worldcubeassociation.org/persons/',b.id,')') Name, b.countryId, a.worst, a.worstorder FROM
  (SELECT personId, MAX(value) worstorder, FORMAT_RESULT(MAX(value),eventId,'s') worst FROM all_attempts WHERE eventId = '${i}' AND value > 0 GROUP BY personId, eventId ORDER BY worstorder, personId LIMIT 1000) a
  JOIN persons_extra b ON a.personId = b.id
  ORDER BY a.worstorder, b.id) c) d;" > ~/mysqloutput/original
	sed 's/\t/|/g' ~/mysqloutput/original > ~/mysqloutput/output
    sed -i.bak '2i\
--|--|--|--\' ~/mysqloutput/output
	sed -i.bak 's/^/|/' ~/mysqloutput/output
	sed -i.bak 's/$/|  /' ~/mysqloutput/output
    date=$(date -r ~/databasedownload/wca-developer-database-dump.zip +"%a %b %d at %H%MUTC")
    cp ~/pages/WCA-Stats/templates/bestworstresult.md ~/pages/WCA-Stats/bestworstresult/"$i"s.md.tmp
	cat ~/mysqloutput/output >> ~/pages/WCA-Stats/bestworstresult/"$i"s.md.tmp
	awk -v r="$i Single" '{gsub(/xxx/,r)}1' ~/pages/WCA-Stats/bestworstresult/"$i"s.md.tmp > ~/pages/WCA-Stats/bestworstresult/"$i"s.md.tmp2 && \
	awk -v r="$date" '{gsub(/today_date/,r)}1' ~/pages/WCA-Stats/bestworstresult/"$i"s.md.tmp2 > ~/pages/WCA-Stats/bestworstresult/"$i"s.md && \
	rm ~/pages/WCA-Stats/bestworstresult/*.tmp*
	let finish=($(date +%s%N | cut -b1-13)-$start)
	echo -e "\\r${CHECK_MARK} ${i} Best Worst Single (${finish}ms)"
done

for i in "${arr[@]}"
do
	start=$(date +%s%N | cut -b1-13)
	echo -n "${i} Best Worst Average"
	mysql --login-path=local wca_stats -e "SET @i = 1, @c = 0, @v = 0, @r = NULL;
SELECT Rank, Name, countryId Country, worst \`Worst Average\`
FROM
(SELECT 
    @i := IF(@v = worstorder, @i, @i + @c) initrank,
    @c := IF(@v = worstorder, @c + 1, 1) counter,
    @r := IF(@v = worstorder, '=', @i) Rank,
    @v := worstorder val,
    c.*
FROM
  (SELECT CONCAT('[',b.name,'](https://www.worldcubeassociation.org/persons/',b.id,')') Name, b.countryId, a.worst, a.worstorder FROM
  (SELECT personId, MAX(average) worstorder, FORMAT_RESULT(MAX(average),eventId,'a') worst FROM results_extra WHERE eventId = '${i}' AND average > 0 GROUP BY personId, eventId ORDER BY worstorder, personId LIMIT 1000) a
  JOIN persons_extra b ON a.personId = b.id
  ORDER BY a.worstorder, b.id) c) d;" > ~/mysqloutput/original
	sed 's/\t/|/g' ~/mysqloutput/original > ~/mysqloutput/output
    sed -i.bak '2i\
--|--|--|--\' ~/mysqloutput/output
	sed -i.bak 's/^/|/' ~/mysqloutput/output
	sed -i.bak 's/$/|  /' ~/mysqloutput/output
    date=$(date -r ~/databasedownload/wca-developer-database-dump.zip +"%a %b %d at %H%MUTC")
    cp ~/pages/WCA-Stats/templates/bestworstresult.md ~/pages/WCA-Stats/bestworstresult/"$i"a.md.tmp
	cat ~/mysqloutput/output >> ~/pages/WCA-Stats/bestworstresult/"$i"a.md.tmp
	awk -v r="$i Average" '{gsub(/xxx/,r)}1' ~/pages/WCA-Stats/bestworstresult/"$i"a.md.tmp > ~/pages/WCA-Stats/bestworstresult/"$i"a.md.tmp2 && \
	awk -v r="$date" '{gsub(/today_date/,r)}1' ~/pages/WCA-Stats/bestworstresult/"$i"a.md.tmp2 > ~/pages/WCA-Stats/bestworstresult/"$i"a.md && \
	rm ~/pages/WCA-Stats/bestworstresult/*.tmp*
	let finish=($(date +%s%N | cut -b1-13)-$start)
	echo -e "\\r${CHECK_MARK} ${i} Best Worst Average (${finish}ms)"
done

#namelength

i="longestnames"
start=$(date +%s%N | cut -b1-13)
echo -n "Longest Names"
mysql --login-path=local wca_stats -e "SET @i = 1, @c = 0, @v = 0, @r = NULL;
SELECT Rank, Name, countryId Country, length \`Name Length\`
FROM
(SELECT 
@i := IF(@v = length, @i, @i + @c) initrank,
@c := IF(@v = length, @c + 1, 1) counter,
@r := IF(@v = length, '=', @i) Rank,
@v := length val,
a.*
FROM
(SELECT CONCAT('[',name,'](https://www.worldcubeassociation.org/persons/',id,')') Name, countryId, CHAR_LENGTH(IF(POSITION(' (' IN name) = 0, REPLACE(name,' ',''), REPLACE(LEFT(name,POSITION(' (' IN name)),' ',''))) length 
FROM persons_extra ORDER BY length DESC, id LIMIT 1000) a) b;" > ~/mysqloutput/original
sed 's/\t/|/g' ~/mysqloutput/original > ~/mysqloutput/output
sed -i.bak '2i\
--|--|--|--\' ~/mysqloutput/output
sed -i.bak 's/^/|/' ~/mysqloutput/output
sed -i.bak 's/$/|  /' ~/mysqloutput/output
date=$(date -r ~/databasedownload/wca-developer-database-dump.zip +"%a %b %d at %H%MUTC")
cp ~/pages/WCA-Stats/templates/namelength.md ~/pages/WCA-Stats/namelength/"$i".md.tmp
cat ~/mysqloutput/output >> ~/pages/WCA-Stats/namelength/"$i".md.tmp
awk -v r="$i" '{gsub(/xxx/,r)}1' ~/pages/WCA-Stats/namelength/"$i".md.tmp > ~/pages/WCA-Stats/namelength/"$i".md.tmp2 && \
awk -v r="$date" '{gsub(/today_date/,r)}1' ~/pages/WCA-Stats/namelength/"$i".md.tmp2 > ~/pages/WCA-Stats/namelength/"$i".md && \
rm ~/pages/WCA-Stats/namelength/*.tmp*
let finish=($(date +%s%N | cut -b1-13)-$start)
echo -e "\\r${CHECK_MARK} Longest Names (${finish}ms)"

i="shortestnames"
start=$(date +%s%N | cut -b1-13)
echo -n "Shortest Names"
mysql --login-path=local wca_stats -e "SET @i = 1, @c = 0, @v = 0, @r = NULL;
SELECT Rank, Name, countryId Country, length \`Name Length\`
FROM
(SELECT 
@i := IF(@v = length, @i, @i + @c) initrank,
@c := IF(@v = length, @c + 1, 1) counter,
@r := IF(@v = length, '=', @i) Rank,
@v := length val,
a.*
FROM
(SELECT CONCAT('[',name,'](https://www.worldcubeassociation.org/persons/',id,')') Name, countryId, CHAR_LENGTH(IF(POSITION(' (' IN name) = 0, REPLACE(name,' ',''), REPLACE(LEFT(name,POSITION(' (' IN name)),' ',''))) length 
FROM persons_extra ORDER BY length ASC, id LIMIT 1000) a) b;" > ~/mysqloutput/original
sed 's/\t/|/g' ~/mysqloutput/original > ~/mysqloutput/output
sed -i.bak '2i\
--|--|--|--\' ~/mysqloutput/output
sed -i.bak 's/^/|/' ~/mysqloutput/output
sed -i.bak 's/$/|  /' ~/mysqloutput/output
date=$(date -r ~/databasedownload/wca-developer-database-dump.zip +"%a %b %d at %H%MUTC")
cp ~/pages/WCA-Stats/templates/namelength.md ~/pages/WCA-Stats/namelength/"$i".md.tmp
cat ~/mysqloutput/output >> ~/pages/WCA-Stats/namelength/"$i".md.tmp
awk -v r="$i" '{gsub(/xxx/,r)}1' ~/pages/WCA-Stats/namelength/"$i".md.tmp > ~/pages/WCA-Stats/namelength/"$i".md.tmp2 && \
awk -v r="$date" '{gsub(/today_date/,r)}1' ~/pages/WCA-Stats/namelength/"$i".md.tmp2 > ~/pages/WCA-Stats/namelength/"$i".md && \
rm ~/pages/WCA-Stats/namelength/*.tmp*
let finish=($(date +%s%N | cut -b1-13)-$start)
echo -e "\\r${CHECK_MARK} Shortest Names (${finish}ms)"

i="mostcommonfirstnames"
start=$(date +%s%N | cut -b1-13)
echo -n "Most Common First Names"
mysql --login-path=local wca_stats -e "SET @i = 1, @c = 0, @v = 0, @r = NULL;
SELECT Rank, firstName \`First Name\`, Number
FROM
(SELECT 
@i := IF(@v = number, @i, @i + @c) initrank,
@c := IF(@v = number, @c + 1, 1) counter,
@r := IF(@v = number, '=', @i) Rank,
@v := number val,
a.*
FROM
(SELECT IF(name LIKE '% %',LEFT(name,POSITION(' ' IN name)),name) firstName, COUNT(*) Number FROM persons_extra GROUP BY IF(name LIKE '% %',LEFT(name,POSITION(' ' IN name)),name) ORDER BY COUNT(*) DESC LIMIT 1000) a) b;" > ~/mysqloutput/original
sed 's/\t/|/g' ~/mysqloutput/original > ~/mysqloutput/output
sed -i.bak '2i\
--|--|--\' ~/mysqloutput/output
sed -i.bak 's/^/|/' ~/mysqloutput/output
sed -i.bak 's/$/|  /' ~/mysqloutput/output
date=$(date -r ~/databasedownload/wca-developer-database-dump.zip +"%a %b %d at %H%MUTC")
cp ~/pages/WCA-Stats/templates/commonfirstnames.md ~/pages/WCA-Stats/commonfirstnames/"$i".md.tmp
cat ~/mysqloutput/output >> ~/pages/WCA-Stats/commonfirstnames/"$i".md.tmp
awk -v r="$i" '{gsub(/xxx/,r)}1' ~/pages/WCA-Stats/commonfirstnames/"$i".md.tmp > ~/pages/WCA-Stats/commonfirstnames/"$i".md.tmp2 && \
awk -v r="$date" '{gsub(/today_date/,r)}1' ~/pages/WCA-Stats/commonfirstnames/"$i".md.tmp2 > ~/pages/WCA-Stats/commonfirstnames/"$i".md && \
rm ~/pages/WCA-Stats/commonfirstnames/*.tmp*
let finish=($(date +%s%N | cut -b1-13)-$start)
echo -e "\\r${CHECK_MARK} Most Common First Names (${finish}ms)"

i="mostcommonwcamiddles"
start=$(date +%s%N | cut -b1-13)
echo -n "Most Common WCA Middles"
mysql --login-path=local wca_stats -e "SET @i = 1, @c = 0, @v = 0, @r = NULL;
SELECT Rank, wcaMiddle \`WCA Middle\`, Number
FROM
(SELECT 
@i := IF(@v = number, @i, @i + @c) initrank,
@c := IF(@v = number, @c + 1, 1) counter,
@r := IF(@v = number, '=', @i) Rank,
@v := number val,
a.*
FROM
(SELECT MID(id,5,4) wcaMiddle, COUNT(*) Number FROM persons_extra GROUP BY MID(id,5,4) ORDER BY COUNT(*) DESC LIMIT 1000) a) b;" > ~/mysqloutput/original
sed 's/\t/|/g' ~/mysqloutput/original > ~/mysqloutput/output
sed -i.bak '2i\
--|--|--\' ~/mysqloutput/output
sed -i.bak 's/^/|/' ~/mysqloutput/output
sed -i.bak 's/$/|  /' ~/mysqloutput/output
date=$(date -r ~/databasedownload/wca-developer-database-dump.zip +"%a %b %d at %H%MUTC")
cp ~/pages/WCA-Stats/templates/commonwcamiddles.md ~/pages/WCA-Stats/commonwcamiddles/"$i".md.tmp
cat ~/mysqloutput/output >> ~/pages/WCA-Stats/commonwcamiddles/"$i".md.tmp
awk -v r="$i" '{gsub(/xxx/,r)}1' ~/pages/WCA-Stats/commonwcamiddles/"$i".md.tmp > ~/pages/WCA-Stats/commonwcamiddles/"$i".md.tmp2 && \
awk -v r="$date" '{gsub(/today_date/,r)}1' ~/pages/WCA-Stats/commonwcamiddles/"$i".md.tmp2 > ~/pages/WCA-Stats/commonwcamiddles/"$i".md && \
rm ~/pages/WCA-Stats/commonwcamiddles/*.tmp*
let finish=($(date +%s%N | cut -b1-13)-$start)
echo -e "\\r${CHECK_MARK} Most Common WCA Middles (${finish}ms)"

#Mollerz Membership

cp ~/pages/WCA-Stats/templates/mollerzmembership.md ~/pages/WCA-Stats/mollerzmembership/table.md.tmp
date=$(date -r ~/databasedownload/wca-developer-database-dump.zip +"%a %b %d at %H%MUTC")
awk -v r="$date" '{gsub(/today_date/,r)}1' ~/pages/WCA-Stats/mollerzmembership/table.md.tmp > ~/pages/WCA-Stats/mollerzmembership/table.md.tmp2
cp ~/pages/WCA-Stats/mollerzmembership/table.md.tmp2 ~/pages/WCA-Stats/mollerzmembership/table.md.tmp
mysql --login-path=local wca_stats -e "SELECT CONCAT('[',name,'](https://www.worldcubeassociation.org/persons/',id,')') Name, IF(eventsSucceeded = 17,'Y',CONCAT('N (',eventsSucceeded,'/17)')) \`All Events\`, IF(currentSpeedsolvingEventsAverage = 12,'Y',CONCAT('N (',currentSpeedsolvingEventsAverage,'/12)')) \`Speedsolving Averages\`, IF(bldfmcEventsAverage = 4,'Y',CONCAT('N (',bldfmcEventsAverage,'/4)')) \`BLD and FMC Means\`, IF(wcPodiums > 0,'Y','N') \`WC Podium\`, IF(WRs > 0,'Y','N') \`WR\`, IF(currentEventsWon = 17,'Y',CONCAT('N (',currentEventsWon,'/17)')) \`Events Won\` FROM persons_extra WHERE mollerzMembership = 'Diamond' ORDER BY FIELD(mollerzMembership,'Bronze','Silver','Gold','Platinum','Opal','Diamond',NULL) DESC, eventsSucceeded DESC, currentSpeedsolvingEventsAverage DESC, bldfmcEventsAverage DESC, wcPodiums DESC, WRs DESC, eventsWon DESC;" > ~/mysqloutput/original
sed 's/\t/|/g' ~/mysqloutput/original > ~/mysqloutput/output && \
sed -i.bak '2i\
--|--|--|--|--|--|--|--\' ~/mysqloutput/output
sed -i.bak 's/^/|/' ~/mysqloutput/output
sed -i.bak 's/$/|  /' ~/mysqloutput/output
output=$(cat ~/mysqloutput/output)
awk -v r="$output" '{gsub(/aaaaa/,r)}1' ~/pages/WCA-Stats/mollerzmembership/table.md.tmp > ~/pages/WCA-Stats/mollerzmembership/table.md.tmp2
cp ~/pages/WCA-Stats/mollerzmembership/table.md.tmp2 ~/pages/WCA-Stats/mollerzmembership/table.md.tmp
mysql --login-path=local wca_stats -e "SELECT CONCAT('[',name,'](https://www.worldcubeassociation.org/persons/',id,')') Name, IF(eventsSucceeded = 18,'Y',CONCAT('N (',eventsSucceeded,'/18)')) \`All Events\`, IF(currentSpeedsolvingEventsAverage = 13,'Y',CONCAT('N (',currentSpeedsolvingEventsAverage,'/13)')) \`Speedsolving Averages\`, IF(bldfmcEventsAverage = 4,'Y',CONCAT('N (',bldfmcEventsAverage,'/4)')) \`BLD and FMC Means\`, IF(wcPodiums > 0,'Y','N') \`WC Podium\`, IF(WRs > 0,'Y','N') \`WR\`, IF(currentEventsWon = 18,'Y',CONCAT('N (',currentEventsWon,'/18)')) \`Events Won\` 
FROM persons_extra 
WHERE mollerzMembership = 'Opal' 
ORDER BY FIELD(mollerzMembership,'Bronze','Silver','Gold','Platinum','Opal','Diamond',NULL) DESC, eventsSucceeded DESC, currentSpeedsolvingEventsAverage DESC, bldfmcEventsAverage DESC, wcPodiums DESC, WRs DESC, eventsWon DESC;" > ~/mysqloutput/original && \
sed 's/\t/|/g' ~/mysqloutput/original > ~/mysqloutput/output && \
sed -i.bak '2i\
--|--|--|--|--|--|--|--\' ~/mysqloutput/output
sed -i.bak 's/^/|/' ~/mysqloutput/output
sed -i.bak 's/$/|  /' ~/mysqloutput/output
output=$(cat ~/mysqloutput/output)
awk -v r="$output" '{gsub(/bbbbb/,r)}1' ~/pages/WCA-Stats/mollerzmembership/table.md.tmp > ~/pages/WCA-Stats/mollerzmembership/table.md.tmp2
cp ~/pages/WCA-Stats/mollerzmembership/table.md.tmp2 ~/pages/WCA-Stats/mollerzmembership/table.md.tmp
mysql --login-path=local wca_stats -e "SELECT CONCAT('[',name,'](https://www.worldcubeassociation.org/persons/',id,')') Name, IF(eventsSucceeded = 18,'Y',CONCAT('N (',eventsSucceeded,'/18)')) \`All Events\`, IF(currentSpeedsolvingEventsAverage = 13,'Y',CONCAT('N (',currentSpeedsolvingEventsAverage,'/13)')) \`Speedsolving Averages\`, IF(bldfmcEventsAverage = 4,'Y',CONCAT('N (',bldfmcEventsAverage,'/4)')) \`BLD and FMC Means\`, IF(wcPodiums > 0,'Y','N') \`WC Podium\`, IF(WRs > 0,'Y','N') \`WR\`, IF(currentEventsWon = 18,'Y',CONCAT('N (',currentEventsWon,'/18)')) \`Events Won\` 
FROM persons_extra 
WHERE mollerzMembership = 'Platinum' 
ORDER BY FIELD(mollerzMembership,'Bronze','Silver','Gold','Platinum','Opal','Diamond',NULL) DESC, eventsSucceeded DESC, currentSpeedsolvingEventsAverage DESC, bldfmcEventsAverage DESC, wcPodiums DESC, WRs DESC, eventsWon DESC;" > ~/mysqloutput/original && \
sed 's/\t/|/g' ~/mysqloutput/original > ~/mysqloutput/output && \
sed -i.bak '2i\
--|--|--|--|--|--|--|--\' ~/mysqloutput/output
sed -i.bak 's/^/|/' ~/mysqloutput/output
sed -i.bak 's/$/|  /' ~/mysqloutput/output
output=$(cat ~/mysqloutput/output)
awk -v r="$output" '{gsub(/ccccc/,r)}1' ~/pages/WCA-Stats/mollerzmembership/table.md.tmp > ~/pages/WCA-Stats/mollerzmembership/table.md.tmp2
cp ~/pages/WCA-Stats/mollerzmembership/table.md.tmp2 ~/pages/WCA-Stats/mollerzmembership/table.md.tmp
mysql --login-path=local wca_stats -e "SELECT CONCAT('[',name,'](https://www.worldcubeassociation.org/persons/',id,')') Name, IF(eventsSucceeded = 18,'Y',CONCAT('N (',eventsSucceeded,'/18)')) \`All Events\`, IF(currentSpeedsolvingEventsAverage = 13,'Y',CONCAT('N (',currentSpeedsolvingEventsAverage,'/13)')) \`Speedsolving Averages\`, IF(bldfmcEventsAverage = 4,'Y',CONCAT('N (',bldfmcEventsAverage,'/4)')) \`BLD and FMC Means\`, IF(wcPodiums > 0,'Y','N') \`WC Podium\`, IF(WRs > 0,'Y','N') \`WR\`, IF(currentEventsWon = 18,'Y',CONCAT('N (',currentEventsWon,'/18)')) \`Events Won\` 
FROM persons_extra 
WHERE mollerzMembership = 'Gold' 
ORDER BY FIELD(mollerzMembership,'Bronze','Silver','Gold','Platinum','Opal','Diamond',NULL) DESC, eventsSucceeded DESC, currentSpeedsolvingEventsAverage DESC, bldfmcEventsAverage DESC, wcPodiums DESC, WRs DESC, eventsWon DESC;" > ~/mysqloutput/original && \
sed 's/\t/|/g' ~/mysqloutput/original > ~/mysqloutput/output && \
sed -i.bak '2i\
--|--|--|--|--|--|--|--\' ~/mysqloutput/output
sed -i.bak 's/^/|/' ~/mysqloutput/output
sed -i.bak 's/$/|  /' ~/mysqloutput/output
output=$(cat ~/mysqloutput/output)
awk -v r="$output" '{gsub(/ddddd/,r)}1' ~/pages/WCA-Stats/mollerzmembership/table.md.tmp > ~/pages/WCA-Stats/mollerzmembership/table.md.tmp2
cp ~/pages/WCA-Stats/mollerzmembership/table.md.tmp2 ~/pages/WCA-Stats/mollerzmembership/table.md.tmp
mysql --login-path=local wca_stats -e "SELECT CONCAT('[',name,'](https://www.worldcubeassociation.org/persons/',id,')') Name, IF(eventsSucceeded = 18,'Y',CONCAT('N (',eventsSucceeded,'/18)')) \`All Events\`, IF(currentSpeedsolvingEventsAverage = 13,'Y',CONCAT('N (',currentSpeedsolvingEventsAverage,'/13)')) \`Speedsolving Averages\`, IF(bldfmcEventsAverage = 4,'Y',CONCAT('N (',bldfmcEventsAverage,'/4)')) \`BLD and FMC Means\`, IF(wcPodiums > 0,'Y','N') \`WC Podium\`, IF(WRs > 0,'Y','N') \`WR\`, IF(currentEventsWon = 18,'Y',CONCAT('N (',currentEventsWon,'/18)')) \`Events Won\` 
FROM persons_extra 
WHERE mollerzMembership = 'Silver' 
ORDER BY FIELD(mollerzMembership,'Bronze','Silver','Gold','Platinum','Opal','Diamond',NULL) DESC, eventsSucceeded DESC, currentSpeedsolvingEventsAverage DESC, bldfmcEventsAverage DESC, wcPodiums DESC, WRs DESC, eventsWon DESC;" > ~/mysqloutput/original && \
sed 's/\t/|/g' ~/mysqloutput/original > ~/mysqloutput/output && \
sed -i.bak '2i\
--|--|--|--|--|--|--|--\' ~/mysqloutput/output
sed -i.bak 's/^/|/' ~/mysqloutput/output
sed -i.bak 's/$/|  /' ~/mysqloutput/output
output=$(cat ~/mysqloutput/output)
awk -v r="$output" '{gsub(/eeeee/,r)}1' ~/pages/WCA-Stats/mollerzmembership/table.md.tmp > ~/pages/WCA-Stats/mollerzmembership/table.md.tmp2
cp ~/pages/WCA-Stats/mollerzmembership/table.md.tmp2 ~/pages/WCA-Stats/mollerzmembership/table.md.tmp
mysql --login-path=local wca_stats -e "SELECT CONCAT('[',name,'](https://www.worldcubeassociation.org/persons/',id,')') Name, IF(eventsSucceeded = 18,'Y',CONCAT('N (',eventsSucceeded,'/18)')) \`All Events\`, IF(currentSpeedsolvingEventsAverage = 13,'Y',CONCAT('N (',currentSpeedsolvingEventsAverage,'/13)')) \`Speedsolving Averages\`, IF(bldfmcEventsAverage = 4,'Y',CONCAT('N (',bldfmcEventsAverage,'/4)')) \`BLD and FMC Means\`, IF(wcPodiums > 0,'Y','N') \`WC Podium\`, IF(WRs > 0,'Y','N') \`WR\`, IF(currentEventsWon = 18,'Y',CONCAT('N (',currentEventsWon,'/18)')) \`Events Won\` 
FROM persons_extra 
WHERE mollerzMembership = 'Bronze' 
ORDER BY FIELD(mollerzMembership,'Bronze','Silver','Gold','Platinum','Opal','Diamond',NULL) DESC, eventsSucceeded DESC, currentSpeedsolvingEventsAverage DESC, bldfmcEventsAverage DESC, wcPodiums DESC, WRs DESC, eventsWon DESC;" > ~/mysqloutput/original && \
sed 's/\t/|/g' ~/mysqloutput/original > ~/mysqloutput/output && \
sed -i.bak '2i\
--|--|--|--|--|--|--|--\' ~/mysqloutput/output
sed -i.bak 's/^/|/' ~/mysqloutput/output
sed -i.bak 's/$/|  /' ~/mysqloutput/output
output=$(cat ~/mysqloutput/output)
awk -v r="$output" '{gsub(/fffff/,r)}1' ~/pages/WCA-Stats/mollerzmembership/table.md.tmp > ~/pages/WCA-Stats/mollerzmembership/table.md.tmp2
cp ~/pages/WCA-Stats/mollerzmembership/table.md.tmp2 ~/pages/WCA-Stats/mollerzmembership/table.md.tmp
mysql --login-path=local wca_stats -e "SELECT CONCAT('[',name,'](https://www.worldcubeassociation.org/persons/',id,')') Name, IF(eventsSucceeded = 18,'Y',CONCAT('N (',eventsSucceeded,'/18)')) \`All Events\`, IF(currentSpeedsolvingEventsAverage = 13,'Y',CONCAT('N (',currentSpeedsolvingEventsAverage,'/13)')) \`Speedsolving Averages\`, IF(bldfmcEventsAverage = 4,'Y',CONCAT('N (',bldfmcEventsAverage,'/4)')) \`BLD and FMC Means\`, IF(wcPodiums > 0,'Y','N') \`WC Podium\`, IF(WRs > 0,'Y','N') \`WR\`, IF(currentEventsWon = 18,'Y',CONCAT('N (',currentEventsWon,'/18)')) \`Events Won\` 
FROM persons_extra 
WHERE eventsSucceeded = 17
ORDER BY FIELD(mollerzMembership,'Bronze','Silver','Gold','Platinum','Opal','Diamond',NULL) DESC, eventsSucceeded DESC, currentSpeedsolvingEventsAverage DESC, bldfmcEventsAverage DESC, wcPodiums DESC, WRs DESC, eventsWon DESC;" > ~/mysqloutput/original && \
sed 's/\t/|/g' ~/mysqloutput/original > ~/mysqloutput/output && \
sed -i.bak '2i\
--|--|--|--|--|--|--|--\' ~/mysqloutput/output
sed -i.bak 's/^/|/' ~/mysqloutput/output
sed -i.bak 's/$/|  /' ~/mysqloutput/output
output=$(cat ~/mysqloutput/output)
awk -v r="$output" '{gsub(/ggggg/,r)}1' ~/pages/WCA-Stats/mollerzmembership/table.md.tmp > ~/pages/WCA-Stats/mollerzmembership/table.md.tmp2
cp ~/pages/WCA-Stats/mollerzmembership/table.md.tmp2 ~/pages/WCA-Stats/mollerzmembership/table.md
rm ~/pages/WCA-Stats/mollerzmembership/*.tmp*

# My PBs

declare -a arr=(2015SPEN01 2017GOLD02)

for i in "${arr[@]}"
do
	mysql --login-path=local wca_stats -e "SELECT eventId, format, succeeded, FORMAT_RESULT(result,eventId,format) result, worldRank, continentRank, countryRank, competitionId, date FROM ranks_all WHERE personId = '${i}';" > ~/mysqloutput/original && \
	sed 's/\t/|/g' ~/mysqloutput/original > ~/mysqloutput/output
	sed -i.bak '2i\
	--|--|--|--|--|--|--|--|--|--|--|--|--|--|--\' ~/mysqloutput/output
	sed -i.bak 's/^/|/' ~/mysqloutput/output
	sed -i.bak 's/$/|  /' ~/mysqloutput/output
	cp ~/pages/WCA-Stats/templates/misc.md ~/pages/WCA-Stats/misc/"$i".md
	cat ~/mysqloutput/output >> ~/pages/WCA-Stats/misc/"$i".md
done

rm ~/mysqloutput/*

d=$(date +%Y-%m-%d)
cd ~/pages/WCA-Stats/ && git add -A && git commit -m "${d} update" && git push origin gh-pages

