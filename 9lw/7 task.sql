use Dobriyan_MyBase;

--- #

EXEC SP_HELPINDEX 'Groups';
EXEC SP_HELPINDEX 'Courses';
EXEC SP_HELPINDEX 'Specialities';
EXEC SP_HELPINDEX 'Teachers';

--- #

SELECT Number, Students_Count
FROM Groups
WHERE Students_Count >= 15 AND Students_Count <= 20;

CREATE INDEX STUD_COUNT ON Groups(Students_Count)
WHERE Students_Count >= 10 AND Students_Count <= 20;

SELECT Number, Students_Count
FROM Groups
WHERE Students_Count >= 15 AND Students_Count <= 20;

--- #

CREATE INDEX STUD_COUNT_SPECIALITY ON Groups(Students_Count asc, Speciality);

SELECT Students_Count, Speciality
FROM Groups;

--- #

SELECT name [Индекс], avg_fragmentation_in_percent [Фрагментация(%)]
	FROM sys.dm_db_index_physical_stats(DB_ID(N'Dobriyan_MyBase'),
	OBJECT_ID(N'Groups'),NULL,NULL,NULL) ss
	JOIN sys.indexes ii on ss.index_id = ii.index_id and ss.object_id = ii.object_id
	WHERE name is not null;