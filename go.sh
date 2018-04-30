#!/bin/bash
mysqlpw='SvW0iJ1QebUMjDDj'
mysql -u sam -p"$mysqlpw" wca_stats < concise_results.sql
mysql -u sam -p"$mysqlpw" wca_stats < PBs.sql
mysql -u sam -p"$mysqlpw" wca_stats < PB_Streak.sql


