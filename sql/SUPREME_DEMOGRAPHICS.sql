/* Code to extract the Demographics Data from Cosmos*/
-- Cohort with data of patients of interest  : [ProjectD0C076].[ET4003\shdw_1208_jvargh1].[RFD03]
USE COSMOS;
DROP TABLE IF EXISTS #SUPREME_BASE;
SELECT TRY_CAST(patientdurablekey AS bigint) AS PATIENTDURABLEKEY
	   ,criterion1_date
	   ,criterion2_date
	   ,diagnosis_date
	   ,diagnosis_datekey
INTO #SUPREME_BASE
FROM [ProjectD0C076].[ET4003\shdw_1208_jvargh1].[RFD03] ;

/* Pull the following Demographics Data for the patients of intetrest using the Patient durbable key*/
SELECT distinct  base.patientdurablekey
				,pd.BirthDate
				,pd.DeathDate
				,pd.[Status]
				,pd.Country
				,pd.ValidatedStateOrProvince_X
				,pd.ValidatedStateOrProvinceAbbreviation_X
				,pd.Ethnicity
				,pd.FirstRace
				,pd.SecondRace
				,pd.ThirdRace
				,pd.Sex
				,pd.GenderIdentity
				,pd.SexAssignedAtBirth
				,pd.MaritalStatus
				,pd.SviHouseholdCharacteristicsPctlRankByZip2020_X
				,pd.SviHousingTypeTransportationPctlRankByZip2020_X
				,pd.SviOverallPctlRankByZip2020_X
				,pd.SviRacialEthnicMinorityStatusPctlRankByZip2020_X
				,pd.SviSocioeconomicPctlRankByZip2020_X
INTO #SUPREME_DEMO
FROM #SUPREME_BASE base
	 JOIN COSMOS.DBO.PatientDim PD ON pd.DurableKey = base.patientdurablekey
Where IsCurrent = 1
	  AND IsValid = 1;
	
	Select Ethnicity, count(Ethnicity) from #SUPREME_DEMO group by country;
/* Clean the demographics data*/

Select distinct  patientdurablekey
				 ,birthdate
				 ,deathdate
				 ,case when [status] like('Deceased') then 1 else 0 end as deceased
				 ,case when Country like('United States of America') then 1 
						else case when Country like('Other') then 2
						 else 3 end end as country
				,ValidatedStateOrProvinceAbbreviation_X as state_cd
				,
				,

into #SUPREME_DEMO_1
From #SUPREME_DEMO



/* Push the data into a stored database in the Project folder*/
DROP TABLE IF EXISTS ProjectD0C076.dbo.Demographics;
Create table ProjectD0C076.dbo.demographics
( patientdurablekey bigint,
  birthdate date,
  deathdate date,
  [status] varchar,
  country varchar,
  ValidatedStateOrProvince_X varchar,
  ValidatedStateOrProvinceAbbreviation_X nvarchar,
  ethnicity varchar,
  firstrace varchar,
  Secondrace varchar,
  thirdrace varchar,
  sex varchar,
  genderidentity varchar,
  sexassignedatbirth varchar,
  maritalstatus varchar,
  SviHouseholdCharacteristicsPctlRankByZip2020_X decimal,
  SviHousingTypeTransportationPctlRankByZip2020_X decimal,
  SviOverallPctlRankByZip2020_X decimal,
  SviRacialEthnicMinorityStatusPctlRankByZip2020_X decimal,
  SviSocioeconomicPctlRankByZip2020_X decimal
)
INSERT INTO ProjectD0C076.dbo.Demographics
(	                patientdurablekey,
					birthdate,
					deathdate,
					status,
					country,
					ValidatedStateOrProvince_X,
					ValidatedStateOrProvinceAbbreviation_X ,
					ethnicity,
					firstrace,
					Secondrace,
					thirdrace ,
					sex ,
					genderidentity ,
					sexassignedatbirth,
					maritalstatus ,
					SviHouseholdCharacteristicsPctlRankByZip2020_X ,
					SviHousingTypeTransportationPctlRankByZip2020_X ,
					SviOverallPctlRankByZip2020_X ,
					SviRacialEthnicMinorityStatusPctlRankByZip2020_X ,
					SviSocioeconomicPctlRankByZip2020_X 
)
SELECT			    patientdurablekey,
					birthdate,
					deathdate,
					status,
					country,
					ValidatedStateOrProvince_X,
					ValidatedStateOrProvinceAbbreviation_X ,
					ethnicity,
					firstrace,
					Secondrace,
					thirdrace ,
					sex ,
					genderidentity ,
					sexassignedatbirth,
					maritalstatus ,
					SviHouseholdCharacteristicsPctlRankByZip2020_X ,
					SviHousingTypeTransportationPctlRankByZip2020_X ,
					SviOverallPctlRankByZip2020_X ,
					SviRacialEthnicMinorityStatusPctlRankByZip2020_X ,
					SviSocioeconomicPctlRankByZip2020_X 
FROM #SUPREME_DEMO;
Select * from ProjectD0C076.dbo.diagnosiscodes;





Select top (1000)* from  #SUPREME_BASE order by PATIENTDURABLEKEY;

Select country, count(Country) from #SUPREME_DEMO group by country;
Drop table #DR_Pts;


