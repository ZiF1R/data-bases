use UNIVER;

SELECT FACULTY.FACULTY, PULPIT.PULPIT, PROFESSION.PROFESSION_NAME, SUBJECT_T.SUBJECT_NAME, STUDENT.NAME,
CASE
	when(PROGRESS.NOTE = 6) then '�����'
	when(PROGRESS.NOTE = 7) then '����'
	when(PROGRESS.NOTE = 8) then '������'
END [NOTE]
FROM STUDENT inner Join PROGRESS ON STUDENT.IDSTUDENT = PROGRESS.IDSTUDENT 
inner join SUBJECT_T ON PROGRESS.SUBJECT_T = SUBJECT_T.SUBJECT_T and (PROGRESS.NOTE between 6 and 8)
inner join GROUPS ON STUDENT.IDGROUP = GROUPS.IDGROUP
inner join PULPIT ON SUBJECT_T.PULPIT = PULPIT.PULPIT
inner join PROFESSION ON PROFESSION.PROFESSION = GROUPS.PROFESSION
inner join FACULTY ON GROUPS.FACULTY = FACULTY.FACULTY
ORDER BY FACULTY.FACULTY, PULPIT.PULPIT, PROFESSION.PROFESSION, STUDENT.NAME ASC,
(CASE
	when(PROGRESS.NOTE = 7) then 1
	when(PROGRESS.NOTE = 8) then 2
	when(PROGRESS.NOTE = 6) then 3
END);