#!/bin/bash

mysqlpw='SvW0iJ1QebUMjDDj'

mysql -u sam -p"$mysqlpw" wca_stats < ~/SQL/queries/result_dates.sql
mysql -u sam -p"$mysqlpw" wca_stats < ~/SQL/queries/all_single_results.sql
mysql -u sam -p"$mysqlpw" wca_stats < ~/SQL/queries/SoR_Average.sql
mysql -u sam -p"$mysqlpw" wca_stats < ~/SQL/queries/SoR_Single.sql
mysql -u sam -p"$mysqlpw" wca_stats < ~/SQL/queries/world_ranks_all.sql
mysql -u sam -p"$mysqlpw" wca_stats < ~/SQL/queries/SoR_Combined.sql
mysql -u sam -p"$mysqlpw" wca_stats < ~/SQL/queries/persons_extra.sql
mysql -u sam -p"$mysqlpw" wca_stats < ~/SQL/queries/records.sql
mysql -u sam -p"$mysqlpw" wca_stats < ~/SQL/queries/concise_results.sql
mysql -u sam -p"$mysqlpw" wca_stats < ~/SQL/queries/PBs.sql
mysql -u sam -p"$mysqlpw" wca_stats < ~/SQL/queries/PB_Streak.sql