#!/bin/bash

source ~/mysqlpw/mysql.conf

mysql -u sam -p"$mysqlpw" wca_stats < ~/WCA-Stats/tables/PB_Streak.sql
