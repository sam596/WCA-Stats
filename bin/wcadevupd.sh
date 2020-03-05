#!/bin/bash

# link to mysql password
source ~/.mysqlpw/mysql.conf

# define the files
dbURL="https://www.worldcubeassociation.org/wst/wca-developer-database-dump.zip"
dbLocal=~/databasedownload/wca-developer-database-dump.zip
dbPath=~/databasedownload

# tell discord
~/.mysqlpw/discord-notify.sh "A forced update has been started; developer database is now being updated"

# download database
curl -sRo "${dbLocal}" "${dbURL}"

# unzip database
unzip -o "${dbLocal}" -d "${dbPath}"

# log that now importing
mysql -u sam -p"$mysqlpw" wca_stats -e "INSERT INTO wca_stats.last_updated VALUES ('wca_dev', NOW(), NULL, '') ON DUPLICATE KEY UPDATE started=NOW(), completed = NULL;"

# import database, tell discord and log finish
mysql -u sam -p"$mysqlpw" wca_dev < ~/databasedownload/wca-developer-database-dump.sql && \
~/.mysqlpw/discord-notify.sh "\`wca_dev\` has been force-updated to the latest developer export! :tada: The stats tables are **not** being updated"
mysql -u sam -p"$mysqlpw" wca_stats -e "UPDATE last_updated SET completed = NOW() WHERE query = 'wca_dev'"