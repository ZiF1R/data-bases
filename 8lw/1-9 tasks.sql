use UNIVER;

-- #1
DECLARE
	@ch char(1) = 'c',
	@vch varchar(3) = 'var',
	@date datetime,
	@time time = '17:28:00',
	@i int,
	@smi smallint,
	@tint tinyint = 2,
	@num numeric(12, 5);

SET @date = '03-19-22 17:28:00';
SET	@smi = (SELECT COUNT(*) FROM GROUPS) + @tint;
SELECT @num = 12345.678;

SELECT
	@date [@datetime],
	@time [@time],
	@smi [@smi],
	@num [@num];

PRINT 'ch = ' + CAST(@ch AS varchar(10));
PRINT 'vch = ' + CAST(@vch AS varchar(10));
PRINT 'tint = ' + CAST(@tint AS varchar(10));

-- #2
DECLARE
	@totalCapacity int = (
		SELECT SUM(AUDITORIUM.AUDITORIUM_CAPACITY)
		FROM AUDITORIUM
	),
	@lessThanAverage int,
	@averageCapacity float(10),
	@totalAuditoriums int;

IF @totalCapacity > 200
	BEGIN
		SELECT
			@averageCapacity = (
				SELECT CAST(AVG(AUDITORIUM.AUDITORIUM_CAPACITY) AS float(10))
				FROM AUDITORIUM
			),
			@totalAuditoriums = (
				SELECT COUNT(*)
				FROM AUDITORIUM
			);

		SET @lessThanAverage = (
			SELECT COUNT(*)
			FROM AUDITORIUM
			WHERE AUDITORIUM.AUDITORIUM_CAPACITY < @averageCapacity
		);

		SELECT
			@totalCapacity [Total_Capacity],
			@averageCapacity [Average_Capacity],
			@totalAuditoriums [Auditoriums_Count],
			@lessThanAverage [Less_Than_Average],
			CAST((100.0 * @lessThanAverage / @totalAuditoriums) AS float(2)) [Less_Percentage]
	END
ELSE
	BEGIN
		PRINT 'Total capacity: ' + CAST(@totalCapacity AS varchar(10));
	END

-- #3
PRINT '@@ROWCOUNT = ' + CAST(@@ROWCOUNT AS varchar(10));
PRINT '@@VERSION = ' + CAST(@@VERSION AS varchar(10));
PRINT '@@SPID = ' + CAST(@@SPID AS varchar(10));
PRINT '@@ERROR = ' + CAST(@@ERROR AS varchar(10));
PRINT '@@SERVERNAME = ' + CAST(@@SERVERNAME AS varchar(10));
PRINT '@@TRANCOUNT = ' + CAST(@@TRANCOUNT AS varchar(10));
PRINT '@@FETCH_STATUS = ' + CAST(@@FETCH_STATUS AS varchar(10));
PRINT '@@NESTLEVEL = ' + CAST(@@NESTLEVEL AS varchar(10));

-- #4
DECLARE @x int = 2, @t int = 3, @z float;

IF (@t > @x) SET @z = POWER(SIN(@t), 2);
ELSE IF (@t < @x) SET @z = 4 * (@t + @x);
ELSE SET @z = 1 - EXP(@x - 2);

PRINT 'x = ' + CAST(@x AS varchar(10));
PRINT 't = ' + CAST(@t AS varchar(10));
PRINT 'z = ' + CAST(@z AS varchar(10));

DECLARE @FIO varchar(50) = 'Макейчик Татьяна Леонидовна';
SET @FIO = (
	SELECT
		SUBSTRING(@FIO, 1, CHARINDEX(' ', @FIO)) +
		SUBSTRING(@FIO, CHARINDEX(' ', @FIO) + 1, 1) + '.'+
		SUBSTRING(@FIO, CHARINDEX(' ', @FIO, CHARINDEX(' ', @FIO) + 1) + 1, 1) + '.'
);
PRINT 'Initials: ' + @FIO;

DECLARE @nextMonth int = MONTH(GETDATE()) + 1;
SELECT 
	STUDENT.NAME,
	STUDENT.BDAY
FROM STUDENT
WHERE MONTH(STUDENT.BDAY) = @nextMonth;

SELECT DISTINCT
	PROGRESS.SUBJECT_T,
	PROGRESS.PDATE,
	DATENAME(DW, PROGRESS.PDATE) [Day of week]
FROM PROGRESS
WHERE PROGRESS.SUBJECT_T = 'СУБД';

-- #5
DECLARE @lectureAuditories int = (
	SELECT COUNT(*)
	FROM AUDITORIUM
	WHERE AUDITORIUM.AUDITORIUM_TYPE LIKE 'ЛК%'
);

IF(@lectureAuditories > 5)
	BEGIN
		PRINT 'Count of lecture auditories > 5';
	END
ELSE
	BEGIN
		SELECT *
		FROM AUDITORIUM
		WHERE AUDITORIUM.AUDITORIUM_TYPE LIKE 'ЛК%';
	END

-- #6
SELECT *
FROM (
	SELECT
		CASE
			when (PROGRESS.NOTE IN (9, 10)) then 'perfect'
			when (PROGRESS.NOTE IN (7, 8)) then 'good'
			when (PROGRESS.NOTE IN (5, 6)) then 'not bad'
			else 'bad'
		END [MARK],
		COUNT(*) [COUNT]
	FROM PROGRESS
	GROUP BY CASE
			when (PROGRESS.NOTE IN (9, 10)) then 'perfect'
			when (PROGRESS.NOTE IN (7, 8)) then 'good'
			when (PROGRESS.NOTE IN (5, 6)) then 'not bad'
		ELSE 'bad'
	END
) AS T
ORDER BY
	CASE [MARK]
		when 'perfect' then 1
		when 'good' then 2
		when 'not bad' then 3
		else 4
	END;

-- #7
CREATE TABLE #TEST (
	ID int NOT NULL IDENTITY(1,1) PRIMARY KEY,
	STRING varchar(50)
);

DECLARE @index int = 0;
WHILE (@index < 10)
	BEGIN
		INSERT #TEST(STRING) VALUES
			(CAST(@index + GETDATE() AS varchar(50)));
		SET @index = @index + 1;
	END;

SELECT *
FROM #TEST;

-- #8
WHILE (@index > 0)
	BEGIN
		INSERT #TEST(STRING) VALUES
			(CAST(@index + GETDATE() AS varchar(50)));
		SET @index = @index + 1;

		IF(@index >= 20)
			RETURN;
	END

SELECT *
FROM #TEST;

-- #9
BEGIN TRY
	SELECT *
	FROM AUDITORIUM
	WHERE AUDITORIUM.AUDITORIUM = 123;
END TRY
BEGIN CATCH
	PRINT 'Error code: ' + CAST(ERROR_NUMBER() AS varchar(10))
	PRINT 'Error message: ' + ERROR_MESSAGE()
	PRINT 'Error line: ' + CAST(ERROR_LINE() AS varchar(10))
	PRINT 'Proceedure name: ' + CAST(ERROR_PROCEDURE() AS varchar(10))
	PRINT 'Error serverity: ' + CAST(ERROR_SEVERITY() AS varchar(10))
	PRINT 'Error state: ' + CAST(ERROR_STATE() AS varchar(10))
END CATCH