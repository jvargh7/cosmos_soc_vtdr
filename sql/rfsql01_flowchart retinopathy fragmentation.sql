USE COSMOS
SELECT COUNT_BIG(DurableKey)
FROM dbo.PatientDim
WHERE DurableKey > 0

/****** Script for SelectTopNRows command from SSMS  ******/
-- T2DM: SUPREMEDM
SELECT COUNT_BIG(patientdurablekey)
FROM [ProjectD0C076].[ET4003\shdw_1208_jvargh1].[RFD03]

SELECT COUNT_BIG(*)
FROM (SELECT DISTINCT PatientDurableKey
FROM dbo.DiagnosisEventFact def
	INNER JOIN dbo.DateDim dd
	   ON def.StartDateKey = dd.DateKey
	 INNER JOIN dbo.DiagnosisTerminologyDim dtd
	   ON def.DiagnosisKey = dtd.DiagnosisKey
WHERE (def.StartDateKey > 20120000 AND def.StartDateKey < 20240000) AND
	dtd.Type = 'ICD-10-CM' AND SUBSTRING(dtd.Value,1,3) = 'E10') unique_pdk


-- rfd05_saving extracted retinopathy cases.R has next step

-- rfa01_descriptive characteristics.R has next step