The SQL files required to update these stats.

|Table|SQL|Notes|
|--|--|--|
|`monthstreaks.md`|`SELECT CONCAT("[",name,"](https://www.worldcubeassociation.org/persons/",personId,")") Name, countryId Country, months MonthStreak FROM monthsbyperson ORDER BY months DESC LIMIT 100;`|Requires `/queries/monthstreaks.sql` (takes 3-4 hours)|
