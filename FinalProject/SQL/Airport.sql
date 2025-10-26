-- Airport analysis

-- Top 10 destination airports with the highest average arrival delays and their % of flights delayed over 1 hour


SELECT 
    d.AirportName AS DestinationAirport,
    COUNT(*) AS total_flights,
    ROUND(AVG(f.ArrDelay),1) AS avg_arrival_delay,
    CONCAT(ROUND(SUM(CASE WHEN f.ArrDelay > 60 THEN 1 ELSE 0 END)/COUNT(*)*100,2),'%') AS over_1h_rate
FROM FactFlights f
JOIN DimAirport d ON f.DestAirportKey = d.AirportKey
WHERE f.ArrDelay > 0
GROUP BY d.AirportName
ORDER BY avg_arrival_delay DESC
LIMIT 10;


-- Analyze airports by comparing average departure vs arrival delays  
-- and calculate the net delay change to identify where delays worsen or improve.



SELECT 
    a.AirportName,
    ROUND(AVG(f.DepDelay),1) AS avg_departure_delay,
    ROUND(AVG(f.ArrDelay),1) AS avg_arrival_delay,
    ROUND(AVG(f.ArrDelay - f.DepDelay),1) AS net_delay_change
FROM FactFlights f
JOIN DimAirport a ON f.OriginAirportKey = a.AirportKey
WHERE f.ArrDelay IS NOT NULL AND f.DepDelay IS NOT NULL
GROUP BY a.AirportName
ORDER BY net_delay_change DESC;


-- Identify airports most affected by weather-related delays,  
-- showing the percentage of total delay caused by weather and the average weather delay duration.


SELECT 
    a.AirportName,
    ROUND(SUM(f.WeatherDelay)/SUM(f.ArrDelay)*100,2) AS weather_influence_pct,
    ROUND(AVG(f.WeatherDelay),1) AS avg_weather_delay
FROM FactFlights f
JOIN DimAirport a ON f.OriginAirportKey = a.AirportKey
WHERE f.ArrDelay > 0
GROUP BY a.AirportName
HAVING weather_influence_pct > 5
ORDER BY weather_influence_pct DESC
LIMIT 10;


-- Compare total carrier vs air traffic (NAS) delay time per origin airport  
-- to determine which delay type is dominant, with totals shown in days.


SELECT 
    o.AirportName,
    CONCAT(ROUND(SUM(f.CarrierDelay) / 60 / 24, 0), ' days') AS total_carrier_delay,
    CONCAT(ROUND(SUM(f.NASDelay) / 60 / 24, 0), ' days') AS total_nas_delay,
    CASE 
        WHEN SUM(f.CarrierDelay) > SUM(f.NASDelay) THEN 'Carrier-related'
        ELSE 'Air Traffic/NAS-related'
    END AS dominant_cause
FROM FactFlights f
JOIN DimAirport o ON f.OriginAirportKey = o.AirportKey
WHERE f.ArrDelay > 0
GROUP BY o.AirportName
ORDER BY SUM(f.CarrierDelay) DESC
LIMIT 20;


-- Identify airport pairs (origin → destination) with the highest average arrival delays,  
-- considering only routes with more than 100 flights.


SELECT 
    o.AirportName AS OriginAirport,
    d.AirportName AS DestinationAirport,
    ROUND(AVG(f.ArrDelay),1) AS avg_delay,
    COUNT(*) AS flights
FROM FactFlights f
JOIN DimAirport o ON f.OriginAirportKey = o.AirportKey
JOIN DimAirport d ON f.DestAirportKey = d.AirportKey
WHERE f.ArrDelay IS NOT NULL
GROUP BY o.AirportName, d.AirportName
HAVING flights > 100
ORDER BY avg_delay DESC
LIMIT 30;

-- Analyze destination airports by total flights, delay frequency, average delay (in days),  
-- and percentage of flights delayed over 1 hour — ranked by highest average delay.



SELECT 
    a.AirportName,
    COUNT(*) AS total_flights,
    SUM(CASE WHEN f.ArrDelay > 0 THEN 1 ELSE 0 END) AS delayed_flights,
    ROUND(AVG(f.ArrDelay) / 60 / 24, 2) AS avg_delay_days,
    CONCAT(ROUND(SUM(CASE WHEN f.ArrDelay > 60 THEN 1 ELSE 0 END) / COUNT(*) * 100, 2), '%') AS over_1h_rate
FROM FactFlights f
JOIN DimAirport a ON f.DestAirportKey = a.AirportKey
GROUP BY a.AirportName
ORDER BY avg_delay_days DESC;



-- Top 10 destination airports with highest average arrival delay (days) and % of flights delayed over 1 hour

SELECT 
    a.AirportName,
    ROUND(AVG(f.ArrDelay) / 60 / 24, 2) AS avg_delay_days,
    CONCAT(ROUND(SUM(CASE WHEN f.ArrDelay > 60 THEN 1 ELSE 0 END)/COUNT(*)*100,2),'%') AS over_1h_rate
FROM FactFlights f
JOIN DimAirport a ON f.DestAirportKey = a.AirportKey
WHERE f.ArrDelay > 0
GROUP BY a.AirportName
ORDER BY avg_delay_days DESC
LIMIT 10;


-- Average delay (in days) and flight count per airport, split by origin/destination

SELECT      
    'Origin' AS AirportType,
    a.AirportName,
    ROUND(AVG(f.DepDelay) / 60 / 24, 2) AS avg_delay_days,
    COUNT(*) AS total_flights
FROM FactFlights f
JOIN DimAirport a ON f.OriginAirportKey = a.AirportKey
GROUP BY a.AirportName  

UNION ALL  

SELECT      
    'Destination' AS AirportType,
    a.AirportName,
    ROUND(AVG(f.ArrDelay) / 60 / 24, 2) AS avg_delay_days,
    COUNT(*) AS total_flights
FROM FactFlights f
JOIN DimAirport a ON f.DestAirportKey = a.AirportKey
GROUP BY a.AirportName

ORDER BY avg_delay_days DESC;
