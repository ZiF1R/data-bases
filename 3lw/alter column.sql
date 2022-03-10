use master;
use Dobriyan_MyBase;
ALTER table Courses ADD Test_column nchar(1) default('a') check(Test_column in ('a', 'b'));
ALTER table Courses ALTER column Cost money; --change type of Cost-column from real to money
ALTER table Courses DROP Column Test_column;