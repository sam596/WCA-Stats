DROP TABLE IF EXISTS tmp_roundTypeReverseRank;
CREATE TEMPORARY TABLE tmp_roundTypeReverseRank (
    competitionId VARCHAR(32),
    eventId VARCHAR(6),
    roundTypeId CHAR(1),
    rtRank INT,
    reverseRank INT,
    INDEX idx_comp_event_round (competitionId, eventId, roundTypeId),
    INDEX idx_round_rank (roundTypeId, rtRank),
    INDEX idx_reverse_rank (competitionId, eventId, reverseRank),
    INDEX idx_tmp_roundTypeReverseRank_competition_event_round_reverse (competitionId, eventId, roundTypeId, reverseRank)
) 
SELECT
    t.competitionId,
    t.eventId,
    t.roundTypeId,
    t.rtRank,
    ROW_NUMBER() OVER (PARTITION BY t.competitionId, t.eventId ORDER BY t.rtRank DESC) AS reverseRank
FROM
    (
        SELECT
            re.competitionId,
            re.eventId,
            re.roundTypeId,
            MAX(rt.rank) AS rtRank
        FROM
            results_extra re
        JOIN
            wca_dev.roundTypes rt ON re.roundTypeId COLLATE utf8mb4_0900_ai_ci = rt.id COLLATE utf8mb4_0900_ai_ci
        GROUP BY
            re.competitionId,
            re.eventId,
            re.roundTypeId
    ) AS t;

CREATE TEMPORARY TABLE tmp_finalMissers (id INT, INDEX idx_id (id))
SELECT b.id
FROM (SELECT re.id, re.competitionId, re.eventId, re.personId, re.pos FROM results_extra re JOIN tmp_roundTypeReverseRank rtrr ON re.competitionId = rtrr.competitionId AND re.eventId = rtrr.eventId AND re.roundTypeId = rtrr.roundTypeId WHERE rtrr.reverseRank = 2) b
WHERE NOT EXISTS (
    SELECT 1
    FROM results_extra a
    WHERE a.personId = b.personId
        AND a.competitionId = b.competitionId
        AND a.eventId = b.eventId
        AND a.roundTypeId IN ('c', 'f')
)
AND NOT EXISTS (
	SELECT 1
    FROM results_extra c
    WHERE c.competitionId = b.competitionId
        AND c.eventId = b.eventId
        AND c.roundTypeId IN ('c', 'f')
	GROUP BY c.competitionId, c.eventId, c.roundTypeId
    HAVING MAX(c.pos) > b.pos
);

UPDATE results_extra
SET finalMisser = True
WHERE id IN (SELECT id FROM tmp_finalMissers);