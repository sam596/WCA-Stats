##title Unofficial-Official {text} World Champions
##desc <div style="width: 35%; margin: 0 auto; padding: 20px; background-color: #FFFFFF; border: 2px solid #CCCCCC; position: relative;"><h3 style="font-weight: bold; text-align: center; margin-top: 0;">Description</h3><div style="text-align: center;">An alternative view of who the WCA's world champions are.<br><h4>How it works:</h4><br>The first person to win an event becomes the World Champion, then they must keep winning that event to maintain their champion status.<br>If the current champion fails to win a round of their event, the winner becomes World Champion and it continues.<br> In the event that the World Champion fails to compete in their event for one year, they lose the title, and the person with the best result on the next possible competition end date becomes World Champion.</div></div>
##summary
##valrange Events
##valfiles {text}
##headers ["Person","Country","Date Set","Started At","Ended At","Days Held"]
SET @s = NULL, @sr = NULL, @sd = '1970-01-01', @e = NULL, @p = NULL;
SELECT
    p.name personName,
    p.wca_id personId,
    p.countryId Country, 
    b.startDate `Date Set`, 
    CONCAT(
        '<a href="https://www.worldcubeassociation.org/competitions/',
        b.startComp,
        '/results/all#e',
        b.eventId,
        '_',
        b.startRound,
        '">',
        b.startComp,
        ' - ',
        rs.name,
        '</a>') `Started At`,
    IFNULL(
        IF(b.endComp LIKE '1 year after [%',
            b.endComp,
            CONCAT(
                '<a href="https://www.worldcubeassociation.org/competitions/',
                b.endComp,
                '/results/all#e',
                b.eventId,
                '_',
                b.endRound,
                '">',
                b.endComp,
                ' - ',
                re.name,
                '</a>')),'Ongoing') `Ended At`, 
    IF(b.endComp IS NULL,DATEDIFF(CURDATE(),(SELECT end_date FROM wca_dev.competitions WHERE id = b.startComp)),IFNULL(DATEDIFF((SELECT end_date FROM wca_dev.competitions WHERE id = b.endComp),(SELECT end_date FROM wca_dev.competitions WHERE id = b.startComp)),DATEDIFF((SELECT DATE_ADD(end_date, INTERVAL 1 YEAR) FROM wca_dev.competitions WHERE id = b.competitionId),(SELECT end_date FROM wca_dev.competitions WHERE id = b.startComp)))) `Days Held`
FROM
    (SELECT a.*,
    @s := IF(a.uowcId = @p, @s, competitionId) startComp,
    @sr := IF(a.uowcId = @p, @sr, roundTypeId) startRound,
    @sd := IF(a.uowcId = @p, @sd, dateSet) startDate,
    @e := IF((SELECT uowcId FROM uowc WHERE id = a.id + 1 AND eventId = a.eventId) = a.uowcId, '',  IF((SELECT dateSet FROM uowc WHERE id = a.id + 1 AND eventId = a.eventId) > DATE_ADD(a.dateSet, INTERVAL 1 YEAR),CONCAT(CONCAT('1 year after [',competitionId,'](https://www.worldcubeassociation.org/competitions/',competitionId,'/results/all#e',eventId,'_',roundTypeId,')')),
    (SELECT competitionId FROM uowc WHERE id = a.id + 1 AND eventId = a.eventId))) endComp,
    @er := IF((SELECT uowcId FROM uowc WHERE id = a.id + 1 AND eventId = a.eventId) = a.uowcId, '',  IF((SELECT dateSet FROM uowc WHERE id = a.id + 1 AND eventId = a.eventId) > DATE_ADD(a.dateSet, INTERVAL 1 YEAR),'1 year',
    (SELECT roundTypeId FROM uowc WHERE id = a.id + 1 AND eventId = a.eventId))) endRound,
    @p := a.uowcId
    FROM wca_stats.uowc a
    WHERE eventId = '{text}') b
LEFT JOIN wca_dev.roundtypes rs ON b.startRound = rs.id
LEFT JOIN wca_dev.roundtypes re ON b.endRound = re.id
LEFT JOIN wca_dev.persons p ON b.uowcId = p.wca_id AND p.subid = 1
WHERE (b.endComp <> '' OR b.endComp IS NULL) AND b.uowcId IS NOT NULL
ORDER BY b.id;