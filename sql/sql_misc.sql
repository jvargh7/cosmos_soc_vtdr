/****** Script for SelectTopNRows command from SSMS  ******/
SELECT TOP (1000) [PatientDurableKey]
      ,[diag_date]
      ,[StartDateKey]
      ,[ICD_Value]
      ,[ICD_Type]
  FROM [ProjectD0C076].[dbo].[DR_PATIENTS]
 
 ORDER BY [PatientDurableKey], [StartDateKey]

 USE COSMOS
 SELECT TOP 1000 *
 FROM EncounterFact
 WHERE PatientDurableKey > 0

 USE COSMOS
 SELECT COUNT(DurableKey)--TOP 1000 *
 FROM ProviderDim
 -- WHERE DurableKey > 0 AND Type <> '*Unknown'
 WHERE DurableKey > 0 AND Type = '*Unknown'

 SELECT TOP 1000 *
 FROM ProcedureEventFact
 WHERE PatientDurableKey > 0 AND ProcedureStartDateKey > 0 AND ProcedureDurableKey > 0

  SELECT TOP 1000 *
 FROM ProcedureDim
 WHERE DurableKey > 0

   SELECT MIN(CodeSet), Count(*)
 FROM ProcedureDim
 WHERE DurableKey > 0
 GROUP BY CodeSet

SELECT TOP 1000 *
FROM ProcedureDim
WHERE DurableKey > 0 AND CodeSet = N'CPT(R)' AND CptCode IN ('67028','67030','67031','67036','99215','99242','2022F','2023F','2024F')

   SELECT MIN(CodeSet), Count(*)
 FROM ProcedureTerminologyDim
 GROUP BY CodeSet

