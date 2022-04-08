-- #1
use Dobriyan_MyBase;
set nocount on;

GO
CREATE PROCEDURE PCOURSES AS
BEGIN
	DECLARE @count int;
	SELECT * FROM dbo.Courses;
	SET @count = (SELECT COUNT(*) FROM Courses);

	RETURN @count;
END;
GO

DECLARE @c int;
EXEC @c = PCOURSES;
PRINT 'Count of rows in Courses table: ' + CAST(@c as varchar(5));

-- #3
use Dobriyan_MyBase;

GO
CREATE PROCEDURE PGROUPS @speciality int AS
BEGIN
	DECLARE @count int;
	SET @count = (SELECT COUNT(*) FROM Groups WHERE Groups.Speciality = @speciality);
	
	SELECT * FROM dbo.Groups WHERE Groups.Speciality = @speciality;
END;
GO

CREATE TABLE #GROUP (
	NUM int NOT NULL,
	STUD_COUNT int,
	SPEC int NOT NULL,
	DEPART varchar(20)
);

INSERT #GROUP EXEC PGROUPS @speciality = 1;
SELECT * FROM #GROUP;
GO

-- #4
use Dobriyan_MyBase;
SET nocount on;

GO
CREATE procedure PSPEC_INSERT @id int, @spec varchar(10) AS
BEGIN
	BEGIN try
		INSERT into Specialities values(@id, @spec);
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
GO

DECLARE @pspec int = 0;
EXEC @pspec = PSPEC_INSERT @id = 5, @spec = 'test spec';
SELECT * from Specialities;
DELETE Specialities where Specialities.Speciality = 'test spec';
GO

-- #5
use Dobriyan_MyBase;
SET nocount on;

GO
CREATE procedure GROUPS_REPORT @spec int AS
BEGIN
	BEGIN try
		if not exists (select * from Groups where Groups.Speciality = @spec)
			RAISERROR('ошибка в параметрах', 11, 1);
		else
			BEGIN
				DECLARE spec_average_stud_count CURSOR LOCAL FOR
					SELECT Groups.Students_Count
					FROM Groups
					WHERE Groups.Speciality = @spec;

				DECLARE @stud_count int, @stud_counts varchar(200) = '', @count int = 0, @average int = 0;

				OPEN spec_average_stud_count;
				FETCH spec_average_stud_count into @stud_count;
				PRINT 'Количество студентов в группах определенной специальности:';
				WHILE @@FETCH_STATUS = 0
					BEGIN
						SET @stud_counts = CAST(@stud_count as varchar(10)) + ', ' + @stud_counts;
						SET @average = @average + @stud_count;
						FETCH spec_average_stud_count into @stud_count;
						SET @count = @count + 1;
					END;
				PRINT @stud_counts;
				CLOSE spec_average_stud_count;
				RETURN @average / @count;
			END
	END try
	BEGIN catch
		print 'Error message: ' + ERROR_MESSAGE();
		if ERROR_PROCEDURE() is not null
			print 'Error procedure:' + error_procedure();
		return -1;
	END catch;
END;
GO

DECLARE @res_rep int;
exec @res_rep = GROUPS_REPORT @spec = 2;
print 'Average students count: ' + cast(@res_rep as varchar(3));
GO

-- #6
use Dobriyan_MyBase;
SET nocount on;

GO
CREATE procedure PSPEC_INSERTX @id int, @spec varchar(10) AS
BEGIN
	BEGIN try
		set transaction isolation level SERIALIZABLE;
		begin transaction
			INSERT into Specialities values(@id, @spec);
			EXEC PSPEC_INSERTX @id = @id, @spec = @spec;
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

DECLARE @pspec int = 0;
EXEC @pspec = PSPEC_INSERTX @id = 5, @spec = 'test spec';
SELECT * from Specialities;
DELETE Specialities WHERE Speciality = 'test spec';