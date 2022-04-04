use Dobriyan_MyBase;

--#
DECLARE course_subjects CURSOR FOR
	SELECT Course_Subject
	FROM Courses;

DECLARE @subject char(30), @subjects char(500) ='';

OPEN course_subjects;

FETCH course_subjects into @subject;
PRINT 'Доступные курсы:';

WHILE @@FETCH_STATUS = 0
	BEGIN
		SET @subjects = RTRIM(@subject) + ', ' +  @subjects;
		FETCH course_subjects into @subject;
	END;
	PRINT @subjects;
CLOSE course_subjects;

--#
GO
DECLARE course_subjects_scroll CURSOR LOCAL DYNAMIC SCROLL FOR
	SELECT
		ROW_NUMBER() over (order by Course_Subject),
		Course_Subject
	FROM Courses;
	
DECLARE @subject char(30), @row int = 0;

OPEN course_subjects_scroll;

FETCH course_subjects_scroll INTO @row, @subject;
PRINT 'Next line: [' + CAST(@row as varchar(4)) + '. ' + RTRIM(@subject) + ']';

FETCH LAST FROM course_subjects_scroll INTO @row, @subject;
PRINT 'Last line: [' + CAST(@row as varchar(4)) + '. ' + RTRIM(@subject) + ']';

FETCH RELATIVE -1 FROM course_subjects_scroll INTO @row, @subject;
PRINT 'Previous line: [' + CAST(@row as varchar(4)) + '. ' + RTRIM(@subject) + ']';

FETCH ABSOLUTE 2 FROM course_subjects_scroll INTO @row, @subject;
PRINT 'Second line: [' + CAST(@row as varchar(4)) + '. ' + RTRIM(@subject) + ']';

FETCH ABSOLUTE -2 FROM course_subjects_scroll INTO @row, @subject;
PRINT 'Second line from end: [' + CAST(@row as varchar(4)) + '. ' + RTRIM(@subject) + ']';

CLOSE course_subjects_scroll;

--#
GO
DECLARE @course varchar(30), @people_count varchar(5), @department varchar(20), @cost varchar(15);
DECLARE course_subjects_currentof CURSOR LOCAL DYNAMIC SCROLL FOR
	SELECT *
	FROM Courses
	FOR UPDATE;

OPEN course_subjects_currentof;
SET nocount on;
FETCH course_subjects_currentof INTO @course, @people_count, @department, @cost;
PRINT 'before: [' + @course + ' ' + @people_count + ' ' + @department + ' ' + @cost + ']';
UPDATE Courses SET Courses.Peoples_Count += 2 WHERE CURRENT OF course_subjects_currentof;
CLOSE course_subjects_currentof;

OPEN course_subjects_currentof;
SET nocount on;
FETCH course_subjects_currentof INTO @course, @people_count, @department, @cost;
PRINT 'after: [' + @course + ' ' + @people_count + ' ' + @department + ' ' + @cost + ']';
UPDATE Courses SET Courses.Peoples_Count -= 2 WHERE CURRENT OF course_subjects_currentof;
CLOSE course_subjects_currentof;
