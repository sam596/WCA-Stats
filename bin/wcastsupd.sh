#!/bin/bash

source ~/mysqlpw/mysql.conf

mysql -u sam -p"$mysqlpw" wca_stats < ~/SQL/tables/PB_Streak.sql