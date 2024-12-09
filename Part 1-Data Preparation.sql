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


-- ΔΙΑΓΡΑΦΗ ΔΕΔΟΜΕΝΩΝ ΠΟΥ ΕΧΟΥΝ ΠΑΥΛΑ ΓΙΑ ΜΟΝΤΕΛΟ ΟΧΗΜΑΤΟΣ, EINAI ΕΙΧ ΚΑΙ ΕΧΟΥΝ ΚΑΤΑΣΚΕΥΑΣΤΕΙ ΜΕΤΑ ΤΟ 1997

SELECT vs.feature_transformed, vi.vehicle_id, vi.manufacturer_c, vi.model_c, vs.use_final, vi.manufactured_date
FROM im-bi-assignment.IM_Data.vehicle_info vi
JOIN im-bi-assignment.IM_Data.vehicle_sales vs
ON vi.vehicle_id = vs.vehicle_id
WHERE (vi.manufacturer_c = '-' OR vi.model_c ='-') AND vs.use_final = 'ΕΙΧ'
ORDER BY vi.manufactured_date ASC;

DELETE vi, vs, c
FROM im-bi-assignment.IM_Data.vehicle_info vi
JOIN im-bi-assignment.IM_Data.vehicle_sales vs
ON vi.vehicle_id = vs.vehicle_id
JOIN im-bi-assignment.IM_Data.covers c
ON vs.feature_transformed = c.license_plate
WHERE vi.model_c = '-' AND vs.use_final = 'ΕΙΧ' AND vi.manufactured_date => '1998-01-01' ;


-- ΔΙΑΓΡΑΦΗ ΔΕΔΟΜΕΝΩΝ ΠΟΥ ΕΧΟΥΝ ΓΙΑ ΜΟΝΤΕΛΟ ΤΗΝ ΜΑΡΚΑ ΟΧΗΜΑΤΟΣ Ή ΠΟΥ ΕΧΟΥΝ ΠΑΥΛΑ ΓΙΑ ΜΑΡΚΑ ΟΧΗΜΑΤΟΣ

SELECT *
FROM im-bi-assignment.IM_Data.vehicle_info
WHERE manufacturer_c = model_c OR manufacturer_c = '-';

DELETE vi, vs, c
FROM im-bi-assignment.IM_Data.vehicle_info vi
JOIN im-bi-assignment.IM_Data.vehicle_sales vs
ON vi.vehicle_id = vs.vehicle_id
JOIN im-bi-assignment.IM_Data.covers c
ON vs.feature_transformed = c.license_plate
WHERE vi.manufacturer_c = vi.model_c OR vi.manufacturer_c = '-';


-- ΔΙΑΓΡΑΦΗ ΟΧΗΜΑΤΩΝ ΜΕ ΑΞΙΑ NULL 'Η ΜΗΔΕΝΙΚΗ 'Η (ΠΑΚΕΤΟ ΑΣΦΑΛΙΣΗΣ NULL 'Η #Δ/Υ 'Η ΠΡΟΣΩΠΙΚΟ ΑΤΥΧΗΜΑ 'Η ΦΔΧ 'Η UNKNOWN

SELECT use_final, value_c, packet_category_c
FROM im-bi-assignment.IM_Data.vehicle_sales
WHERE value_c IS NULL OR value_c = 0 OR packet_category_c IS NULL
OR (packet_category_c IS NULL OR packet_category_c = '#Δ/Υ' OR packet_category_c = 'ΠΡΟΣΩΠΙΚΟ ΑΤΥΧΗΜΑ' 
OR packet_category_c = 'ΦΔΧ' OR packet_category_c = 'unknown');

DELETE vs, vi, c
FROM im-bi-assignment.IM_Data.vehicle_sales vs
JOIN im-bi-assignment.IM_Data.vehicle_info vi
ON vs.vehicle_id = vi.vehicle_id
JOIN im-bi-assignment.IM_Data.covers c
ON vs.feature_transformed = c.license_plate
WHERE value_c IS NULL OR value_c = 0 
OR (packet_category_c IS NULL OR packet_category_c = '#Δ/Υ' OR packet_category_c = 'ΠΡΟΣΩΠΙΚΟ ΑΤΥΧΗΜΑ' 
OR packet_category_c = 'ΦΔΧ' OR packet_category_c = 'unknown');


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








 