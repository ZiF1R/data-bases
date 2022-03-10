use master;
use Dobriyan_MyBase;
SELECT * from Teachers;
SELECT Course_subject, Lessons_Type from Courses;
SELECT count(*) [Columns_Count] from Groups;
SELECT Distinct TOP(2) * from Courses WHERE Cost BETWEEN 200 AND 300;