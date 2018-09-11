#!/bin/bash

# Link to mysql password
source ~/.mysqlpw/mysql.conf

# Log that this script has started
mysql -u sam -p"$mysqlpw" wca_stats -e "INSERT INTO wca_stats.last_updated VALUES ('wcadevstsupd.sh', NOW(), NULL, '') ON DUPLICATE KEY UPDATE started=NOW(), completed = NULL;"

# Define the files
dbURL="https://www.worldcubeassociation.org/wst/wca-developer-database-dump.zip"
dbLocal=~/databasedownload/wca-developer-database-dump.zip
dbPath=~/databasedownload

# Import DB and Run Stats
mysql -u sam -p"$mysqlpw" wca_stats -e "UPDATE last_updated SET notes = 'Script forced to run; developer database and wca_stats now being updated' WHERE query = 'wcadevstsupd.sh'"
curl -H "Content-Type: application/json" -X POST -d '{"username": "WCA-Stats", "content": "A forced update has been started; developer database is now being updated"}' $discordwh
  
  curl -sRo "${dbLocal}" "${dbURL}"
  
  unzip -o "${dbLocal}" -d "${dbPath}"
  
  mysql -u sam -p"$mysqlpw" wca_stats -e "INSERT INTO wca_stats.last_updated VALUES ('wca_dev', NOW(), NULL, '') ON DUPLICATE KEY UPDATE started=NOW(), completed = NULL;"
  
  mysql -u sam -p"$mysqlpw" wca_dev < ~/databasedownload/wca-developer-database-dump.sql && \
  curl -H "Content-Type: application/json" -X POST -d '{"username": "WCA-Stats", "content": "`wca_dev` has been force-updated to the latest developer export! :tada: The tables in `wca_stats` are now being updated."}' $discordwh && \
  mysql -u sam -p"$mysqlpw" wca_stats -e "UPDATE last_updated SET completed = NOW() WHERE query = 'wca_dev'"
  
  mysql -u sam -p"$mysqlpw" wca_stats < ~/WCA-Stats/tables/results_extra.sql && \
  curl -H "Content-Type: application/json" -X POST -d '{"username": "WCA-Stats", "content": "`results_extra` has been updated! :tada:"}' $discordwh
  
  mysql -u sam -p"$mysqlpw" wca_stats < ~/WCA-Stats/tables/all_attempts.sql && \
  curl -H "Content-Type: application/json" -X POST -d '{"username": "WCA-Stats", "content": "`all_attempts` has been updated! :tada:"}' $discordwh

  mysql -u sam -p"$mysqlpw" wca_stats < ~/WCA-Stats/tables/sum_of_ranks.sql && \
  curl -H "Content-Type: application/json" -X POST -d '{"username": "WCA-Stats", "content": "All the `sor` and `world_ranks` tables have been updated! :tada:"}' $discordwh
  
  mysql -u sam -p"$mysqlpw" wca_stats < ~/WCA-Stats/tables/kinch.sql && \
  curl -H "Content-Type: application/json" -X POST -d '{"username": "WCA-Stats", "content": "The `world`,`continent` and `country_kinch` tables have all been updated! :tada:"}' $discordwh

  mysql -u sam -p"$mysqlpw" wca_stats < ~/WCA-Stats/tables/uowc.sql && \
  curl -H "Content-Type: application/json" -X POST -d '{"username": "WCA-Stats", "content": "The UWOC table has been updated! :tada:"}' $discordwh

  mysql -u sam -p"$mysqlpw" wca_stats < ~/WCA-Stats/tables/records.sql && \
  curl -H "Content-Type: application/json" -X POST -d '{"username": "WCA-Stats", "content": "The `records` table has been updated! :tada:"}' $discordwh
  
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
  mysql -u sam -p"$mysqlpw" wca_stats < ~/WCA-Stats/tables/persons_extra.sql && \
  mysql -u sam -p"$mysqlpw" wca_stats < ~/WCA-Stats/tables/competitions_extra.sql && \
  curl -H "Content-Type: application/json" -X POST -d '{"username": "WCA-Stats", "content": "`registrations_extra`, `persons_extra` and `competitions_extra` have been updated! :tada:"}' $discordwh
  
  mysql -u sam -p"$mysqlpw" wca_stats -e "UPDATE last_updated SET completed = NOW(), notes = 'Force-updated; developer database imported, wca_stats updated' WHERE query = 'wcadevstsupd.sh'" 
  curl -H "Content-Type: application/json" -X POST -d '{"username": "WCA-Stats", "content": "Force Update of `wca_dev` and `wca_stats` complete!"}' $discordwh
