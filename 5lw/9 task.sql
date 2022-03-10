use Dobriyan_MyBase;

-- ¹1
SELECT Groups.Number, Specialities.Speciality
FROM Groups, Specialities
WHERE Specialities.id = Groups.Speciality AND
	Specialities.Speciality IN (
		SELECT Specialities.Speciality
		FROM Specialities
		WHERE (
			Specialities.Speciality LIKE '%ÏÎÈÒ%' OR
			Specialities.Speciality LIKE '%ÄÝèÂÈ%'
		)
	);

-- ¹2
SELECT Groups.Number, Specialities.Speciality
FROM Groups JOIN Specialities
ON Specialities.id = Groups.Speciality AND
	Specialities.Speciality IN (
		SELECT Specialities.Speciality
		FROM Specialities
		WHERE (
			Specialities.Speciality LIKE '%ÏÎÈÒ%' OR
			Specialities.Speciality LIKE '%ÄÝèÂÈ%'
		)
	);

-- ¹3
SELECT DISTINCT Groups.Number, Specialities.Speciality
FROM Groups
JOIN Specialities ON Specialities.id = Groups.Speciality
JOIN Teachers ON Teachers.Active_Group = Groups.Number AND
			Specialities.Speciality LIKE '%ÏÎÈÒ%' OR
			Specialities.Speciality LIKE '%ÄÝèÂÈ%';

-- ¹4
SELECT a.Number,
	a.Students_Count,
	Specialities.Speciality
FROM Groups AS a, Specialities
WHERE a.Number = (
		SELECT TOP(1) b.Number
		FROM Groups AS b
		WHERE b.Speciality = a.Speciality
		ORDER BY b.Students_Count DESC
	)
AND a.Speciality = Specialities.id
ORDER BY a.Students_Count DESC;

-- ¹5
SELECT Specialities.Speciality, Groups.Number
FROM Groups, Specialities
WHERE EXISTS (
	SELECT * FROM Specialities
	WHERE Specialities.id = Groups.Speciality
)
AND Groups.Speciality = Specialities.id;

-- ¹6
SELECT TOP(1)
	ISNULL((
		SELECT AVG(Groups.Students_Count) FROM Groups
		WHERE Groups.Speciality = '1'
	), 0) [ÏÎÈÒ],
	ISNULL((
		SELECT AVG(Groups.Students_Count) FROM Groups
		WHERE Groups.Speciality = '2'
	), 0) [ÄÝèÂÈ],
	ISNULL((
		SELECT AVG(Groups.Students_Count) FROM Groups
		WHERE Groups.Speciality = '3'
	), 0) [ÈÑÈÒ],
	ISNULL((
		SELECT AVG(Groups.Students_Count) FROM Groups
		WHERE Groups.Speciality = '4'
	), 0) [ÏÎÈÁÌÑ]
FROM Groups;

-- ¹7
SELECT Specialities.Speciality, Groups.Students_Count
FROM Groups, Specialities
WHERE Groups.Students_Count >= ALL (
	SELECT Groups.Students_Count
	FROM Groups
	WHERE Groups.Speciality = 2
)
AND Groups.Speciality = 2
AND Groups.Speciality = Specialities.id;

-- ¹8
SELECT Specialities.Speciality, Groups.Students_Count
FROM Groups, Specialities
WHERE Groups.Students_Count < ANY (
	SELECT Groups.Students_Count
	FROM Groups
	WHERE Groups.Speciality = 2
)
AND Groups.Speciality = 2
AND Groups.Speciality = Specialities.id;