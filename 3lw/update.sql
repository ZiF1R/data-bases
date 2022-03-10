use master;
use Dobriyan_MyBase;
UPDATE Courses SET Peoples_Count = 15
	WHERE Lessons_Type = 'аудиторно' AND Peoples_Count > 15; --measure for COVID situation
SELECT * from Courses; -- check results