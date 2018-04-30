#!/bin/bash

source ~/mysqlpw/mysql.conf

wget -O ~/databasedownload/WCA_export.sql.zip https://www.worldcubeassociation.org/results/misc/WCA_export.sql.zip
unzip -o ~/databasedownload/WCA_export.sql.zip -d ~/databasedownload
mysql -u sam -p"$mysqlpw" wca_stats -e "INSERT INTO wca_stats.last_updated VALUES ('wca', NOW(), NULL, '') ON DUPLICATE KEY UPDATE started=NOW(), completed = NULL;"
mysql -u sam -p"$mysqlpw" wca < ~/databasedownload/WCA_export.sql
mysql -u sam -p"$mysqlpw" wca_stats -e "UPDATE last_updated SET completed = NOW() WHERE query = 'wca'"