-- #1
use UNIVER;

CREATE TABLE TR_AUDIT
(
	ID int identity,
	STMT varchar(20) check (STMT in ('INS','DEL','UPD')),
	TRNAME varchar(50),
	CC varchar(300)
);

GO
CREATE TRIGGER TR_TEACHER_INS on TEACHER after INSERT AS
insert into TR_AUDIT values (
	'INS',
	'TR_TEACHER_INS',
	'Преподаватель:' + rtrim((SELECT TEACHER from INSERTED)) + 
	'. Имя:' + rtrim((SELECT TEACHER_NAME from INSERTED)) + 
	'. Пол:' + rtrim((SELECT GENDER from INSERTED)) + 
	'. Кафедра: ' + rtrim((SELECT PULPIT from INSERTED))
);

INSERT into TEACHER(TEACHER,TEACHER_NAME,GENDER,PULPIT)
VALUES ('ДБРН','Добриян Александр Витальевич','м','ИСиТ');

SELECT * from TR_AUDIT;

-- #2
GO
CREATE TRIGGER TR_TEACHER_DEL on TEACHER after DELETE AS
insert into TR_AUDIT values (
	'DEL',
	'TR_TEACHER_DEL',
	'Преподаватель:' + rtrim((SELECT TEACHER from DELETED)) + 
	'. Имя:' + rtrim((SELECT TEACHER_NAME from DELETED)) + 
	'. Пол:' + rtrim((SELECT GENDER from DELETED)) + 
	'. Кафедра: ' + rtrim((SELECT PULPIT from DELETED))
);
GO

DELETE FROM TEACHER where TEACHER = 'ДБРН';
SELECT * from TR_AUDIT;

-- #3
GO
CREATE TRIGGER TR_TEACHER_UPD on TEACHER after UPDATE AS
insert into TR_AUDIT values (
	'UPD',
	'TR_TEACHER_UPD',
	'Преподаватель:' + rtrim((SELECT TEACHER from INSERTED)) + 
	'. Имя:' + rtrim((SELECT TEACHER_NAME from INSERTED)) + 
	'. Пол:' + rtrim((SELECT GENDER from INSERTED)) + 
	'. Кафедра: ' + rtrim((SELECT PULPIT from INSERTED))
);
GO

UPDATE TEACHER SET PULPIT = 'ТЛ' where TEACHER = 'РЖК';
SELECT * from TR_AUDIT;

-- #4
GO
CREATE TRIGGER TR_TEACHER on TEACHER after INSERT, DELETE, UPDATE AS
	DECLARE @upd int = (select count(*) from inserted),
		@del int = (select count(*) from deleted);

	if @upd > 0 and @del = 0
		BEGIN
			insert into TR_AUDIT values (
				'INS',
				'TR_TEACHER',
				'Преподаватель:' + rtrim((SELECT TEACHER from INSERTED)) + 
				'. Имя:' + rtrim((SELECT TEACHER_NAME from INSERTED)) + 
				'. Пол:' + rtrim((SELECT GENDER from INSERTED)) + 
				'. Кафедра: ' + rtrim((SELECT PULPIT from INSERTED))
			);
		END
	else if @upd = 0 and @del > 0
		BEGIN
			insert into TR_AUDIT values (
				'DEL',
				'TR_TEACHER',
				'Преподаватель:' + rtrim((SELECT TEACHER from DELETED)) + 
				'. Имя:' + rtrim((SELECT TEACHER_NAME from DELETED)) + 
				'. Пол:' + rtrim((SELECT GENDER from DELETED)) + 
				'. Кафедра: ' + rtrim((SELECT PULPIT from DELETED))
			);
		END
	else if @upd > 0 and @del > 0
		BEGIN
			insert into TR_AUDIT values (
				'UPD',
				'TR_TEACHER',
				'Преподаватель:' + rtrim((SELECT TEACHER from INSERTED)) + 
				'. Имя:' + rtrim((SELECT TEACHER_NAME from INSERTED)) + 
				'. Пол:' + rtrim((SELECT GENDER from INSERTED)) + 
				'. Кафедра: ' + rtrim((SELECT PULPIT from INSERTED))
			);
		END
	return;
GO

INSERT into TEACHER(TEACHER,TEACHER_NAME,GENDER,PULPIT) VALUES
	('ДБРН','Добриян Александр Витальевич','м','ИСиТ');
DELETE FROM TEACHER where TEACHER = 'ДБРН';
UPDATE TEACHER SET PULPIT = 'ЛВ' where TEACHER = 'РЖК';

SELECT * from TR_AUDIT;

-- #5
alter table TEACHER add constraint PULPIT_LEN check(len(TEACHER) <= 7)
GO
UPDATE TEACHER SET TEACHER = '123456789' where TEACHER = 'РЖК';
SELECT * from TR_AUDIT;
alter table TEACHER drop constraint PULPIT_LEN;

-- #6
use UNIVER;
GO
CREATE TRIGGER TR_TEACHER_DEL1 on TEACHER after DELETE AS
insert into TR_AUDIT values (
	'DEL',
	'TR_TEACHER_DEL1',
	'Преподаватель:' + rtrim((SELECT TEACHER from DELETED)) + 
	'. Имя:' + rtrim((SELECT TEACHER_NAME from DELETED)) + 
	'. Пол:' + rtrim((SELECT GENDER from DELETED)) + 
	'. Кафедра: ' + rtrim((SELECT PULPIT from DELETED))
);
GO

GO
CREATE TRIGGER TR_TEACHER_DEL2 on TEACHER after DELETE AS
insert into TR_AUDIT values (
	'DEL',
	'TR_TEACHER_DEL2',
	'Преподаватель:' + rtrim((SELECT TEACHER from DELETED)) + 
	'. Имя:' + rtrim((SELECT TEACHER_NAME from DELETED)) + 
	'. Пол:' + rtrim((SELECT GENDER from DELETED)) + 
	'. Кафедра: ' + rtrim((SELECT PULPIT from DELETED))
);
GO

GO
CREATE TRIGGER TR_TEACHER_DEL3 on TEACHER after DELETE AS
insert into TR_AUDIT values (
	'DEL',
	'TR_TEACHER_DEL3',
	'Преподаватель:' + rtrim((SELECT TEACHER from DELETED)) + 
	'. Имя:' + rtrim((SELECT TEACHER_NAME from DELETED)) + 
	'. Пол:' + rtrim((SELECT GENDER from DELETED)) + 
	'. Кафедра: ' + rtrim((SELECT PULPIT from DELETED))
);
GO

exec SP_SETTRIGGERORDER @triggername = 'TEACHER.TR_TEACHER_DEL3', 
	@order = 'First', @stmttype = 'DELETE';

exec SP_SETTRIGGERORDER @triggername = 'TEACHER.TR_TEACHER_DEL2', 
	@order = 'Last', @stmttype = 'DELETE';

select t.name, e.type_desc
from sys.triggers t
join sys.trigger_events e on t.object_id = e.object_id
where OBJECT_NAME(t.parent_id) = 'TEACHER' and  e.type_desc = 'DELETE';

DELETE FROM TEACHER where TEACHER = 'ДБРН';
SELECT * from TR_AUDIT;

-- #7
use UNIVER;
go
create trigger TEACHER_TRAN on TEACHER after INSERT, DELETE, UPDATE AS 
	declare @count int = (select  count(*) from TEACHER);
	begin try
		if (@count >= 9)
		begin
			raiserror('Количество преподавателей не больше 9!', 11, 1);
			rollback;
		end;
	end try
	begin catch
		print 'Error number: ' + cast(ERROR_NUMBER() as varchar(6));
		print 'Error message: ' + ERROR_MESSAGE();
		print 'Error line: ' + cast(ERROR_LINE()as varchar(8));
		print 'Error secerity: ' + cast(ERROR_SEVERITY()as varchar(6));
		print 'Error state: ' + cast(ERROR_STATE()as varchar(8));
		rollback;
	end catch
return;

INSERT into TEACHER(TEACHER,TEACHER_NAME,GENDER,PULPIT)
VALUES ('ДБРН','Добриян Александр Витальевич','м','ИСиТ');

-- #8
use UNIVER;
set nocount on;

GO
create trigger FACULTY_INSTEAD_OF on FACULTY instead of DELETE AS
	PRINT 'Instead of delete';
	return;

delete from FACULTY where FACULTY ='ИТ';

-- #9
use UNIVER;

GO	
create trigger DDL_UNIVER on database for DDL_DATABASE_LEVEL_EVENTS AS   
	declare @t varchar(50) =  EVENTDATA().value('(/EVENT_INS-TANCE/EventType)[1]', 'varchar(50)');
	declare @t1 varchar(50) = EVENTDATA().value('(/EVENT_INS-TANCE/ObjectName)[1]', 'varchar(50)');
	declare @t2 varchar(50) = EVENTDATA().value('(/EVENT_INS-TANCE/ObjectType)[1]', 'varchar(50)'); 
    print 'Тип события: '+@t;
    print 'Имя объекта: '+@t1;
    print 'Тип объекта: '+@t2;
    raiserror( N'Операции с таблицами запрещены ', 16, 1);  
    rollback;
	
use UNIVER;
CREATE TABLE BUBUB (
	ID int identity(1,1)
)