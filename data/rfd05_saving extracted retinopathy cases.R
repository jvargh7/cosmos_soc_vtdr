rm(list=ls());gc();source(".Rprofile")


dbGetQuery(con_ProjectD0C076,"SELECT * 
           FROM dbo.DR_PATIENTS") %>% 
  mutate(diag_date = ymd(diag_date)) %>% 
  mutate(Year = year(diag_date)) %>% 
  write_dataset(.,path=paste0(path_retinopathy_fragmentation_folder,"/working/rfd05"),partitioning = "Year")

open_dataset(paste0(path_retinopathy_fragmentation_folder,"/working/rfd05"),format = "parquet",partitioning = "Year") %>% 
  dim()

open_dataset(paste0(path_retinopathy_fragmentation_folder,"/working/rfd05"),format = "parquet",partitioning = "Year") %>% 
  dplyr::filter(str_detect(ICD_Value,"E10")) %>% 
  head(n = 1000) %>% 
  collect() %>% View()

open_dataset(paste0(path_retinopathy_fragmentation_folder,"/working/rfd05"),format = "parquet",partitioning = "Year") %>% 
  to_duckdb() %>% 
  dplyr::filter(str_detect(ICD_Value,"(E10|E11)\\.(319|329|339)")) %>% 
  group_by(PatientDurableKey) %>% 
  dplyr::filter(StartDateKey == min(StartDateKey),StartDateKey > 20150000 & StartDateKey < 20230000,ICD_Type == "ICD-10-CM") %>% 
  ungroup() %>%
  group_by(PatientDurableKey,StartDateKey) %>% 
  summarize(ICD_Value = str_flatten(ICD_Value,collapse=";")) %>% 
  ungroup() %>% 
  collect() %>% 
  mutate(t1dm = case_when(str_detect(ICD_Value,"E10") ~ 1,
                          TRUE ~ 0)) %>% 
  group_by(t1dm) %>% 
  tally()
