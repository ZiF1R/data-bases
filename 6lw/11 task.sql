use Dobriyan_MyBase;

-- #1
SELECT
	MIN(Groups.Students_Count) [Min_Capacity],
	MAX(Groups.Students_Count) [Max_Capacity],
	AVG(Groups.Students_Count) [Average_Capacity],
	SUM(Groups.Students_Count) [Total_Capacity],
	COUNT(*) [Groups_Count]
FROM Groups;

-- #2
SELECT
	Specialities.Speciality,
	MIN(Groups.Students_Count) [Min_Capacity],
	MAX(Groups.Students_Count) [Max_Capacity],
	AVG(Groups.Students_Count) [Average_Capacity],
	SUM(Groups.Students_Count) [Total_Capacity],
	COUNT(Groups.Speciality) [Groups_Count]
FROM Groups
JOIN Specialities ON Groups.Speciality = Specialities.id
GROUP BY Specialities.Speciality;

-- #3
SELECT *
FROM (
	SELECT 
		CASE
			when (Courses.Cost > 300) then '> 300'
			when (Courses.Cost BETWEEN 271 AND 300) then '271-300'
			when (Courses.Cost BETWEEN 250 AND 270) then '250-270'
			else '< 250'
		END [Courses_Cost],
		COUNT(*) [Count]
	FROM Courses
	GROUP BY
		CASE
			when (Courses.Cost > 300) then '> 300'
			when (Courses.Cost BETWEEN 271 AND 300) then '271-300'
			when (Courses.Cost BETWEEN 250 AND 270) then '250-270'
			else '< 250'
		END
) AS T
ORDER BY
	CASE [Courses_Cost]
		when '> 300' then 1
		when '271-300' then 2
		when '250-270' then 3
		else 0
	END;

-- #4
SELECT
	Specialities.Speciality,
	COUNT(Groups.Number) [Groups_Count],
	ROUND(AVG(CAST(Groups.Students_Count AS float(2))), 2) [Avg_Students_Count]
FROM Specialities
JOIN Groups ON Specialities.id= Groups.Speciality
GROUP BY Specialities.Speciality
ORDER BY [Avg_Students_Count] DESC;

SELECT
	Specialities.Speciality,
	COUNT(Groups.Number) [Groups_Count],
	ROUND(AVG(CAST(Groups.Students_Count AS float(2))), 2) [Avg_Students_Count]
FROM Specialities
JOIN Groups ON Specialities.id= Groups.Speciality
WHERE Specialities.Speciality IN ('œŒ»“', 'ƒ›Ë¬»')
GROUP BY Specialities.Speciality
ORDER BY [Avg_Students_Count] DESC;

-- #5
SELECT
	Specialities.Speciality,
	COUNT(Groups.Number) [Groups_Count],
	ROUND(AVG(CAST(Groups.Students_Count AS float(2))), 2) [Avg_Students_Count]
FROM Specialities
JOIN Groups ON Specialities.id= Groups.Speciality
WHERE Specialities.Speciality IN ('œŒ»“', 'ƒ›Ë¬»')
GROUP BY ROLLUP(Specialities.Speciality)
ORDER BY [Avg_Students_Count] DESC;

-- #6
SELECT
	Specialities.Speciality,
	COUNT(Groups.Number) [Groups_Count],
	ROUND(AVG(CAST(Groups.Students_Count AS float(2))), 2) [Avg_Students_Count]
FROM Specialities
JOIN Groups ON Specialities.id= Groups.Speciality
WHERE Specialities.Speciality IN ('œŒ»“', 'ƒ›Ë¬»')
GROUP BY CUBE(Specialities.Speciality)
ORDER BY [Avg_Students_Count] DESC;

-- #7
SELECT
	Specialities.Speciality,
	COUNT(Groups.Number) [Groups_Count],
	ROUND(AVG(CAST(Groups.Students_Count AS float(2))), 2) [Avg_Students_Count]
FROM Specialities
JOIN Groups ON Specialities.id= Groups.Speciality
WHERE Specialities.Speciality = 'œŒ»“'
GROUP BY CUBE(Specialities.Speciality)

UNION

SELECT
	Specialities.Speciality,
	COUNT(Groups.Number) [Groups_Count],
	ROUND(AVG(CAST(Groups.Students_Count AS float(2))), 2) [Avg_Students_Count]
FROM Specialities
JOIN Groups ON Specialities.id= Groups.Speciality
WHERE Specialities.Speciality = 'ƒ›Ë¬»'
GROUP BY CUBE(Specialities.Speciality)
ORDER BY [Avg_Students_Count] DESC;


-- UNION ALL

SELECT
	Specialities.Speciality,
	COUNT(Groups.Number) [Groups_Count],
	ROUND(AVG(CAST(Groups.Students_Count AS float(2))), 2) [Avg_Students_Count]
FROM Specialities
JOIN Groups ON Specialities.id= Groups.Speciality
WHERE Specialities.Speciality = 'œŒ»“'
GROUP BY CUBE(Specialities.Speciality)

UNION ALL

SELECT
	Specialities.Speciality,
	COUNT(Groups.Number) [Groups_Count],
	ROUND(AVG(CAST(Groups.Students_Count AS float(2))), 2) [Avg_Students_Count]
FROM Specialities
JOIN Groups ON Specialities.id= Groups.Speciality
WHERE Specialities.Speciality = 'ƒ›Ë¬»'
GROUP BY CUBE(Specialities.Speciality)
ORDER BY [Avg_Students_Count] DESC;

-- #8
SELECT
	Specialities.Speciality,
	COUNT(Groups.Number) [Groups_Count],
	ROUND(AVG(CAST(Groups.Students_Count AS float(2))), 2) [Avg_Students_Count]
FROM Specialities
JOIN Groups ON Specialities.id= Groups.Speciality
WHERE Specialities.Speciality = 'œŒ»“'
GROUP BY CUBE(Specialities.Speciality)

INTERSECT

SELECT
	Specialities.Speciality,
	COUNT(Groups.Number) [Groups_Count],
	ROUND(AVG(CAST(Groups.Students_Count AS float(2))), 2) [Avg_Students_Count]
FROM Specialities
JOIN Groups ON Specialities.id= Groups.Speciality
WHERE Specialities.Speciality = 'ƒ›Ë¬»'
GROUP BY CUBE(Specialities.Speciality)
ORDER BY [Avg_Students_Count] DESC;

-- #9
SELECT
	Specialities.Speciality,
	COUNT(Groups.Number) [Groups_Count],
	ROUND(AVG(CAST(Groups.Students_Count AS float(2))), 2) [Avg_Students_Count]
FROM Specialities
JOIN Groups ON Specialities.id= Groups.Speciality
WHERE Specialities.Speciality = 'œŒ»“'
GROUP BY CUBE(Specialities.Speciality)

INTERSECT

SELECT
	Specialities.Speciality,
	COUNT(Groups.Number) [Groups_Count],
	ROUND(AVG(CAST(Groups.Students_Count AS float(2))), 2) [Avg_Students_Count]
FROM Specialities
JOIN Groups ON Specialities.id= Groups.Speciality
WHERE Specialities.Speciality = 'ƒ›Ë¬»'
GROUP BY CUBE(Specialities.Speciality)

EXCEPT

SELECT
	Specialities.Speciality,
	COUNT(Groups.Number) [Groups_Count],
	ROUND(AVG(CAST(Groups.Students_Count AS float(2))), 2) [Avg_Students_Count]
FROM Specialities
JOIN Groups ON Specialities.id= Groups.Speciality
WHERE Specialities.Speciality = 'œŒ»“'
GROUP BY CUBE(Specialities.Speciality)
ORDER BY [Avg_Students_Count] DESC;

-- #10
SELECT DISTINCT
	Specialities.Speciality,
	(
		SELECT COUNT(*)
		FROM Groups b
		WHERE a.Speciality = b.Speciality
			AND b.Students_Count BETWEEN 15 AND 20
	) [Groups with 15-20 students]
FROM Groups a
JOIN Specialities ON a.Speciality = Specialities.id
GROUP BY a.Students_Count, a.Speciality, Specialities.Speciality
HAVING a.Students_Count BETWEEN 15 AND 20
ORDER BY [Groups with 15-20 students] DESC;