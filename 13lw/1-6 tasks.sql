-- #1
use UNIVER;

GO
CREATE function COUNT_STUDENTS(@faculty varchar(20) = null, @prof varchar(20) = null) returns int AS
BEGIN
	RETURN (
		SELECT count(IDSTUDENT)
		FROM GROUPS
		JOIN FACULTY ON GROUPS.FACULTY = FACULTY.FACULTY
		JOIN STUDENT ON STUDENT.IDGROUP = GROUPS.IDGROUP AND GROUPS.PROFESSION = @prof
		WHERE GROUPS.FACULTY = @faculty
	);
END
GO

DECLARE @facult varchar(10) = 'ИТ';
DECLARE @profession varchar(10) = '1-40 01 02';
PRINT 'Количество студентов факультета [' + @facult
  + '] с профессией номер ['+ @profession + ']: ' 
  + cast(dbo.COUNT_STUDENTS(@facult, @profession) as varchar(5));

-- #2
use UNIVER;

GO
CREATE function FSUBJECTS(@pulpit varchar(20)) returns varchar(300) AS
BEGIN
	DECLARE @subject varchar(10), @subjects varchar(300) = 'Дисциплины: ';
	DECLARE subj_cursor CURSOR STATIC LOCAL FOR
		SELECT SUBJECT_T.SUBJECT_T
		FROM SUBJECT_T
		WHERE SUBJECT_T.PULPIT = @pulpit;

	OPEN subj_cursor;
	fetch subj_cursor into @subject;   	 
    while @@fetch_status = 0                                     
		begin 
			set @subjects = @subjects + rtrim(@subject) + ', ';         
			FETCH subj_cursor into @subject; 
		end;
	CLOSE subj_cursor;

	RETURN @subjects;
END
GO

SELECT PULPIT.PULPIT, dbo.FSUBJECTS(PULPIT) [SUBJECTS] FROM PULPIT;

-- #3
use UNIVER;

GO
CREATE function FFACPUL(@faculty varchar(20), @pulpit varchar(20)) returns table AS
	RETURN
		SELECT FACULTY.FACULTY,PULPIT.PULPIT
		FROM FACULTY
		LEFT OUTER JOIN PULPIT ON FACULTY.FACULTY = PULPIT.FACULTY
		WHERE FACULTY.FACULTY = isnull(@faculty, FACULTY.FACULTY) AND
				PULPIT.PULPIT = isnull(@pulpit, PULPIT.PULPIT);
GO

select * from dbo.FFACPUL(NULL,NULL);
select * from dbo.FFACPUL('ТТЛП',NULL);
select * from dbo.FFACPUL(NULL,'ИСиТ');
select * from dbo.FFACPUL('ТТЛП','ТДП');
select * from dbo.FFACPUL('ЛХ','ПИ');

-- #4
use UNIVER;

GO
CREATE function FTEACHER (@pulpit varchar(20)) returns int AS
	BEGIN
		DECLARE @result int = 0;
		SET @result  = (
			SELECT count(*)
			FROM TEACHER
			JOIN PULPIT ON TEACHER.PULPIT = PULPIT.PULPIT
			WHERE PULPIT.PULPIT = isnull(@pulpit, PULPIT.PULPIT)
		);
		RETURN @result;
	END;
GO

select PULPIT, dbo.FTEACHER(PULPIT.PULPIT) 'Количество преподавателей' from PULPIT;
select dbo.FTEACHER(NULL) 'Всего преподавателей';

-- #5
use Dobriyan_MyBase;

GO
CREATE function COUNT_STUDENT(@spec varchar(20) = null) returns int AS
BEGIN
	RETURN (
		SELECT count(*)
		FROM Specialities
		JOIN Groups ON Groups.Speciality = Specialities.id
		WHERE Specialities.Speciality = isnull(@spec, Specialities.Speciality)
	);
END;
GO

DECLARE @spec varchar(29) = 'ДЭиВИ';
PRINT 'Количество групп специальности [' + @spec + ']: ' + cast(dbo.COUNT_STUDENT(@spec) as varchar(10));
PRINT 'Общее количество групп: ' + cast(dbo.COUNT_STUDENT(NULL) as varchar(10));

---
use Dobriyan_MyBase;

GO
CREATE function FSTUD_COUNT(@spec int) returns varchar(300) AS
BEGIN
	DECLARE @group int, @groups varchar(300) = 'Количество студентов в группах: ';
	DECLARE group_cursor CURSOR STATIC LOCAL FOR
		SELECT Students_Count
		FROM Specialities
		JOIN Groups ON Groups.Speciality = Specialities.id
		WHERE Specialities.id = @spec;

	OPEN group_cursor;
	fetch group_cursor into @group;   	 
    while @@fetch_status = 0                                     
		begin 
			set @groups = @groups + CAST(@group as varchar(10)) + ', ';         
			FETCH group_cursor into @group; 
		end;
	CLOSE group_cursor;

	RETURN @groups;
END
GO

SELECT Specialities.Speciality, dbo.FSTUD_COUNT(id) [STUD_COUNTS] FROM Specialities;

-- #6
use UNIVER;

go 
CREATE function COUNT_PULPIT(@faculty varchar(20)) returns int AS
begin 
	return (
		SELECT count(PULPIT)
		FROM PULPIT
		WHERE FACULTY = @faculty
	);
end;

go 
CREATE function COUNT_GROUP(@faculty varchar(20)) returns int AS
begin 
	return (
		SELECT count(IDGROUP)
		FROM GROUPS
		WHERE FACULTY = @faculty
	);
end;

go 
CREATE function COUNT_PROFESSION(@faculty varchar(20)) returns int AS
begin 
	return (
		SELECT count(PROFESSION)
		FROM PROFESSION
		WHERE FACULTY = @faculty
	);
end;

go 
CREATE function COUNT_STUD(@faculty varchar(20) = null, @prof varchar(20) = null) returns int AS
BEGIN
	RETURN (
		SELECT count(IDSTUDENT)
		FROM GROUPS
		JOIN FACULTY ON GROUPS.FACULTY = FACULTY.FACULTY
		JOIN STUDENT ON STUDENT.IDGROUP = GROUPS.IDGROUP AND GROUPS.PROFESSION = ISNULL(@prof, GROUPS.PROFESSION)
		WHERE GROUPS.FACULTY = @faculty
	);
END

go
CREATE function FACULTY_REPORT(@c int) returns @fr table(
	[Факультет] varchar(50), [Количество кафедр] int, [Количество групп] int,
	[Количество студентов] int, [Количество специальностей] int
) AS
begin 
    declare cc CURSOR static for select FACULTY.FACULTY from FACULTY where dbo.COUNT_STUD(FACULTY, NULL) > @c; 
	declare @f varchar(30);
	open cc;  
    fetch cc into @f;
	while @@fetch_status = 0
	begin
	    insert @fr values(@f, dbo.COUNT_PULPIT(@f),
			dbo.COUNT_GROUP(@f), dbo.COUNT_STUD(@f, NULL),
			dbo.COUNT_PROFESSION(@f)); 
	    fetch cc into @f;  
	end;   
    return; 
end;
go

SELECT * from  dbo.FACULTY_REPORT(0);