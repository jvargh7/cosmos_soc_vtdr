/* Project : Identify and create a datamart of patients based on SUPREME DM criteria.
SUPREME-DM Computable Phenotype 
Any combination of 2 of the following events occuring within 24 months of each other
1) HbA1c >= 6.5% [LOINC: 4548-4, 41995-2, 55454-3, 71875-9, 549-2, 17856-6, 59261-6, 62388-4, 17855-8, 10839-9]
2) Fasting plasma glucose >= 126 mg/dL [LOINC: 1558-6, 76629-5, 77145-1, 1556-0, 35184-1, 14771-0]
3) Random plasma glucose >= 200 mg/dL [LOINC: 2345-7, 2339-0, 41653-7, 2340-8, 27353-2, 1547-9]
4) Outpatient diagnosis of Type 2 Diabetes (E11)
5) Any 'dispensation' of antihyperglycemic medication (filled prescription): 
	sulfonylureas, insulins, biguanides, thiazolidinediones, AGI, DPP4 inhibitors, meglitinides, amylin analogs
	Refer: ~retinopathy_fragmentation/sql/Retinopathy Fragmentation Variable List.xlsx >> medications
- We are not going to use 'incretin mimetics' since these are also prescribed for weight loss
4) Inpatient diagnosis of Type 2 Diabetes (E11)
Conditions:
Two events of the same type would qualify but only if the 2 events occured on separate days
Two prescription dispensations of metformin or thiazolidinediones with no other indication of diabetes were not counted
*/

SELECT DISTINCT PharmaceuticalClass, PharmaceuticalSubclass
FROM dbo.MedicationDim 
WHERE PharmaceuticalClass LIKE ('%ANTIHYPERTEN%' )
ORDER BY PharmaceuticalClass

SELECT DISTINCT PharmaceuticalClass, PharmaceuticalSubclass
FROM dbo.MedicationDim 
WHERE PharmaceuticalClass LIKE ('%ANTIHYPER%' )
ORDER BY PharmaceuticalClass

SELECT DISTINCT PharmaceuticalClass, PharmaceuticalSubclass
FROM dbo.MedicationDim 
WHERE TherapeuticClass LIKE ('%OBESITY%' )
ORDER BY PharmaceuticalClass

USE COSMOS;
/*---------------------------------------------------------------------------------------------------------------------------------------------------------------*//*---------------------------------------------------------------------------------------------------------------------------------------------------------------*/
/*---------------------------------------------------------------------------------------------------------------------------------------------------------------*//*---------------------------------------------------------------------------------------------------------------------------------------------------------------*/
/*  Creating a list of the ICD Codes  for Type 2 Diabetes (E11.*) */
DROP TABLE IF EXISTS #diagnosiscodes
SELECT distinct  DiagnosisKey
				,DiagnosisTerminologykey
				,Value
				,displaystring
into #DiagnosisCodes
FROM dbo.DiagnosisTerminologyDim
WHERE Type = 'ICD-10-CM' 
       AND Value LIKE ('%E11%');
USE ProjectD0C076; -- This is the location of the project
/* Creating a permanent instance of the DM 2 DX codes for use*/
DROP TABLE IF EXISTS ProjectD0C076.dbo.diagnosiscodes;
Create table ProjectD0C076.dbo.diagnosiscodes
( DiagnosisKey bigint,
  DiagnosisTerminologykey bigint,
  icd_value nvarchar(300),
  displaystring nvarchar(300)
)
INSERT INTO ProjectD0C076.dbo.diagnosiscodes
(DiagnosisKey , DiagnosisTerminologykey,  icd_value ,displaystring)
SELECT           DiagnosisKey
				,DiagnosisTerminologykey
				,Value
				,displaystring
FROM #diagnosiscodes;
Select * from ProjectD0C076.dbo.diagnosiscodes;

/*---------------------------------------------------------------------------------------------------------------------------------------------------------------*//*---------------------------------------------------------------------------------------------------------------------------------------------------------------*/
/*---------------------------------------------------------------------------------------------------------------------------------------------------------------*//*---------------------------------------------------------------------------------------------------------------------------------------------------------------*/
/* Create a list of the Labs to identify patient based on the Lab values*/
Drop table if exists #labs_list;
with HbA1c as
( 
SELECT distinct LabComponentKey
				,CommonName
				,'hba1c' as filter_reason
FROM dbo.LabComponentDim
WHERE LoincCode IN ('4548-4', '41995-2', '55454-3', '71875-9', '549-2', '17856-6', '59261-6', '62388-4', '17855-8', '10839-9')
)
,
Fgluc as
(
SELECT distinct LabComponentKey
				,CommonName	
				,'Fgluc' as filter_reason
FROM dbo.LabComponentDim
WHERE LoincCode IN ('1558-6', '76629-5', '77145-1', '1556-0', '35184-1', '14771-0')
)
,
rgluc as
(
SELECT distinct LabComponentKey
				,CommonName
				,'rgluc' as filter_reason
FROM dbo.LabComponentDim
WHERE LoincCode IN ('2345-7', '2339-0', '41653-7', '2340-8', '27353-2', '1547-9')
)
,
combo as
(
Select distinct * from HbA1c
UNION
select distinct * from fgluc
union 
Select distinct * from rgluc 
)
select * 
into #labs_list
from combo ;
-- Create a permanent instance of the list of labs for use;
USE ProjectD0C076; -- This is the location of the project
/* Creating a permanent instance of the DM 2 DX codes for use*/
DROP TABLE IF EXISTS ProjectD0C076.dbo.labslist;
Create table ProjectD0C076.dbo.labslist
( labcomponentkey bigint,
  commonname nvarchar(300),
  filter_reason nvarchar(300)
)
INSERT INTO ProjectD0C076.dbo.labslist
( labcomponentkey,commonname,filter_reason)
SELECT          labcomponentkey
				,commonname
				,filter_reason
FROM #labs_list;
Select * from ProjectD0C076.dbo.labslist;
/*---------------------------------------------------------------------------------------------------------------------------------------------------------------*//*---------------------------------------------------------------------------------------------------------------------------------------------------------------*/
/*---------------------------------------------------------------------------------------------------------------------------------------------------------------*//*---------------------------------------------------------------------------------------------------------------------------------------------------------------*/
/* Creating a table that has all the mdications of interest to use as a filter*/
DROP TABLE IF EXISTS #medications;
SELECT distinct  MedicationKey
				,Name
				,CASE WHEN (PharmaceuticalClass IN (	'ANTIHYPERGLYCEMIC, BIGUANIDE TYPE',
														'ANTIHYPERGLYCEMIC,THIAZOLIDINEDIONE(PPARG AGONIST)',
														'ANTIHYPERGLY,INCRETIN MIMETIC(GLP-1 RECEP.AGONIST)',
														'ANTIHYPERGLYCEMIC - INCRETIN MIMETICS COMBINATION')) THEN 'CONFOUNDING CLASS'
														ELSE PharmaceuticalClass END AS flagged_PharmaceuticalClass
INTO #medications
FROM dbo.MedicationDim
WHERE TherapeuticClass = 'ANTIHYPERGLYCEMICS' 
      and MedicationKey not in (SELECT distinct  MedicationKey FROM dbo.MedicationDim WHERE TherapeuticClass = 'ANTI-OBESITY DRUGS'); /* Also want to exclude the Obseity Medications since they can also be used for DM*/
USE ProjectD0C076; -- This is the location of the project
DROP TABLE IF EXISTS ProjectD0C076.dbo.medications;
Create table ProjectD0C076.dbo.medications
( Medicationkey bigint,
  Name nvarchar(300),
  flagged_PharmaceuticalClass nvarchar(300)
)
USE COSMOS;
INSERT INTO ProjectD0C076.dbo.medications
(medicationkey , name , flagged_pharmaceuticalclass )
SELECT    medicationkey 
		  ,name 
		  ,flagged_pharmaceuticalclass
FROM #medications;
/*---------------------------------------------------------------------------------------------------------------------------------------------------------------*//*---------------------------------------------------------------------------------------------------------------------------------------------------------------*/
/*---------------------------------------------------------------------------------------------------------------------------------------------------------------*//*---------------------------------------------------------------------------------------------------------------------------------------------------------------*/

/* Extracting data from COSMOS for patients ancd creating individiual tables for each*/
USE cosmos;
DROP TABLE IF EXISTS #Filter_cat1;
Select Distinct  lcrf.PatientDurableKey
				,spec_dt.MonthYear
				,spec_dt.Year
into #Filter_cat1
From dbo.LabComponentResultFact LCRF
     join ProjectD0C076.dbo.labslist ll on (ll.LabComponentKey = lcrf.LabComponentKey and ll.filter_reason = 'hba1c')
	 join dbo.DateDim spec_dt on (spec_dt.datekey = lcrf.PrioritizedDateKey)
	 join dbo.CohortDataMartX datamart on (datamart.PatientDurableKey = lcrf.PatientDurableKey and datamart.IsOnDiabetesRegistry = 1)
Where lcrf.NumericValue >= '6.5'
      and spec_dt.year>= 2012;
Select count(*) from #Filter_cat1; 
USE ProjectD0C076; -- This is the location of the project
DROP TABLE IF EXISTS ProjectD0C076.dbo.filterCat1;
Create table ProjectD0C076.dbo.filterCat1
( patientdurablekey bigint,
  monthyear nvarchar(50),	
  year bigint
)
USE COSMOS;
INSERT INTO ProjectD0C076.dbo.filterCat1
			(patientdurablekey
			,monthyear
			,year
)
SELECT       patientdurablekey
			,monthyear
			,year
FROM #Filter_cat1;
/*---------------------------------------------------------------------------------------------------------------------------------------------------------------*//*---------------------------------------------------------------------------------------------------------------------------------------------------------------*/
/*---------------------------------------------------------------------------------------------------------------------------------------------------------------*//*---------------------------------------------------------------------------------------------------------------------------------------------------------------*/
/* Extracting data from COSMOS for patients ancd creating individiual tables for each*/
/* Filter Category 2: Fasting plasma glucose >= 126 mg/dL*/
DROP TABLE IF EXISTS #Filter_cat2;
USE COSMOS;
Select Distinct lcrf.PatientDurableKey
				,spec_dt.MonthYear
				,spec_dt.Year
into #Filter_cat2
From dbo.LabComponentResultFact LCRF
	 join ProjectD0C076.dbo.labslist ll on (ll.LabComponentKey = lcrf.LabComponentKey and ll.filter_reason = 'fgluc')
	 join dbo.DateDim spec_dt on (spec_dt.datekey = lcrf.PrioritizedDateKey)
	 join dbo.CohortDataMartX datamart on (datamart.PatientDurableKey = lcrf.PatientDurableKey and datamart.IsOnDiabetesRegistry = 1)
Where lcrf.NumericValue >= '126' and spec_dt.year>= 2012;
select count (*) from #Filter_cat2;
USE ProjectD0C076; -- This is the location of the project
DROP TABLE IF EXISTS ProjectD0C076.dbo.filterCat2;
Create table ProjectD0C076.dbo.filterCat2
( patientdurablekey bigint,
  monthyear nvarchar(50),	
  year bigint,
  filter_cat tinyint    
)
Select * from ProjectD0C076.dbo.filterCat2;
USE COSMOS;
INSERT INTO ProjectD0C076.dbo.filterCat2
			(patientdurablekey ,
			  monthyear ,	
			  year )
SELECT patientdurablekey ,
			  monthyear ,	
			  year			
From #Filter_cat2;	
Select count(*) from ProjectD0C076.dbo.filterCat2;


/*---------------------------------------------------------------------------------------------------------------------------------------------------------------*//*---------------------------------------------------------------------------------------------------------------------------------------------------------------*/
/*---------------------------------------------------------------------------------------------------------------------------------------------------------------*//*---------------------------------------------------------------------------------------------------------------------------------------------------------------*/

/* Extracting data from COSMOS for patients ancd creating individiual tables for each*/
/* Filter Category 3: Regular plasma glucose >= 200 mg/dL*/


DROP TABLE IF EXISTS #Filter_cat3;
Select Distinct lcrf.PatientDurableKey
				,spec_dt.MonthYear
				,spec_dt.Year
				,'3' as Filter_Cat
into #Filter_cat3
From dbo.LabComponentResultFact LCRF
   	 join ProjectD0C076.dbo.labslist ll on (ll.LabComponentKey = lcrf.LabComponentKey and ll.filter_reason = 'rgluc')
	 join dbo.DateDim spec_dt on (spec_dt.datekey = lcrf.PrioritizedDateKey)
	 join dbo.CohortDataMartX datamart on (datamart.PatientDurableKey = lcrf.PatientDurableKey and datamart.IsOnDiabetesRegistry = 1)
Where lcrf.NumericValue >= '200'
	   and spec_dt.year>= 2012;
Select count(*) from #Filter_cat3;
USE ProjectD0C076; -- This is the location of the project
DROP TABLE IF EXISTS ProjectD0C076.dbo.filterCat3;
Create table ProjectD0C076.dbo.filterCat3
( patientdurablekey bigint,
  monthyear nvarchar(50),	
  year bigint,
  filter_cat tinyint 
)
--Select * from ProjectD0C076.dbo.filterCat3;
USE COSMOS;
INSERT INTO ProjectD0C076.dbo.filterCat3
			(patientdurablekey ,
			  monthyear ,	
			  year ,
			  filter_cat  )
SELECT		  patientdurablekey ,
			  monthyear ,	
			  year ,
			  filter_cat 
FROM  #Filter_cat3;

Select count(*) from ProjectD0C076.dbo.filterCat3;

/*---------------------------------------------------------------------------------------------------------------------------------------------------------------*//*---------------------------------------------------------------------------------------------------------------------------------------------------------------*/
/*---------------------------------------------------------------------------------------------------------------------------------------------------------------*//*---------------------------------------------------------------------------------------------------------------------------------------------------------------*/

USE COSMOS;
/* Filter Category 4a:  Outpatient diagnosis of Type 2 Diabetes (E11)*/

Drop table if exists #Filter_cat4_1;
Select distinct  def.PatientDurableKey
				,enc_dt.MonthYear
				,enc_dt.Year
				,'4' as Filter_Cat
into #Filter_cat4_1
From dbo.DiagnosisEventFact DEF
		JOIN ProjectD0C076.dbo.diagnosiscodes p_diagcode on (p_diagcode.DiagnosisKey = def.DiagnosisKey)
		join dbo.EncounterFact enc_fact on (enc_fact.EncounterKey = def.EncounterKey)
		join dbo.DateDim enc_dt on (enc_dt.datekey = enc_fact.datekey)
		join dbo.CohortDataMartX datamart on (datamart.PatientDurableKey = def.PatientDurableKey and datamart.IsOnDiabetesRegistry = 1)
where enc_fact.IsHospitalAdmission <>1 
		and enc_fact.IsEdVisit <>1 
		and ( def.type like ('Encounter Diagnosis') or def.type like ('Billing Final Diagnosis'))
		and  def.status like ('Active')
		and  ( enc_dt.year >=2012 and enc_dt.year <= 2018) ;
USE ProjectD0C076; -- This is the location of the project
DROP TABLE IF EXISTS ProjectD0C076.dbo.filterCat4a;
Create table ProjectD0C076.dbo.filterCat4a
( patientdurablekey bigint,
  monthyear nvarchar(50),	
  year bigint,
  filter_cat tinyint
)
USE COSMOS;
INSERT INTO ProjectD0C076.dbo.filterCat4a
			(patientdurablekey
			 ,monthyear
			 ,year
			,filter_cat )
SELECT      patientdurablekey
			 ,monthyear
			 ,year
			,filter_cat
FROM  #Filter_cat4_1;
Select count(*) from ProjectD0C076.dbo.filterCat4a;

/*---------------------------------------------------------------------------------------------------------------------------------------------------------------*/
USE COSMOS;
/* Filter Category 4b:  Outpatient diagnosis of Type 2 Diabetes (E11)*/
Drop table if exists #Filter_cat4_2;
Select distinct  def.PatientDurableKey
				,enc_dt.MonthYear
				,enc_dt.Year
				,'4' as Filter_Cat
into #Filter_cat4_2
From  dbo.DiagnosisEventFact DEF
		JOIN ProjectD0C076.dbo.diagnosiscodes p_diagcode on (p_diagcode.DiagnosisKey = def.DiagnosisKey)
		join dbo.EncounterFact enc_fact on (enc_fact.EncounterKey = def.EncounterKey)
		join dbo.DateDim enc_dt on (enc_dt.datekey = enc_fact.datekey)
		join dbo.CohortDataMartX datamart on (datamart.PatientDurableKey = def.PatientDurableKey and datamart.IsOnDiabetesRegistry = 1)
where enc_fact.IsHospitalAdmission <>1 
		and enc_fact.IsEdVisit <>1 
		and ( def.type like ('Billing Final Diagnosis'))
		and  def.status like ('Active')
		and  ( enc_dt.year >=2019 and enc_dt.year <= 2021) ;
USE ProjectD0C076; -- This is the location of the project
DROP TABLE IF EXISTS ProjectD0C076.dbo.filterCat4b;
Create table ProjectD0C076.dbo.filterCat4b
( patientdurablekey bigint,
  monthyear nvarchar(50),	
  year bigint,
  filter_cat tinyint
)
USE COSMOS;
INSERT INTO ProjectD0C076.dbo.filterCat4b
			(patientdurablekey
			 ,monthyear
			 ,year
			,filter_cat )
SELECT      patientdurablekey
			 ,monthyear
			 ,year
			,filter_cat
FROM  #Filter_cat4_2;
Select  top 10 * from   ProjectD0C076.dbo.filterCat4b;
Drop table if exists #Filter_cat4_2;
Select count(*) from ProjectD0C076.dbo.filterCat4b;

/*---------------------------------------------------------------------------------------------------------------------------------------------------------------*/
USE COSMOS;
/* Filter Category 4C:  Outpatient diagnosis of Type 2 Diabetes (E11)*/

Drop table if exists #Filter_cat4_3;
Select distinct  def.PatientDurableKey
				,enc_dt.MonthYear
				,enc_dt.Year
				,'4' as Filter_Cat
into #Filter_cat4_3
From  dbo.DiagnosisEventFact DEF
		JOIN ProjectD0C076.dbo.diagnosiscodes p_diagcode on (p_diagcode.DiagnosisKey = def.DiagnosisKey)
		join dbo.EncounterFact enc_fact on (enc_fact.EncounterKey = def.EncounterKey)
		join dbo.DateDim enc_dt on (enc_dt.datekey = enc_fact.datekey)
		join dbo.CohortDataMartX datamart on (datamart.PatientDurableKey = def.PatientDurableKey and datamart.IsOnDiabetesRegistry = 1)
where enc_fact.IsHospitalAdmission <>1 
		and enc_fact.IsEdVisit <>1 
		and ( def.type like ('Encounter Diagnosis') or def.type like ('Billing Final Diagnosis'))
		and  def.status like ('Active')
		and  ( enc_dt.year >=2022 and enc_dt.year <= 2024) ;
USE ProjectD0C076; -- This is the location of the project
DROP TABLE IF EXISTS ProjectD3A05D.dbo.filterCat4c;
Create table ProjectD0C076.dbo.filterCat4c
( patientdurablekey bigint,
  monthyear nvarchar(50),	
  year bigint,
  filter_cat tinyint
)
USE COSMOS;
INSERT INTO ProjectD3A05D.dbo.filterCat4c
			(patientdurablekey
			 ,monthyear
			 ,year
			,filter_cat )
SELECT      patientdurablekey
			 ,monthyear
			 ,year
			,filter_cat
FROM  #Filter_cat4_3;


Select count(*) from #Filter_cat4_3;

/*---------------------------------------------------------------------------------------------------------------------------------------------------------------*//*---------------------------------------------------------------------------------------------------------------------------------------------------------------*/
/*---------------------------------------------------------------------------------------------------------------------------------------------------------------*//*---------------------------------------------------------------------------------------------------------------------------------------------------------------*/


-- Filter to create a datatable with the patients who have a prescription for the listed meds.
USE COSMOS;
Drop table if exists #Filter_Cat5a;
Select Distinct mof.PatientDurableKey
				,enc_dt.MonthYear
				,enc_dt.Year
			    ,meddim.SimpleGenericName
				,meds.flagged_PharmaceuticalClass
				
into #Filter_Cat5a
From DBO.MedicationOrderFact MOF
	 join dbo.DateDim enc_dt on (enc_dt.datekey = mof.StartDateKey)
	 join ProjectD0C076.dbo.medications meds on (meds.Medicationkey = mof.MedicationKey)
	 join dbo.CohortDataMartX datamart on (datamart.PatientDurableKey = mof.PatientDurableKey and datamart.IsOnDiabetesRegistry = 1)
	 join dbo.MedicationDim meddim on (meddim.MedicationKey =	mof.MedicationKey)
Where  enc_dt.year >= 2012 and  enc_dt.year <= 2024;
USE ProjectD0C076; -- This is the location of the project
DROP TABLE IF EXISTS ProjectD0C076.dbo.filterCat5a;
Create table ProjectD0C076.dbo.filterCat5a
( patientdurablekey bigint,
  monthyear nvarchar(50),	
  year bigint,
  SimpleGenericName nvarchar(300),
  flagged_PharmaceuticalClass nvarchar(300),

)
USE COSMOS;
INSERT INTO ProjectD0C076.dbo.filterCat5a
			(patientdurablekey
			 ,monthyear
			 ,year
			 ,SimpleGenericName
			 ,flagged_PharmaceuticalClass
			 )
SELECT      patientdurablekey
			 ,monthyear
			 ,year
			 ,SimpleGenericName
			 ,flagged_PharmaceuticalClass
			
FROM  ProjectD3A05D.dbo.filterCat5a;


Select count(*) from  ProjectD3A05D.dbo.filterCat5a;


-- Part 2 of the same filter table 
USE COSMOS;
Drop table if exists #Filter_Cat5b;
Select Distinct mof.PatientDurableKey
				,enc_dt.MonthYear
				,enc_dt.Year
				,meddim.SimpleGenericName
				,meds.flagged_PharmaceuticalClass
				,'5' Filter_cat
into #Filter_Cat5b
From DBO.MedicationOrderFact MOF
	 join dbo.DateDim enc_dt on (enc_dt.datekey = mof.StartDateKey)
	 join ProjectD0C076.dbo.medications meds on (meds.Medicationkey = mof.MedicationKey)
	 join dbo.CohortDataMartX datamart on (datamart.PatientDurableKey = mof.PatientDurableKey and datamart.IsOnDiabetesRegistry = 1)
	 join dbo.MedicationDim meddim on (meddim.MedicationKey =	mof.MedicationKey)
Where  enc_dt.year >= 2019 and  enc_dt.year <= 2022 ;


USE ProjectD3A05D; -- This is the location of the project
DROP TABLE IF EXISTS ProjectD3A05D.dbo.filterCat5b_2;
Create table ProjectD3A05D.dbo.filterCat5b_2
( patientdurablekey bigint,
  monthyear nvarchar(50),	
  year bigint,
  SimpleGenericName nvarchar(300),
  flagged_PharmaceuticalClass nvarchar(300),
  filter_cat tinyint
)
USE COSMOS;
INSERT INTO ProjectD3A05D.dbo.filterCat5b_2
			(patientdurablekey
			 ,monthyear
			 ,year
			 ,SimpleGenericName
			 ,flagged_PharmaceuticalClass
			,filter_cat )
SELECT      patientdurablekey
			 ,monthyear
			 ,year
			 ,SimpleGenericName
			 ,flagged_PharmaceuticalClass
			,filter_cat
FROM  #Filter_cat5b
where year >2020;


-- Part 3 of the same filter table 
USE COSMOS;
Drop table if exists #Filter_Cat5c;
Select Distinct mof.PatientDurableKey
				,enc_dt.MonthYear
				,enc_dt.Year
				,meddim.SimpleGenericName
				,meds.flagged_PharmaceuticalClass
				,'5' Filter_cat
into #Filter_Cat5c
From DBO.MedicationOrderFact MOF
	 join dbo.DateDim enc_dt on (enc_dt.datekey = mof.StartDateKey)
	 join ProjectD0C076.dbo.medications meds on (meds.Medicationkey = mof.MedicationKey)
	 join dbo.CohortDataMartX datamart on (datamart.PatientDurableKey = mof.PatientDurableKey and datamart.IsOnDiabetesRegistry = 1)
	 join dbo.MedicationDim meddim on (meddim.MedicationKey =	mof.MedicationKey)
Where  enc_dt.year >= 2023 and  enc_dt.year <= 2024 ;

USE ProjectD3A05D; -- This is the location of the project
DROP TABLE IF EXISTS ProjectD3A05D.dbo.filterCat5c;
Create table ProjectD0C076.dbo.filterCat5c
( patientdurablekey bigint,
  monthyear nvarchar(50),	
  year bigint,
  SimpleGenericName nvarchar(300),
  flagged_PharmaceuticalClass nvarchar(300),
  filter_cat tinyint
)
USE COSMOS;
INSERT INTO ProjectD3A05D.dbo.filterCat5c
			(patientdurablekey
			 ,monthyear
			 ,year
			 ,SimpleGenericName
			 ,flagged_PharmaceuticalClass
			,filter_cat )
SELECT      patientdurablekey
			 ,monthyear
			 ,year
			 ,SimpleGenericName
			 ,flagged_PharmaceuticalClass
			,filter_cat
FROM  #Filter_cat5c;

Select count(*) from ProjectD0C076.dbo.filterCat5c;
/*---------------------------------------------------------------------------------------------------------------------------------------------------------------*//*---------------------------------------------------------------------------------------------------------------------------------------------------------------*/
/*---------------------------------------------------------------------------------------------------------------------------------------------------------------*//*---------------------------------------------------------------------------------------------------------------------------------------------------------------*/
USE COSMOS;
/* Filter Category 6a:  Inpatient diagnosis of Type 2 Diabetes (E11)*/

Drop table if exists #Filter_cat6_1;
Select distinct  def.PatientDurableKey
				,enc_dt.MonthYear
				,enc_dt.Year
				,'6' as Filter_Cat
into #Filter_cat6_1
From dbo.DiagnosisEventFact DEF
		JOIN ProjectD0C076.dbo.diagnosiscodes p_diagcode on (p_diagcode.DiagnosisKey = def.DiagnosisKey)
		join dbo.EncounterFact enc_fact on (enc_fact.EncounterKey = def.EncounterKey)
		join dbo.DateDim enc_dt on (enc_dt.datekey = enc_fact.datekey)
		join dbo.CohortDataMartX datamart on (datamart.PatientDurableKey = def.PatientDurableKey and datamart.IsOnDiabetesRegistry = 1)
where enc_fact.IsHospitalAdmission =1 
		and enc_fact.IsEdVisit <>1 
		and ( def.type like ('Encounter Diagnosis') or def.type like ('Billing Final Diagnosis'))
		and  def.status like ('Active')
		and  ( enc_dt.year >=2012 and enc_dt.year <= 2018) ;
USE ProjectD0C076; -- This is the location of the project
DROP TABLE IF EXISTS ProjectD0C076.dbo.filterCat6a;
Create table ProjectD0C076.dbo.filterCat6a
( patientdurablekey bigint,
  monthyear nvarchar(50),	
  year bigint,
  filter_cat tinyint
)
USE COSMOS;
INSERT INTO ProjectD0C076.dbo.filterCat6a
			(patientdurablekey
			 ,monthyear
			 ,year
			,filter_cat )
SELECT      patientdurablekey
			 ,monthyear
			 ,year
			,filter_cat
FROM  #Filter_cat6_1;
Select * from ProjectD0C076.dbo.filterCat6a;

/*---------------------------------------------------------------------------------------------------------------------------------------------------------------*/
USE COSMOS;
/* Filter Category 6b:  Outpatient diagnosis of Type 2 Diabetes (E11)*/
Drop table if exists #Filter_cat6_2;
Select distinct  def.PatientDurableKey
				,enc_dt.MonthYear
				,enc_dt.Year
				,'6' as Filter_Cat
into #Filter_cat6_2
From  dbo.DiagnosisEventFact DEF
		JOIN ProjectD0C076.dbo.diagnosiscodes p_diagcode on (p_diagcode.DiagnosisKey = def.DiagnosisKey)
		join dbo.EncounterFact enc_fact on (enc_fact.EncounterKey = def.EncounterKey)
		join dbo.DateDim enc_dt on (enc_dt.datekey = enc_fact.datekey)
		join dbo.CohortDataMartX datamart on (datamart.PatientDurableKey = def.PatientDurableKey and datamart.IsOnDiabetesRegistry = 1)
where enc_fact.IsHospitalAdmission =1
		and enc_fact.IsEdVisit <>1 
		and ( def.type like ('Billing Final Diagnosis'))
		and  def.status like ('Active')
		and  ( enc_dt.year >=2019 and enc_dt.year <= 2024) ;
USE ProjectD0C076; -- This is the location of the project
DROP TABLE IF EXISTS ProjectD0C076.dbo.filterCat6b;
Create table ProjectD0C076.dbo.filterCat6b
( patientdurablekey bigint,
  monthyear nvarchar(50),	
  year bigint,
  filter_cat tinyint
)
USE COSMOS;
INSERT INTO ProjectD0C076.dbo.filterCat6b
			(patientdurablekey
			 ,monthyear
			 ,year
			,filter_cat )
SELECT      patientdurablekey
			 ,monthyear
			 ,year
			,filter_cat
FROM  #Filter_cat6_2;
Drop table if exists #Filter_cat6_2;
Select count(*) from ProjectD0C076.dbo.filterCat6b;
/*---------------------------------------------------------------------------------------------------------------------------------------------------------------*//*---------------------------------------------------------------------------------------------------------------------------------------------------------------*/
/*---------------------------------------------------------------------------------------------------------------------------------------------------------------*//*---------------------------------------------------------------------------------------------------------------------------------------------------------------*/

Create table ProjectD0C076.dbo.Combined_1
( patientdurablekey bigint,
  monthyear nvarchar(50),	
  year bigint,
  filter_cat tinyint
)
