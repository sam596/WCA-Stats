DROP FUNCTION IF EXISTS FORMAT_RESULT;
DELIMITER $$
CREATE FUNCTION FORMAT_RESULT(value VARCHAR(64), eventId VARCHAR(6), format CHAR(1))
RETURNS varchar(32)
BEGIN
	RETURN
		IF(value = -1,
			'DNF',
		IF(value = -2,
			'DNS',
		IF(value = 0,
			'',
		IF(eventId = '333mbf' AND format = 's',
			CONCAT(
				99-LEFT(value,2)+RIGHT(value,2),
				"/",
				99-LEFT(value,2)+(2*RIGHT(value,2)),
				" ",
				IF(MID(value,4,4)*1 >= 3600,
					LEFT(TIME_FORMAT(SEC_TO_TIME(MID(value,4,4)*1),'%H:%i:%s.%f'),11),
				IF(MID(value,4,4)*1 >= 600,
					LEFT(TIME_FORMAT(SEC_TO_TIME(MID(value,4,4)*1),'%i:%s.%f'),8),
				IF(MID(value,4,4)*1 >= 60,
					RIGHT(LEFT(TIME_FORMAT(SEC_TO_TIME(MID(value,4,4)*1),'%i:%s.%f'),8),7),
				IF(MID(value,4,4)*1 >= 10,
					LEFT(TIME_FORMAT(SEC_TO_TIME(MID(value,4,4)*1),'%s.%f'),5),
					RIGHT(LEFT(TIME_FORMAT(SEC_TO_TIME(MID(value,4,4)*1),'%s.%f'),5),4)
					))))),
		IF(eventId = '333fm' AND format = 's',
			value,
		IF(eventId = '333fm' AND format = 'a',
			ROUND(value/100,2),
		IF(value >= 360000,
			LEFT(TIME_FORMAT(SEC_TO_TIME(value/100),'%H:%i:%s.%f'),11),
		IF(value >= 60000,
			LEFT(TIME_FORMAT(SEC_TO_TIME(value/100),'%i:%s.%f'),8),
		IF(value >= 6000,
			RIGHT(LEFT(TIME_FORMAT(SEC_TO_TIME(value/100),'%i:%s.%f'),8),7),
		IF(value >= 1000,
			LEFT(TIME_FORMAT(SEC_TO_TIME(value/100),'%s.%f'),5),
		IF(value > 0,
			RIGHT(LEFT(TIME_FORMAT(SEC_TO_TIME(value/100),'%s.%f'),5),4),
			'Error'
		)))))))))));
END;
$$
DELIMITER ;
