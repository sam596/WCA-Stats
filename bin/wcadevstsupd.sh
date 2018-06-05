#!/bin/bash

source ~/mysqlpw/mysql.conf

wget -O ~/databasedownload/wca-developer-database-dump.zip https://www.worldcubeassociation.org/wst/wca-developer-database-dump.zip
unzip -o ~/databasedownload/wca-developer-database-dump.zip -d ~/databasedownload
mysql -u sam -p"$mysqlpw" wca_stats -e "INSERT INTO wca_stats.last_updated VALUES ('wca_dev', NOW(), NULL, '') ON DUPLICATE KEY UPDATE started=NOW(), completed = NULL;"
mysql -u sam -p"$mysqlpw" wca_dev < ~/databasedownload/wca-developer-database-dump.sql
mysql -u sam -p"$mysqlpw" wca_stats -e "UPDATE last_updated SET completed = NOW() WHERE query = 'wca_dev'"
mysql -u sam -p"$mysqlpw" wca_stats < ~/WCA-Stats/tables/result_dates.sql
mysql -u sam -p"$mysqlpw" wca_stats < ~/WCA-Stats/tables/all_single_results.sql
mysql -u sam -p"$mysqlpw" wca_stats < ~/WCA-Stats/tables/kinch.sql
mysql -u sam -p"$mysqlpw" wca_stats < ~/WCA-Stats/tables/SoR_Average.sql
mysql -u sam -p"$mysqlpw" wca_stats < ~/WCA-Stats/tables/SoR_Single.sql
mysql -u sam -p"$mysqlpw" wca_stats < ~/WCA-Stats/tables/world_ranks_all.sql
mysql -u sam -p"$mysqlpw" wca_stats < ~/WCA-Stats/tables/SoR_Combined.sql
mysql -u sam -p"$mysqlpw" wca_stats < ~/WCA-Stats/tables/persons_extra.sql
mysql -u sam -p"$mysqlpw" wca_stats < ~/WCA-Stats/tables/records.sql
mysql -u sam -p"$mysqlpw" wca_stats < ~/WCA-Stats/tables/concise_results.sql
mysql -u sam -p"$mysqlpw" wca_stats < ~/WCA-Stats/tables/PBs.sql
mysql -u sam -p"$mysqlpw" wca_stats < ~/WCA-Stats/tables/PB_Streak.sql
mysql -u sam -p"$mysqlpw" wca_stats < ~/WCA-Stats/tables/mbld_decoded.sql
mysql -u sam -p"$mysqlpw" wca_stats < ~/WCA-Stats/tables/relays.sql