SET GLOBAL local_infile = 1;
CREATE DATABASE IF NOT EXISTS new;
USE new;

-- create table

CREATE TABLE flight (
    DayOfWeek int,
    date VARCHAR(20),
    DepTime time,
    ArrTime time,
    CRSArrTime time,
    UniqueCarrier varchar(5),
    Airline varchar(100),
    FlightNum varchar(10),
    TailNum varchar(10),
    ActualElapsedTime int,
	CRSElapsedTime INT,
    AirTime int,
    ArrDelay int,
    DepDelay int,
    Origin varchar(5),
    Org_Airport varchar(100),
	Dest varchar(5),
    Dest_Airport varchar(100),
    Distance int,
    Taxiln int,
    TaxiOut int,
    Cancelled int,
    CancellationCode varchar(1),
	Diverted int,
    CarrierDelay int,
    WeatherDelay int,
    NASDelay int,
    SecurityDelay int,
    LateAircraftDelay int
);
-- insert data into the table
LOAD DATA LOCAL INFILE 'E:\\desktop\\projecr\\Flight Delay My sql.csv'
INTO TABLE flight
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;
select * from flight;


-- تعديل صيغة التاريخ


SET SQL_SAFE_UPDATES = 0;
UPDATE flight 
SET date = STR_TO_DATE(date, '%m/%d/%Y');
SET SQL_SAFE_UPDATES = 1;
SELECT DISTINCT date
FROM flight
WHERE STR_TO_DATE(date, '%m/%d/%Y') IS NULL;
UPDATE flight
SET date = STR_TO_DATE(date, '%m/%d/%Y')
WHERE date REGEXP '^[0-9]{1,2}/[0-9]{1,2}/[0-9]{4}$';
SELECT date
FROM flight
WHERE date IS NOT NULL 
  AND date NOT REGEXP '^[0-9]{4}-[0-9]{2}-[0-9]{2}$';
  SELECT *
FROM flight
WHERE STR_TO_DATE(date, '%m/%d/%Y') IS NULL
  AND date IS NOT NULL;
  ALTER TABLE flight 
MODIFY COLUMN date DATE;
SELECT *
FROM flight
LIMIT 260575, 1;
DELETE FROM flight
WHERE DayOfWeek = 0 or date = '6';
SELECT *
FROM flight
WHERE date NOT REGEXP '^[0-9]{1,2}/[0-9]{1,2}/[0-9]{4}$';
DELETE FROM flight
WHERE date IS NULL;

-- Finding null values 

SELECT *
FROM flight
WHERE DayOfWeek IS NULL
   OR date IS NULL
   OR DepTime IS NULL
   OR ArrTime IS NULL
   OR CRSArrTime IS NULL
   OR UniqueCarrier IS NULL
   OR Airline IS NULL
   OR FlightNum IS NULL
   OR TailNum IS NULL
   OR ActualElapsedTime IS NULL
   OR CRSElapsedTime IS NULL
   OR AirTime IS NULL
   OR ArrDelay IS NULL
   OR DepDelay IS NULL
   OR Origin IS NULL
   OR Org_Airport IS NULL
   OR Dest IS NULL
   OR Dest_Airport IS NULL
   OR Distance IS NULL
   OR Taxiln IS NULL
   OR TaxiOut IS NULL
   OR Cancelled IS NULL
   OR CancellationCode IS NULL
   OR Diverted IS NULL
   OR CarrierDelay IS NULL
   OR WeatherDelay IS NULL
   OR NASDelay IS NULL
   OR SecurityDelay IS NULL
   OR LateAircraftDelay IS NULL;
   
-- Finding outlier
 
CREATE TABLE IF NOT EXISTS OutlierSummary (
    id INT AUTO_INCREMENT PRIMARY KEY,
    ColumnName VARCHAR(50),
    Q1 DOUBLE,
    Q3 DOUBLE,
    IQR DOUBLE,
    LowerBound DOUBLE,
    UpperBound DOUBLE,
    OutlierCount INT,
    CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

DELIMITER $$

CREATE PROCEDURE FindOutliers(IN col_name VARCHAR(50))
BEGIN
    SET @sql = CONCAT(
        'WITH ranked AS (',
        '  SELECT ', col_name, ', PERCENT_RANK() OVER (ORDER BY ', col_name, ') AS pr ',
        '  FROM flight ',
        '  WHERE ', col_name, ' IS NOT NULL',
        '), quartiles AS (',
        '  SELECT ',
        '    MAX(CASE WHEN pr <= 0.25 THEN ', col_name, ' END) AS q1,',
        '    MAX(CASE WHEN pr <= 0.75 THEN ', col_name, ' END) AS q3 ',
        '  FROM ranked',
        '), bounds AS (',
        '  SELECT ',
        '    q1, q3, (q3 - q1) AS iqr, ',
        '    (q1 - 1.5*(q3 - q1)) AS lower_bound, ',
        '    (q3 + 1.5*(q3 - q1)) AS upper_bound ',
        '  FROM quartiles',
        ') ',
        'SELECT f.* ',
        'FROM flight f JOIN bounds b ',
        'ON f.', col_name, ' IS NOT NULL ',
        'WHERE f.', col_name, ' < b.lower_bound OR f.', col_name, ' > b.upper_bound;'
    );

    PREPARE stmt FROM @sql;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;

    SET @insert_sql = CONCAT(
        'INSERT INTO OutlierSummary (ColumnName, Q1, Q3, IQR, LowerBound, UpperBound, OutlierCount) ',
        'WITH ranked AS (',
        '  SELECT ', col_name, ', PERCENT_RANK() OVER (ORDER BY ', col_name, ') AS pr ',
        '  FROM flight ',
        '  WHERE ', col_name, ' IS NOT NULL',
        '), quartiles AS (',
        '  SELECT ',
        '    MAX(CASE WHEN pr <= 0.25 THEN ', col_name, ' END) AS q1,',
        '    MAX(CASE WHEN pr <= 0.75 THEN ', col_name, ' END) AS q3 ',
        '  FROM ranked',
        '), bounds AS (',
        '  SELECT ',
        '    q1, q3, (q3 - q1) AS iqr, ',
        '    (q1 - 1.5*(q3 - q1)) AS lower_bound, ',
        '    (q3 + 1.5*(q3 - q1)) AS upper_bound ',
        '  FROM quartiles',
        '), counts AS (',
        '  SELECT COUNT(*) AS outliers ',
        '  FROM flight f JOIN bounds b ',
        '  ON f.', col_name, ' IS NOT NULL ',
        '  WHERE f.', col_name, ' < b.lower_bound OR f.', col_name, ' > b.upper_bound',
        ') ',
        'SELECT ''', col_name, ''', q1, q3, iqr, lower_bound, upper_bound, outliers ',
        'FROM bounds, counts;'
    );

    PREPARE insert_stmt FROM @insert_sql;
    EXECUTE insert_stmt;
    DEALLOCATE PREPARE insert_stmt;
END$$

DELIMITER ;

CALL FindOutliers('ActualElapsedTime');
CALL FindOutliers('CRSElapsedTime');
CALL FindOutliers('AirTime');
CALL FindOutliers('ArrDelay');
CALL FindOutliers('DepDelay');
CALL FindOutliers('Distance');
CALL FindOutliers('Taxiln');
CALL FindOutliers('TaxiOut');
CALL FindOutliers('CarrierDelay');
CALL FindOutliers('WeatherDelay');
CALL FindOutliers('NASDelay');
CALL FindOutliers('SecurityDelay');
CALL FindOutliers('LateAircraftDelay');

SELECT ColumnName, Q1, Q3, LowerBound, UpperBound, OutlierCount, CreatedAt
FROM OutlierSummary
ORDER BY CreatedAt DESC;



-- Creating dimension tables


-- Dimension: Date

CREATE TABLE DimDate (
    DateKey INT PRIMARY KEY,       -- YYYYMMDD
    FullDate DATE,
    DayOfWeek INT,
    DayName VARCHAR(20),
    DayOfMonth INT,
    WeekOfYear INT,
    Month INT,
    MonthName VARCHAR(20),
    Quarter INT,
    Year INT
);


-- Dimension: Airline
CREATE TABLE DimAirline (
    AirlineKey INT AUTO_INCREMENT PRIMARY KEY,
    UniqueCarrier VARCHAR(10),
    AirlineName VARCHAR(200)
);

-- Dimension: Airport
CREATE TABLE DimAirport (
    AirportKey INT AUTO_INCREMENT PRIMARY KEY,
    AirportCode VARCHAR(10),
    AirportName VARCHAR(200)
);

-- Dimension: Plane
CREATE TABLE DimPlane (
    PlaneKey INT AUTO_INCREMENT PRIMARY KEY,
    TailNum VARCHAR(20)
);

-- insert data into dims with duplicate deleted 
-- DimDate
INSERT INTO DimDate
(DateKey, FullDate, DayOfWeek, DayName, DayOfMonth, WeekOfYear, Month, MonthName, Quarter, Year)
SELECT 
    DATE_FORMAT(date, '%Y%m%d') AS DateKey,
    MIN(date) AS FullDate,
    MIN(DayOfWeek) AS DayOfWeek,
    MIN(DAYNAME(date)) AS DayName,
    MIN(DAY(date)) AS DayOfMonth,
    MIN(WEEK(date, 1)) AS WeekOfYear,     -- mode 1 = ISO weeks
    MIN(MONTH(date)) AS Month,
    MIN(MONTHNAME(date)) AS MonthName,
    MIN(QUARTER(date)) AS Quarter,
    MIN(YEAR(date)) AS Year
FROM flight
GROUP BY DATE_FORMAT(date, '%Y%m%d');
select * from DimDate;
SELECT *
FROM DimDate
WHERE DayOfWeek IS NULL
   OR FullDate IS NULL;
DELETE FROM DimDate
WHERE FullDate IS NULL
or DayOfWeek IS NULL;

-- DimAirline
INSERT INTO DimAirline (UniqueCarrier, AirlineName)
SELECT DISTINCT UniqueCarrier, Airline
FROM flight;
select * from DimAirline;


-- DimAirport (Origin + Destination في جدول واحد)
INSERT INTO DimAirport (AirportCode, AirportName)
SELECT DISTINCT Origin, Org_Airport FROM flight
UNION
SELECT DISTINCT Dest, Dest_Airport FROM flight;
select * from DimAirport;

-- DimPlane
INSERT INTO DimPlane (TailNum)
SELECT DISTINCT TailNum
FROM flight
WHERE TailNum IS NOT NULL;
select * from DimPlane;



CREATE TABLE FactFlights (
    FactID INT AUTO_INCREMENT PRIMARY KEY,
    DateKey INT,
    AirlineKey INT,
    OriginAirportKey INT,
    DestAirportKey INT,
    PlaneKey INT,
    FlightNum INT,
    DepTime TIME,
    ArrTime TIME,
    CRSArrTime TIME,
    ActualElapsedTime INT,
    CRSElapsedTime INT,
    AirTime INT,
    ArrDelay INT,
    DepDelay INT,
    Distance INT,
    TaxiIn INT,
    TaxiOut INT,
    Cancelled TINYINT,
    CancellationCode VARCHAR(5),
    Diverted TINYINT,
    CarrierDelay INT,
    WeatherDelay INT,
    NASDelay INT,
    SecurityDelay INT,
    LateAircraftDelay INT,
    FOREIGN KEY (DateKey) REFERENCES DimDate(DateKey),
    FOREIGN KEY (AirlineKey) REFERENCES DimAirline(AirlineKey),
    FOREIGN KEY (OriginAirportKey) REFERENCES DimAirport(AirportKey),
    FOREIGN KEY (DestAirportKey) REFERENCES DimAirport(AirportKey),
    FOREIGN KEY (PlaneKey) REFERENCES DimPlane(PlaneKey)
);

INSERT INTO FactFlights
(DateKey, AirlineKey, OriginAirportKey, DestAirportKey, PlaneKey,
 FlightNum, DepTime, ArrTime, CRSArrTime,
 ActualElapsedTime, CRSElapsedTime, AirTime,
 ArrDelay, DepDelay, Distance, TaxiIn, TaxiOut,
 Cancelled, CancellationCode, Diverted,
 CarrierDelay, WeatherDelay, NASDelay, SecurityDelay, LateAircraftDelay)
SELECT 
    DATE_FORMAT(f.date, '%Y%m%d') AS DateKey,
    a.AirlineKey,
    o.AirportKey AS OriginAirportKey,
    d.AirportKey AS DestAirportKey,
    p.PlaneKey,
    f.FlightNum,
    f.DepTime,
    f.ArrTime,
    f.CRSArrTime,
    f.ActualElapsedTime,
    f.CRSElapsedTime,
    f.AirTime,
    f.ArrDelay,
    f.DepDelay,
    f.Distance,
    f.Taxiln,
    f.TaxiOut,
    f.Cancelled,
    f.CancellationCode,
    f.Diverted,
    f.CarrierDelay,
    f.WeatherDelay,
    f.NASDelay,
    f.SecurityDelay,
    f.LateAircraftDelay
FROM flight f
JOIN DimAirline a ON f.UniqueCarrier = a.UniqueCarrier
JOIN DimAirport o ON f.Origin = o.AirportCode
JOIN DimAirport d ON f.Dest   = d.AirportCode
LEFT JOIN DimPlane   p ON f.TailNum = p.TailNum;

select * from FactFlights;