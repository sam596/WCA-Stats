DROP TABLE IF EXISTS tmp_roundTypeReverseRank;
CREATE TEMPORARY TABLE tmp_roundTypeReverseRank (
competitionId VARCHAR(32),
eventId VARCHAR(6),
roundTypeId CHAR(1),
rtRank INT,
reverseRank INT,
INDEX idx_comp_event_round (competitionId, eventId, roundTypeId),
INDEX idx_round_rank (roundTypeId, rtRank),
INDEX idx_reverse_rank (competitionId, eventId, reverseRank)
)
SELECT
competitionId,
eventId,
roundTypeId,
MAX(roundTypeRank) rtRank,
ROW_NUMBER() OVER (PARTITION BY competitionId, eventId ORDER BY MAX(roundTypeRank) DESC) reverseRank
FROM
results_extra
GROUP BY
competitionId,
eventId,
roundTypeId;

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