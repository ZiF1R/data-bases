-- #1
use UNIVER;
set nocount on;

go
SELECT * from TEACHER
where PULPIT = 'ИСиТ'
FOR xml PATH('TEACHER'), root('Преподаватели_ИСиТ'), elements;

-- #2
use UNIVER;
set nocount on;

go
SELECT
	AUDITORIUM.AUDITORIUM_NAME,
	AUDITORIUM.AUDITORIUM_TYPE,
	AUDITORIUM.AUDITORIUM_CAPACITY
FROM AUDITORIUM_TYPE
JOIN AUDITORIUM ON AUDITORIUM_TYPE.AUDITORIUM_TYPE = AUDITORIUM.AUDITORIUM_TYPE
WHERE AUDITORIUM.AUDITORIUM_TYPE like 'ЛК%'
for xml AUTO, root('Лекционные_аудитории'), elements;

-- #3
use UNIVER;
set nocount on;

go
declare @h int = 0,
    @x varchar(2000) =
		'<?xml version="1.0" encoding="windows-1251" ?>
		<SUBJECTS> 
			<SUBJECT_T SUBJECT_T="new_subj1" SUBJECT_NAME="new_subj1" PULPIT="ИСиТ" />
			<SUBJECT_T SUBJECT_T="new_subj2" SUBJECT_NAME="new_subj2" PULPIT="ИСиТ" />
			<SUBJECT_T SUBJECT_T="new_subj3" SUBJECT_NAME="new_subj3" PULPIT="ИСиТ" />
		</SUBJECTS>';

exec sp_xml_preparedocument @h output, @x;
insert SUBJECT_T select [SUBJECT_T], [SUBJECT_NAME], [PULPIT]
	from openxml(@h, '/SUBJECTS/SUBJECT_T', 0)
	with([SUBJECT_T] nvarchar(10), [SUBJECT_NAME] nvarchar(100), [PULPIT] nvarchar(20))
exec sp_xml_removedocument @h;

-- #4
use UNIVER
INSERT INTO STUDENT(IDGROUP, NAME, BDAY, INFO) values
	(2, 'Добриян Александр Витальевич', '1970-01-01', 
		'<паспорт>
			<серия>1</серия>
			<номер>123456</номер>
			<дата_выдачи>1980-01-01</дата_выдачи>
			<адрес>Беларусь, г. Минск, Свердлова 13а</адрес>
		</паспорт>');

select * from STUDENT where NAME = 'Добриян Александр Витальевич';

update STUDENT set INFO =
		'<паспорт>
			<серия>2</серия>
			<номер>654321</номер>
			<дата_выдачи>1981-01-01</дата_выдачи>
			<адрес>Беларусь, г. Минск, Свердлова 13а</адрес>
		</паспорт>'
where STUDENT.INFO.value('(/паспорт/серия)[1]','int') = 1;

select * from STUDENT where NAME = 'Добриян Александр Витальевич';

select NAME, 
	INFO.value('(/паспорт/дата_выдачи)[1]', 'date') [дата_выдачи],
	INFO.value('(/паспорт/адрес)[1]', 'varchar(100)') [адрес],
	INFO.query('/паспорт') [паспорт]
from  STUDENT where NAME = 'Добриян Александр Витальевич';

-- #5
use UNIVER;
create xml schema collection Student_info as 
N'<?xml version="1.0" encoding="utf-16" ?>
<xs:schema attributeFormDefault="unqualified" 
           elementFormDefault="qualified"
           xmlns:xs="http://www.w3.org/2001/XMLSchema">
       <xs:element name="студент">  
       <xs:complexType><xs:sequence>
       <xs:element name="паспорт" maxOccurs="1" minOccurs="1">
       <xs:complexType>
       <xs:attribute name="серия" type="xs:string" use="required" />
       <xs:attribute name="номер" type="xs:unsignedInt" use="required"/>
       <xs:attribute name="дата"  use="required" >  
       <xs:simpleType>  <xs:restriction base ="xs:string">
   <xs:pattern value="[0-9]{2}.[0-9]{2}.[0-9]{4}"/>
   </xs:restriction> 	</xs:simpleType>
   </xs:attribute> </xs:complexType> 
   </xs:element>
   <xs:element maxOccurs="3" name="телефон" type="xs:unsignedInt"/>
   <xs:element name="адрес">   <xs:complexType><xs:sequence>
   <xs:element name="страна" type="xs:string" />
   <xs:element name="город" type="xs:string" />
   <xs:element name="улица" type="xs:string" />
   <xs:element name="дом" type="xs:string" />
   <xs:element name="квартира" type="xs:string" />
   </xs:sequence></xs:complexType>  </xs:element>
   </xs:sequence></xs:complexType>
   </xs:element>
</xs:schema>';

alter table STUDENT alter column INFO xml(Student_info);
drop XML SCHEMA COLLECTION Student_info;

-- #6
use Dobriyan_MyBase;
set nocount on;

go
SELECT * from Courses
where Courses.Lessons_Type = 'аудиторно'
FOR xml PATH('Courses'), root('Курсы_в_аудиториях'), elements;

--- #

use Dobriyan_MyBase;
set nocount on;

go
SELECT
	Groups.Number,
	Groups.Students_Count,
	Specialities.Speciality
FROM Groups
JOIN Specialities ON Groups.Speciality = Specialities.id
WHERE Specialities.Speciality = 'ДЭиВИ'
ORDER BY Groups.Number
for xml AUTO, root('ДЭиВИ_группы'), elements;

--- #

use Dobriyan_MyBase;
set nocount on;

go
declare @h int = 0,
    @x varchar(2000) =
		'<?xml version="1.0" encoding="windows-1251" ?>
		<specs> 
			<Specialities id="22" Speciality="new_spec1" />
			<Specialities id="23" Speciality="new_spec2" />
		</specs>';

exec sp_xml_preparedocument @h output, @x;
insert Specialities select id, Speciality
	from openxml(@h, '/specs/Specialities', 0)
	with(id int, Speciality nvarchar(20))
exec sp_xml_removedocument @h;