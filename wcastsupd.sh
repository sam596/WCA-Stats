#!/bin/bash

mysqlpw='SvW0iJ1QebUMjDDj'

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