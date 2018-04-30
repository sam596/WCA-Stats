#!/bin/bash

source ~/mysqlpw/mysql.conf

mysql -u sam -p"$mysqlpw" wca_stats < ~/sql/tables/result_dates.sql
mysql -u sam -p"$mysqlpw" wca_stats < ~/sql/tables/all_single_results.sql
mysql -u sam -p"$mysqlpw" wca_stats < ~/sql/tables/SoR_Average.sql
mysql -u sam -p"$mysqlpw" wca_stats < ~/sql/tables/SoR_Single.sql
mysql -u sam -p"$mysqlpw" wca_stats < ~/sql/tables/world_ranks_all.sql
mysql -u sam -p"$mysqlpw" wca_stats < ~/sql/tables/SoR_Combined.sql
mysql -u sam -p"$mysqlpw" wca_stats < ~/sql/tables/persons_extra.sql
mysql -u sam -p"$mysqlpw" wca_stats < ~/sql/tables/records.sql
mysql -u sam -p"$mysqlpw" wca_stats < ~/sql/tables/concise_results.sql
mysql -u sam -p"$mysqlpw" wca_stats < ~/sql/tables/PBs.sql
mysql -u sam -p"$mysqlpw" wca_stats < ~/sql/tables/PB_Streak.sql