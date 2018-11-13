#	DROP PROCEDURE IF EXISTS worldrank;
#	DELIMITER ;;
#	CREATE PROCEDURE worldrank(IN event VARCHAR(16), IN form VARCHAR(1))
#	BEGIN
#	DECLARE n INT DEFAULT 0;
#	DECLARE i INT DEFAULT 0;
#	SELECT COUNT(DISTINCT weekend) FROM wca_stats.pbs WHERE eventId = event AND format = form INTO n;
#	SET i = 0;
#	WHILE i<n DO
#	  SET @Tie = 0, @WR = 0, @PB = 0;
#	  INSERT INTO wca_stats.world_rank_history
#	  SELECT weekend, eventId, format, worldRank, PR, personId
#	  FROM (SELECT a.*,
#	    @Tie := @Tie+1 'Tie',
#	    @WR := IF(@PB = a.PB,@WR,@Tie) 'worldRank',
#	    @PB := a.PB 'PR'
#	FROM 
#	  (SELECT weekend, eventId, format, PB, personId
#	  FROM 
#	    (SELECT weekend, personId, eventId, format,
#	      (SELECT MIN(result) 
#	        FROM wca_stats.pbs 
#	        WHERE personId = b.personId AND 
#	          eventId = event AND 
#	          format = form AND 
#	          weekend <= b.weekend) 'PB'
#	    FROM
#	        (SELECT personId, eventId, format, (SELECT DISTINCT weekend FROM wca_stats.pbs WHERE eventId = event AND format = form ORDER BY weekend LIMIT i,1) weekend
#	        FROM wca_stats.ranks_all
#	        WHERE succeeded = 1 AND 
#	        eventId = event AND 
#	        format = form) b
#	    ORDER BY personId, eventId, format DESC, weekend ASC) b
#	WHERE PB > 0
#	ORDER BY PB ASC) a) b
#	WHERE worldRank <= 100;
#	  SET i = i + 1;
#	    SELECT event, form, CONCAT(i,"/",n) progress;
#	END WHILE;
#	END;
#	;;
#	DELIMITER ;
#	
#	CALL worldrank('333','s');
#	CALL worldrank('222','s');
#	CALL worldrank('444','s');
#	CALL worldrank('555','s');
#	CALL worldrank('666','s');
#	CALL worldrank('777','s');
#	CALL worldrank('333bf','s');
#	CALL worldrank('333fm','s');
#	CALL worldrank('333ft','s');
#	CALL worldrank('333oh','s');
#	CALL worldrank('clock','s');
#	CALL worldrank('minx','s');
#	CALL worldrank('pyram','s');
#	CALL worldrank('skewb','s');
#	CALL worldrank('sq1','s');
#	CALL worldrank('444bf','s');
#	CALL worldrank('555bf','s');
#	CALL worldrank('333mbf','s');
#	CALL worldrank('333','a');
#	CALL worldrank('222','a');
#	CALL worldrank('444','a');
#	CALL worldrank('555','a');
#	CALL worldrank('666','a');
#	CALL worldrank('777','a');
#	CALL worldrank('333bf','a');
#	CALL worldrank('333fm','a');
#	CALL worldrank('333ft','a');
#	CALL worldrank('333oh','a');
#	CALL worldrank('clock','a');
#	CALL worldrank('minx','a');
#	CALL worldrank('pyram','a');
#	CALL worldrank('skewb','a');
#	CALL worldrank('sq1','a');
#	
#	
#	DROP PROCEDURE IF EXISTS worldrankUPD;
#	DELIMITER ;;
#	CREATE PROCEDURE worldrankUPD(IN event VARCHAR(16), IN form VARCHAR(1))
#	BEGIN
#	DECLARE n INT DEFAULT 0;
#	DECLARE i INT DEFAULT 0;
#	SELECT COUNT(DISTINCT weekend) FROM wca_stats.pbs WHERE eventId = event AND format = form INTO n;
#	SET i = n-5;
#	WHILE i<n DO
#	  SET @Tie = 0, @WR = 0, @PB = 0;
#	  DELETE FROM wca_stats.world_rank_history WHERE eventId = event AND format = form AND weekend = (SELECT DISTINCT weekend FROM wca_stats.pbs WHERE eventId = event AND format = form ORDER BY weekend LIMIT i,1);
#	  INSERT INTO wca_stats.world_rank_history
#	  SELECT weekend, eventId, format, worldRank, PR, personId
#	  FROM (SELECT a.*,
#	    @Tie := @Tie+1 'Tie',
#	    @WR := IF(@PB = a.PB,@WR,@Tie) 'worldRank',
#	    @PB := a.PB 'PR'
#	FROM 
#	  (SELECT weekend, eventId, format, PB, personId
#	  FROM 
#	    (SELECT weekend, personId, eventId, format,
#	      (SELECT MIN(result) 
#	        FROM wca_stats.pbs 
#	        WHERE personId = b.personId AND 
#	          eventId = event AND 
#	          format = form AND 
#	          weekend <= b.weekend) 'PB'
#	    FROM
#	        (SELECT personId, eventId, format, (SELECT DISTINCT weekend FROM wca_stats.pbs WHERE eventId = event AND format = form ORDER BY weekend LIMIT i,1) weekend
#	        FROM wca_stats.ranks_all
#	        WHERE succeeded = 1 AND 
#	        eventId = event AND 
#	        format = form) b
#	    ORDER BY personId, eventId, format DESC, weekend ASC) b
#	WHERE PB > 0
#	ORDER BY PB ASC) a) b
#	WHERE worldRank <= 100;
#	  SET i = i + 1;
#	    SELECT event, form, CONCAT(i,"/",n) progress;
#	END WHILE;
#	END;
#	;;
#	DELIMITER ;

CALL worldrankUPD('333','s');
CALL worldrankUPD('222','s');
CALL worldrankUPD('444','s');
CALL worldrankUPD('555','s');
CALL worldrankUPD('666','s');
CALL worldrankUPD('777','s');
CALL worldrankUPD('333bf','s');
CALL worldrankUPD('333fm','s');
CALL worldrankUPD('333ft','s');
CALL worldrankUPD('333oh','s');
CALL worldrankUPD('clock','s');
CALL worldrankUPD('minx','s');
CALL worldrankUPD('pyram','s');
CALL worldrankUPD('skewb','s');
CALL worldrankUPD('sq1','s');
CALL worldrankUPD('444bf','s');
CALL worldrankUPD('555bf','s');
CALL worldrankUPD('333mbf','s');
CALL worldrankUPD('333','a');
CALL worldrankUPD('222','a');
CALL worldrankUPD('444','a');
CALL worldrankUPD('555','a');
CALL worldrankUPD('666','a');
CALL worldrankUPD('777','a');
CALL worldrankUPD('333bf','a');
CALL worldrankUPD('333fm','a');
CALL worldrankUPD('333ft','a');
CALL worldrankUPD('333oh','a');
CALL worldrankUPD('clock','a');
CALL worldrankUPD('minx','a');
CALL worldrankUPD('pyram','a');
CALL worldrankUPD('skewb','a');
CALL worldrankUPD('sq1','a');