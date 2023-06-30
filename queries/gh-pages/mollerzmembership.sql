##title {tier} Mollerz Memberships
##desc <div style="width: 35%; margin: 0 auto; padding: 20px; background-color: #FFFFFF; border: 2px solid #CCCCCC; position: relative;"><h3 style="font-weight: bold; text-align: center; margin-top: 0;">Description</h3><div style="text-align: center;">An alternative view of a "Membership" system for the WCA, as devised by <a href="https://www.worldcubeassociation.org/persons/2011MOLL01">James Molloy</a><br><h4>How it works:</h4><b>Bronze</b>: A result in every event. <i>(Because this is an all-rounder thing)</i><br><br>Then you get a ranking stage each time you complete any one of the following:<br><ul style="list-style-type: disc; display: inline-block; text-align: left;"><li>Averages in all sighted speedsolve events (Not BLD/FMC)</li><li>Means in FMC/BLD</li><li>WC Podium WR</li><li>Win all events</li></ul><br>Ranking stages go Bronze 🡆 Silver 🡆 Gold 🡆 Platinum 🡆 Opal 🡆 Diamond<br><br><i>This reduces region bias with CR/NR and also makes Gold obtainable only on personal talent. Gold is considered the pinnacle of a lot of things (Olympics, World Championships at sports, etc.), but getting past this point requires that bit extra to be on the next level.</i></div></div>
##summary
##valrange ['Bronze','Silver','Gold','Platinum','Opal','Diamond']
##valfiles {tier}
##headers ["Person","Country","All Events","Speedsolving Averages","BLD and FMC Means","WC Podium","WR","Events Won"]

SELECT 
  id `personId`, 
  name `personName`,
  countryId `Country`,
  IF(currentEventsSucceeded = 17, 'Y', CONCAT('N (', currentEventsSucceeded, '/17)')) AS `All Events`,
  IF(currentSpeedsolvingEventsAverage = 12, 'Y', CONCAT('N (', currentSpeedsolvingEventsAverage, '/12)')) AS `Speedsolving Averages`,
  IF(bldfmcEventsAverage = 4, 'Y', CONCAT('N (', bldfmcEventsAverage, '/4)')) AS `BLD and FMC Means`,
  IF(wcPodiums > 0, 'Y', 'N') AS `WC Podium`,
  IF(WRs > 0, 'Y', 'N') AS `WR`,
  IF(currentEventsWon = 17, 'Y', CONCAT('N (', currentEventsWon, '/17)')) AS `Events Won`
FROM
  wca_stats.persons_extra
WHERE
  mollerzMembership = '{tier}'
ORDER BY
  FIELD(mollerzMembership, 'Bronze', 'Silver', 'Gold', 'Platinum', 'Opal', 'Diamond', NULL) DESC,
  currentEventsSucceeded DESC,
  currentSpeedsolvingEventsAverage DESC,
  bldfmcEventsAverage DESC,
  wcPodiums DESC,
  WRs DESC,
  currentEventsWon DESC;