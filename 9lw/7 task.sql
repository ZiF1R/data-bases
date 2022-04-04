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


SELECT a.index_id, name, avg_fragmentation_in_percent
FROM sys.dm_db_index_physical_stats (DB_ID(N'Groups'),
NULL, NULL, NULL, NULL) AS a
JOIN sys.indexes AS b
ON a.object_id = b.object_id AND a.index_id = b.index_id;