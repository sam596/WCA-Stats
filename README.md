# WCA Database SQL Dump

A repo full of SQL queries to run to supplement the official World Cube Association database available at https://www.worldcubeassociation.org/results/misc/export.html

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

### Table Definitions

|Table|Details|
|--|--|
|`result_dates`|A near-clone of the original WCA `results` table, but with added fields for `weekend` (the period of time beginning on the Thursday before on which the competition takes place) and `date` (the date on which the **competition ended** - not necessarily the correct date)|
|`all_single_results`|Every single result ever completed has its own entry in this table|
|`kinch_ranks_by_event` and `kinch`|Calculates the kinch score for each event for each person, and the `kinch` table averages these for each person and ranks them|
|`world_ranks_single`, `world_ranks_average` and `world_ranks_all`|Creates near-clones of the WCA's `ranksaverage` and `rankssingle` tables, but with fields for the competition, round and date which the PB was set at. These also have a `competed` field which is set to 0 if the competitor hasn't competed in the event, if this is indeed 0, the `worldrank` is set to `N + 1`, where `N` is the number of competitors who have succeeded in the event|
|`sor_single`,`sor_average` and `sor_combined`|Creates Sum of Ranks tables, and ranks competitors by their sum|
|`persons_extra`|Creates a clone of the WCA's `persons` table, with many other statistics about each person. These include: `competitions` (competed at), `eventsAttempted`, `eventsSucceeded`, `eventsAverage`, `finals`, `podiums`, `gold`, `silver`, `bronze`, `eventsPodiumed`, `eventsWon`, `wcPodium`, `wChampion`, `records`, `WRs`, `CRs`, `NRs`, `countries` (competed in), `continents` (competed in), `multipleCountryComps` (i.e. FMC Europe), `distinctMultipleCountryComps` (number of competitions matching previous criteria), `completedSolves`, `DNFs`, `sorAverage`, `sorAverageRank`, `sorSingle`, `sorSingleRank`, `sorCombined`, `sorCombinedRank`, `minWorldRank` and `membership` (as explained [here](https://www.speedsolving.com/forum/threads/all-wca-events-completion-club.39896/)). Massive credit to Oliver Wheat who wrote the original sql file for this, which I have adapted since.|
|`records`|All the results from `result_dates` where a record was set.|
|`concise_results` and `pbs`, `competition_pbs`|Calculates whether or not a result was a PB. `concise_results` then lists all results, with a `PB` boolean field. `pbs` contains only the results from `concise_results` that are PBs. `conmpetition_pbs` counts the number of PBs set by a competitor at every competition.|
|`pb_streak`|Calculates streaks of competitions with a PB set. *This query takes a substantial amount of time, so is not included in `wcadevupd.sh`*|