
#End of Year Stats for WCT

cp ~/pages/WCA-Stats/templates/endofyearstats.md ~/pages/WCA-Stats/endofyearstats/2018.md.tmp
date=$(date -r ~/databasedownload/wca-developer-database-dump.zip +"%a %b %d at %H%MUTC")
awk -v r="$date" '{gsub(/today_date/,r)}1' ~/pages/WCA-Stats/endofyearstats/2018.md.tmp > ~/pages/WCA-Stats/endofyearstats/2018.md.tmp2
cp ~/pages/WCA-Stats/endofyearstats/2018.md.tmp2 ~/pages/WCA-Stats/endofyearstats/2018.md.tmp
mysql --login-path=local wca_stats -e "SELECT personId, personName, personCountryId, COUNT(*) FROM all_attempts WHERE value > 0 AND YEAR(date) = 2018 GROUP BY personId ORDER BY COUNT(*) DESC LIMIT 10;" > ~/mysqloutput/original && \
sed 's/\t/|/g' ~/mysqloutput/original > ~/mysqloutput/output && \
sed -i.bak '2i\
--|--|--|--\' ~/mysqloutput/output
sed -i.bak 's/^/|/' ~/mysqloutput/output
sed -i.bak 's/$/|  /' ~/mysqloutput/output
output=$(cat ~/mysqloutput/output)
awk -v r="$output" '{gsub(/aaaaa/,r)}1' ~/pages/WCA-Stats/endofyearstats/2018.md.tmp > ~/pages/WCA-Stats/endofyearstats/2018.md.tmp2
cp ~/pages/WCA-Stats/endofyearstats/2018.md.tmp2 ~/pages/WCA-Stats/endofyearstats/2018.md.tmp
mysql --login-path=local wca_stats -e "SELECT personId, personName, personCountryId, COUNT(DISTINCT compCountryId) FROM results_extra WHERE YEAR(date) = 2018 AND compCountryId NOT LIKE 'X_' GROUP BY personId ORDER BY COUNT(DISTINCT compCountryId) DESC LIMIT 10;" > ~/mysqloutput/original && \
sed 's/\t/|/g' ~/mysqloutput/original > ~/mysqloutput/output && \
sed -i.bak '2i\
--|--|--|--\' ~/mysqloutput/output
sed -i.bak 's/^/|/' ~/mysqloutput/output
sed -i.bak 's/$/|  /' ~/mysqloutput/output
output=$(cat ~/mysqloutput/output)
awk -v r="$output" '{gsub(/bbbbb/,r)}1' ~/pages/WCA-Stats/endofyearstats/2018.md.tmp > ~/pages/WCA-Stats/endofyearstats/2018.md.tmp2
cp ~/pages/WCA-Stats/endofyearstats/2018.md.tmp2 ~/pages/WCA-Stats/endofyearstats/2018.md.tmp
mysql --login-path=local wca_stats -e "SELECT personId, personName, personCountryId, COUNT(*) FROM results_extra WHERE YEAR(date) = 2018 AND roundTypeId IN ('c','f') AND pos = 1 AND best > 0 GROUP BY personID ORDER BY COUNT(*) DESC LIMIT 10;" > ~/mysqloutput/original && \
sed 's/\t/|/g' ~/mysqloutput/original > ~/mysqloutput/output && \
sed -i.bak '2i\
--|--|--|--\' ~/mysqloutput/output
sed -i.bak 's/^/|/' ~/mysqloutput/output
sed -i.bak 's/$/|  /' ~/mysqloutput/output
output=$(cat ~/mysqloutput/output)
awk -v r="$output" '{gsub(/ccccc/,r)}1' ~/pages/WCA-Stats/endofyearstats/2018.md.tmp > ~/pages/WCA-Stats/endofyearstats/2018.md.tmp2
cp ~/pages/WCA-Stats/endofyearstats/2018.md.tmp2 ~/pages/WCA-Stats/endofyearstats/2018.md.tmp
mysql --login-path=local wca_stats -e "SELECT personId, personName, personCountryId, COUNT(*) FROM results_extra WHERE YEAR(date) = 2018 AND roundTypeId IN ('c','f') AND pos = 2 AND best > 0 GROUP BY personID ORDER BY COUNT(*) DESC LIMIT 10;" > ~/mysqloutput/original && \
sed 's/\t/|/g' ~/mysqloutput/original > ~/mysqloutput/output && \
sed -i.bak '2i\
--|--|--|--\' ~/mysqloutput/output
sed -i.bak 's/^/|/' ~/mysqloutput/output
sed -i.bak 's/$/|  /' ~/mysqloutput/output
output=$(cat ~/mysqloutput/output)
awk -v r="$output" '{gsub(/ddddd/,r)}1' ~/pages/WCA-Stats/endofyearstats/2018.md.tmp > ~/pages/WCA-Stats/endofyearstats/2018.md.tmp2
cp ~/pages/WCA-Stats/endofyearstats/2018.md.tmp2 ~/pages/WCA-Stats/endofyearstats/2018.md.tmp
mysql --login-path=local wca_stats -e "SELECT personId, personName, personCountryId, COUNT(*) FROM results_extra WHERE YEAR(date) = 2018 AND roundTypeId IN ('c','f') AND pos = 3 AND best > 0 GROUP BY personID ORDER BY COUNT(*) DESC LIMIT 10;" > ~/mysqloutput/original && \
sed 's/\t/|/g' ~/mysqloutput/original > ~/mysqloutput/output && \
sed -i.bak '2i\
--|--|--|--\' ~/mysqloutput/output
sed -i.bak 's/^/|/' ~/mysqloutput/output
sed -i.bak 's/$/|  /' ~/mysqloutput/output
output=$(cat ~/mysqloutput/output)
awk -v r="$output" '{gsub(/eeeee/,r)}1' ~/pages/WCA-Stats/endofyearstats/2018.md.tmp > ~/pages/WCA-Stats/endofyearstats/2018.md.tmp2
cp ~/pages/WCA-Stats/endofyearstats/2018.md.tmp2 ~/pages/WCA-Stats/endofyearstats/2018.md.tmp
mysql --login-path=local wca_stats -e "SELECT personId, personName, personCountryId, COUNT(*) FROM results_extra WHERE YEAR(date) = 2018 AND roundTypeId IN ('c','f') AND pos <= 3 AND best > 0 GROUP BY personID ORDER BY COUNT(*) DESC LIMIT 10;" > ~/mysqloutput/original && \
sed 's/\t/|/g' ~/mysqloutput/original > ~/mysqloutput/output && \
sed -i.bak '2i\
--|--|--|--\' ~/mysqloutput/output
sed -i.bak 's/^/|/' ~/mysqloutput/output
sed -i.bak 's/$/|  /' ~/mysqloutput/output
output=$(cat ~/mysqloutput/output)
awk -v r="$output" '{gsub(/fffff/,r)}1' ~/pages/WCA-Stats/endofyearstats/2018.md.tmp > ~/pages/WCA-Stats/endofyearstats/2018.md.tmp2
cp ~/pages/WCA-Stats/endofyearstats/2018.md.tmp2 ~/pages/WCA-Stats/endofyearstats/2018.md.tmp
mysql --login-path=local wca_stats -e "SELECT u.name, COUNT(*) FROM wca_dev.competition_organizers co JOIN wca_dev.users u ON co.organizer_id = u.id WHERE competition_id LIKE '%2018' GROUP BY co.organizer_id ORDER BY COUNT(*) DESC LIMIT 10;" > ~/mysqloutput/original && \
sed 's/\t/|/g' ~/mysqloutput/original > ~/mysqloutput/output && \
sed -i.bak '2i\
--|--\' ~/mysqloutput/output
sed -i.bak 's/^/|/' ~/mysqloutput/output
sed -i.bak 's/$/|  /' ~/mysqloutput/output
output=$(cat ~/mysqloutput/output)
awk -v r="$output" '{gsub(/ggggg/,r)}1' ~/pages/WCA-Stats/endofyearstats/2018.md.tmp > ~/pages/WCA-Stats/endofyearstats/2018.md.tmp2
cp ~/pages/WCA-Stats/endofyearstats/2018.md.tmp2 ~/pages/WCA-Stats/endofyearstats/2018.md.tmp
mysql --login-path=local wca_stats -e "SELECT countryId FROM competitions_extra GROUP BY countryId HAVING MIN(YEAR(endDate)) = 2018;" > ~/mysqloutput/original && \
sed 's/\t/|/g' ~/mysqloutput/original > ~/mysqloutput/output && \
sed -i.bak '2i\
--\' ~/mysqloutput/output
sed -i.bak 's/^/|/' ~/mysqloutput/output
sed -i.bak 's/$/|  /' ~/mysqloutput/output
output=$(cat ~/mysqloutput/output)
awk -v r="$output" '{gsub(/hhhhh/,r)}1' ~/pages/WCA-Stats/endofyearstats/2018.md.tmp > ~/pages/WCA-Stats/endofyearstats/2018.md.tmp2
cp ~/pages/WCA-Stats/endofyearstats/2018.md.tmp2 ~/pages/WCA-Stats/endofyearstats/2018.md.tmp
mysql --login-path=local wca_stats -e "SELECT cityName, COUNT(*) FROM competitions_extra WHERE YEAR(endDate) = 2018 GROUP BY cityName ORDER BY COUNT(*) DESC LIMIT 10;" > ~/mysqloutput/original && \
sed 's/\t/|/g' ~/mysqloutput/original > ~/mysqloutput/output && \
sed -i.bak '2i\
--|--\' ~/mysqloutput/output
sed -i.bak 's/^/|/' ~/mysqloutput/output
sed -i.bak 's/$/|  /' ~/mysqloutput/output
output=$(cat ~/mysqloutput/output)
awk -v r="$output" '{gsub(/iiiii/,r)}1' ~/pages/WCA-Stats/endofyearstats/2018.md.tmp > ~/pages/WCA-Stats/endofyearstats/2018.md.tmp2
cp ~/pages/WCA-Stats/endofyearstats/2018.md.tmp2 ~/pages/WCA-Stats/endofyearstats/2018.md.tmp
mysql --login-path=local wca_stats -e "SELECT countryId, COUNT(*) FROM competitions_extra WHERE YEAR(endDate) = 2018 GROUP BY countryId ORDER BY COUNT(*) DESC LIMIT 10;" > ~/mysqloutput/original && \
sed 's/\t/|/g' ~/mysqloutput/original > ~/mysqloutput/output && \
sed -i.bak '2i\
--|--\' ~/mysqloutput/output
sed -i.bak 's/^/|/' ~/mysqloutput/output
sed -i.bak 's/$/|  /' ~/mysqloutput/output
output=$(cat ~/mysqloutput/output)
awk -v r="$output" '{gsub(/jjjjj/,r)}1' ~/pages/WCA-Stats/endofyearstats/2018.md.tmp > ~/pages/WCA-Stats/endofyearstats/2018.md.tmp2
cp ~/pages/WCA-Stats/endofyearstats/2018.md.tmp2 ~/pages/WCA-Stats/endofyearstats/2018.md.tmp
mysql --login-path=local wca_stats -e "SELECT personId, personName, personCountryId, COUNT(*) FROM all_attempts WHERE value = -1 AND YEAR(date) = 2018 GROUP BY personId ORDER BY COUNT(*) DESC LIMIT 10;" > ~/mysqloutput/original && \
sed 's/\t/|/g' ~/mysqloutput/original > ~/mysqloutput/output && \
sed -i.bak '2i\
--|--|--|--\' ~/mysqloutput/output
sed -i.bak 's/^/|/' ~/mysqloutput/output
sed -i.bak 's/$/|  /' ~/mysqloutput/output
output=$(cat ~/mysqloutput/output)
awk -v r="$output" '{gsub(/kkkkk/,r)}1' ~/pages/WCA-Stats/endofyearstats/2018.md.tmp > ~/pages/WCA-Stats/endofyearstats/2018.md.tmp2
cp ~/pages/WCA-Stats/endofyearstats/2018.md.tmp2 ~/pages/WCA-Stats/endofyearstats/2018.md.tmp
mysql --login-path=local wca_stats -e "SELECT personId, personName, personCountryId, COUNT(*) FROM all_attempts WHERE value > 0 AND YEAR(date) = 2018 AND eventId = '333bf' GROUP BY personId ORDER BY COUNT(*) DESC LIMIT 10;" > ~/mysqloutput/original && \
sed 's/\t/|/g' ~/mysqloutput/original > ~/mysqloutput/output && \
sed -i.bak '2i\
--|--|--|--\' ~/mysqloutput/output
sed -i.bak 's/^/|/' ~/mysqloutput/output
sed -i.bak 's/$/|  /' ~/mysqloutput/output
output=$(cat ~/mysqloutput/output)
awk -v r="$output" '{gsub(/lllll/,r)}1' ~/pages/WCA-Stats/endofyearstats/2018.md.tmp > ~/pages/WCA-Stats/endofyearstats/2018.md.tmp2
cp ~/pages/WCA-Stats/endofyearstats/2018.md.tmp2 ~/pages/WCA-Stats/endofyearstats/2018.md.tmp
mysql --login-path=local wca_stats -e "SET @a = 0, @p = ''; SELECT personId, personName, personCountryId, MAX(streak) FROM (SELECT *, @a := IF(@p = personId AND value > 0, @a + 1, 1) streak, @p := personId FROM (SELECT personId, personName, personCountryId, value, id FROM all_attempts WHERE YEAR(date) = 2018 AND eventId = '333bf' ORDER BY personId, id) a ORDER BY personId, id) b GROUP BY personId ORDER BY MAX(streak) DESC LIMIT 10;" > ~/mysqloutput/original && \
sed 's/\t/|/g' ~/mysqloutput/original > ~/mysqloutput/output && \
sed -i.bak '2i\
--|--|--|--\' ~/mysqloutput/output
sed -i.bak 's/^/|/' ~/mysqloutput/output
sed -i.bak 's/$/|  /' ~/mysqloutput/output
output=$(cat ~/mysqloutput/output)
awk -v r="$output" '{gsub(/mmmmm/,r)}1' ~/pages/WCA-Stats/endofyearstats/2018.md.tmp > ~/pages/WCA-Stats/endofyearstats/2018.md.tmp2
cp ~/pages/WCA-Stats/endofyearstats/2018.md.tmp2 ~/pages/WCA-Stats/endofyearstats/2018.md.tmp
mysql --login-path=local wca_stats -e "SELECT personId, personName, personCountryId, COUNT(DISTINCT competitionId) FROM results_extra WHERE YEAR(date) = 2018 GROUP BY personId ORDER BY COUNT(DISTINCT competitionId) DESC LIMIT 10;" > ~/mysqloutput/original && \
sed 's/\t/|/g' ~/mysqloutput/original > ~/mysqloutput/output && \
sed -i.bak '2i\
--|--|--|--\' ~/mysqloutput/output
sed -i.bak 's/^/|/' ~/mysqloutput/output
sed -i.bak 's/$/|  /' ~/mysqloutput/output
output=$(cat ~/mysqloutput/output)
awk -v r="$output" '{gsub(/nnnnn/,r)}1' ~/pages/WCA-Stats/endofyearstats/2018.md.tmp > ~/pages/WCA-Stats/endofyearstats/2018.md.tmp2
cp ~/pages/WCA-Stats/endofyearstats/2018.md.tmp2 ~/pages/WCA-Stats/endofyearstats/2018.md.tmp
mysql --login-path=local wca_stats -e "SELECT pce.personId, pce.personName, pce.personCountryId, SUM(ce.WRs) FROM person_comps_extra pce JOIN competitions_extra ce ON pce.competitionId = ce.id WHERE YEAR(ce.endDate) = 2018 GROUP BY pce.personId ORDER BY SUM(ce.WRs) DESC LIMIT 10;" > ~/mysqloutput/original && \
sed 's/\t/|/g' ~/mysqloutput/original > ~/mysqloutput/output && \
sed -i.bak '2i\
--|--|--|--\' ~/mysqloutput/output
sed -i.bak 's/^/|/' ~/mysqloutput/output
sed -i.bak 's/$/|  /' ~/mysqloutput/output
output=$(cat ~/mysqloutput/output)
awk -v r="$output" '{gsub(/ooooo/,r)}1' ~/pages/WCA-Stats/endofyearstats/2018.md.tmp > ~/pages/WCA-Stats/endofyearstats/2018.md.tmp2
cp ~/pages/WCA-Stats/endofyearstats/2018.md.tmp2 ~/pages/WCA-Stats/endofyearstats/2018.md.tmp
mysql --login-path=local wca_stats -e "SELECT a.id, a.name, a.countryId, b.membership \`2017\`, a.membership \`2018\` FROM persons_extra a INNER JOIN persons_extra_2017 b ON a.id = b.id WHERE a.membership <> b.membership ORDER BY FIELD(a.membership,'Platinum','Gold','Silver','Bronze','None'), FIELD(b.membership,'Platinum','Gold','Silver','Bronze','None'), a.id;" > ~/mysqloutput/original && \
sed 's/\t/|/g' ~/mysqloutput/original > ~/mysqloutput/output && \
sed -i.bak '2i\
--|--|--|--|--\' ~/mysqloutput/output
sed -i.bak 's/^/|/' ~/mysqloutput/output
sed -i.bak 's/$/|  /' ~/mysqloutput/output
output=$(cat ~/mysqloutput/output)
awk -v r="$output" '{gsub(/ppppp/,r)}1' ~/pages/WCA-Stats/endofyearstats/2018.md.tmp > ~/pages/WCA-Stats/endofyearstats/2018.md.tmp2
cp ~/pages/WCA-Stats/endofyearstats/2018.md.tmp2 ~/pages/WCA-Stats/endofyearstats/2018.md.tmp
mysql --login-path=local wca_stats -e "SELECT name, competitors FROM competitions_extra WHERE YEAR(endDate) = 2018 AND competitors > 0 ORDER BY competitors ASC LIMIT 10;" > ~/mysqloutput/original && \
sed 's/\t/|/g' ~/mysqloutput/original > ~/mysqloutput/output && \
sed -i.bak '2i\
--|--\' ~/mysqloutput/output
sed -i.bak 's/^/|/' ~/mysqloutput/output
sed -i.bak 's/$/|  /' ~/mysqloutput/output
output=$(cat ~/mysqloutput/output)
awk -v r="$output" '{gsub(/qqqqq/,r)}1' ~/pages/WCA-Stats/endofyearstats/2018.md.tmp > ~/pages/WCA-Stats/endofyearstats/2018.md.tmp2
cp ~/pages/WCA-Stats/endofyearstats/2018.md.tmp2 ~/pages/WCA-Stats/endofyearstats/2018.md.tmp
mysql --login-path=local wca_stats -e "SET @val = 0, @pid = ''; SELECT p.id, p.name, p.countryId, MAX(pbStreak) FROM (SELECT a.*, @val := IF(a.PBs = 0, 0, IF(a.personId = @pid, @val + 1, 1)) pbStreak, @scomp := IF(@val = 0, NULL, IF(@val = 1, competitionId, @scomp)) startComp, @ecomp := IF(@val = 0, NULL, competitionId) endComp, @pid := personId pidhelp FROM (SELECT * FROM competition_PBs WHERE competitionId LIKE '%2018' ORDER BY id ASC) a GROUP BY a.personId, a.competitionId ORDER BY a.id ASC) pbs JOIN persons_extra p ON pbs.personid = p.id GROUP BY p.id ORDER BY MAX(pbStreak) DESC LIMIT 10;" > ~/mysqloutput/original && \
sed 's/\t/|/g' ~/mysqloutput/original > ~/mysqloutput/output && \
sed -i.bak '2i\
--|--|--|--\' ~/mysqloutput/output
sed -i.bak 's/^/|/' ~/mysqloutput/output
sed -i.bak 's/$/|  /' ~/mysqloutput/output
output=$(cat ~/mysqloutput/output)
awk -v r="$output" '{gsub(/rrrrr/,r)}1' ~/pages/WCA-Stats/endofyearstats/2018.md.tmp > ~/pages/WCA-Stats/endofyearstats/2018.md.tmp2
cp ~/pages/WCA-Stats/endofyearstats/2018.md.tmp2 ~/pages/WCA-Stats/endofyearstats/2018.md.tmp
mysql --login-path=local wca_stats -e "SELECT p.id, p.name, p.countryId, pbs.pbs, pbs.competitionId FROM competition_pbs pbs JOIN persons_extra p ON pbs.personId = p.id WHERE competitionId IN (SELECT id FROM competitions_extra WHERE YEAR(endDate) = 2018) ORDER BY PBs DESC LIMIT 10;" > ~/mysqloutput/original && \
sed 's/\t/|/g' ~/mysqloutput/original > ~/mysqloutput/output && \
sed -i.bak '2i\
--|--|--|--|--\' ~/mysqloutput/output
sed -i.bak 's/^/|/' ~/mysqloutput/output
sed -i.bak 's/$/|  /' ~/mysqloutput/output
output=$(cat ~/mysqloutput/output)
awk -v r="$output" '{gsub(/sssss/,r)}1' ~/pages/WCA-Stats/endofyearstats/2018.md.tmp > ~/pages/WCA-Stats/endofyearstats/2018.md.tmp2
cp ~/pages/WCA-Stats/endofyearstats/2018.md.tmp2 ~/pages/WCA-Stats/endofyearstats/2018.md.tmp
mysql --login-path=local wca_stats -e "SELECT u.name, COUNT(*) FROM wca_dev.competition_delegates co JOIN wca_dev.users u ON co.delegate_id = u.id WHERE competition_id LIKE '%2018' GROUP BY co.delegate_id ORDER BY COUNT(*) DESC LIMIT 10;" > ~/mysqloutput/original && \
sed 's/\t/|/g' ~/mysqloutput/original > ~/mysqloutput/output && \
sed -i.bak '2i\
--|--\' ~/mysqloutput/output
sed -i.bak 's/^/|/' ~/mysqloutput/output
sed -i.bak 's/$/|  /' ~/mysqloutput/output
output=$(cat ~/mysqloutput/output)
awk -v r="$output" '{gsub(/ttttt/,r)}1' ~/pages/WCA-Stats/endofyearstats/2018.md.tmp > ~/pages/WCA-Stats/endofyearstats/2018.md.tmp2
cp ~/pages/WCA-Stats/endofyearstats/2018.md.tmp2 ~/pages/WCA-Stats/endofyearstats/2018.md.tmp
mysql --login-path=local wca_stats -e "SELECT p.id, p.name, p.countryId, CENTISECONDTOTIME(a.average) \`2017\`, CENTISECONDTOTIME(b.result) \`2018\`, 100*(a.average-b.result)/a.average percentImproved FROM (SELECT personId, MIN(average) average FROM results_extra WHERE average > 0 AND eventId = '333' AND YEAR(date) < 2018 GROUP BY personId) a JOIN (SELECT * FROM ranks_all WHERE eventId = '333' AND succeeded = 1 AND format = 'a') b ON a.personid = b.personId JOIN persons_extra p ON a.personId = p.id ORDER BY percentImproved DESC LIMIT 10;" > ~/mysqloutput/original && \
sed 's/\t/|/g' ~/mysqloutput/original > ~/mysqloutput/output && \
sed -i.bak '2i\
--|--\' ~/mysqloutput/output
sed -i.bak 's/^/|/' ~/mysqloutput/output
sed -i.bak 's/$/|  /' ~/mysqloutput/output
output=$(cat ~/mysqloutput/output)
awk -v r="$output" '{gsub(/uuuuu/,r)}1' ~/pages/WCA-Stats/endofyearstats/2018.md.tmp > ~/pages/WCA-Stats/endofyearstats/2018.md.tmp2
cp ~/pages/WCA-Stats/endofyearstats/2018.md.tmp2 ~/pages/WCA-Stats/endofyearstats/2018.md
rm ~/pages/WCA-Stats/endofyearstats/*.tmp*

#End of Year Stats for WCT China

cp ~/pages/WCA-Stats/templates/endofyearstats.md ~/pages/WCA-Stats/endofyearstats/2018china.md.tmp
date=$(date -r ~/databasedownload/wca-developer-database-dump.zip +"%a %b %d at %H%MUTC")
awk -v r="$date" '{gsub(/today_date/,r)}1' ~/pages/WCA-Stats/endofyearstats/2018china.md.tmp > ~/pages/WCA-Stats/endofyearstats/2018china.md.tmp2
cp ~/pages/WCA-Stats/endofyearstats/2018china.md.tmp2 ~/pages/WCA-Stats/endofyearstats/2018china.md.tmp
mysql --login-path=local wca_stats -e "SELECT personId, personName, personCountryId, COUNT(*) FROM all_attempts WHERE personCountryId = 'China' AND value > 0 AND YEAR(date) = 2018 GROUP BY personId ORDER BY COUNT(*) DESC LIMIT 10;" > ~/mysqloutput/original && \
sed 's/\t/|/g' ~/mysqloutput/original > ~/mysqloutput/output && \
sed -i.bak '2i\
--|--|--|--\' ~/mysqloutput/output
sed -i.bak 's/^/|/' ~/mysqloutput/output
sed -i.bak 's/$/|  /' ~/mysqloutput/output
output=$(cat ~/mysqloutput/output)
awk -v r="$output" '{gsub(/aaaaa/,r)}1' ~/pages/WCA-Stats/endofyearstats/2018china.md.tmp > ~/pages/WCA-Stats/endofyearstats/2018china.md.tmp2
cp ~/pages/WCA-Stats/endofyearstats/2018china.md.tmp2 ~/pages/WCA-Stats/endofyearstats/2018china.md.tmp
mysql --login-path=local wca_stats -e "SELECT personId, personName, personCountryId, COUNT(DISTINCT compCountryId) FROM results_extra WHERE personCountryId = 'China' AND YEAR(date) = 2018 AND compCountryId NOT LIKE 'X_' GROUP BY personId ORDER BY COUNT(DISTINCT compCountryId) DESC LIMIT 10;" > ~/mysqloutput/original && \
sed 's/\t/|/g' ~/mysqloutput/original > ~/mysqloutput/output && \
sed -i.bak '2i\
--|--|--|--\' ~/mysqloutput/output
sed -i.bak 's/^/|/' ~/mysqloutput/output
sed -i.bak 's/$/|  /' ~/mysqloutput/output
output=$(cat ~/mysqloutput/output)
awk -v r="$output" '{gsub(/bbbbb/,r)}1' ~/pages/WCA-Stats/endofyearstats/2018china.md.tmp > ~/pages/WCA-Stats/endofyearstats/2018china.md.tmp2
cp ~/pages/WCA-Stats/endofyearstats/2018china.md.tmp2 ~/pages/WCA-Stats/endofyearstats/2018china.md.tmp
mysql --login-path=local wca_stats -e "SELECT personId, personName, personCountryId, COUNT(*) FROM results_extra WHERE personCountryId ='China' AND YEAR(date) = 2018 AND roundTypeId IN ('c','f') AND pos = 1 AND best > 0 GROUP BY personID ORDER BY COUNT(*) DESC LIMIT 10;" > ~/mysqloutput/original && \
sed 's/\t/|/g' ~/mysqloutput/original > ~/mysqloutput/output && \
sed -i.bak '2i\
--|--|--|--\' ~/mysqloutput/output
sed -i.bak 's/^/|/' ~/mysqloutput/output
sed -i.bak 's/$/|  /' ~/mysqloutput/output
output=$(cat ~/mysqloutput/output)
awk -v r="$output" '{gsub(/ccccc/,r)}1' ~/pages/WCA-Stats/endofyearstats/2018china.md.tmp > ~/pages/WCA-Stats/endofyearstats/2018china.md.tmp2
cp ~/pages/WCA-Stats/endofyearstats/2018china.md.tmp2 ~/pages/WCA-Stats/endofyearstats/2018china.md.tmp
mysql --login-path=local wca_stats -e "SELECT personId, personName, personCountryId, COUNT(*) FROM results_extra WHERE personCountryId = 'China' AND YEAR(date) = 2018 AND roundTypeId IN ('c','f') AND pos = 2 AND best > 0 GROUP BY personID ORDER BY COUNT(*) DESC LIMIT 10;" > ~/mysqloutput/original && \
sed 's/\t/|/g' ~/mysqloutput/original > ~/mysqloutput/output && \
sed -i.bak '2i\
--|--|--|--\' ~/mysqloutput/output
sed -i.bak 's/^/|/' ~/mysqloutput/output
sed -i.bak 's/$/|  /' ~/mysqloutput/output
output=$(cat ~/mysqloutput/output)
awk -v r="$output" '{gsub(/ddddd/,r)}1' ~/pages/WCA-Stats/endofyearstats/2018china.md.tmp > ~/pages/WCA-Stats/endofyearstats/2018china.md.tmp2
cp ~/pages/WCA-Stats/endofyearstats/2018china.md.tmp2 ~/pages/WCA-Stats/endofyearstats/2018china.md.tmp
mysql --login-path=local wca_stats -e "SELECT personId, personName, personCountryId, COUNT(*) FROM results_extra WHERE personCountryId = 'China' AND YEAR(date) = 2018 AND roundTypeId IN ('c','f') AND pos = 3 AND best > 0 GROUP BY personID ORDER BY COUNT(*) DESC LIMIT 10;" > ~/mysqloutput/original && \
sed 's/\t/|/g' ~/mysqloutput/original > ~/mysqloutput/output && \
sed -i.bak '2i\
--|--|--|--\' ~/mysqloutput/output
sed -i.bak 's/^/|/' ~/mysqloutput/output
sed -i.bak 's/$/|  /' ~/mysqloutput/output
output=$(cat ~/mysqloutput/output)
awk -v r="$output" '{gsub(/eeeee/,r)}1' ~/pages/WCA-Stats/endofyearstats/2018china.md.tmp > ~/pages/WCA-Stats/endofyearstats/2018china.md.tmp2
cp ~/pages/WCA-Stats/endofyearstats/2018china.md.tmp2 ~/pages/WCA-Stats/endofyearstats/2018china.md.tmp
mysql --login-path=local wca_stats -e "SELECT personId, personName, personCountryId, COUNT(*) FROM results_extra WHERE personCountryId = 'China' AND YEAR(date) = 2018 AND roundTypeId IN ('c','f') AND pos <= 3 AND best > 0 GROUP BY personID ORDER BY COUNT(*) DESC LIMIT 10;" > ~/mysqloutput/original && \
sed 's/\t/|/g' ~/mysqloutput/original > ~/mysqloutput/output && \
sed -i.bak '2i\
--|--|--|--\' ~/mysqloutput/output
sed -i.bak 's/^/|/' ~/mysqloutput/output
sed -i.bak 's/$/|  /' ~/mysqloutput/output
output=$(cat ~/mysqloutput/output)
awk -v r="$output" '{gsub(/fffff/,r)}1' ~/pages/WCA-Stats/endofyearstats/2018china.md.tmp > ~/pages/WCA-Stats/endofyearstats/2018china.md.tmp2
cp ~/pages/WCA-Stats/endofyearstats/2018china.md.tmp2 ~/pages/WCA-Stats/endofyearstats/2018china.md.tmp
mysql --login-path=local wca_stats -e "SELECT u.name, COUNT(*) FROM wca_dev.competition_organizers co JOIN wca_dev.users u ON co.organizer_id = u.id WHERE u.country_iso2 = 'CN' AND competition_id LIKE '%2018' GROUP BY co.organizer_id ORDER BY COUNT(*) DESC LIMIT 10;" > ~/mysqloutput/original && \
sed 's/\t/|/g' ~/mysqloutput/original > ~/mysqloutput/output && \
sed -i.bak '2i\
--|--\' ~/mysqloutput/output
sed -i.bak 's/^/|/' ~/mysqloutput/output
sed -i.bak 's/$/|  /' ~/mysqloutput/output
output=$(cat ~/mysqloutput/output)
awk -v r="$output" '{gsub(/ggggg/,r)}1' ~/pages/WCA-Stats/endofyearstats/2018china.md.tmp > ~/pages/WCA-Stats/endofyearstats/2018china.md.tmp2
cp ~/pages/WCA-Stats/endofyearstats/2018china.md.tmp2 ~/pages/WCA-Stats/endofyearstats/2018china.md.tmp
mysql --login-path=local wca_stats -e "SELECT countryId FROM competitions_extra GROUP BY countryId HAVING MIN(YEAR(endDate)) = 2018;" > ~/mysqloutput/original && \
sed 's/\t/|/g' ~/mysqloutput/original > ~/mysqloutput/output && \
sed -i.bak '2i\
--\' ~/mysqloutput/output
sed -i.bak 's/^/|/' ~/mysqloutput/output
sed -i.bak 's/$/|  /' ~/mysqloutput/output
output=$(cat ~/mysqloutput/output)
awk -v r="$output" '{gsub(/hhhhh/,r)}1' ~/pages/WCA-Stats/endofyearstats/2018china.md.tmp > ~/pages/WCA-Stats/endofyearstats/2018china.md.tmp2
cp ~/pages/WCA-Stats/endofyearstats/2018china.md.tmp2 ~/pages/WCA-Stats/endofyearstats/2018china.md.tmp
mysql --login-path=local wca_stats -e "SELECT cityName, COUNT(*) FROM competitions_extra WHERE countryId = 'China' AND YEAR(endDate) = 2018 GROUP BY cityName ORDER BY COUNT(*) DESC LIMIT 10;" > ~/mysqloutput/original && \
sed 's/\t/|/g' ~/mysqloutput/original > ~/mysqloutput/output && \
sed -i.bak '2i\
--|--\' ~/mysqloutput/output
sed -i.bak 's/^/|/' ~/mysqloutput/output
sed -i.bak 's/$/|  /' ~/mysqloutput/output
output=$(cat ~/mysqloutput/output)
awk -v r="$output" '{gsub(/iiiii/,r)}1' ~/pages/WCA-Stats/endofyearstats/2018china.md.tmp > ~/pages/WCA-Stats/endofyearstats/2018china.md.tmp2
cp ~/pages/WCA-Stats/endofyearstats/2018china.md.tmp2 ~/pages/WCA-Stats/endofyearstats/2018china.md.tmp
mysql --login-path=local wca_stats -e "SELECT countryId, COUNT(*) FROM competitions_extra WHERE countryId = 'China' AND YEAR(endDate) = 2018 GROUP BY countryId ORDER BY COUNT(*) DESC LIMIT 10;" > ~/mysqloutput/original && \
sed 's/\t/|/g' ~/mysqloutput/original > ~/mysqloutput/output && \
sed -i.bak '2i\
--|--\' ~/mysqloutput/output
sed -i.bak 's/^/|/' ~/mysqloutput/output
sed -i.bak 's/$/|  /' ~/mysqloutput/output
output=$(cat ~/mysqloutput/output)
awk -v r="$output" '{gsub(/jjjjj/,r)}1' ~/pages/WCA-Stats/endofyearstats/2018china.md.tmp > ~/pages/WCA-Stats/endofyearstats/2018china.md.tmp2
cp ~/pages/WCA-Stats/endofyearstats/2018china.md.tmp2 ~/pages/WCA-Stats/endofyearstats/2018china.md.tmp
mysql --login-path=local wca_stats -e "SELECT personId, personName, personCountryId, COUNT(*) FROM all_attempts WHERE personCountryId = 'China' AND value = -1 AND YEAR(date) = 2018 GROUP BY personId ORDER BY COUNT(*) DESC LIMIT 10;" > ~/mysqloutput/original && \
sed 's/\t/|/g' ~/mysqloutput/original > ~/mysqloutput/output && \
sed -i.bak '2i\
--|--|--|--\' ~/mysqloutput/output
sed -i.bak 's/^/|/' ~/mysqloutput/output
sed -i.bak 's/$/|  /' ~/mysqloutput/output
output=$(cat ~/mysqloutput/output)
awk -v r="$output" '{gsub(/kkkkk/,r)}1' ~/pages/WCA-Stats/endofyearstats/2018china.md.tmp > ~/pages/WCA-Stats/endofyearstats/2018china.md.tmp2
cp ~/pages/WCA-Stats/endofyearstats/2018china.md.tmp2 ~/pages/WCA-Stats/endofyearstats/2018china.md.tmp
mysql --login-path=local wca_stats -e "SELECT personId, personName, personCountryId, COUNT(*) FROM all_attempts WHERE personCountryId = 'China' AND value > 0 AND YEAR(date) = 2018 AND eventId = '333bf' GROUP BY personId ORDER BY COUNT(*) DESC LIMIT 10;" > ~/mysqloutput/original && \
sed 's/\t/|/g' ~/mysqloutput/original > ~/mysqloutput/output && \
sed -i.bak '2i\
--|--|--|--\' ~/mysqloutput/output
sed -i.bak 's/^/|/' ~/mysqloutput/output
sed -i.bak 's/$/|  /' ~/mysqloutput/output
output=$(cat ~/mysqloutput/output)
awk -v r="$output" '{gsub(/lllll/,r)}1' ~/pages/WCA-Stats/endofyearstats/2018china.md.tmp > ~/pages/WCA-Stats/endofyearstats/2018china.md.tmp2
cp ~/pages/WCA-Stats/endofyearstats/2018china.md.tmp2 ~/pages/WCA-Stats/endofyearstats/2018china.md.tmp
mysql --login-path=local wca_stats -e "SET @a = 0, @p = ''; SELECT personId, personName, personCountryId, MAX(streak) FROM (SELECT *, @a := IF(@p = personId AND value > 0, @a + 1, 1) streak, @p := personId FROM (SELECT personId, personName, personCountryId, value, id FROM all_attempts WHERE personCountryId = 'China' AND YEAR(date) = 2018 AND eventId = '333bf' ORDER BY personId, id) a ORDER BY personId, id) b GROUP BY personId ORDER BY MAX(streak) DESC LIMIT 10;" > ~/mysqloutput/original && \
sed 's/\t/|/g' ~/mysqloutput/original > ~/mysqloutput/output && \
sed -i.bak '2i\
--|--|--|--\' ~/mysqloutput/output
sed -i.bak 's/^/|/' ~/mysqloutput/output
sed -i.bak 's/$/|  /' ~/mysqloutput/output
output=$(cat ~/mysqloutput/output)
awk -v r="$output" '{gsub(/mmmmm/,r)}1' ~/pages/WCA-Stats/endofyearstats/2018china.md.tmp > ~/pages/WCA-Stats/endofyearstats/2018china.md.tmp2
cp ~/pages/WCA-Stats/endofyearstats/2018china.md.tmp2 ~/pages/WCA-Stats/endofyearstats/2018china.md.tmp
mysql --login-path=local wca_stats -e "SELECT personId, personName, personCountryId, COUNT(DISTINCT competitionId) FROM results_extra WHERE YEAR(date) = 2018 AND personCountryId = 'China' GROUP BY personId ORDER BY COUNT(DISTINCT competitionId) DESC LIMIT 10;" > ~/mysqloutput/original && \
sed 's/\t/|/g' ~/mysqloutput/original > ~/mysqloutput/output && \
sed -i.bak '2i\
--|--|--|--\' ~/mysqloutput/output
sed -i.bak 's/^/|/' ~/mysqloutput/output
sed -i.bak 's/$/|  /' ~/mysqloutput/output
output=$(cat ~/mysqloutput/output)
awk -v r="$output" '{gsub(/nnnnn/,r)}1' ~/pages/WCA-Stats/endofyearstats/2018china.md.tmp > ~/pages/WCA-Stats/endofyearstats/2018china.md.tmp2
cp ~/pages/WCA-Stats/endofyearstats/2018china.md.tmp2 ~/pages/WCA-Stats/endofyearstats/2018china.md.tmp
mysql --login-path=local wca_stats -e "SELECT pce.personId, pce.personName, pce.personCountryId, SUM(ce.WRs) FROM person_comps_extra pce JOIN competitions_extra ce ON pce.competitionId = ce.id WHERE YEAR(ce.endDate) = 2018 AND pce.personCountryId = 'China' GROUP BY pce.personId ORDER BY SUM(ce.WRs) DESC LIMIT 10;" > ~/mysqloutput/original && \
sed 's/\t/|/g' ~/mysqloutput/original > ~/mysqloutput/output && \
sed -i.bak '2i\
--|--|--|--\' ~/mysqloutput/output
sed -i.bak 's/^/|/' ~/mysqloutput/output
sed -i.bak 's/$/|  /' ~/mysqloutput/output
output=$(cat ~/mysqloutput/output)
awk -v r="$output" '{gsub(/ooooo/,r)}1' ~/pages/WCA-Stats/endofyearstats/2018china.md.tmp > ~/pages/WCA-Stats/endofyearstats/2018china.md.tmp2
cp ~/pages/WCA-Stats/endofyearstats/2018china.md.tmp2 ~/pages/WCA-Stats/endofyearstats/2018china.md.tmp
mysql --login-path=local wca_stats -e "SELECT a.id, a.name, a.countryId, b.membership \`2017\`, a.membership \`2018\` FROM persons_extra a INNER JOIN persons_extra_2017 b ON a.id = b.id WHERE a.countryId = 'China' AND a.membership <> b.membership ORDER BY FIELD(a.membership,'Platinum','Gold','Silver','Bronze','None'), FIELD(b.membership,'Platinum','Gold','Silver','Bronze','None'), a.id;" > ~/mysqloutput/original && \
sed 's/\t/|/g' ~/mysqloutput/original > ~/mysqloutput/output && \
sed -i.bak '2i\
--|--|--|--|--\' ~/mysqloutput/output
sed -i.bak 's/^/|/' ~/mysqloutput/output
sed -i.bak 's/$/|  /' ~/mysqloutput/output
output=$(cat ~/mysqloutput/output)
awk -v r="$output" '{gsub(/ppppp/,r)}1' ~/pages/WCA-Stats/endofyearstats/2018china.md.tmp > ~/pages/WCA-Stats/endofyearstats/2018china.md.tmp2
cp ~/pages/WCA-Stats/endofyearstats/2018china.md.tmp2 ~/pages/WCA-Stats/endofyearstats/2018china.md.tmp
mysql --login-path=local wca_stats -e "SELECT name, competitors FROM competitions_extra WHERE countryId = 'China' AND YEAR(endDate) = 2018 AND competitors > 0 ORDER BY competitors ASC LIMIT 10;" > ~/mysqloutput/original && \
sed 's/\t/|/g' ~/mysqloutput/original > ~/mysqloutput/output && \
sed -i.bak '2i\
--|--\' ~/mysqloutput/output
sed -i.bak 's/^/|/' ~/mysqloutput/output
sed -i.bak 's/$/|  /' ~/mysqloutput/output
output=$(cat ~/mysqloutput/output)
awk -v r="$output" '{gsub(/qqqqq/,r)}1' ~/pages/WCA-Stats/endofyearstats/2018china.md.tmp > ~/pages/WCA-Stats/endofyearstats/2018china.md.tmp2
cp ~/pages/WCA-Stats/endofyearstats/2018china.md.tmp2 ~/pages/WCA-Stats/endofyearstats/2018china.md.tmp
mysql --login-path=local wca_stats -e "SET @val = 0, @pid = ''; SELECT p.id, p.name, p.countryId, MAX(pbStreak) FROM (SELECT a.*, @val := IF(a.PBs = 0, 0, IF(a.personId = @pid, @val + 1, 1)) pbStreak, @scomp := IF(@val = 0, NULL, IF(@val = 1, competitionId, @scomp)) startComp, @ecomp := IF(@val = 0, NULL, competitionId) endComp, @pid := personId pidhelp FROM (SELECT * FROM competition_PBs WHERE competitionId LIKE '%2018' ORDER BY id ASC) a GROUP BY a.personId, a.competitionId ORDER BY a.id ASC) pbs JOIN persons_extra p ON pbs.personid = p.id WHERE p.countryId = 'China' GROUP BY p.id ORDER BY MAX(pbStreak) DESC LIMIT 10;" > ~/mysqloutput/original && \
sed 's/\t/|/g' ~/mysqloutput/original > ~/mysqloutput/output && \
sed -i.bak '2i\
--|--|--|--\' ~/mysqloutput/output
sed -i.bak 's/^/|/' ~/mysqloutput/output
sed -i.bak 's/$/|  /' ~/mysqloutput/output
output=$(cat ~/mysqloutput/output)
awk -v r="$output" '{gsub(/rrrrr/,r)}1' ~/pages/WCA-Stats/endofyearstats/2018china.md.tmp > ~/pages/WCA-Stats/endofyearstats/2018china.md.tmp2
cp ~/pages/WCA-Stats/endofyearstats/2018china.md.tmp2 ~/pages/WCA-Stats/endofyearstats/2018china.md.tmp
mysql --login-path=local wca_stats -e "SELECT p.id, p.name, p.countryId, pbs.pbs, pbs.competitionId FROM competition_pbs pbs JOIN persons_extra p ON pbs.personId = p.id WHERE p.countryId = 'China' AND competitionId IN (SELECT id FROM competitions_extra WHERE YEAR(endDate) = 2018) ORDER BY PBs DESC LIMIT 10;" > ~/mysqloutput/original && \
sed 's/\t/|/g' ~/mysqloutput/original > ~/mysqloutput/output && \
sed -i.bak '2i\
--|--|--|--|--\' ~/mysqloutput/output
sed -i.bak 's/^/|/' ~/mysqloutput/output
sed -i.bak 's/$/|  /' ~/mysqloutput/output
output=$(cat ~/mysqloutput/output)
awk -v r="$output" '{gsub(/sssss/,r)}1' ~/pages/WCA-Stats/endofyearstats/2018china.md.tmp > ~/pages/WCA-Stats/endofyearstats/2018china.md.tmp2
cp ~/pages/WCA-Stats/endofyearstats/2018china.md.tmp2 ~/pages/WCA-Stats/endofyearstats/2018china.md.tmp
mysql --login-path=local wca_stats -e "SELECT u.name, COUNT(*) FROM wca_dev.competition_delegates co JOIN wca_dev.users u ON co.delegate_id = u.id WHERE u.country_iso2 = 'CN' AND competition_id LIKE '%2018' GROUP BY co.delegate_id ORDER BY COUNT(*) DESC LIMIT 10;" > ~/mysqloutput/original && \
sed 's/\t/|/g' ~/mysqloutput/original > ~/mysqloutput/output && \
sed -i.bak '2i\
--|--\' ~/mysqloutput/output
sed -i.bak 's/^/|/' ~/mysqloutput/output
sed -i.bak 's/$/|  /' ~/mysqloutput/output
output=$(cat ~/mysqloutput/output)
awk -v r="$output" '{gsub(/ttttt/,r)}1' ~/pages/WCA-Stats/endofyearstats/2018china.md.tmp > ~/pages/WCA-Stats/endofyearstats/2018china.md.tmp2
cp ~/pages/WCA-Stats/endofyearstats/2018china.md.tmp2 ~/pages/WCA-Stats/endofyearstats/2018china.md.tmp
mysql --login-path=local wca_stats -e "SELECT p.id, p.name, p.countryId, CENTISECONDTOTIME(a.average) \`2017\`, CENTISECONDTOTIME(b.result) \`2018\`, 100*(a.average-b.result)/a.average percentImproved FROM (SELECT personId, MIN(average) average FROM results_extra WHERE personCountryId = 'China' AND average > 0 AND eventId = '333' AND YEAR(date) < 2018 GROUP BY personId) a JOIN (SELECT * FROM ranks_all WHERE eventId = '333' AND succeeded = 1 AND format = 'a') b ON a.personid = b.personId JOIN persons_extra p ON a.personId = p.id ORDER BY percentImproved DESC LIMIT 10;" > ~/mysqloutput/original && \
sed 's/\t/|/g' ~/mysqloutput/original > ~/mysqloutput/output && \
sed -i.bak '2i\
--|--\' ~/mysqloutput/output
sed -i.bak 's/^/|/' ~/mysqloutput/output
sed -i.bak 's/$/|  /' ~/mysqloutput/output
output=$(cat ~/mysqloutput/output)
awk -v r="$output" '{gsub(/uuuuu/,r)}1' ~/pages/WCA-Stats/endofyearstats/2018china.md.tmp > ~/pages/WCA-Stats/endofyearstats/2018china.md.tmp2
cp ~/pages/WCA-Stats/endofyearstats/2018china.md.tmp2 ~/pages/WCA-Stats/endofyearstats/2018china.md
rm ~/pages/WCA-Stats/endofyearstats/*.tmp*
