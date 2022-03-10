use Dobriyan_MyBase;

-- №1
SELECT Groups.Number [Group], Specialities.Speciality
FROM Specialities INNER JOIN Groups
ON Specialities.id = Groups.Speciality;

-- №2
SELECT Groups.Number [Group], Specialities.Speciality
FROM Specialities INNER JOIN Groups
ON Specialities.id = Groups.Speciality
 AND Specialities.Speciality LIKE '%П%';
 
-- №3
SELECT Groups.Number [Group], Specialities.Speciality
FROM Specialities, Groups
WHERE Specialities.id = Groups.Speciality;

SELECT Groups.Number [Group], Specialities.Speciality
FROM Specialities, Groups
WHERE Specialities.id = Groups.Speciality
 AND Specialities.Speciality LIKE '%П%';
 
-- №4-5
SELECT Courses.Course_Subject [Subject],
	Teachers.Surname [Teacher Surname],
	Teachers.Name [Teacher Name],
	Teachers.Patronimic [Teacher Patronimic],
	Specialities.Speciality [Group Speciality],
	CASE
		when(Groups.Number = 1) then 'первая'
		when(Groups.Number = 2) then 'вторая'
		when(Groups.Number = 3) then 'третья'
		when(Groups.Number = 4) then 'четвертая'
	END [Group Number]
FROM Teachers
INNER JOIN Courses on Teachers.Active_Course = Courses.Course_Subject
INNER JOIN Groups on Teachers.Active_Group = Groups.Number AND Groups.Number BETWEEN 1 and 4
INNER JOIN Specialities on Groups.Speciality = Specialities.id
ORDER BY
(CASE
	when(Groups.Number = 1) then 1
	when(Groups.Number = 2) then 4
	when(Groups.Number = 3) then 2
	when(Groups.Number = 4) then 3
END);
 
-- №6
SELECT Courses.Course_Subject [Group], ISNULL(Teachers.Surname, '---') [Teacher Surname]
FROM Courses
LEFT JOIN Teachers on Courses.Course_Subject = Teachers.Active_Course;
 
-- №7
SELECT Courses.Course_Subject [Group], ISNULL(Teachers.Surname, '---') [Teacher Surname]
FROM Teachers
LEFT JOIN Courses on Courses.Course_Subject = Teachers.Active_Course;

SELECT Courses.Course_Subject [Group], ISNULL(Teachers.Surname, '---') [Teacher Surname]
FROM Courses
RIGHT JOIN Teachers on Courses.Course_Subject = Teachers.Active_Course;
 
-- №9
SELECT Groups.Number [Group], Specialities.Speciality
FROM Specialities CROSS JOIN Groups
WHERE Specialities.id = Groups.Speciality;