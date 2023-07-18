##title PR Streaks {text}
##desc
##summary
##valrange ['pr_streak','pr_streak_exfmc','pr_streak_exfmcbld']
##valfiles {text}
##headers ["Rank","Person","Country","PR Streak","Started At","Ended At"]
SET @i = 1, @c = 0, @v = 0, @r = NULL;
SELECT
    `Rank`, personName, personId, `PR Streak`, `Started At`, `Ended At`
FROM	
    (SELECT
            @i := IF(@v = `PR Streak`, @i, @i + @c) initrank,
            @c := IF(@v = `PR Streak`, @c + 1, 1) counter,
            @r := IF(@v = `PR Streak`, '=', @i) `Rank`,
            @v := `PR Streak` val,
            a.*
        FROM	
            (SELECT 
                    p.name personName,
                    p.wca_id personId, 
                    a.prStreak `PR Streak`, 
                    CONCAT(
                        '<a href="https://www.worldcubeassociation.org/competitions/',
                        a.startcomp,
                        '">',
                        a.startcomp,
                        '</a>') `Started At`,
                    IF((SELECT id FROM {text} WHERE personId = a.personId AND endcomp = a.endComp)=(SELECT MAX(id) FROM {text} WHERE personId = a.personId),'',
                    CONCAT('<a href="https://www.worldcubeassociation.org/competitions/',(SELECT competitionId FROM {text} WHERE id = a.id + 1),'">',(SELECT competitionId FROM {text} WHERE id = a.id + 1),'</a>' )) `Ended At` 
                FROM {text} a 
                INNER JOIN (SELECT personId, startcomp, MAX(prStreak) maxprs FROM {text} GROUP BY personId, startcomp) b 
                    ON a.personId = b.personId AND 
                    a.startcomp = b.startcomp AND 
                    b.maxprs = a.prstreak 
                JOIN wca_dev.persons p 
                    ON a.personId = p.wca_id AND p.subid = 1
                ORDER BY a.prStreak DESC, p.name 
                LIMIT 1000) a
        ) b;