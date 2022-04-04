use UNIVER;

-- #1
GO
DECLARE isit_subjects CURSOR FOR
	SELECT SUBJECT_T.SUBJECT_T
	FROM SUBJECT_T
	WHERE SUBJECT_T.PULPIT = 'ИСиТ';

DECLARE @subject char(30), @subjects char(500) ='';

OPEN isit_subjects;
FETCH isit_subjects into @subject;
PRINT 'Дисциплины кафедры ИСиТ:';
WHILE @@FETCH_STATUS = 0
	BEGIN
		SET @subjects = RTRIM(@subject) +', ' +  @subjects;
		FETCH isit_subjects into @subject;
	END;
	PRINT @subjects;
CLOSE isit_subjects;

-- #2
GO
use UNIVER;

-- local
DECLARE isit_subjects_local CURSOR LOCAL FOR
	SELECT SUBJECT_T.SUBJECT_T
	FROM SUBJECT_T
	WHERE SUBJECT_T.PULPIT = 'ИСиТ';

PRINT 'Дисциплины кафедры ИСиТ (local cursor):';

GO
DECLARE @subject char(30), @subjects char(500) ='';

OPEN isit_subjects_local;
FETCH isit_subjects_local into @subject;

WHILE @@FETCH_STATUS = 0
	BEGIN
		SET @subjects = RTRIM(@subject) +', ' +  @subjects;
		FETCH isit_subjects_local into @subject;
	END;
	PRINT @subjects;
CLOSE isit_subjects_local;
GO

-- global
GO
use UNIVER;
DECLARE isit_subjects_global CURSOR GLOBAL FOR
	SELECT SUBJECT_T.SUBJECT_T
	FROM SUBJECT_T
	WHERE SUBJECT_T.PULPIT = 'ИСиТ';

PRINT 'Дисциплины кафедры ИСиТ (global cursor):';

GO
DECLARE @subject char(30), @subjects char(500) ='';
OPEN isit_subjects_global;
FETCH isit_subjects_global into @subject;

WHILE @@FETCH_STATUS = 0
	BEGIN
		SET @subjects = RTRIM(@subject) +', ' +  @subjects;
		FETCH isit_subjects_global into @subject;
	END;
	PRINT @subjects;
CLOSE isit_subjects_global;
GO

-- #3
GO
SET nocount on;
use UNIVER;

-- static
DECLARE isit_subjects_static CURSOR STATIC FOR
	SELECT SUBJECT_T.SUBJECT_T
	FROM SUBJECT_T
	WHERE SUBJECT_T.PULPIT = 'ИСиТ';

DECLARE @subject char(30), @subjects char(500) ='';

OPEN isit_subjects_static;
INSERT INTO SUBJECT_T VALUES('test_subj', 'test_subj', 'ИСиТ');

FETCH isit_subjects_static into @subject;
PRINT 'Дисциплины кафедры ИСиТ(static cursor):';
WHILE @@FETCH_STATUS = 0
	BEGIN
		SET @subjects = RTRIM(@subject) +', ' +  @subjects;
		FETCH isit_subjects_static into @subject;
	END;
	PRINT @subjects;
CLOSE isit_subjects_static;

DELETE SUBJECT_T WHERE SUBJECT_NAME = 'test_subj';
GO

-- dynamic
GO
SET nocount on;
use UNIVER;

DECLARE isit_subjects_dynamic CURSOR DYNAMIC FOR
	SELECT SUBJECT_T.SUBJECT_T
	FROM SUBJECT_T
	WHERE SUBJECT_T.PULPIT = 'ИСиТ';

DECLARE @subject char(30), @subjects char(500) ='';

OPEN isit_subjects_dynamic;
INSERT INTO SUBJECT_T VALUES('test_subj', 'test_subj', 'ИСиТ');

FETCH isit_subjects_dynamic into @subject;
PRINT 'Дисциплины кафедры ИСиТ(dynamic cursor):';
WHILE @@FETCH_STATUS = 0
	BEGIN
		SET @subjects = RTRIM(@subject) +', ' +  @subjects;
		FETCH isit_subjects_dynamic into @subject;
	END;
	PRINT @subjects;
CLOSE isit_subjects_dynamic;

DELETE SUBJECT_T WHERE SUBJECT_T = 'test_subj';
GO

-- #4
GO
SET nocount on;
use UNIVER;

DECLARE isit_subjects_scroll CURSOR LOCAL DYNAMIC SCROLL FOR
	SELECT
		ROW_NUMBER() over (order by SUBJECT_T),
		SUBJECT_T.SUBJECT_T
	FROM SUBJECT_T
	WHERE SUBJECT_T.PULPIT = 'ИСиТ';

DECLARE @subject char(30), @row int = 0;

OPEN isit_subjects_scroll;

FETCH isit_subjects_scroll INTO @row, @subject;
PRINT 'Next line: [' + CAST(@row as varchar(4)) + '. ' + RTRIM(@subject) + ']';

FETCH LAST FROM isit_subjects_scroll INTO @row, @subject;
PRINT 'Last line: [' + CAST(@row as varchar(4)) + '. ' + RTRIM(@subject) + ']';

FETCH RELATIVE -1 FROM isit_subjects_scroll INTO @row, @subject;
PRINT 'Previous line: [' + CAST(@row as varchar(4)) + '. ' + RTRIM(@subject) + ']';

FETCH ABSOLUTE 2 FROM isit_subjects_scroll INTO @row, @subject;
PRINT 'Second line: [' + CAST(@row as varchar(4)) + '. ' + RTRIM(@subject) + ']';

FETCH ABSOLUTE -2 FROM isit_subjects_scroll INTO @row, @subject;
PRINT 'Second line from end: [' + CAST(@row as varchar(4)) + '. ' + RTRIM(@subject) + ']';

-- #5
GO
SET nocount on;
use UNIVER;

INSERT INTO SUBJECT_T VALUES('test_subj1', 'test_subj1', 'ИСиТ');
INSERT INTO SUBJECT_T VALUES('test_subj2', 'test_subj2', 'ИСиТ');
INSERT INTO SUBJECT_T VALUES('test_subj3', 'test_subj3', 'ИСиТ');
DECLARE isit_subjects_currentof CURSOR LOCAL DYNAMIC FOR
	SELECT *
	FROM SUBJECT_T
	WHERE SUBJECT_T.PULPIT = 'ИСиТ' AND SUBJECT_T LIKE 'test_subj%'
	FOR UPDATE;

DECLARE @subject varchar(30), @subject_name varchar(30), @pulpit varchar(30);

OPEN isit_subjects_currentof;

FETCH isit_subjects_currentof INTO @subject, @subject_name, @pulpit;
PRINT @subject + ' ' + @subject_name + ' ' + @pulpit;
DELETE SUBJECT_T WHERE CURRENT OF isit_subjects_currentof;

FETCH isit_subjects_currentof INTO @subject, @subject_name, @pulpit;
UPDATE SUBJECT_T SET SUBJECT_T.SUBJECT_T += '(upd)' WHERE CURRENT OF isit_subjects_currentof;
PRINT @subject + ' ' + @subject_name + ' ' + @pulpit;

CLOSE isit_subjects_currentof;

OPEN isit_subjects_currentof;
WHILE @@FETCH_STATUS = 0
	BEGIN
		PRINT @subject + ' ' + @subject_name + ' ' + @pulpit;
		FETCH isit_subjects_currentof into @subject, @subject_name, @pulpit;
	END;
CLOSE isit_subjects_currentof;

-- #5
use UNIVER;

GO
DECLARE @id varchar(10), @name varchar(100), @subj varchar(50), @note varchar(2);
DECLARE PROGRESS_DELETE_CURSOR CURSOR LOCAL DYNAMIC FOR
	SELECT STUDENT.IDSTUDENT, STUDENT.NAME, PROGRESS.SUBJECT_T, PROGRESS.NOTE
	FROM PROGRESS JOIN STUDENT on PROGRESS.IDSTUDENT = STUDENT.IDSTUDENT
	FOR UPDATE;

OPEN PROGRESS_DELETE_CURSOR
FETCH PROGRESS_DELETE_CURSOR into @id, @name, @subj, @note;

IF(@note < 4)
	BEGIN
		DELETE PROGRESS WHERE CURRENT OF PROGRESS_DELETE_CURSOR;
	END;
PRINT @id + ' - ' + @name + ' - '+ RTRIM(@subj) + ' - ' + @note ;

WHILE @@FETCH_STATUS = 0
	BEGIN
		FETCH PROGRESS_DELETE_CURSOR into @id, @name, @subj, @note;
		PRINT @id + ' - ' + @name + ' - '+ RTRIM(@subj) + ' - ' + @note ;
		IF(@note < 4)
			BEGIN
				DELETE PROGRESS WHERE CURRENT OF PROGRESS_DELETE_CURSOR;
			END;
	END;
CLOSE PROGRESS_DELETE_CURSOR;

OPEN PROGRESS_DELETE_CURSOR;
FETCH PROGRESS_DELETE_CURSOR into @id, @name, @subj, @note;
IF (@note <= 9)
	UPDATE PROGRESS SET NOTE += 1 WHERE CURRENT OF PROGRESS_DELETE_CURSOR;

WHILE (@@FETCH_STATUS = 0)
	BEGIN
		FETCH PROGRESS_DELETE_CURSOR into @id, @name, @subj, @note;
		PRINT @id + ' - ' + @name + ' - '+ RTRIM(@subj) + ' - ' + @note ;
		IF (@note <= 9)
			BEGIN
				UPDATE PROGRESS SET NOTE += 1 WHERE CURRENT OF PROGRESS_DELETE_CURSOR;
			END;
	END;
CLOSE PROGRESS_DELETE_CURSOR;