#!/bin/bash

source ~/.mysqlpw/mysql.conf

dbURL="https://www.worldcubeassociation.org/results/misc/WCA_export.sql.zip"
dbLocal=~/databasedownload/WCA_export.sql.zip
dbPath=~/databasedownload

curl -H "Content-Type: application/json" -X POST -d '{"username": "WCA-Stats", "content": "The latest **public** WCA export is now being imported to `wca`"}' $discordwh
  
curl -sRo "${dbLocal}" "${dbURL}"
  
unzip -o "${dbLocal}" -d "${dbPath}" -x "README.txt"

mysql -u sam -p"$mysqlpw" wca_stats -e "INSERT INTO wca_stats.last_updated VALUES ('wca', NOW(), NULL, '') ON DUPLICATE KEY UPDATE started=NOW(), completed = NULL;"

mysql -u sam -p"$mysqlpw" wca < ~/databasedownload/WCA_export.sql && \
curl -H "Content-Type: application/json" -X POST -d '{"username": "WCA-Stats", "content": "`wca` has been updated to the latest public export! :tada:"}' $discordwh && \
mysql -u sam -p"$mysqlpw" wca_stats -e "UPDATE last_updated SET completed = NOW() WHERE query = 'wca'"
