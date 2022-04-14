-- #1
use UNIVER;
set nocount on;

go
SELECT * from TEACHER
where PULPIT = '����'
FOR xml PATH('TEACHER'), root('�������������_����'), elements;

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
WHERE AUDITORIUM.AUDITORIUM_TYPE like '��%'
for xml AUTO, root('����������_���������'), elements;

-- #3
use UNIVER;
set nocount on;

go
declare @h int = 0,
    @x varchar(2000) =
		'<?xml version="1.0" encoding="windows-1251" ?>
		<SUBJECTS> 
			<SUBJECT_T SUBJECT_T="new_subj1" SUBJECT_NAME="new_subj1" PULPIT="����" />
			<SUBJECT_T SUBJECT_T="new_subj2" SUBJECT_NAME="new_subj2" PULPIT="����" />
			<SUBJECT_T SUBJECT_T="new_subj3" SUBJECT_NAME="new_subj3" PULPIT="����" />
		</SUBJECTS>';

exec sp_xml_preparedocument @h output, @x;
insert SUBJECT_T select [SUBJECT_T], [SUBJECT_NAME], [PULPIT]
	from openxml(@h, '/SUBJECTS/SUBJECT_T', 0)
	with([SUBJECT_T] nvarchar(10), [SUBJECT_NAME] nvarchar(100), [PULPIT] nvarchar(20))
exec sp_xml_removedocument @h;

-- #4
use UNIVER
INSERT INTO STUDENT(IDGROUP, NAME, BDAY, INFO) values
	(2, '������� ��������� ����������', '1970-01-01', 
		'<�������>
			<�����>1</�����>
			<�����>123456</�����>
			<����_������>1980-01-01</����_������>
			<�����>��������, �. �����, ��������� 13�</�����>
		</�������>');

select * from STUDENT where NAME = '������� ��������� ����������';

update STUDENT set INFO =
		'<�������>
			<�����>2</�����>
			<�����>654321</�����>
			<����_������>1981-01-01</����_������>
			<�����>��������, �. �����, ��������� 13�</�����>
		</�������>'
where STUDENT.INFO.value('(/�������/�����)[1]','int') = 1;

select * from STUDENT where NAME = '������� ��������� ����������';

select NAME, 
	INFO.value('(/�������/����_������)[1]', 'date') [����_������],
	INFO.value('(/�������/�����)[1]', 'varchar(100)') [�����],
	INFO.query('/�������') [�������]
from  STUDENT where NAME = '������� ��������� ����������';

-- #5
use UNIVER;
create xml schema collection Student_info as 
N'<?xml version="1.0" encoding="utf-16" ?>
<xs:schema attributeFormDefault="unqualified" 
           elementFormDefault="qualified"
           xmlns:xs="http://www.w3.org/2001/XMLSchema">
       <xs:element name="�������">  
       <xs:complexType><xs:sequence>
       <xs:element name="�������" maxOccurs="1" minOccurs="1">
       <xs:complexType>
       <xs:attribute name="�����" type="xs:string" use="required" />
       <xs:attribute name="�����" type="xs:unsignedInt" use="required"/>
       <xs:attribute name="����"  use="required" >  
       <xs:simpleType>  <xs:restriction base ="xs:string">
   <xs:pattern value="[0-9]{2}.[0-9]{2}.[0-9]{4}"/>
   </xs:restriction> 	</xs:simpleType>
   </xs:attribute> </xs:complexType> 
   </xs:element>
   <xs:element maxOccurs="3" name="�������" type="xs:unsignedInt"/>
   <xs:element name="�����">   <xs:complexType><xs:sequence>
   <xs:element name="������" type="xs:string" />
   <xs:element name="�����" type="xs:string" />
   <xs:element name="�����" type="xs:string" />
   <xs:element name="���" type="xs:string" />
   <xs:element name="��������" type="xs:string" />
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
where Courses.Lessons_Type = '���������'
FOR xml PATH('Courses'), root('�����_�_����������'), elements;

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
WHERE Specialities.Speciality = '�����'
ORDER BY Groups.Number
for xml AUTO, root('�����_������'), elements;

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