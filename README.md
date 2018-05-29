# WCA Database SQL Dump

A repo full of SQL queries to run to supplement the official World Cube Association database available at https://www.worldcubeassociation.org/results/misc/export.html

### Outputs

Some stats have been output to a markdown file in [`/queries/outputs`](https://github.com/sam596/SQL/tree/master/queries/outputs) for easy access to quick statistics, and some which I have contributed to the [WCA Statistics Facebook Group](https://www.facebook.com/groups/439995439706174/). These are most likely out of date, you can message me whereever and I will update whichever table to the current developer export.

### Prerequisites

To run these, have an SQL server with databases named `wca`, `wca_dev` and `wca_stats`. Also in the `wca_stats` database, have a table named `last_updated` with three columns named `query` (varchar20), `started` and `completed` (both DATETIME). To do these, you can run the following queries:
```sql
CREATE DATABASE wca;
CREATE DATABASE wca_dev;
CREATE DATABASE wca_stats;
CREATE TABLE `wca_stats`.`last_updated` (
  `query` varchar(20) NOT NULL,
  `started` datetime DEFAULT NULL,
  `completed` datetime DEFAULT NULL);
```

The `last_updated` table will show you the last time the two databases were last updated in addition to the SQL queries, as these have statements to update this table in addition to their primary purpose.

There are `.sh` files in `/bin` which automatically do the following:

`bin/wcadevupd.sh` will pull the latest developer export from the WCA, and run (most of) the stats in the `tables/` directory, which will import into the `wca_stats` database.

`bin/wcaupd.sh` will pull the latest public export from the WCA into the `wca` table.

`bin/wcastsupd.sh` will only run the .sql files that I have deemed to run too long to automatically update periodically.

**NB:** to run these, you will have to edit them yourself as you will have a different username and password to your mysql server. For reference, my username is `sam` and my password is stored in a file in `~/mysqlpw/mysql.conf`. Its contents is a singular line such as this: `mysqlpw='mypassword'`; just replace `mypassword` for your own.
