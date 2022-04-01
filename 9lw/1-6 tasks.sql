GO
use UNIVER;

-- #1
EXEC SP_HELPINDEX 'AUDITORIUM';
EXEC SP_HELPINDEX 'AUDITORIUM_TYPE';
EXEC SP_HELPINDEX 'FACULTY';
EXEC SP_HELPINDEX 'GROUPS';
EXEC SP_HELPINDEX 'PROFESSION';
EXEC SP_HELPINDEX 'PROGRESS';
EXEC SP_HELPINDEX 'PULPIT';
EXEC SP_HELPINDEX 'STUDENT';
EXEC SP_HELPINDEX 'SUBJECT_T';
EXEC SP_HELPINDEX 'TEACHER';

GO
CREATE TABLE #EXAMPLE_1 (
	ID int IDENTITY(1,1),
    TFIELD varchar(100)
);

SET nocount on;
DECLARE @i int = 0;
WHILE (@i < 1000)
	BEGIN
		INSERT #EXAMPLE_1 VALUES(@i + GETDATE());
		SET @i = @i + 1;
	END;

SELECT *
FROM #EXAMPLE_1
WHERE ID BETWEEN 150 AND 250
ORDER BY ID;

checkpoint;
DBCC DROPCLEANBUFFERS;
CREATE clustered index ##EXAMPLE_1_CL on #EXAMPLE_1(ID asc);

SELECT *
FROM #EXAMPLE_1
WHERE ID BETWEEN 150 AND 250
ORDER BY ID;


-- #2
GO
CREATE TABLE #EXAMPLE_2 (
	ID int IDENTITY(1,1),
    TFIELD varchar(100),
	RAND_NUM int
);

SET nocount on;
DECLARE @i int = 0;
WHILE (@i < 10000)
	BEGIN
		INSERT #EXAMPLE_2 VALUES(@i + GETDATE(), floor(300*RAND()));
		SET @i = @i + 1;
	END;

SELECT COUNT(*) [Row count]
FROM #EXAMPLE_2;

checkpoint;
DBCC DROPCLEANBUFFERS;
CREATE clustered index #EXAMPLE_2_CL on #EXAMPLE_2(ID asc, TFIELD);

SELECT *
FROM #EXAMPLE_2
WHERE RAND_NUM = 123 
ORDER BY ID;


-- #3
GO
CREATE TABLE #EXAMPLE_3 (
	ID int IDENTITY(1,1),
    TFIELD varchar(100),
	RAND_NUM int
);

SET nocount on;
DECLARE @i int = 0;
WHILE (@i < 10000)
	BEGIN
		INSERT #EXAMPLE_3 VALUES(@i + GETDATE(), floor(300*RAND()));
		SET @i = @i + 1;
	END;

SELECT TFIELD from #EXAMPLE_3 where ID between 1 and 100;

checkpoint;
DBCC DROPCLEANBUFFERS;
CREATE INDEX #EXAMPLE_3_CL on #EXAMPLE_3(ID) INCLUDE (TFIELD);

SELECT *
FROM #EXAMPLE_3
WHERE RAND_NUM = 123 
ORDER BY ID;


-- #4
GO
CREATE TABLE #EXAMPLE_4 (
	ID int IDENTITY(1,1),
    TFIELD varchar(100),
	RAND_NUM int
);

SET nocount on;
DECLARE @i int = 0;
WHILE (@i < 20000)
	BEGIN
		INSERT #EXAMPLE_4 VALUES(@i + GETDATE(), floor(30000*RAND()));
		SET @i = @i + 1;
	END;

CREATE INDEX #EX_WHERE ON #EXAMPLE_4(RAND_NUM)
WHERE RAND_NUM >= 10000 AND RAND_NUM <= 20000;

SELECT RAND_NUM FROM #EXAMPLE_4 WHERE RAND_NUM BETWEEN 5000 AND 19999;
SELECT RAND_NUM FROM #EXAMPLE_4 WHERE RAND_NUM >= 10000 AND RAND_NUM <= 20000;
SELECT RAND_NUM FROM #EXAMPLE_4 WHERE RAND_NUM = 17000;


-- #5
GO
CREATE TABLE #EXAMPLE_5 (
	ID int IDENTITY(1,1),
    TFIELD varchar(100),
	RAND_NUM int
);

SET nocount on;
DECLARE @i int = 0;
WHILE (@i < 20000)
	BEGIN
		INSERT #EXAMPLE_5 VALUES(@i + GETDATE(), floor(30000*RAND()));
		SET @i = @i + 1;
	END;

SELECT * FROM #EXAMPLE_5 where ID between 150 and 200 order by ID; 

SELECT name [Индекс], avg_fragmentation_in_percent [Фрагментация(%)]
	FROM sys.dm_db_index_physical_stats(DB_ID(N'TEMPDB'), 
	OBJECT_ID(N'#EXAMPLE'),NULL,NULL,NULL) ss
	JOIN sys.indexes ii on ss.index_id = ii.index_id and ss.object_id = ii.object_id
											WHERE name is not null;

ALTER index #EXAMPLE_UNCL on #EXAMPLE reorganize;
ALTER index #EXAMPLE_UNCL on #EXAMPLE rebuild with (online = off);


-- #6
GO
CREATE TABLE #EXAMPLE_6 (
	ID int IDENTITY(1,1),
    TFIELD varchar(100),
	RAND_NUM int
);

SET nocount on;
DECLARE @i int = 0;
WHILE (@i < 20000)
	BEGIN
		INSERT #EXAMPLE_6 VALUES(@i + GETDATE(), floor(30000*RAND()));
		SET @i = @i + 1;
	END;

CREATE index #EX_TKEY on #EXAMPLE_6(RAND_NUM) with (fillfactor = 65);

INSERT top(50) percent INTO #EXAMPLE_6(TFIELD, RAND_NUM)
	SELECT TFIELD, RAND_NUM  FROM #EXAMPLE_6;
SELECT name [Индекс], avg_fragmentation_in_percent [Фрагментация (%)]
       FROM sys.dm_db_index_physical_stats(DB_ID(N'TEMPDB'),    
       OBJECT_ID(N'#EX'), NULL, NULL, NULL) ss  JOIN sys.indexes ii 
        ON ss.object_id = ii.object_id and ss.index_id = ii.index_id  
        WHERE name is not null;