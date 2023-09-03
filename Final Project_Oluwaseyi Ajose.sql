# Project Work
# Create a database called entertainment 
# With 5 tables - Categories, Media, Countries, Cast, Appearances
# Data from Kaggle and myself

CREATE DATABASE entertainment;

CREATE TABLE Categories(
Category_ID INT PRIMARY KEY,
Category VARCHAR(25)
);

CREATE TABLE Media(
Media_ID INT PRIMARY KEY,
Media VARCHAR(50),
Media_Type CHAR(10),
Release_Year INT,
Category_ID INT
);

CREATE TABLE Countries(
Country_ID INT PRIMARY KEY,
Country VARCHAR(25)
);

ALTER TABLE Media
ADD CONSTRAINT fk_media
FOREIGN KEY (Category_ID)
REFERENCES Categories(Category_ID);

CREATE TABLE Cast (
Cast_ID INT PRIMARY KEY,
Cast_Name VARCHAR(50),
Country_ID INT,
DOB DATE,
Net_Worth_Million DECIMAL(5,2),
CONSTRAINT fk_country
FOREIGN KEY (Country_ID)
REFERENCES Countries(Country_ID)
	ON UPDATE CASCADE
    ON DELETE CASCADE
);

CREATE TABLE Appearances (
Appearance_ID INT PRIMARY KEY,
Cast_Name VARCHAR(50),
Cast_ID INT,
Media_ID INT,
Earning_Per_Appearance DECIMAL(5,2)
);

ALTER TABLE Appearances
ADD CONSTRAINT fk_cast
FOREIGN KEY (Cast_ID)
REFERENCES Cast (Cast_ID);

ALTER TABLE Appearances
ADD CONSTRAINT fk_media_id
FOREIGN KEY (Media_ID)
REFERENCES Media (Media_ID);

ALTER TABLE Appearances
ADD COLUMN Number_of_appearances INT;

TRUNCATE TABLE Appearances;
SELECT * FROM Appearances;

USE entertainment;

# Note that date format should be YYYY-MM-DD

INSERT INTO Cast 
	(Cast_ID, Cast_Name, Country_ID, DOB, Net_Worth_Million)
VALUES
	(2345, 'Julia Roberts', 345, '1967/10/22', 255.23),
    (2346, 'Emily Blunt', 346, '1983/02/23', 80.12),
    (2347, 'Dwayne Johnson', 345, '1972/05/02', 800.03),
    (2348, 'Denzel Washington', 345, '1954/12/28', 280.15),
    (2349, 'Gary Oldman', 346, '1958/03/21', 49.89),
    (2350, 'Nicole Kidman', 345, '1967/06/20', 249.87),
    (2351, 'Ryan Renolds', 347, '1976/10/23', 350.06),
    (2352, 'Simon Baker', 348, '1969/07/30', 40.28),
    (2353, 'Reese Witherspoon', 345, '1976/03/22', 440.33),
    (2354, 'Steve Martin', 345, '1945/08/14', 150.41),
    (2355, 'Courtney Cox', 345, '1964/06/15', 160.41),
    (2356, 'Cara Delevinge', 346, '1992/08/12', 55.04),
    (2357, 'Hugh Laurie', 346, '1959/06/11', 45.22),
    (2358, 'Meryl Streep', 345, '1949/06/22', 160.44);

UPDATE CAST
SET Country_ID = 348
WHERE Cast_Name = 'Nicole Kidman';



USE entertainment;

/* Joins + WHERE - cast_names, earning of actors that appeared in RomCom movies after 2000 */

SELECT a.Cast_Name, a.Earning_Per_Appearance
FROM Appearances a
INNER JOIN Media m ON a.Media_ID = m.Media_ID
INNER JOIN Categories c ON m.Category_ID = c.Category_ID
WHERE c.Category = 'Romantic Comedy' 
AND m.Release_Year > 2000;

/* Joins + Group By - cast_name and average earning for their appearances */

SELECT a.Cast_Name, ROUND(AVG(a.Earning_Per_Appearance), 2) AS Average_Earning
FROM Appearances a
JOIN Media m ON a.Media_ID = m.Media_ID
JOIN Categories c ON m.Category_ID = c.Category_ID
GROUP BY a.Cast_Name;

SELECT a.Cast_Name, ROUND(AVG(a.Earning_Per_Appearance), 2) AS Average_Earning, c.Category
FROM Appearances a
JOIN Media m ON a.Media_ID = m.Media_ID
JOIN Categories c ON m.Category_ID = c.Category_ID
GROUP BY a.Cast_Name, c.Category;

/*View + Joins - create a view of the media, media type, release year & cast name 
in which US actors appeared more than 13 times */

CREATE VIEW cast_appearances AS
SELECT m.Media, m.Media_Type, m.Release_Year, ca.Cast_Name
FROM Media m
INNER JOIN Appearances a ON m.Media_ID = a.Media_ID
INNER JOIN Cast ca ON a.Cast_ID = ca.Cast_ID
INNER JOIN Countries c ON ca.Country_ID = c.Country_ID
WHERE c.Country_ID = 345
AND ca.cast_name LIKE '%e%'
AND a.Number_of_appearances > 13;

/* to view the new view */

SELECT * FROM cast_appearances;


/* Group By + Having - Which category types are the most popular by highest count */

USE entertainment;
SELECT COUNT(m.Category_ID) AS Popular_Category, m.Category_ID, c.Category
FROM Media m
JOIN Categories c ON m.Category_ID = c.Category_ID
GROUP BY Category_ID
HAVING Popular_Category > 3;


/* Subquery - Show the cast names that have a net worth of 250 to 500 million */

USE entertainment;

SELECT DISTINCT Cast_ID, Cast_Name
FROM Appearances
WHERE Cast_ID IN (
	SELECT Cast_ID 
    FROM Cast
    WHERE Net_Worth_Million BETWEEN 250 AND 500);
    
    
/* Stored Function - a code that finds actors born after 1983 
but not younger than 10yrs to cast in the alternate role
And actors born before 1983 to cast in the current reality role  */

DELIMITER //
CREATE FUNCTION is_type_cast(DOB DATE)
RETURNS VARCHAR(25)
DETERMINISTIC
BEGIN
	DECLARE type_cast VARCHAR(25);
    IF (DOB >= '1983-01-01' AND DOB <= '2013-01-01') THEN SET type_cast = 'alternate role';
    ELSEIF DOB < '1983-01-01' THEN SET type_cast = 'current reality';
    END IF;
    RETURN (type_cast);
END//
DELIMITER ;

USE entertainment;

SELECT Cast_Name, DOB, Net_Worth_Million, is_type_cast(DOB) AS 'New Casting'
FROM Cast;

/* Stored Procedure - write a code that inserts new rows into the Cast table */

DELIMITER //
CREATE PROCEDURE insertNewCast
	(IN Cast_ID_New INT, IN Cast_Name_New VARCHAR(50), IN Country_ID_New INT, IN DOB_New DATE, IN Net_Worth_Million_New DECIMAL(5,2))
BEGIN
	INSERT INTO Cast
		(Cast_ID, Cast_Name, Country_ID, DOB, Net_Worth_Million)
	VALUES
		(Cast_ID_New, Cast_Name_New, Country_ID_New, DOB_New, Net_Worth_Million_New);
END//
DELIMITER ;

USE entertainment;
CALL insertNewCast (2359, 'James Tupper', 347, '1965-08-04', 25.76);
CALL insertNewCast (2360, 'Douglas Smith', 347, '1987-01-01', 22.51);


CALL insertNewCast (2361, 'Sarita Choudhury', 346, '1966-08-18', 19.99);
CALL insertNewCast (2362, 'Melanie Nicholls-King', 347, '1978-04-01', 15.23);