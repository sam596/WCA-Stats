#!/bin/bash

# Link to mysql password
source ~/.mysqlpw/mysql.conf

# Log that this script has started
mysql -u sam -p"$mysqlpw" wca_stats -e "INSERT INTO wca_stats.last_updated VALUES ('wcadevstsupd.sh', NOW(), NULL, '') ON DUPLICATE KEY UPDATE started=NOW(), completed = NULL;"

# Define the files
dbURL="https://www.worldcubeassociation.org/wst/wca-developer-database-dump.zip"
dbLocal=~/databasedownload/wca-developer-database-dump.zip
dbPath=~/databasedownload

# Get local and remote timestamps
URLStamp=$(date --date="$(curl -s -I "${dbURL}" | awk '/Last-Modified/ {$1=""; print $0}')" +%s)
localStamp=$(stat -c %Y "$dbLocal")

# Compare the timestamps
if [ ${localStamp} -lt ${URLStamp} ];
then
  mysql -u sam -p"$mysqlpw" wca_stats -e "UPDATE last_updated SET notes = 'Change noticed; developer database and wca_stats now being updated --- (${URLStamp} vs ${localStamp})' WHERE query = 'wcadevstsupd.sh'"
  
  curl -H "Content-Type: application/json" -X POST -d '{"username": "WCA-Stats", "content": "Newer database available; developer database is now being updated"}' $discordwh
  
  curl -sRo "${dbLocal}" "${dbURL}"
  
  unzip -o "${dbLocal}" -d "${dbPath}"
  
  mysql -u sam -p"$mysqlpw" wca_stats -e "INSERT INTO wca_stats.last_updated VALUES ('wca_dev', NOW(), NULL, '') ON DUPLICATE KEY UPDATE started=NOW(), completed = NULL;"
  
  mysql -u sam -p"$mysqlpw" wca_dev < ~/databasedownload/wca-developer-database-dump.sql && \
  curl -H "Content-Type: application/json" -X POST -d '{"username": "WCA-Stats", "content": "`wca_dev` has been updated to the latest developer export! :tada: The tables in `wca_stats` are now being updated."}' $discordwh && \
  mysql -u sam -p"$mysqlpw" wca_stats -e "UPDATE last_updated SET completed = NOW() WHERE query = 'wca_dev'"
  
  mysql -u sam -p"$mysqlpw" wca_stats < ~/WCA-Stats/tables/results_extra.sql && \
  curl -H "Content-Type: application/json" -X POST -d '{"username": "WCA-Stats", "content": "`results_extra` and `wfc_dues` have been updated! :tada: \n <@118059908628348935> <3"}' $discordwh
  
  mysql -u sam -p"$mysqlpw" wca_stats < ~/WCA-Stats/tables/all_attempts.sql && \
  curl -H "Content-Type: application/json" -X POST -d '{"username": "WCA-Stats", "content": "`all_attempts` has been updated! :tada:"}' $discordwh

  mysql -u sam -p"$mysqlpw" wca_stats < ~/WCA-Stats/tables/sum_of_ranks.sql && \
  curl -H "Content-Type: application/json" -X POST -d '{"username": "WCA-Stats", "content": "All the `ranks` and `sor` tables have been updated! :tada:"}' $discordwh

  mysql -u sam -p"$mysqlpw" wca_stats < ~/WCA-Stats/tables/kinch.sql && \
  curl -H "Content-Type: application/json" -X POST -d '{"username": "WCA-Stats", "content": "The `world`,`continent` and `country_kinch` tables have all been updated! :tada:"}' $discordwh
  
  mysql -u sam -p"$mysqlpw" wca_stats < ~/WCA-Stats/tables/uowc.sql && \
  curl -H "Content-Type: application/json" -X POST -d '{"username": "WCA-Stats", "content": "The `UOWC` table has been updated! :tada:"}' $discordwh

  mysql -u sam -p"$mysqlpw" wca_stats < ~/WCA-Stats/tables/records.sql && \
  curl -H "Content-Type: application/json" -X POST -d '{"username": "WCA-Stats", "content": "`records` has been updated! :tada:"}' $discordwh
  
  mysql -u sam -p"$mysqlpw" wca_stats < ~/WCA-Stats/tables/championship_podium.sql && \
  curl -H "Content-Type: application/json" -X POST -d '{"username": "WCA-Stats", "content": "`championship_podiums` has been updated! :tada:"}' $discordwh
  
  mysql -u sam -p"$mysqlpw" wca_stats < ~/WCA-Stats/tables/concise_results.sql && \
  mysql -u sam -p"$mysqlpw" wca_stats < ~/WCA-Stats/tables/pbs.sql && \
  mysql -u sam -p"$mysqlpw" wca_stats < ~/WCA-Stats/tables/pb_streak.sql && \
  curl -H "Content-Type: application/json" -X POST -d '{"username": "WCA-Stats", "content": "The `concise_results`, `PBs` and `PB_Streak` tables have been updated! :tada:"}' $discordwh
  
  mysql -u sam -p"$mysqlpw" wca_stats < ~/WCA-Stats/tables/mbld_decoded.sql && \
  curl -H "Content-Type: application/json" -X POST -d '{"username": "WCA-Stats", "content": "`mbld_decoded` has been updated! :tada:"}' $discordwh
  
  mysql -u sam -p"$mysqlpw" wca_stats < ~/WCA-Stats/tables/relays.sql && \
  curl -H "Content-Type: application/json" -X POST -d '{"username": "WCA-Stats", "content": "The relay tables have been updated! :tada:"}' $discordwh

  mysql -u sam -p"$mysqlpw" wca_stats < ~/WCA-Stats/tables/registrations_extra.sql && \
  mysql -u sam -p"$mysqlpw" wca_stats < ~/WCA-Stats/tables/person_comps_extra.sql && \
  mysql -u sam -p"$mysqlpw" wca_stats < ~/WCA-Stats/tables/persons_extra.sql && \
  mysql -u sam -p"$mysqlpw" wca_stats < ~/WCA-Stats/tables/competitions_extra.sql && \
  curl -H "Content-Type: application/json" -X POST -d '{"username": "WCA-Stats", "content": "`registrations_extra`, `person_comps_extra`, `persons_extra` and `competitions_extra` have been updated! :tada:"}' $discordwh
  
  mysql -u sam -p"$mysqlpw" wca_stats < ~/WCA-Stats/tables/seasons.sql && \
  mysql -u sam -p"$mysqlpw" wca_stats < ~/WCA-Stats/tables/current_averages.sql && \
  curl -H "Content-Type: application/json" -X POST -d '{"username": "WCA-Stats", "content": "The `seasons` and `current_averages` tables been updated! :tada:"}' $discordwh

  mysql -u sam -p"$mysqlpw" wca_stats < ~/WCA-Stats/tables/world_rank_history.sql && \
  curl -H "Content-Type: application/json" -X POST -d '{"username": "WCA-Stats", "content": "The last 5 weeks of `world_rank_history` have been recalculated! :tada:"}' $discordwh

  mysql -u sam -p"$mysqlpw" wca_stats -e "UPDATE last_updated SET completed = NOW(), notes = 'Change noticed; developer database imported, wca_stats updated --- (${ldu1} vs ${ldu2})' WHERE query = 'wcadevstsupd.sh'" 
  
  ~/WCA-Stats/bin/ghpagesupd.sh

  cd ~/pages/WCA-Stats/
  
  commit=$(git log --format="%H" -n 1)

  curl -H "Content-Type: application/json" -X POST -d '{"username": "WCA-Stats", "content": "http://sam596.github.io Updated with latest stats. \n View the changes here: https://github.com/sam596/WCA-Stats/commit/'"$commit"'. \n \n That concludes the tri-daily spam of messages thanks to the WCA updating their developer database! :smiley: See you in three days :wink:"}' $discordwh

 else
  mysql -u sam -p"$mysqlpw" wca_stats -e "UPDATE last_updated SET completed = NOW(), notes = 'no change noticed; no import made --- (${URLStamp} vs ${localStamp})' WHERE query = 'wcadevstsupd.sh'"
fi
