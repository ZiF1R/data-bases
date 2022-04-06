use Dobriyan_MyBase;

-- #1
DECLARE @rows int;
SET IMPLICIT_TRANSACTIONS ON;
SET nocount on;

INSERT INTO Specialities VALUES(5, 'test1'),(6, 'test2'),(7, 'test3'),(8, 'test4');

SET @rows = (SELECT COUNT(*) FROM Specialities);
print 'Количество строк в таблице Specialities: ' + cast(@rows as varchar(5));

if @rows < 5
	commit;
else
	rollback;

SET IMPLICIT_TRANSACTIONS OFF;

DELETE Specialities WHERE Specialities.Speciality LIKE 'test%';

if exists (select * from  SYS.OBJECTS where OBJECT_ID = object_id(N'DBO.Specialities'))
	print 'таблица Specialities есть'; 
else
	print 'таблицы Specialities нет';

-- #2
use Dobriyan_MyBase;
SET nocount on;

BEGIN try
	BEGIN transaction
		INSERT INTO Specialities VALUES(5, 'test1'),(6, 'test2'),(7, 'test3'),(8, 'test4');
		DELETE Specialities WHERE Specialities.Speciality LIKE 'test%';
		RAISERROR('Test error', 1, 1);
	commit transaction;
END try
BEGIN catch
	print 'Ошибка: ' + cast(error_number() as varchar(5))
	print 'Line: ' + cast(error_line() as varchar(5))
	print 'Message: ' + error_message();
	if @@TRANCOUNT > 0
		rollback transaction;
END catch;

-- #3
use Dobriyan_MyBase;
set nocount on;

DECLARE @checkpoint varchar(10);
BEGIN try
	BEGIN transaction
		INSERT INTO Specialities VALUES(5, 'test1'),(6, 'test2'),(7, 'test3'),(8, 'test4');
		SET @checkpoint = 'checkpoint1'; SAVE transaction @checkpoint;
		
		DELETE Specialities WHERE Specialities.Speciality LIKE 'test%';
		SET @checkpoint = 'checkpoint2'; SAVE transaction @checkpoint;

		SELECT *
		FROM dbo.Specialities;
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
use Dobriyan_MyBase;
SET nocount on;

--- A ---
SET transaction isolation level READ UNCOMMITTED;

BEGIN transaction
	SELECT @@SPID 'SPID', 'insert Speciality' 'результат', *
	FROM dbo.Specialities;

	--- t1 ---

	SELECT
		@@SPID 'SPID',
		'update AUDITORIUM' 'результат',
		id, Speciality
	FROM dbo.Specialities;
commit;
	--- t2 ---

--- B ---
begin transaction 
	SELECT @@SPID 'SPID';
	INSERT INTO Specialities VALUES(5, 'test1'),(6, 'test2'),(7, 'test3'),(8, 'test4');

	UPDATE Specialities SET Specialities.id = 22
	FROM dbo.Specialities
	WHERE Specialities.Speciality = 'test2';
	--- t1 ---
rollback;
	--- t2 ---

-- #5
use Dobriyan_MyBase;
SET nocount on;

--- A ---
set transaction isolation level READ COMMITTED 
begin transaction 
	select count(*) [count] from Courses where Courses.Peoples_Count >= 20;
	
	--- t1 ---
	--- t2 ---

	select
		@@SPID 'SID',
		'update Courses' 'результат', *
	from Courses
	where Courses.Course_Subject = 'ОИТ';
commit; 

--- B ---	
begin transaction
	--- t1 ---
	update Courses set Courses.Peoples_Count = 20 where Courses.Course_Subject = 'ОИТ';
commit;
	--- t2 ---

-- #6
use Dobriyan_MyBase;
SET nocount on;
--delete dbo.Groups where Students_Count = 33;

--- A ---
set transaction isolation level  REPEATABLE READ
begin transaction
	select * from Groups where Groups.Speciality = 2;
	--- t1 ---
	--- t2 ---
	select case
			when Groups.Students_Count = 33 then 'insert Group' else '-'
		end 'результат', *
	FROM Groups
	WHERE Groups.Speciality = 2;
commit;

--- B ---
begin transaction
	--- t1 ---
	INSERT into dbo.Groups values(10, 33, 2, 'дневная'),(11, 33, 2, 'дневная');
commit;
	--- t2 ---

-- #7
use Dobriyan_MyBase;
SET nocount on;
set transaction isolation level SERIALIZABLE;

--- A ---
BEGIN transaction
	DELETE Specialities WHERE Specialities.Speciality LIKE 'test%';
	INSERT INTO Specialities VALUES(5, 'test1'),(6, 'test2'),(7, 'test3'),(8, 'test4');
	
	UPDATE Specialities SET Specialities.id = 22
	FROM dbo.Specialities
	WHERE Specialities.Speciality = 'test2';
	
	--- t1 ---
	SELECT * from Specialities where Speciality LIKE 'test%';
	--- t2 ---
commit;

--- B ---
BEGIN transaction
	DELETE Specialities WHERE Specialities.Speciality LIKE 'test%';
	INSERT INTO Specialities VALUES(5, 'test1'),(6, 'test2'),(7, 'test3'),(8, 'test4');
	
	UPDATE Specialities SET Specialities.id = 22
	FROM dbo.Specialities
	WHERE Specialities.Speciality = 'test2';
	
	SELECT * from Specialities where Speciality LIKE 'test%';
	--- t1 ---
commit;
SELECT * from Specialities where Speciality LIKE 'test%';
	--- t2 ---

-- #8
use Dobriyan_MyBase;
SET nocount on;

BEGIN transaction
	INSERT INTO Specialities VALUES(5, 'test1'),(6, 'test2'),(7, 'test3'),(8, 'test4');
	BEGIN transaction
		UPDATE Specialities SET Specialities.id = 22
		FROM dbo.Specialities
		WHERE Specialities.Speciality = 'test2';
	commit;

	if @@TRANCOUNT > 0
		rollback;
		
	SELECT * from Specialities where Speciality LIKE 'test%';
	DELETE Specialities WHERE Specialities.Speciality LIKE 'test%';