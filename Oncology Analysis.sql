Create Database Oncology;
USE ONCOLOGY;
	SELECT * FROM patient_master;
	SELECT * FROM treatment_data;
	SELECT * FROM prescriptions ;
	SELECT * FROM drug_master;
	select * from doctor_master;	

	describe patient_master;
	describe treatment_data;
	describe prescriptions;
	describe drug_master;
    
  
 ####Total Prescription   
    SELECT
  drug_name,
  COUNT(*) AS total_prescriptions,
  COUNT(DISTINCT patient_id) AS unique_patients
FROM
  prescriptions
GROUP BY
  drug_name
ORDER BY
  total_prescriptions DESC
LIMIT 5;

### For Each Cancer Type How many Patients in each stage
select cancer_type, stage, count(*) as patient_count
from patient_master
group by cancer_type,stage;

#### Prescription giver per stage of cancer

select a.Cancer_type, a.stage, count(*) as prescription_count
from patient_master as a
inner join prescriptions as b
on a.patient_id = b.patient_id
group by a.cancer_type, a.stage;

##### Drug name
###Drug class
###Company name
#Number of times it was prescribed
#Number of unique doctors who prescribed it

select a.drug_name, b.drug_class, b.company, count(*)
as Total_prescribed, count(distinct c.doctor_id) as unique_doctors
from prescriptions as a
join drug_master as b
on a.drug_name = b.drug_name
join doctor_master as c
on a.doctor_id = c.doctor_id
group by a.drug_name, b.drug_class, b.company;

###Top 5 Drugs by Cancer Stage

select a.stage, b.drug_name,
count(b.drug_name) as top_5_drugs
from patient_master as a
join prescriptions as b
on a.patient_id = b.patient_id
group by a.stage, b.drug_name order by count(b.drug_name) desc limit 5;

select * from(
select a.stage, b.drug_name,
count(b.drug_name) as top_5_drugs,
rank() over (partition by a.stage order by count(b.drug_name) desc) as ranked 
from patient_master as a
join prescriptions as b
on a.patient_id = b.patient_id
group by stage, drug_name) as ranking 
where ranked <= 5;


### Therapy trends for different cancer types

Select a.cancer_type, b.line_of_therapy, count(*) as most_used_therapy
from patient_master as a
join treatment_data as b
on a.patient_id = b.patient_id
group by a.cancer_type,b.line_of_therapy order by count(*) desc;



ALTER TABLE drug_master
ADD COLUMN cost DECIMAL(10,2);

UPDATE drug_master
SET cost = 
  CASE 
    WHEN drug_class = 'Chemotherapy' THEN 12000
    WHEN drug_class = 'Targeted Therapy' THEN 10000
    WHEN drug_class = 'Immunotherapy' THEN 6000
    WHEN drug_class = 'Hormone Therapy' THEN 2000
    ELSE 1000
  END;
  
  SET SQL_SAFE_UPDATES = 0;

select sum(b.cost) as therapy_cost, c.doctor_name
from prescriptions  as a
join drug_master as b
on a.drug_name = b.drug_name
join doctor_master as c 
on a.doctor_id = c.doctor_id
group by c.doctor_name	
order by sum(b.cost) desc limit 3;	

