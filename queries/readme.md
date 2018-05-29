### Table Definitions

|Table|Details|
|--|--|
|`PB_time`|Outputs a `.csv` file with the `result` and `worldRank` of the specified `personId`, `eventId` and `format` on each weekend since the first time a result was achieved. This can be used to find someone's best worldRank in an event or to create a graph of worldRank over time.|
|`monthsstreak`|Creates a table counting the number of consecutive months a competitor has competed in. Also, as some of the tables used to create this table may be useful, I haven't dropped these at the end of the query. These include `months3` which has a list of all the months someone competed in and a running streak value `streakystreak`, and `personcompdate` which gives lots of data about the different days that a person has competed on, (e.g. the day of week, day of month etc.)|
