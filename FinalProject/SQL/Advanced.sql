-- Some advanced analysis

 /* 
  ✈️ Segmentation Analysis
  - Categorize flights by distance (short/medium/long)
  - Categorize by delay severity (on_time/minor/major/extreme)
  - Then compute percentage and average delay per group
*/




CREATE OR REPLACE VIEW v_segmentation AS
SELECT *,
  CASE WHEN Distance < 500 THEN 'short'
       WHEN Distance BETWEEN 500 AND 1500 THEN 'medium'
       ELSE 'long' END AS dist_bucket,
  CASE WHEN ArrDelay <= 0 THEN 'on_time'
       WHEN ArrDelay BETWEEN 1 AND 30 THEN 'minor'
       WHEN ArrDelay BETWEEN 31 AND 120 THEN 'major'
       ELSE 'extreme' END AS delay_bucket
FROM v_flight_clean;

-- تحليل المجموعات
SELECT dist_bucket, delay_bucket, COUNT(*) AS cnt,
       ROUND(COUNT(*)*100 / (SELECT COUNT(*) FROM v_flight_clean),2) AS pct_all,
       ROUND(AVG(ArrDelay),2) AS avg_arr_delay
FROM v_segmentation
GROUP BY dist_bucket, delay_bucket
ORDER BY dist_bucket, delay_bucket;

-- متوسط التأخير الشهري
CREATE OR REPLACE VIEW v_monthly_delay AS
SELECT DATE_FORMAT(date,'%Y-%m') AS ym,
       AVG(ArrDelay) AS avg_arrdelay,
       COUNT(*) AS cnt
FROM v_flight_clean
GROUP BY ym
ORDER BY ym;

-- فرق النسبة الشهرية
SELECT cur.ym, cur.avg_arrdelay,
       LAG(cur.avg_arrdelay) OVER (ORDER BY cur.ym) AS prev_avg,
       ROUND( (cur.avg_arrdelay - LAG(cur.avg_arrdelay) OVER (ORDER BY cur.ym)) * 100 / NULLIF(LAG(cur.avg_arrdelay) OVER (ORDER BY cur.ym),0),2) AS pct_change
FROM v_monthly_delay cur
ORDER BY ym DESC
LIMIT 24;


-- average delay and % of flights delayed over 1 hour per airline by main delay cause

SELECT 
    AirlineName,
    dominant_cause,
    COUNT(*) AS flights,
    CONCAT(ROUND(SUM(CASE WHEN ArrDelay > 60 THEN 1 ELSE 0 END) / COUNT(*) * 100,2),'%') AS over_1h_rate,
    ROUND(AVG(ArrDelay),1) AS avg_delay
FROM v_advanced_segmentation
GROUP BY AirlineName, dominant_cause
ORDER BY AirlineName, avg_delay DESC;


-- severity rank


SELECT 
    dominant_cause,
    ROUND(AVG(ArrDelay),1) AS avg_delay,
    COUNT(*) AS total_flights,
    CONCAT(ROUND(COUNT(*) * 100 / (SELECT COUNT(*) FROM v_advanced_segmentation),2),'%') AS pct_total,
    RANK() OVER (ORDER BY AVG(ArrDelay) DESC) AS severity_rank
FROM v_advanced_segmentation
WHERE ArrDelay > 0
GROUP BY dominant_cause;
