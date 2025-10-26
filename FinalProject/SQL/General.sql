-- General analysis of delay

-- عدد الرحلات الكلي
SELECT COUNT(*) AS TotalFlights FROM FactFlights;

-- عدد شركات الطيران
SELECT COUNT(DISTINCT AirlineKey) AS Airlines FROM FactFlights;

-- عدد المطارات
SELECT COUNT(DISTINCT OriginAirportKey) AS TotalAirports FROM FactFlights;

-- عدد الطائرات
SELECT COUNT(DISTINCT PlaneKey) AS Planes FROM FactFlights;

-- AVG delay by airline 

SELECT 
    a.AirlineName,
    CONCAT(ROUND(AVG(f.ArrDelay), 0), ' minutes') AS AvgArrivalDelay,
    CONCAT(ROUND(AVG(f.DepDelay), 0), ' minutes') AS AvgDepartureDelay
FROM FactFlights f
JOIN DimAirline a ON f.AirlineKey = a.AirlineKey
GROUP BY a.AirlineName
ORDER BY AVG(f.ArrDelay) DESC;

-- Worset 10 airport by departure delay

SELECT 
    ap.AirportName AS airport_name,
    COUNT(*) AS total_flights,
    CONCAT(ROUND(AVG(f.DepDelay), 0), ' minutes') AS avg_departure_delay
FROM FactFlights f
JOIN DimAirport ap ON f.OriginAirportKey = ap.AirportKey
GROUP BY ap.AirportCode, ap.AirportName
ORDER BY AVG(f.DepDelay) DESC
LIMIT 10;

-- AVG arrival delay by flight route

SELECT 
    dep.AirportName AS FromAirport,
    arr.AirportName AS ToAirport,
    CONCAT(ROUND(AVG(f.ArrDelay), 0), ' minutes') AS AvgArrivalDelay
FROM FactFlights f
JOIN DimAirport dep ON f.OriginAirportKey = dep.AirportKey
JOIN DimAirport arr ON f.DestAirportKey = arr.AirportKey
GROUP BY dep.AirportName, arr.AirportName
ORDER BY AVG(f.ArrDelay) DESC;


-- Total delay by airline

SELECT 
    a.AirlineName,
    CONCAT(ROUND(SUM(f.ArrDelay + f.DepDelay) / 60 / 24, 0), ' days') AS TotalDelay
FROM FactFlights f
JOIN DimAirline a ON f.AirlineKey = a.AirlineKey
GROUP BY a.AirlineName
ORDER BY SUM(f.ArrDelay + f.DepDelay) DESC;


-- Top 10 flights with the smallest delays (less than 30 minutes) 


SELECT 
    d.FullDate AS flight_date,
    a.AirlineName AS airline,
    f.FlightNum AS flight_number,
    o.AirportName AS origin_airport,
    dest.AirportName AS destination_airport,
    CONCAT(ROUND(f.DepDelay, 0), ' minutes') AS departure_delay,
    CONCAT(ROUND(f.ArrDelay, 0), ' minutes') AS arrival_delay
FROM FactFlights f
JOIN DimDate d ON f.DateKey = d.DateKey
JOIN DimAirline a ON f.AirlineKey = a.AirlineKey
JOIN DimAirport o ON f.OriginAirportKey = o.AirportKey
JOIN DimAirport dest ON f.DestAirportKey = dest.AirportKey
WHERE f.DepDelay < 30 
  AND f.ArrDelay < 30
ORDER BY f.ArrDelay ASC
LIMIT 10;

-- Total flights by airline

SELECT 
    a.AirlineName AS airline,
    COUNT(*) AS total_flights
FROM FactFlights f
JOIN DimAirline a ON f.AirlineKey = a.AirlineKey
GROUP BY a.AirlineName
ORDER BY total_flights DESC;

-- Total delay by delay type

SELECT 
    'Carrier Delay' AS delay_type, CONCAT(ROUND(SUM(f.CarrierDelay) / 1440, 0), ' days') AS total_delay
FROM FactFlights f
UNION ALL
SELECT 'Weather Delay', CONCAT(ROUND(SUM(f.WeatherDelay) / 1440, 0), ' days') FROM FactFlights f
UNION ALL
SELECT 'NAS Delay', CONCAT(ROUND(SUM(f.NASDelay) / 1440, 0), ' days') FROM FactFlights f
UNION ALL
SELECT 'Security Delay', CONCAT(ROUND(SUM(f.SecurityDelay) / 1440, 0), ' days') FROM FactFlights f
UNION ALL
SELECT 'Late Aircraft Delay', CONCAT(ROUND(SUM(f.LateAircraftDelay) / 1440, 0), ' days') FROM FactFlights f;



-- Relation Between Flight Distance and Average Delay

SELECT 
    CONCAT(ROUND(f.Distance, 0), ' km') AS flight_distance,
    CONCAT(ROUND(AVG(f.ArrDelay), 0), ' minutes') AS avg_arrival_delay
FROM FactFlights f
GROUP BY f.Distance
ORDER BY AVG(f.ArrDelay) DESC
LIMIT 20;

-- Top 10 Routes (Origin → Destination) with the Longest Average Arrival Delay

SELECT 
    CONCAT(o.AirportName, ' → ', dest.AirportName) AS route,
    CONCAT(ROUND(AVG(f.Distance), 0), ' km') AS avg_distance,
    CONCAT(ROUND(AVG(f.ArrDelay), 0), ' minutes') AS avg_arrival_delay,
    CONCAT(ROUND(AVG(f.WeatherDelay), 0), ' minutes') AS avg_weather_delay,
    CONCAT(ROUND(AVG(f.CarrierDelay), 0), ' minutes') AS avg_carrier_delay
FROM FactFlights f
JOIN DimAirport o ON f.OriginAirportKey = o.AirportKey
JOIN DimAirport dest ON f.DestAirportKey = dest.AirportKey
GROUP BY route
ORDER BY AVG(f.ArrDelay) DESC
LIMIT 10;



-- Average Flight Duration vs. Delay

SELECT 
    CONCAT(ROUND(AVG(f.AirTime), 0), ' minutes') AS avg_air_time,
    CONCAT(ROUND(AVG(f.ArrDelay), 0), ' minutes') AS avg_arrival_delay
FROM FactFlights f;

-- long flights vs short flights

SELECT 
  CASE WHEN Distance < 500 THEN 'Short (<500 miles)'
       WHEN Distance BETWEEN 500 AND 1500 THEN 'Medium (500–1500 miles)'
       ELSE 'Long (>1500 miles)' END AS Flight_Length,
  ROUND(AVG(ArrDelay),2) AS Avg_ArrDelay,
  COUNT(*) AS Total_Flights
FROM factflights
GROUP BY Flight_Length
ORDER BY Avg_ArrDelay DESC;