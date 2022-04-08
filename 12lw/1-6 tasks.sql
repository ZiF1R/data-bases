-- #1
use UNIVER;
set nocount on;

GO
CREATE PROCEDURE PSUBJECT AS
BEGIN
	DECLARE @count int;
	SELECT * FROM dbo.SUBJECT_T;
	SET @count = (SELECT COUNT(*) FROM SUBJECT_T);

	RETURN @count;
END;

DECLARE @c int;
EXEC @c = PSUBJECT;
PRINT 'Count of rows in SUBJECT table: ' + CAST(@c as varchar(5));

-- #2
GO
use UNIVER;
set nocount on;

DECLARE @k int, @r int, @param varchar(20);
EXEC @k = PSUBJECT @param = 'ИСиТ', @cout = @r output;
PRINT 'Count of rows in SUBJECT table: ' + CAST(@r as varchar(5));
PRINT 'Count of rows in SUBJECT table: ' + CAST(@k as varchar(5));

-- #3
use UNIVER;

GO
CREATE procedure PSUBJECT_3 @param varchar(20) AS
BEGIN
	DECLARE @count int;
	SET @count = (SELECT COUNT(*) FROM SUBJECT_T WHERE SUBJECT_T.PULPIT = @param);
	PRINT 'Params: @p = ' + @param + ' @c = ' + CAST(@count as varchar(5));

	SELECT * FROM dbo.SUBJECT_T WHERE SUBJECT_T.PULPIT = @param;
END;

CREATE TABLE #SUBJECT (
	SUBJ varchar(10) NOT NULL,
	SUBJ_NAME varchar(100),
	PULP varchar(10) NOT NULL
);

INSERT #SUBJECT EXEC PSUBJECT_3 @param = 'ИСиТ';
SELECT * FROM #SUBJECT;
GO

-- #4
use UNIVER;
SET nocount on;

GO
CREATE procedure PAUDITORIUM_INSERT @a char(20), @n varchar(50), @c int = 0, @t char(10) AS
BEGIN
	BEGIN try
		INSERT into AUDITORIUM(AUDITORIUM,AUDITORIUM_NAME,AUDITORIUM_CAPACITY,AUDITORIUM_TYPE)
			values(@a, @n, @c, @t);
		RETURN 1;
	END try
	BEGIN catch
		print 'Error number: ' + cast(ERROR_NUMBER() as varchar(6));
		print 'Error message: ' + ERROR_MESSAGE();
		print 'Error line: ' + cast(ERROR_LINE()as varchar(8));
		if ERROR_PROCEDURE() is not null
			print 'Error procedure: ' + ERROR_PROCEDURE();
		print 'Error secerity: ' + cast(ERROR_SEVERITY()as varchar(6));
		print 'Error state: ' + cast(ERROR_STATE()as varchar(8));
		RETURN -1;
	END CATCH
END;

DECLARE @paud int = 0;
EXEC @paud = PAUDITORIUM_INSERT @a='423-1',@n='423-1',@c='90',@t='ЛК-К';
DELETE AUDITORIUM where AUDITORIUM_NAME='423-1';
GO

-- #5
use UNIVER;
SET nocount on;

GO
CREATE procedure SUBJECT_REPORT @pulpit varchar(20) AS
BEGIN
	BEGIN try
		if not exists (select * from SUBJECT_T where SUBJECT_T.PULPIT = @pulpit)
			RAISERROR('ошибка в параметрах', 11, 1);
		else
			BEGIN
				DECLARE pulpit_subjects CURSOR LOCAL FOR
					SELECT SUBJECT_T.SUBJECT_T
					FROM SUBJECT_T
					WHERE SUBJECT_T.PULPIT = @pulpit;

				DECLARE @subject char(30), @subjects char(500) ='', @count int = 0;

				OPEN pulpit_subjects;
				FETCH pulpit_subjects into @subject;
				PRINT 'Дисциплины кафедры ИСиТ:';
				WHILE @@FETCH_STATUS = 0
					BEGIN
						SET @subjects = RTRIM(@subject) +', ' +  @subjects;
						FETCH pulpit_subjects into @subject;
						SET @count = @count + 1;
					END;
					PRINT @subjects;
				CLOSE pulpit_subjects;
				RETURN @count;
			END
	END try
	BEGIN catch
		print 'ошибка в параметрах.'
		if ERROR_PROCEDURE() is not null
			print 'Error procedure:' + error_procedure();
		return -1;
	END catch;
END;

DECLARE @res_rep int;
exec @res_rep = SUBJECT_REPORT @pulpit = 'ИСиТ';
print 'Subjects count: ' + cast(@res_rep as varchar(3));
GO

-- #6
use UNIVER;
SET nocount on;

GO
CREATE procedure PAUDITORIUM_INSERTX @a char(20), @n varchar(50), @c int = 0, @t char(10), @tn varchar(50) AS
BEGIN
	BEGIN try
		set transaction isolation level SERIALIZABLE;
		begin transaction
			INSERT into AUDITORIUM_TYPE (AUDITORIUM_TYPE,AUDITORIUM_TYPENAME)
				values(@t,@tn);
			EXEC PAUDITORIUM_INSERT @a=@a, @n=@n, @c=@c, @t=@t;
		commit transaction;
		return  1;
	END try
	BEGIN catch
		print 'Error number: ' + cast(ERROR_NUMBER() as varchar(6));
		print 'Error message: ' + ERROR_MESSAGE();
		print 'Error line: ' + cast(ERROR_LINE()as varchar(8));
		if ERROR_PROCEDURE() is not null
			print 'Error procedure: ' + ERROR_PROCEDURE();
		print 'Error secerity: ' + cast(ERROR_SEVERITY()as varchar(6));
		print 'Error state: ' + cast(ERROR_STATE()as varchar(8));
		RETURN -1;
	END catch
END;
GO

DECLARE @paud int = 0;
EXEC @paud = PAUDITORIUM_INSERTX @a='423-1',@n='423-1',@c='90',@t='ЛК-К', @tn ='test auditorium name';
