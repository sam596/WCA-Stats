# WCA Database SQL Dump

A repo full of SQL queries to run to supplement the official World Cube Association database available at https://www.worldcubeassociation.org/results/misc/export.html

### Outputs

Some stats have been output to a markdown file in [`/docs`](https://github.com/sam596/SQL/tree/master/docs) for easy access to quick statistics, and some which I have contributed to the [WCA Statistics Facebook Group](https://www.facebook.com/groups/439995439706174/). These are also available via [GitHub Pages here](http://sam596.github.io/WCA-Stats). 

These are most likely out of date, you can message me whereever and I will update whichever table to the current developer export.

### Prerequisites

To run these, have an SQL server with databases named `wca`, `wca_dev` and `wca_stats`. Also in the `wca_stats` database, have a table named `last_updated` with three columns named `query` (varchar20), `started`, `completed` (both DATETIME) and a `notes` field for any details. To do these, you can run the following queries:
```sql
CREATE DATABASE wca;
CREATE DATABASE wca_dev;
CREATE DATABASE wca_stats;
CREATE TABLE `wca_stats`.`last_updated` (
  `query` varchar(20) NOT NULL,
  `started` datetime DEFAULT NULL,
  `completed` datetime DEFAULT NULL,
  `notes` TEXT DEFAULT NULL,
  PRIMARY KEY (query));
```

The `last_updated` table will show you the last time the two databases were last updated in addition to the SQL queries, as these have statements to update this table in addition to their primary purpose.

There are `.sh` files in `/bin` which automatically do the following:

`bin/wcadevstsupd.sh` will pull the latest developer export from the WCA if the one available online is newer than the local version, and run the queries in the `tables/` directory, which will import into the `wca_stats` database.

`bin/wcadevupd.sh` will import the latest developer export, even if there isn't a newer version available. This won't run any additional queries.

`bin/wcaupd.sh` will pull the latest public export from the WCA into the `wca` table. This won't run any additional queries.

**NB:** to run these, you will have to edit them yourself as I will have a different username and password to your mysql server. For reference, my username is `sam` and my password is stored in a file in `~/mysqlpw/mysql.conf`. Its contents is a singular line such as this: `mysqlpw='mypassword'`; just replace `mypassword` for your own.
Also, I have a line in my `~/mysqlpw/mysql.conf` file called `discordwh=<link>`. Through this, a bot posts in my personal discord server to let me know when tables and databases have been updated, through the abundance of lines in the `.sh` scripts in `bin/`
