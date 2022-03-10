use master;
use Dobriyan_MyBase;
CREATE table Courses (
	Course_Subject nvarchar(20) not null PRIMARY KEY,
	Peoples_Count int,
	Lessons_Type nvarchar(20),
	Cost real
);
CREATE table Groups (
	Number int not null PRIMARY KEY,
	Students_Count int,
	Speciality nvarchar(20),
	Department nvarchar(20)
);
CREATE table Teachers (
	Teacher_key int not null PRIMARY KEY,
	Surname nvarchar(20) not null,
	Name nvarchar(20) not null,
	Patronimic nvarchar(20) not null,
	Telephone nvarchar(15) unique,
	Experience_years int default(0),
	Active_Course nvarchar(20) REFERENCES Courses(Course_Subject),
	Active_Group int REFERENCES Groups(Number)
);