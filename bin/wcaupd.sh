#!/bin/bash

# link to mysql password
source ~/.mysqlpw/mysql.conf

# define files
dbURL="https://www.worldcubeassociation.org/results/misc/WCA_export.sql.zip"
dbLocal=~/databasedownload/WCA_export.sql.zip
dbPath=~/databasedownload

# tell discord
~/.mysqlpw/discord-notify.sh "The latest **public** WCA export is now being imported to \`wca\`"

# download database
curl -sRo "${dbLocal}" "${dbURL}"

# unzip database
unzip -o "${dbLocal}" -d "${dbPath}" -x "README.txt"

# log starting
mysql -u sam -p"$mysqlpw" wca_stats -e "INSERT INTO wca_stats.last_updated VALUES ('wca', NOW(), NULL, '') ON DUPLICATE KEY UPDATE started=NOW(), completed = NULL;"

# import, tell discord and log finish
mysql -u sam -p"$mysqlpw" wca < ~/databasedownload/WCA_export.sql && \
~/.mysqlpw/discord-notify.sh "\`wca\` has been updated to the latest public export! :tada:" && \
mysql -u sam -p"$mysqlpw" wca_stats -e "UPDATE last_updated SET completed = NOW() WHERE query = 'wca'"
