/* Create a subset of tha patients from SUPEREME DM that have been diagnosed with Diabetic REtinopathy*/
-- Cohort with data of patients of interest  : [ProjectD0C076].[ET4003\shdw_1208_jvargh1].[RFD03]
-- Pull the patients from the project folder into the local instance of the database.

USE COSMOS;
DROP TABLE IF EXISTS #SUPREME_BASE;
SELECT PatientDurableKey
	   ,criterion1_date
	   ,criterion2_date
	   ,diagnosis_date
	   ,diagnosis_datekey
INTO #SUPREME_BASE
FROM [ProjectD0C076].[ET4003\shdw_1208_jvargh1].[rfd03] ;

DROP TABLE IF EXISTS #dm_patients 
SELECT combined.PatientDurableKey
INTO #dm_patients
FROM ( 
	SELECT sb.PatientDurableKey
	FROM #SUPREME_BASE sb

	UNION ALL
	
	SELECT DISTINCT PatientDurableKey
	FROM dbo.DiagnosisEventFact def
		INNER JOIN (
                    SELECT * 
                    FROM(
                          SELECT dtd_internal2.DiagnosisKey, dtd_internal2.Type, dtd_internal2.Value, 
                          SUBSTRING(dtd_internal2.Value,1,3) AS Value_Grouper
                          FROM dbo.DiagnosisTerminologyDim dtd_internal2
                          ) dtd_internal
                    WHERE dtd_internal.Value_Grouper IN ('E10')) dtd 
          ON def.DiagnosisKey = dtd.DiagnosisKey
	WHERE def.StartDateKey > 20120000 AND def.StartDateKey < 20240000
	AND dtd.Type = 'ICD-10-CM'
) combined 


SELECT count_big(*)
FROM #dm_patients

/* Creating the table that has all the patients who have been diagnosed with Diabetic Retinopathy*/
DROP TABLE IF EXISTS #DR_pts
Select Distinct dp.PatientDurableKey,Datedim.DateValue Diag_date, 
def.StartDateKey as StartDateKey, DD.Value as ICD_Value, DD.Type as ICD_Type
into #DR_pts
From #dm_patients dp
	 INNER JOIN  cosmos.dbo.DiagnosisEventFact DEF ON DEF.PatientDurableKey = dp.PatientDurableKey
	 JOIN COSMOS.DBO.DiagnosisTerminologyDim DD ON DD.DiagnosisKey = DEF.DiagnosisKey
	 join cosmos.dbo.datedim datedim on datedim.DateKey = def.StartDateKey
Where DD.Value IN (
'E08.21', 'E08.22', 'E08.29', 'E08.31', 'E08.311', 'E08.319', 'E08.321', 'E08.3211', 'E08.3212', 
'E08.3213', 'E08.3219', 'E08.329', 'E08.3291', 'E08.3292', 'E08.3293', 'E08.3299', 'E08.331', 'E08.3311', 'E08.3312', 
'E08.3313', 'E08.3319', 'E08.339', 'E08.3391', 'E08.3392', 'E08.3393', 'E08.3399', 'E08.341', 'E08.3411', 'E08.3412', 
'E08.3413', 'E08.3419', 'E08.349', 'E08.3491', 'E08.3492', 'E08.3493', 'E08.3499', 'E08.351', 'E08.3511', 'E08.3512', 
'E08.3513', 'E08.3519', 'E08.352', 'E08.3521', 'E08.3522', 'E08.3523', 'E08.3529', 'E08.3531', 'E08.3532', 'E08.3533', 
'E08.3539', 'E08.3541', 'E08.3542', 'E08.3543', 'E08.3549', 'E08.3551', 'E08.3552', 'E08.3553', 'E08.3559', 'E08.359', 
'E08.3591', 'E08.3592', 'E08.3593', 'E08.3599', 'E08.36', 'E08.37X1', 'E08.37X2', 'E08.37X3', 'E08.37X9', 'E08.39', 'E08.40', 
'E08.41', 'E08.42', 'E08.43', 'E08.44', 'E08.49', 'E08.51', 'E08.52', 'E08.610', 'E08.618', 'E08.620', 'E09.311', 'E09.319', 
'E09.321', 'E09.3211', 'E09.3212', 'E09.3213', 'E09.3219', 'E09.329', 'E09.3291', 'E09.3292', 'E09.3293', 'E09.3299', 'E09.331', 
'E09.3311', 'E09.3312', 'E09.3313', 'E09.3319', 'E09.339', 'E09.3391', 'E09.3392', 'E09.3393', 'E09.3399', 'E09.341', 'E09.3411', 
'E09.3412', 'E09.3413', 'E09.3419', 'E09.349', 'E09.3491', 'E09.3492', 'E09.3493', 'E09.3499', 'E09.351', 'E09.3511', 'E09.3512', 
'E09.3513', 'E09.3519', 'E09.3521', 'E09.3522', 'E09.3523', 'E09.3529', 'E09.3531', 'E09.3532', 'E09.3533', 'E09.3539', 'E09.3541', 
'E09.3542', 'E09.3543', 'E09.3549', 'E09.3551', 'E09.3552', 'E09.3553', 'E09.3559', 'E09.359', 'E09.3591', 'E09.3592', 'E09.3593', 
'E09.3599', 'E09.37X1', 'E09.37X2', 'E09.37X3', 'E09.37X9', 'E10.31', 'E10.311', 'E10.319', 'E10.32', 'E10.321', 'E10.3211', 
'E10.3212', 'E10.3213', 'E10.3219', 'E10.329', 'E10.3291', 'E10.3292', 'E10.3293', 'E10.3299', 'E10.331', 'E10.3311', 
'E10.3312', 'E10.3313', 'E10.3319', 'E10.339', 'E10.3391', 'E10.3392', 'E10.3393', 'E10.3399', 'E10.34', 'E10.341', 
'E10.3411', 'E10.3412', 'E10.3413', 'E10.3419', 'E10.349', 'E10.3491', 'E10.3492', 'E10.3493', 'E10.3499', 'E10.35', 
'E10.351', 'E10.3511', 'E10.3512', 'E10.3513', 'E10.3519', 'E10.3521', 'E10.3522', 'E10.3523', 'E10.3529', 'E10.3531', 
'E10.3532', 'E10.3533', 'E10.3539', 'E10.3541', 'E10.3542', 'E10.3543', 'E10.3549', 'E10.3551', 'E10.3552', 'E10.3553', 
'E10.3559', 'E10.359', 'E10.3591', 'E10.3592', 'E10.3593', 'E10.3599', 'E10.37X1', 'E10.37X2', 'E10.37X3', 'E10.37X9', 
'E11.31', 'E11.311', 'E11.319', 'E11.32', 'E11.321', 'E11.3211', 'E11.3212', 'E11.3213', 'E11.3219', 'E11.329', 'E11.3291', 
'E11.3292', 'E11.3293', 'E11.3299', 'E11.33', 'E11.331', 'E11.3311', 'E11.3312', 'E11.3313', 'E11.3319', 'E11.339', 'E11.3391', 
'E11.3392', 'E11.3393', 'E11.3399', 'E11.34', 'E11.341', 'E11.3411', 'E11.3412', 'E11.3413', 'E11.3419', 'E11.349', 'E11.3491', 
'E11.3492', 'E11.3493', 'E11.3499', 'E11.35', 'E11.351', 'E11.3511', 'E11.3512', 'E11.3513', 'E11.3519', 'E11.3521', 'E11.3522', 
'E11.3523', 'E11.3529', 'E11.3531', 'E11.3532', 'E11.3533', 'E11.3539', 'E11.3541', 'E11.3542', 'E11.3543', 'E11.3549', 'E11.355', 
'E11.3551', 'E11.3552', 'E11.3553', 'E11.3559', 'E11.359', 'E11.3591', 'E11.3592', 'E11.3593', 'E11.3599', 'E11.37X1', 'E11.37X2', 
'E11.37X3', 'E11.37X9', 'E13.311', 'E13.319', 'E13.321', 'E13.3211', 'E13.3212', 'E13.3213', 'E13.3219', 'E13.329', 'E13.3291', 'E13.3292', 
'E13.3293', 'E13.3299', 'E13.331', 'E13.3311', 'E13.3312', 'E13.3313', 'E13.3319', 'E13.339', 'E13.3391', 'E13.3392', 'E13.3393', 'E13.3399', 
'E13.341', 'E13.3411"', 'E13.3412', 'E13.3413', 'E13.3419', 'E13.349', 'E13.3491', 'E13.3492', 'E13.3493', 'E13.3499', 'E13.351', 
'E13.3511', 'E13.3512', 'E13.3513', 'E13.3519', 'E13.3521', 'E13.3522', 'E13.3523', 'E13.3529', 'E13.3531', 'E13.3532', 'E13.3533', 
'E13.3539', 'E13.3541', 'E13.3542', 'E13.3543', 'E13.3549', 'E13.3551', 'E13.3552', 'E13.3553', 'E13.3559', 'E13.359', 'E13.3591', 
'E13.3592', 'E13.3593', 'E13.3599', 'E13.37X1', 'E13.37X2', 'E13.37X3', 'E13.37X9')
		 AND DD.Type IN ('ICD-10-CM')
		 AND def.StartDateKey > 20100000;
Drop table if exists PROJECTD0C076.dbo.DR_PATIENTS;
CREATE TABLE PROJECTD0C076.dbo.DR_PATIENTS
(
   PatientDurableKey BIGINT,
   diag_date date,
   StartDateKey BIGINT,
   ICD_Value nvarchar(50),
   ICD_Type nvarchar(50)
)
insert into PROJECTD0C076.dbo.DR_PATIENTS
(
	PatientDurableKey
	,diag_date, StartDateKey, ICD_Value, ICD_Type
)  
select PatientDurableKey , Diag_date, StartDateKey, ICD_Value, ICD_Type
from #DR_pts;
select * from PROJECTD0C076.dbo.DR_PATIENTS;

/* JV Commenting out
--select * from #DR_pts order by PATIENTDURABLEKEY, diag_date asc;
/* Create a list of the first billings for the patients and then check to see if they had  1 outpatient visit per year for the 2 years before the date of first billing*/
drop table if exists #DR_Incidence;
with tabx as
(
Select  *
	from  PROJECTD0C076.dbo.DR_PATIENTS base 
	where diag_date is not null	 
)
,
tab1 as
(	Select           base.patientdurablekey	
					,min(diag_date) as first_DR_Dt
	from  tabx base 
	group by base.patientdurablekey	
)
,
tab2 as
(		select base.PATIENTDURABLEKEY
			   ,base.first_DR_Dt
			   ,dd.Year yr_count
		From tab1 base
			 join cosmos.dbo.EncounterFact ef on ef.PatientDurableKey = base.PATIENTDURABLEKEY and ef.Date between base.first_DR_Dt and dateadd(year,-2,base.first_DR_Dt)
			 join cosmos.dbo.DateDim dd on dd.DateKey = ef.DateKey
		where ef.IsOutpatientFaceToFaceVisit = 1
)
select * into #DR_Incidence from tab2;


drop table  ;
,
tab3 as
(
select distinct  patientdurablekey	
				,first_DR_Dt
				,count(distinct yr_count) as yr_counter
From Tab2
group by Tab2.patientdurablekey	,Tab2.first_DR_Dt
)
select  distinct *
into #DR_Incidence
from tab3
where yr_counter >1 ;
Drop table if exists PROJECTD0C076.dbo.DR_incidence;
CREATE TABLE PROJECTD0C076.dbo.DR_incidence
(  PatientDurableKey BIGINT,
   first_dr_dt date,
   yr_counter BIGINT
)
insert into PROJECTD0C076.dbo.DR_incidence
(
	PatientDurableKey
	,first_DR_Dt
	,yr_counter
)  
select PatientDurableKey
	,first_DR_Dt
	,yr_counter
from #DR_Incidence;

select * from PROJECTD0C076.dbo.DR_PATIENTS where diag_date is null ;

*/