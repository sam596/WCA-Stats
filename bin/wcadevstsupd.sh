#!/bin/bash

# Link to mysql password
source ~/mysqlpw/mysql.conf

# Log that this script has started
mysql -u sam -p"$mysqlpw" wca_stats -e "INSERT INTO wca_stats.last_updated VALUES ('wcadevstsupd.sh', NOW(), NULL, '') ON DUPLICATE KEY UPDATE started=NOW(), completed = NULL;"
curl -H "Content-Type: application/json" -X POST -d '{"username": "WCA-Stats", "content": "Developer database script now running"}' $discordwh

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
  
  curl -H "Content-Type: application/json" -X POST -d '{"username": "WCA-Stats", "content": "Newer database available; developer database is now being updated --- (${URLStamp} vs ${localStamp})"}' $discordwh
  
  curl -sRo "${dbLocal}" "${dbURL}"
  
  unzip -o "${dbLocal}" -d "${dbPath}"
  
  mysql -u sam -p"$mysqlpw" wca_stats -e "INSERT INTO wca_stats.last_updated VALUES ('wca_dev', NOW(), NULL, '') ON DUPLICATE KEY UPDATE started=NOW(), completed = NULL;"
  
  mysql -u sam -p"$mysqlpw" wca_dev < ~/databasedownload/wca-developer-database-dump.sql && \
  curl -H "Content-Type: application/json" -X POST -d '{"username": "WCA-Stats", "content": "`wca_dev` has been updated to the latest developer export! :tada: The tables in `wca_stats` are now being updated."}' $discordwh && \
  mysql -u sam -p"$mysqlpw" wca_stats -e "UPDATE last_updated SET completed = NOW() WHERE query = 'wca_dev'"
  
  mysql -u sam -p"$mysqlpw" wca_stats < ~/WCA-Stats/tables/result_dates.sql && \
  curl -H "Content-Type: application/json" -X POST -d '{"username": "WCA-Stats", "content": "`result_dates` has been updated! :tada:"}' $discordwh
  
  mysql -u sam -p"$mysqlpw" wca_stats < ~/WCA-Stats/tables/all_single_results.sql && \
  curl -H "Content-Type: application/json" -X POST -d '{"username": "WCA-Stats", "content": "`all_single_results` has been updated! :tada:"}' $discordwh
  
  mysql -u sam -p"$mysqlpw" wca_stats < ~/WCA-Stats/tables/kinch.sql && \
  curl -H "Content-Type: application/json" -X POST -d '{"username": "WCA-Stats", "content": "The `world`,`continent` and `country_kinch` tables have all been updated! :tada:"}' $discordwh
  
  mysql -u sam -p"$mysqlpw" wca_stats < ~/WCA-Stats/tables/sor_average.sql && \
  mysql -u sam -p"$mysqlpw" wca_stats < ~/WCA-Stats/tables/sor_single.sql && \
  mysql -u sam -p"$mysqlpw" wca_stats < ~/WCA-Stats/tables/sor_combined.sql && \
  curl -H "Content-Type: application/json" -X POST -d '{"username": "WCA-Stats", "content": "All the `sor` and `world_ranks` tables have been updated! :tada:"}' $discordwh
  
  mysql -u sam -p"$mysqlpw" wca_stats < ~/WCA-Stats/tables/records.sql && \
  curl -H "Content-Type: application/json" -X POST -d '{"username": "WCA-Stats", "content": "all the `sor` and `world_ranks` tables have been updated! :tada:"}' $discordwh
  
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
  
  mysql -u sam -p"$mysqlpw" wca_stats < ~/WCA-Stats/tables/persons_extra.sql && \
  curl -H "Content-Type: application/json" -X POST -d '{"username": "WCA-Stats", "content": "`persons_extra` has been updated! :tada:"}' $discordwh
  
  mysql -u sam -p"$mysqlpw" wca_stats -e "UPDATE last_updated SET completed = NOW(), notes = 'Change noticed; developer database imported, wca_stats updated --- (${ldu1} vs ${ldu2})' WHERE query = 'wcadevstsupd.sh'" 
  curl -H "Content-Type: application/json" -X POST -d '{"username": "WCA-Stats", "content": "This concludes the tri-daily spam of messages thanks to the WCA updating their developer database! :smiley: See you in three days :wink:' $discordwh
else
  mysql -u sam -p"$mysqlpw" wca_stats -e "UPDATE last_updated SET completed = NOW(), notes = 'no change noticed; no import made --- (${URLStamp} vs ${localStamp})' WHERE query = 'wcadevstsupd.sh'"
  curl -H "Content-Type: application/json" -X POST -d '{"username": "WCA-Stats", "content": "Developer database is already up-to-date!"}' $discordwh
fi
