#!/bin/bash

source ~/.mysqlpw/mysql.conf

dbURL="https://www.worldcubeassociation.org/wst/wca-developer-database-dump.zip"
dbLocal=~/databasedownload/wca-developer-database-dump.zip
dbPath=~/databasedownload

curl -H "Content-Type: application/json" -X POST -d '{"username": "WCA-Stats", "content": "A forced update has been started; developer database is now being updated"}' $discordwh
  
curl -sRo "${dbLocal}" "${dbURL}"
  
unzip -o "${dbLocal}" -d "${dbPath}"
  
mysql -u sam -p"$mysqlpw" wca_stats -e "INSERT INTO wca_stats.last_updated VALUES ('wca_dev', NOW(), NULL, '') ON DUPLICATE KEY UPDATE started=NOW(), completed = NULL;"
  
mysql -u sam -p"$mysqlpw" wca_dev < ~/databasedownload/wca-developer-database-dump.sql && \
curl -H "Content-Type: application/json" -X POST -d '{"username": "WCA-Stats", "content": "`wca_dev` has been force-updated to the latest developer export! :tada: The stats tables are **not** being updated"}' $discordwh && \
mysql -u sam -p"$mysqlpw" wca_stats -e "UPDATE last_updated SET completed = NOW() WHERE query = 'wca_dev'"
