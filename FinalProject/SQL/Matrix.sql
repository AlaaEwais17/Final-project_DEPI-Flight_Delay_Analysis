-- correlation matrix

SELECT 
    'DepDelay vs ArrDelay' AS Relationship,
    ROUND((AVG(DepDelay * ArrDelay) - AVG(DepDelay) * AVG(ArrDelay)) / 
          (STD(DepDelay) * STD(ArrDelay)), 0) AS Correlation
FROM factflights
WHERE DepDelay IS NOT NULL AND ArrDelay IS NOT NULL

UNION ALL

SELECT 
    'DepDelay vs AirTime',
    ROUND((AVG(DepDelay * AirTime) - AVG(DepDelay) * AVG(AirTime)) / 
          (STD(DepDelay) * STD(AirTime)), 0)
FROM factflights
WHERE DepDelay IS NOT NULL AND AirTime IS NOT NULL

UNION ALL

SELECT 
    'ArrDelay vs Distance',
    ROUND((AVG(ArrDelay * Distance) - AVG(ArrDelay) * AVG(Distance)) / 
          (STD(ArrDelay) * STD(Distance)), 0)
FROM factflights
WHERE ArrDelay IS NOT NULL AND Distance IS NOT NULL

UNION ALL

SELECT 
    'ArrDelay vs AirTime',
    ROUND((AVG(ArrDelay * AirTime) - AVG(ArrDelay) * AVG(AirTime)) / 
          (STD(ArrDelay) * STD(AirTime)), 0)
FROM factflights
WHERE ArrDelay IS NOT NULL AND AirTime IS NOT NULL

UNION ALL

SELECT 
    'AirTime vs Distance',
    ROUND((AVG(AirTime * Distance) - AVG(AirTime) * AVG(Distance)) / 
          (STD(AirTime) * STD(Distance)), 0)
FROM factflights
WHERE AirTime IS NOT NULL AND Distance IS NOT NULL

UNION ALL

SELECT 
    'DepDelay vs TaxiOut',
    ROUND((AVG(DepDelay * TaxiOut) - AVG(DepDelay) * AVG(TaxiOut)) / 
          (STD(DepDelay) * STD(TaxiOut)), 0)
FROM factflights
WHERE DepDelay IS NOT NULL AND TaxiOut IS NOT NULL

UNION ALL

SELECT 
    'ArrDelay vs LateAircraftDelay',
    ROUND((AVG(ArrDelay * LateAircraftDelay) - AVG(ArrDelay) * AVG(LateAircraftDelay)) / 
          (STD(ArrDelay) * STD(LateAircraftDelay)), 0)
FROM factflights
WHERE ArrDelay IS NOT NULL AND LateAircraftDelay IS NOT NULL

UNION ALL

SELECT 
    'CarrierDelay vs ArrDelay',
    ROUND((AVG(CarrierDelay * ArrDelay) - AVG(CarrierDelay) * AVG(ArrDelay)) / 
          (STD(CarrierDelay) * STD(ArrDelay)), 0)
FROM factflights
WHERE CarrierDelay IS NOT NULL AND ArrDelay IS NOT NULL

UNION ALL

SELECT 
    'WeatherDelay vs ArrDelay',
    ROUND((AVG(WeatherDelay * ArrDelay) - AVG(WeatherDelay) * AVG(ArrDelay)) / 
          (STD(WeatherDelay) * STD(ArrDelay)), 0)
FROM factflights
WHERE WeatherDelay IS NOT NULL AND ArrDelay IS NOT NULL;
