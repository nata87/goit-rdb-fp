------------------------------------------- p1 -------------------------------------------------

CREATE SCHEMA IF NOT EXISTS pandemic;

USE pandemic;

-------------------------------------------- p2 ------------------------------------------------

USE pandemic;

CREATE TABLE countries(
id INT PRIMARY KEY AUTO_INCREMENT,
code VARCHAR(50) UNIQUE,
country VARCHAR(50) NOT NULL UNIQUE
);

INSERT INTO countries (code, country)
SELECT DISTINCT code, entity FROM infectious_cases;

CREATE TABLE infectious_cases_normalized 
AS SELECT * FROM infectious_cases;

ALTER TABLE infectious_cases_normalized
ADD id INT PRIMARY KEY AUTO_INCREMENT FIRST,
ADD country_id INT AFTER id,
ADD CONSTRAINT fk_country_id FOREIGN KEY (country_id) REFERENCES countries(id);

UPDATE infectious_cases_normalized icn, countries c  
SET icn.country_id = c.id WHERE c.code = icn.code;

ALTER TABLE infectious_cases_normalized
DROP COLUMN entity,
DROP COLUMN code;

------------------------------------------ p3 --------------------------------------------------

USE pandemic;

SELECT id, MAX(number_rabies) AS max_value, MIN(number_rabies) AS min_value, 
AVG(number_rabies) AS average_value FROM infectious_cases_normalized
WHERE number_rabies IS NOT NULL AND number_rabies <> ''
GROUP BY id
ORDER BY average_value DESC
LIMIT 10;

------------------------------------------- p4 -------------------------------------------------

USE pandemic;

ALTER TABLE infectious_cases_normalized 
ADD COLUMN start_date DATE NULL AFTER year,
ADD COLUMN cur_date DATE NULL AFTER start_date,
ADD COLUMN subtract_year INT NULL AFTER cur_date;

DROP FUNCTION IF EXISTS fn_start_date;

DELIMITER //

CREATE FUNCTION fn_start_date(year INT)
RETURNS DATE
DETERMINISTIC 
NO SQL
BEGIN
    DECLARE result DATE;
    SET result = MAKEDATE(year, 1);
    RETURN result;
END //

DELIMITER ;

DROP FUNCTION IF EXISTS fn_cur_date;

DELIMITER //

CREATE FUNCTION fn_cur_date()
RETURNS DATE
DETERMINISTIC 
NO SQL
BEGIN
    DECLARE result DATE;
    SET result = CURDATE();
    RETURN result;
END //

DELIMITER ;

DROP FUNCTION IF EXISTS fn_subtract_year;

DELIMITER //

CREATE FUNCTION fn_subtract_year(cur_date DATE, start_date DATE)
RETURNS INT
DETERMINISTIC 
NO SQL
BEGIN
    DECLARE result INT;
    SET result = YEAR(cur_date) - YEAR(start_date);
    RETURN result;
END //

DELIMITER ;

UPDATE infectious_cases_normalized
SET cur_date = fn_cur_date(),
start_date = fn_start_date(year),
subtract_year = fn_subtract_year(cur_date, start_date);

--------------------------------------------- p4_result -----------------------------------------------

SELECT * FROM infectious_cases_normalized;

--------------------------------------------- p5 ------------------------------------------------

DROP FUNCTION IF EXISTS fn_subtract_now_year;

DELIMITER //

CREATE FUNCTION fn_subtract_now_year(year INT)
RETURNS INT
DETERMINISTIC 
NO SQL
BEGIN
    DECLARE result INT;
    SET result = YEAR(CURDATE()) - year;
    RETURN result;
END //

DELIMITER ;

SELECT fn_subtract_now_year(2000);

