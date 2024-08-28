

dbGetQuery(con_Cosmos,"SELECT DISTINCT PatientDurableKey
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
	AND dtd.Type = 'ICD-10-CM'") %>% 
  write_dataset(.,path=paste0(path_retinopathy_fragmentation_folder,"/working/rfd04"))

open_dataset(paste0(path_retinopathy_fragmentation_folder,"/working/rfd04"),format="parquet") %>% 
  tally() %>% 
  collect()
