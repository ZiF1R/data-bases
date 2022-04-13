-- #1
use Dobriyan_MyBase;

CREATE TABLE TR_SPEC
(
	ID int identity,
	STMT varchar(20) check (STMT in ('INS','DEL','UPD')),
	TRNAME varchar(50),
	CC varchar(300)
);

GO
CREATE TRIGGER TR_SPEC_INS on Specialities after INSERT AS
insert into TR_SPEC values (
	'INS',
	'TR_SPEC_INS',
	'ID:' + rtrim((SELECT id from INSERTED)) + 
	'. Специальность:' + rtrim((SELECT Speciality from INSERTED))
);

INSERT into Specialities VALUES (15, 'test1');
SELECT * from TR_SPEC;
DROP TRIGGER TR_SPEC_INS;

-- #2
use Dobriyan_MyBase;

GO
CREATE TRIGGER TR_SPEC_DEL on Specialities after DELETE AS
insert into TR_SPEC values (
	'DEL',
	'TR_SPEC_DEL',
	'ID:' + rtrim((SELECT id from deleted)) + 
	'. Специальность:' + rtrim((SELECT Speciality from deleted))
);

DELETE Specialities where Speciality = 'test1';
SELECT * from TR_SPEC;
DROP TRIGGER TR_SPEC_DEL;

-- #3
use Dobriyan_MyBase;

GO
CREATE TRIGGER TR_SPEC_UPD on Specialities after UPDATE AS
insert into TR_SPEC values (
	'UPD',
	'TR_SPEC_UPD',
	'ID:' + rtrim((SELECT id from inserted)) + 
	'. Специальность:' + rtrim((SELECT Speciality from inserted))
);

UPDATE Specialities set id = id + 1 where Speciality = 'test1';
SELECT * from TR_SPEC;
DROP TRIGGER TR_SPEC_UPD;

-- #4
use Dobriyan_MyBase;

GO
CREATE TRIGGER TRG_SPEC on Specialities after INSERT, DELETE, UPDATE AS
	DECLARE @upd int = (select count(*) from inserted),
		@del int = (select count(*) from deleted);

	if @upd > 0 and @del = 0
		BEGIN
			insert into TR_SPEC values (
				'INS',
				'TRG_SPEC',
				'ID:' + rtrim((SELECT id from INSERTED)) + 
				'. Специальность:' + rtrim((SELECT Speciality from INSERTED))
			);
		END
	else if @upd = 0 and @del > 0
		BEGIN
			insert into TR_SPEC values (
				'DEL',
				'TRG_SPEC',
				'ID:' + rtrim((SELECT id from deleted)) + 
				'. Специальность:' + rtrim((SELECT Speciality from deleted))
			);
		END
	else if @upd > 0 and @del > 0
		BEGIN
			insert into TR_SPEC values (
				'UPD',
				'TRG_SPEC',
				'ID:' + rtrim((SELECT id from inserted)) + 
				'. Специальность:' + rtrim((SELECT Speciality from inserted))
			);
		END
	return;
GO

DELETE Specialities where Speciality = 'test1';
INSERT into Specialities VALUES (17, 'test1');
UPDATE Specialities set id = id + 1 where Speciality = 'test1';
SELECT * from TR_SPEC;
DROP TRIGGER TRG_SPEC;