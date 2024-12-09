-- What’s the model with the highest value in December 2020?

SELECT vi.manufacturer_c, vi.model_c, vs.value_c
FROM im-bi-assignment.IM_Data.vehicle_info vi
JOIN im-bi-assignment.IM_Data.vehicle_sales vs
ON vi.vehicle_id = vs.vehicle_id
WHERE vi.manufactured_date BETWEEN '2020-12-01' AND '2020-12-31'
ORDER BY vs.value_c DESC
LIMIT 1;


-- What’s the average premium in Attiki for motos over the years per policy duration?

SELECT AVG(premium) AS avg_premium, DATE_DIFF(end_date, start_date, DAY) / 365.25 AS policy_duration_years 
FROM im-bi-assignment.IM_Data.vehicle_sales
WHERE use_final = 'ΜΟΤΟ' AND 
      ((zipcode_c >= '10431' AND zipcode_c <= '19600') 
      OR zipcode_c = '27052' OR zipcode_c = '47100' OR zipcode_c = '80100' OR zipcode_c = '80200')
GROUP BY policy_duration_years
ORDER BY policy_duration_years;


-- What type of packet was preferred by customers aged 40 to 45 who drove a car in 2021?

SELECT packet_category_c, 
       COUNT(DISTINCT feature_transformed) AS num_customers, 
       DATE_DIFF(CURRENT_DATE(), DATE(date_of_birth_c), DAY) / 365.25 AS age
FROM im-bi-assignment.IM_Data.vehicle_sales
WHERE use_final = 'ΕΙΧ' AND (start_date <= '2021-12-31' AND end_date >= '2021-01-01')
GROUP BY packet_category_c, date_of_birth_c
HAVING age BETWEEN 40 AND 45 
ORDER BY num_customers DESC
LIMIT 1;


-- What percentage of customers, with renewals starting in November 2022, changed insurance companies?

WITH renewals AS 
(
   SELECT feature_transformed, company_id, start_date, end_date
    FROM im-bi-assignment.IM_Data.vehicle_sales
    WHERE EXTRACT(YEAR FROM start_date) = 2022 AND EXTRACT(MONTH FROM start_date) = 11 AND kind = 1
),
changes AS 
(
    SELECT r1.feature_transformed
    FROM renewals r1
    JOIN renewals r2
    ON r1.feature_transformed = r2.feature_transformed
    AND r1.company_id != r2.company_id 
    GROUP BY r1.feature_transformed
)
SELECT (COUNT(DISTINCT c.feature_transformed) / COUNT(DISTINCT r.feature_transformed)) * 100 AS change_percentage
FROM renewals r
LEFT JOIN changes c
ON r.feature_transformed = c.feature_transformed;


-- What is the average premium percent difference between years 2022 and 2021 in annual cars with Basic Packet in Crete?

WITH premiums AS 
(
  SELECT feature_transformed, EXTRACT(YEAR FROM start_date) AS policy_year, premium, packet_category_c, str_sub.nomos_name 
  FROM  im-bi-assignment.IM_Data.vehicle_sales vs
  JOIN 
  (
    SELECT CAST(n.tk AS STRING) AS zipcode_nomoi, n.nomos_name         
    FROM im-bi-assignment.IM_Data.nomoi n
  ) AS str_sub 
  ON vs.zipcode_c = str_sub.zipcode_nomoi
  WHERE packet_category_c = 'BASIC'  
        AND EXTRACT(MONTH FROM start_date) = 1  
        AND (str_sub.nomos_name = 'ΧΑΝΙΩΝ' OR str_sub.nomos_name = 'ΗΡΑΚΛΕΙΟΥ' OR str_sub.nomos_name = 'ΡΕΘΥΜΝΗΣ' OR str_sub.nomos_name = 'ΛΑΣΙΘΙΟΥ') 
        AND (EXTRACT(YEAR FROM start_date) = 2022 OR EXTRACT(YEAR FROM start_date) = 2021)
),
premium_comparison AS 
(
  SELECT p1.feature_transformed, p1.premium AS premium_2022, p2.premium AS premium_2021
  FROM premiums p1
  LEFT JOIN premiums p2
  ON p1.feature_transformed = p2.feature_transformed
  AND (p1.policy_year = 2022 AND p2.policy_year = 2021)
)
SELECT AVG((premium_2022 - premium_2021) / premium_2021 * 100) AS avg_premium_dif_percent
FROM premium_comparison
WHERE premium_2021 > 0;

