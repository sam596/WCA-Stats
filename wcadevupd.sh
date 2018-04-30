#!/bin/bash

mysqlpw='SvW0iJ1QebUMjDDj'

wget -O wca-developer-database-dump.zip https://www.worldcubeassociation.org/wst/wca-developer-database-dump.zip
unzip -o wca-developer-database-dump.zip
mysql -u sam -p"$mysqlpw" wca_stats -e "INSERT INTO wca_stats.last_updated VALUES ('wca_dev', NOW(), NULL, '') ON DUPLICATE KEY UPDATE started=NOW(), completed = NULL;"
mysql -u sam -p"$mysqlpw" wca_dev < wca-developer-database-dump.sql
mysql -u sam -p"$mysqlpw" wca_stats -e "UPDATE last_updated SET completed = NOW() WHERE query = 'wca_dev'"
mysql -u sam -p"$mysqlpw" wca_stats < SQL/result_dates.sql
mysql -u sam -p"$mysqlpw" wca_stats < SQL/all_single_results.sql
mysql -u sam -p"$mysqlpw" wca_stats < SQL/SoR_Average.sql
mysql -u sam -p"$mysqlpw" wca_stats < SQL/SoR_Single.sql
mysql -u sam -p"$mysqlpw" wca_stats < SQL/world_ranks_all.sql
mysql -u sam -p"$mysqlpw" wca_stats < SQL/SoR_Combined.sql
mysql -u sam -p"$mysqlpw" wca_stats < SQL/persons_extra.sql
mysql -u sam -p"$mysqlpw" wca_stats < SQL/records.sql
mysql -u sam -p"$mysqlpw" wca_stats < SQL/concise_results.sql
mysql -u sam -p"$mysqlpw" wca_stats < SQL/PBs.sql
mysql -u sam -p"$mysqlpw" wca_stats < SQL/PB_Streak.sql