-- Airline analysis


-- Dominant delay for every airline


SELECT  
    a.AirlineName AS Airline,
    CONCAT(ROUND(MAX(f.ArrDelay), 0), ' minutes') AS MaxDelay,
    CONCAT(ROUND(AVG(f.ArrDelay), 1), ' minutes') AS AvgDelay,
    CONCAT(
        ROUND(SUM(CASE WHEN f.ArrDelay > 60 THEN 1 ELSE 0 END) / COUNT(*) * 100, 2),
        '%'
    ) AS FlightsOver1hDelay,
    CASE 
        WHEN SUM(f.CarrierDelay > 0) >= GREATEST(
                SUM(f.WeatherDelay > 0),
                SUM(f.NASDelay > 0),
                SUM(f.SecurityDelay > 0),
                SUM(f.LateAircraftDelay > 0)
            ) THEN 'Carrier issue'
        WHEN SUM(f.WeatherDelay > 0) >= GREATEST(
                SUM(f.NASDelay > 0),
                SUM(f.SecurityDelay > 0),
                SUM(f.LateAircraftDelay > 0)
            ) THEN 'Weather issue'
        WHEN SUM(f.NASDelay > 0) >= GREATEST(
                SUM(f.SecurityDelay > 0),
                SUM(f.LateAircraftDelay > 0)
            ) THEN 'Air Traffic (NAS) issue'
        WHEN SUM(f.SecurityDelay > 0) >= SUM(f.LateAircraftDelay > 0)
            THEN 'Security issue'
        ELSE 'Late Aircraft arrival'
    END AS DominantDelayCause
FROM factflights f
JOIN DimAirline a 
    ON f.AirlineKey = a.AirlineKey
WHERE f.ArrDelay IS NOT NULL
GROUP BY a.AirlineName
ORDER BY CAST(REPLACE(MaxDelay, ' minutes', '') AS DECIMAL(6,2)) DESC
LIMIT 50000;


-- Every delay type impact


SELECT 
    a.AirlineName AS Airline,
    CONCAT(ROUND(SUM(f.CarrierDelay) / SUM(f.ArrDelay) * 100, 2), '%') AS CarrierImpact,
    CONCAT(ROUND(SUM(f.WeatherDelay) / SUM(f.ArrDelay) * 100, 2), '%') AS WeatherImpact,
    CONCAT(ROUND(SUM(f.NASDelay) / SUM(f.ArrDelay) * 100, 2), '%') AS NASImpact,
    CONCAT(ROUND(SUM(f.SecurityDelay) / SUM(f.ArrDelay) * 100, 2), '%') AS SecurityImpact,
    CONCAT(ROUND(SUM(f.LateAircraftDelay) / SUM(f.ArrDelay) * 100, 2), '%') AS LateAircraftImpact
FROM factflights f
JOIN DimAirline a ON f.AirlineKey = a.AirlineKey
WHERE f.ArrDelay > 0
GROUP BY a.AirlineName
ORDER BY CarrierImpact DESC;




