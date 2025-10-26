-- Delay type analysis

-- percentage of each delay type

SELECT 
    'Carrier Delay' AS DelayType,
    CONCAT(ROUND(SUM(CarrierDelay) / SUM(ArrDelay) * 100, 2), '%') AS ImpactPercent
FROM factflights
UNION ALL
SELECT 
    'Weather Delay',
    CONCAT(ROUND(SUM(WeatherDelay) / SUM(ArrDelay) * 100, 2), '%')
FROM factflights
UNION ALL
SELECT 
    'NAS Delay',
    CONCAT(ROUND(SUM(NASDelay) / SUM(ArrDelay) * 100, 2), '%')
FROM factflights
UNION ALL
SELECT 
    'Security Delay',
    CONCAT(ROUND(SUM(SecurityDelay) / SUM(ArrDelay) * 100, 2), '%')
FROM factflights
UNION ALL
SELECT 
    'Late Aircraft Delay',
    CONCAT(ROUND(SUM(LateAircraftDelay) / SUM(ArrDelay) * 100, 2), '%')
FROM factflights;

-- General analysis for types

SELECT 
    CASE 
        WHEN CarrierDelay = GREATEST(CarrierDelay, WeatherDelay, NASDelay, SecurityDelay, LateAircraftDelay) THEN 'Carrier issue'
        WHEN WeatherDelay = GREATEST(CarrierDelay, WeatherDelay, NASDelay, SecurityDelay, LateAircraftDelay) THEN 'Weather issue'
        WHEN NASDelay = GREATEST(CarrierDelay, WeatherDelay, NASDelay, SecurityDelay, LateAircraftDelay) THEN 'NAS issue'
        WHEN SecurityDelay = GREATEST(CarrierDelay, WeatherDelay, NASDelay, SecurityDelay, LateAircraftDelay) THEN 'Security issue'
        WHEN LateAircraftDelay = GREATEST(CarrierDelay, WeatherDelay, NASDelay, SecurityDelay, LateAircraftDelay) THEN 'Late Aircraft issue'
        ELSE 'Unknown'
    END AS DominantDelayReason,
    COUNT(*) AS TotalFlights,
    ROUND(AVG(f.ArrDelay), 2) AS AvgDelay,
    MAX(f.ArrDelay) AS MaxDelay
FROM factflights f
WHERE f.ArrDelay > 0
GROUP BY DominantDelayReason
ORDER BY AvgDelay DESC;


-- Dominant Delay Reason


SELECT 
    a.AirlineName,
    CASE 
        WHEN CarrierDelay = GREATEST(CarrierDelay, WeatherDelay, NASDelay, SecurityDelay, LateAircraftDelay) THEN 'Carrier issue'
        WHEN WeatherDelay = GREATEST(CarrierDelay, WeatherDelay, NASDelay, SecurityDelay, LateAircraftDelay) THEN 'Weather issue'
        WHEN NASDelay = GREATEST(CarrierDelay, WeatherDelay, NASDelay, SecurityDelay, LateAircraftDelay) THEN 'NAS issue'
        WHEN SecurityDelay = GREATEST(CarrierDelay, WeatherDelay, NASDelay, SecurityDelay, LateAircraftDelay) THEN 'Security issue'
        WHEN LateAircraftDelay = GREATEST(CarrierDelay, WeatherDelay, NASDelay, SecurityDelay, LateAircraftDelay) THEN 'Late Aircraft issue'
    END AS DominantDelayReason,
    COUNT(*) AS FlightsAffected,
    ROUND(AVG(f.ArrDelay), 2) AS AvgDelay
FROM factflights f
JOIN DimAirline a ON f.AirlineKey = a.AirlineKey
WHERE f.ArrDelay > 0
GROUP BY a.AirlineName, DominantDelayReason
ORDER BY FlightsAffected DESC;


-- each type over months

-- 1/carrier delay

SELECT 
    d.Year,
    d.Month,
    d.MonthName,
    CONCAT(ROUND(AVG(f.CarrierDelay), 1), ' minutes') AS AvgCarrierDelay,
    CONCAT(ROUND(SUM(CASE WHEN f.CarrierDelay > 60 THEN 1 ELSE 0 END) / COUNT(*) * 100, 2), '%') AS Over1hRate
FROM factflights f
JOIN DimDate d ON f.DateKey = d.DateKey
WHERE f.CarrierDelay > 0
GROUP BY d.Year, d.Month, d.MonthName
ORDER BY d.Year, d.Month;

-- 2/ Weather delay

SELECT 
    d.Year,
    d.Month,
    d.MonthName,
    CONCAT(ROUND(AVG(f.WeatherDelay), 1), ' minutes') AS AvgWeatherDelay,
    CONCAT(ROUND(SUM(CASE WHEN f.WeatherDelay > 60 THEN 1 ELSE 0 END) / COUNT(*) * 100, 2), '%') AS Over1hRate
FROM factflights f
JOIN DimDate d ON f.DateKey = d.DateKey
WHERE f.WeatherDelay > 0
GROUP BY d.Year, d.Month, d.MonthName
ORDER BY d.Year, d.Month;

-- 3/ NAS delay 

SELECT 
    d.Year,
    d.Month,
    d.MonthName,
    CONCAT(ROUND(AVG(f.NASDelay), 1), ' minutes') AS AvgNASDelay,
    CONCAT(ROUND(SUM(CASE WHEN f.NASDelay > 60 THEN 1 ELSE 0 END) / COUNT(*) * 100, 2), '%') AS Over1hRate
FROM factflights f
JOIN DimDate d ON f.DateKey = d.DateKey
WHERE f.NASDelay > 0
GROUP BY d.Year, d.Month, d.MonthName
ORDER BY d.Year, d.Month;

-- 4/ Security delay

SELECT 
    d.Year,
    d.Month,
    d.MonthName,
    CONCAT(ROUND(AVG(f.SecurityDelay), 1), ' minutes') AS AvgSecurityDelay,
    CONCAT(ROUND(SUM(CASE WHEN f.SecurityDelay > 60 THEN 1 ELSE 0 END) / COUNT(*) * 100, 2), '%') AS Over1hRate
FROM factflights f
JOIN DimDate d ON f.DateKey = d.DateKey
WHERE f.SecurityDelay > 0
GROUP BY d.Year, d.Month, d.MonthName
ORDER BY d.Year, d.Month;

-- 5/ Lateaircraft delay


SELECT 
    d.Year,
    d.Month,
    d.MonthName,
    CONCAT(ROUND(AVG(f.LateAircraftDelay), 1), ' minutes') AS AvgLateAircraftDelay,
    CONCAT(ROUND(SUM(CASE WHEN f.LateAircraftDelay > 60 THEN 1 ELSE 0 END) / COUNT(*) * 100, 2), '%') AS Over1hRate
FROM factflights f
JOIN DimDate d ON f.DateKey = d.DateKey
WHERE f.LateAircraftDelay > 0
GROUP BY d.Year, d.Month, d.MonthName
ORDER BY d.Year, d.Month;



-- AVG delay by type for each month


SELECT     
    d.Year,     
    d.Month,
    d.MonthName,     
    ROUND(AVG(f.CarrierDelay),1) AS AvgCarrierDelay,     
    ROUND(AVG(f.WeatherDelay),1) AS AvgWeatherDelay,     
    ROUND(AVG(f.NASDelay),1) AS AvgNASDelay,     
    ROUND(AVG(f.SecurityDelay),1) AS AvgSecurityDelay,     
    ROUND(AVG(f.LateAircraftDelay),1) AS AvgLateAircraftDelay 
FROM factflights f 
JOIN DimDate d 
    ON f.DateKey = d.DateKey 
WHERE f.ArrDelay > 0 
GROUP BY d.Year, d.Month, d.MonthName 
ORDER BY d.Year, d.Month 
LIMIT 0, 50000;




