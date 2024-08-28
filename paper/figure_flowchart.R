rm(list=ls());gc();source(".Rprofile")

rfd04 <- open_dataset(paste0(path_retinopathy_fragmentation_folder,"/working/rfd04"),format="parquet") %>% collect() %>% 
  mutate(PatientDurableKey = as.numeric(PatientDurableKey))

rfd08 <- open_dataset(paste0(path_retinopathy_fragmentation_folder,"/working/rfd08/eligible patients.parquet")) %>% 
  mutate(PatientDurableKey = as.numeric(PatientDurableKey)) %>% 
  mutate(YearMonth = str_sub(as.character(StartDateKey),1,6),
         StartDateKey_plus1y = StartDateKey + 10000,
         StartDateKey_plus2y = StartDateKey + 20000
  )
rfd08 %>% dim()

rfd08 %>% 
  inner_join(rfd04,
             by="PatientDurableKey") %>%
  collect() %>% 
  dim()

analytic_before_historycheck <- readRDS(paste0(path_retinopathy_fragmentation_folder,"/working/rfa001_sample before history check.RDS"))
table(analytic_before_historycheck$PatientDurableKey %in% rfd04$PatientDurableKey)

analytic_after_historycheck = readRDS(paste0(path_retinopathy_fragmentation_folder,"/working/rfa001_analytic sample.RDS")) 
table(analytic_after_historycheck$dx_detected_t1dm)

source("analysis/rfa_analytic sample preprocessing.R")
table(analytic$dx_detected_t1dm)