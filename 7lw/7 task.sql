use Dobriyan_MyBase;

-- #1
GO
CREATE VIEW [TEACHER_V]
	AS SELECT
		Teachers.Surname,
		Teachers.Name,
		Teachers.Telephone
	FROM Teachers;

-- #2
use Dobriyan_MyBase;
GO
CREATE VIEW [Active_Courses_Count]
	AS SELECT
		Teachers.Surname,
		Teachers.Name,
		COUNT(Teachers.Active_Course) [COUNT]
	FROM Teachers
	JOIN Courses ON Teachers.Active_Course = Courses.Course_Subject
	GROUP BY Teachers.Active_Course, Teachers.Surname, Teachers.Name;

-- #3
use Dobriyan_MyBase;
GO
CREATE VIEW [Groups_V]
	AS SELECT
		Groups.Speciality,
		Groups.Students_Count
	FROM Groups;

GO
INSERT Groups_V VALUES (3, 19);

-- #4
use Dobriyan_MyBase;
GO
CREATE VIEW [Design_Groups]
	AS SELECT
		Groups.Number,
		Groups.Students_Count
	FROM Groups
	WHERE Groups.Speciality = 2 WITH CHECK OPTION;

GO
use Dobriyan_MyBase;
INSERT [Design_Groups] VALUES(10, 21);

GO
UPDATE [Design_Groups]
SET Students_Count = 20
WHERE Number = 5;

-- #5
use Dobriyan_MyBase;
GO
CREATE VIEW [Courses_V]
	AS SELECT TOP(5) *
	FROM Courses
	ORDER BY Courses.Course_Subject;

-- #6
use Dobriyan_MyBase;
GO
ALTER VIEW [Active_Courses_Count] WITH SCHEMABINDING
	AS SELECT
		Teachers.Surname,
		Teachers.Name,
		COUNT(Teachers.Active_Course) [COUNT]
	FROM dbo.Teachers
	JOIN dbo.Courses ON Teachers.Active_Course = Courses.Course_Subject
	GROUP BY Teachers.Active_Course, Teachers.Surname, Teachers.Name;
