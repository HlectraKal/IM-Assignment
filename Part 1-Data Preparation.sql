-- ΜΕΤΑΤΡΟΠΗ ΤΩΝ ΟΝΟΜΑΤΩΝ ΕΤΑΙΡΕΙΩΝ ΣΕ ΚΕΦΑΛΑΙΑ

SELECT manufacturer_c
FROM im-bi-assignment.IM_Data.vehicle_info;

UPDATE im-bi-assignment.IM_Data.vehicle_info
SET manufacturer_c = UPPER(manufacturer_c);


-- ΣΥΜΠΛΗΡΩΣΗ ΜΟΝΤΕΛΩΝ ΟΧΗΜΑΤΩΝ [ΠΟΥ ΗΤΑΝ ΚΕΝΑ (ΔΥΟ ΜΗΧΑΝΕΣ)] Ή (ΠΑΥΛΑ ΚΑΙ ΔΕΝ ΕΙΝΑΙ ΕΙΧ) Ή (ΠΑΥΛΑ ΚΑΙ ΕΙΝΑΙ ΕΙΧ ΚΑΙ ΚΑΤΑΣΚΕΥΑΣΤΗΚΑΝ ΠΡΙΝ ΤΟ 1998)

SELECT *
FROM im-bi-assignment.IM_Data.vehicle_info
WHERE model_c =' ' OR (model_c ='-' AND manufactured_date <= '1997-12-31');

UPDATE vi, vs
FROM im-bi-assignment.IM_Data.vehicle_info vi
JOIN im-bi-assignment.IM_Data.vehicle_sales vs
ON vi.vehicle_id = vs.vehicle_id
SET vi.model_c = 'Άλλο μοντέλο'
WHERE vi.model_c = ' ' OR (vi.model_c ='-' AND vs.use_final != 'ΕΙΧ') OR (vs.use_final = 'ΕΙΧ' AND vi.manufactured_date <= '1997-12-31');


-- ΔΙΑΓΡΑΦΗ ΔΙΠΛΟΤΥΠΩΝ ΟΧΗΜΑΤΩΝ ΜΕ ΙΔΙΑ ΗΜΕΡΟΜΗΝΙΑ, ΔΙΑΡΚΕΙΑ, ΠΑΚΕΤΟ ΚΑΙ ΑΣΦΑΛΙΣΤΡΟ

SELECT feature_transformed, start_date, end_date, duration_months, packet_category_c, premium
FROM im-bi-assignment.IM_Data.vehicle_sales;

CREATE TABLE im-bi-assignment.IM_Data.vehicle_sales1 AS
SELECT DISTINCT feature_transformed, start_date, end_date, duration_months, packet_category_c, premium
FROM im-bi-assignment.IM_Data.vehicle_sales;

DROP TABLE im-bi-assignment.IM_Data.vehicle_sales;

ALTER TABLE im-bi-assignment.IM_Data.vehicle_sales1 RENAME TO im-bi-assignment.IM_Data.vehicle_sales;



-- ΔΙΟΡΘΩΣΗ ΗΜΕΡΟΜΗΝΙΑ ΛΗΞΕΩΝ ΣΜΒΟΛΑΙΩΝ ΠΟΥ ΕΙΝΑΙ NULL

SELECT start_date, end_date, duration_months
FROM im-bi-assignment.IM_Data.vehicle_sales
WHERE end_date IS NULL;

UPDATE im-bi-assignment.IM_Data.vehicle_sales
SET end_date = DATEADD(MONTH, duration_months, start_date)
WHERE end_date IS NULL AND duration_months IS NOT NULL;


-- ΔΙΟΡΘΩΣΗ ΔΙΑΡΚΕΙΑΣ ΣΥΜΒΟΛΑΙΩΝ ΠΟΥ ΕΙΝΑΙ NULL

SELECT start_date, end_date, duration_months
FROM im-bi-assignment.IM_Data.vehicle_sales
WHERE duration_months IS NULL;

UPDATE im-bi-assignment.IM_Data.vehicle_sales
SET duration_months = DATEDIFF(MONTH, start_date, end_date)
WHERE duration_months IS NULL AND end_date IS NOT NULL;








 