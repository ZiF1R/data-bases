-- #1
use UNIVER;
set nocount on;
if  exists (select * from SYS.OBJECTS where OBJECT_ID= object_id(N'DBO.MyTable'))
	drop table MyTable;
		   
DECLARE @rows int;
SET IMPLICIT_TRANSACTIONS ON;

CREATE table MyTable(
	X int UNIQUE
); 

INSERT INTO MyTable VALUES
	(1),(2),(3),(4);

SET @rows = (SELECT COUNT(*) FROM MyTable);
print 'Количество строк в таблице MyTable: ' + cast(@rows as varchar(5));

if @rows < 5
	commit;
else
	rollback;

SET IMPLICIT_TRANSACTIONS OFF;

if exists (select * from  SYS.OBJECTS where OBJECT_ID = object_id(N'DBO.MyTable'))
	print 'таблица MyTable есть'; 
else   
	print 'таблицы MyTable нет';

-- #2
use UNIVER;

BEGIN try
	BEGIN transaction
		DELETE SUBJECT_T WHERE SUBJECT_T LIKE 'test_subj%';
		INSERT INTO SUBJECT_T VALUES('test_subj5', 'test_subj5', 'ИСиТ');

		UPDATE dbo.SUBJECT_T
		SET SUBJECT_T.SUBJECT_NAME = SUBJECT_T.SUBJECT_NAME + '(upd)'
		FROM dbo.SUBJECT_T
		WHERE SUBJECT_T.SUBJECT_NAME LIKE 'test_subj%';

		SELECT *
		FROM dbo.SUBJECT_T;

		RAISERROR('Test error', 1, 1);
	commit transaction;
END try
BEGIN catch
	print 'Ошибка: ' + cast(error_number() as varchar(5))
	print 'Line: ' + cast(error_line() as varchar(5))
	print 'Message: ' + error_message();
	if @@TRANCOUNT > 0
		rollback tran;
END catch;

-- #3
use UNIVER;
set nocount on;

DECLARE @checkpoint varchar(10);
BEGIN try
	BEGIN transaction
		DELETE SUBJECT_T WHERE SUBJECT_T LIKE 'test_subj%';
		SET @checkpoint = 'checkpoint1'; SAVE transaction @checkpoint;

		INSERT INTO SUBJECT_T VALUES('test_subj5', 'test_subj5', 'ИСиТ');
		SET @checkpoint = 'checkpoint2'; SAVE transaction @checkpoint;
		
		UPDATE dbo.SUBJECT_T
		SET SUBJECT_T.SUBJECT_NAME = SUBJECT_T.SUBJECT_NAME + '(upd)'
		FROM dbo.SUBJECT_T
		WHERE SUBJECT_T.SUBJECT_NAME LIKE 'test_subj%';
		SET @checkpoint = 'checkpoint3'; SAVE transaction @checkpoint;

		SELECT *
		FROM dbo.SUBJECT_T;
	commit transaction;
END try
BEGIN catch
	print 'Ошибка: ' + cast(error_number() as varchar(5))
	print 'Line: ' + cast(error_line() as varchar(5))
	print 'Message: ' + error_message();
	if @@TRANCOUNT > 0
		BEGIN
			print 'Контрольная точка: ' + @checkpoint;
			rollback transaction @checkpoint;
			commit transaction;
		END;
END catch;

-- #4
use UNIVER;
SET nocount on;

--- A ---
SET transaction isolation level READ UNCOMMITTED;

BEGIN transaction
	SELECT @@SPID 'SPID', 'insert SUBJECT' 'результат', *
	FROM dbo.SUBJECT_T
	WHERE SUBJECT_T.PULPIT = 'ИСиТ';

	--- t1 ---

	SELECT
		@@SPID 'SPID',
		'update AUDITORIUM' 'результат',
		AUDITORIUM_NAME,
		AUDITORIUM_TYPE,
		AUDITORIUM_CAPACITY
	FROM dbo.AUDITORIUM
	WHERE AUDITORIUM.AUDITORIUM_TYPE LIKE 'ЛК%';
commit;
	--- t2 ---

--- B ---
--set transaction isolation level READ COMMITTED
begin transaction 
	SELECT @@SPID 'SPID';
	INSERT into dbo.SUBJECT_T values('test_subj6', 'test_subj_tran', 'ИСиТ');


	UPDATE AUDITORIUM SET AUDITORIUM.AUDITORIUM_CAPACITY = 22
	FROM dbo.AUDITORIUM
	WHERE AUDITORIUM.AUDITORIUM = '301-1';
	--- t1 ---
rollback;
	--- t2 ---

-- #5
use UNIVER;
SET nocount on;

--- A ---
set transaction isolation level READ COMMITTED 
begin transaction 
	select count(*) [count] from AUDITORIUM where AUDITORIUM_CAPACITY >= 30;
	
	--- t1 ---
	--- t2 ---

	select
		@@SPID 'SID',
		'update AUDITORIUM' 'результат',
		AUDITORIUM_NAME, 
		AUDITORIUM_TYPE,AUDITORIUM_CAPACITY
	from AUDITORIUM
	where  AUDITORIUM_NAME = '301-1';
commit; 

--- B ---	
begin transaction
	--- t1 ---
	update AUDITORIUM set AUDITORIUM_CAPACITY = 30 where AUDITORIUM_NAME = '301-1';
commit;
	--- t2 ---

-- #6
use UNIVER;
SET nocount on;

--- A ---
set transaction isolation level  REPEATABLE READ
begin transaction
	select SUBJECT_NAME from SUBJECT_T where SUBJECT_T = 'test_subj6';
	--- t1 ---
	--- t2 ---
	select case
			when SUBJECT_T = 'test_subj6' then 'insert  SUBJECT' else '-'
		end 'результат',
		SUBJECT_NAME
	FROM SUBJECT_T
	WHERE PULPIT = 'ИСиТ';
commit;

--- B ---
begin transaction
	--- t1 ---
	INSERT into dbo.SUBJECT_T values('test_subj6', 'test_subj6', 'ИСиТ');
commit;
	--- t2 ---

-- #7
use UNIVER;
SET nocount on;
set transaction isolation level SERIALIZABLE;

--- A ---
BEGIN transaction
	DELETE SUBJECT_T WHERE SUBJECT_T LIKE 'test_subj%';
	INSERT INTO SUBJECT_T VALUES('test_subj7', 'test_subj7', 'ИСиТ');

	UPDATE dbo.SUBJECT_T
	SET SUBJECT_T.SUBJECT_NAME = SUBJECT_T.SUBJECT_NAME + '(upd)'
	FROM dbo.SUBJECT_T
	WHERE SUBJECT_T.SUBJECT_NAME LIKE 'test_subj%';
	
	--- t1 ---
	SELECT SUBJECT_T from SUBJECT_T where SUBJECT_T LIKE 'test_subj%';
	--- t2 ---
commit;

--- B ---
BEGIN transaction
	delete SUBJECT_T where SUBJECT_T LIKE 'test_subj%';
	INSERT INTO SUBJECT_T VALUES('test_subj7', 'test_subj7', 'ИСиТ');

	UPDATE dbo.SUBJECT_T
	SET SUBJECT_T.SUBJECT_NAME = SUBJECT_T.SUBJECT_NAME + '(upd)'
	FROM dbo.SUBJECT_T
	WHERE SUBJECT_T.SUBJECT_NAME LIKE 'test_subj%';

	SELECT SUBJECT_T from SUBJECT_T where SUBJECT_T LIKE 'test_subj%';
	--- t1 ---
commit;
SELECT SUBJECT_T from SUBJECT_T where SUBJECT_T LIKE 'test_subj%';
	--- t2 ---

-- #8
use UNIVER;
SET nocount on;

BEGIN transaction
	INSERT INTO SUBJECT_T VALUES('test_subj8', 'test_subj8', 'ИСиТ');
	BEGIN transaction
		UPDATE dbo.SUBJECT_T
		SET SUBJECT_T.SUBJECT_NAME = SUBJECT_T.SUBJECT_NAME + '(upd)'
		FROM dbo.SUBJECT_T
		WHERE SUBJECT_T.SUBJECT_NAME LIKE 'test_subj%';
	commit;

	if @@TRANCOUNT > 0
		rollback;

	SELECT *
	FROM SUBJECT_T
	WHERE SUBJECT_T.SUBJECT_NAME LIKE 'test_subj%';
