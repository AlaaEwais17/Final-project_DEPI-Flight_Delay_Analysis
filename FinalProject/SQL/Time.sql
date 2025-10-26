-- Time & date analysis

-- Total flight by day

SELECT DayOfWeek, COUNT(*) AS Total_Flights,
       ROUND(COUNT(*) * 100 / (SELECT COUNT(*) FROM flight), 2) AS Percentage
FROM flight
GROUP BY DayOfWeek
ORDER BY DayOfWeek;

-- Total flight by month

SELECT MONTH(date) AS Month, COUNT(*) AS Flights,
       ROUND(COUNT(*) * 100 / (SELECT COUNT(*) FROM flight), 2) AS Percentage
FROM flight
GROUP BY MONTH(date)
ORDER BY Month;

-- Average Delays by Day of Week

SELECT 
    d.DayName AS day_of_week,
    CONCAT(ROUND(AVG(f.DepDelay), 0), ' minutes') AS avg_departure_delay,
    CONCAT(ROUND(AVG(f.ArrDelay), 0), ' minutes') AS avg_arrival_delay
FROM FactFlights f
JOIN DimDate d ON f.DateKey = d.DateKey
GROUP BY d.DayName
ORDER BY AVG(f.ArrDelay) DESC;

--  Monthly Delay Trends (Average Arrival Delay per Month)

SELECT 
    d.MonthName AS month, 
    CONCAT(ROUND(AVG(f.ArrDelay), 0), ' minutes') AS avg_arrival_delay, 
    CONCAT(ROUND(AVG(f.DepDelay), 0), ' minutes') AS avg_departure_delay
FROM FactFlights f
JOIN DimDate d ON f.DateKey = d.DateKey
GROUP BY d.MonthName
ORDER BY MIN(d.DateKey)
LIMIT 50000;

-- AVG delay due to departure time
SELECT 
    FLOOR(DepTime / 100) AS Hour,
    ROUND(AVG(DepDelay), 1) AS AvgDepDelay,
    COUNT(*) AS FlightCount
FROM factflights
WHERE DepTime IS NOT NULL
GROUP BY Hour
ORDER BY Hour;

-- delay variation by month

SELECT 
    DATE_FORMAT(d.FullDate, '%Y-%m') AS Month,
    ROUND(STD(f.ArrDelay), 1) AS DelayVariation,
    ROUND(AVG(f.ArrDelay), 1) AS AvgDelay,
    COUNT(*) AS Flights
FROM factflights f
JOIN DimDate d 
    ON f.DateKey = d.DateKey
GROUP BY DATE_FORMAT(d.FullDate, '%Y-%m')
ORDER BY DelayVariation DESC;

-- correlation between departure delay & arrival delay

SELECT 
    ROUND(
        (AVG(DepDelay * ArrDelay) - AVG(DepDelay) * AVG(ArrDelay)) /
        (STD(DepDelay) * STD(ArrDelay))
    , 0) AS DelayCorrelation
FROM factflights
WHERE DepDelay IS NOT NULL AND ArrDelay IS NOT NULL;


-- Analyze the impact of previous delays on the current trip(Cascade effect)


SELECT 
    ROUND(AVG(ArrDelay - DepDelay), 1) AS AvgExtraDelay,
    CONCAT(
        ROUND(SUM(CASE WHEN ArrDelay > DepDelay THEN 1 ELSE 0 END) / COUNT(*) * 100, 2),
        '%'
    ) AS PercentOfFlightsWithExtraDelay
FROM factflights;

-- Analyze the impact of previous delays on the current trip(Cascade effect) by airline


SELECT 
    a.AirlineName,
    ROUND(AVG(f.ArrDelay - f.DepDelay), 1) AS AvgExtraDelay,
    CONCAT(
        ROUND(SUM(CASE WHEN f.ArrDelay > f.DepDelay THEN 1 ELSE 0 END) / COUNT(*) * 100, 2),
        '%'
    ) AS PercentOfFlightsWithExtraDelay
FROM factflights f
JOIN DimAirline a 
    ON f.AirlineKey = a.AirlineKey
GROUP BY a.AirlineName
ORDER BY AvgExtraDelay DESC;


-- Percntage of impact of delay reasons on flights


SELECT 
    ROUND(SUM(WeatherDelay) / SUM(ArrDelay) * 100, 2) AS WeatherImpactPercent,
    ROUND(SUM(CarrierDelay) / SUM(ArrDelay) * 100, 2) AS CarrierImpactPercent,
    ROUND(SUM(LateAircraftDelay) / SUM(ArrDelay) * 100, 2) AS LateAircraftImpactPercent
FROM factflights
WHERE ArrDelay > 0;

-- Average delay by time of day (morning - afternoon - evening)

SELECT 
    CASE
        WHEN DepTime BETWEEN 500 AND 1159 THEN 'Morning'
        WHEN DepTime BETWEEN 1200 AND 1759 THEN 'Afternoon'
        WHEN DepTime BETWEEN 1800 AND 2359 THEN 'Evening'
        ELSE 'Night'
    END AS TimeOfDay,
    ROUND(AVG(DepDelay), 1) AS AvgDepartureDelay,
    COUNT(*) AS Flights
FROM factflights
WHERE DepTime IS NOT NULL
GROUP BY TimeOfDay
ORDER BY AvgDepartureDelay DESC;






