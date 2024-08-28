rm(list=ls());gc();source(".Rprofile")

rfd05 = open_dataset(paste0(path_retinopathy_fragmentation_folder,"/working/rfd05"),format = "parquet",partitioning = "Year") %>% 
  mutate(PatientDurableKey = as.numeric(PatientDurableKey))

rfd05 %>% 
  dplyr::filter(Year >= 2012, Year <= 2023) %>% 
  # collect() %>% 
  dim()

rfd05 %>%
  dplyr::filter(Year >= 2012, Year <= 2023) %>% 
  distinct(PatientDurableKey) %>% 
  collect() %>% 
  dim()


rfd07a = open_dataset(paste0(path_retinopathy_fragmentation_folder,"/working/rfd07a"),partitioning = c("Year")) %>% 
  mutate(PatientDurableKey = as.numeric(PatientDurableKey)) %>% 
  group_by(PatientDurableKey,StartDateKey) %>% 
  tally() 
rfd07b = open_dataset(paste0(path_retinopathy_fragmentation_folder,"/working/rfd07b"),partitioning = c("Year")) %>% 
  mutate(PatientDurableKey = as.numeric(PatientDurableKey)) %>% 
  group_by(PatientDurableKey,StartDateKey) %>% 
  tally()

rfd07a %>% 
  head() %>% 
  collect()

rfd05 %>% 
  head() %>% collect()

rfd06 = open_dataset(paste0(path_retinopathy_fragmentation_folder,"/working/rfd06"),format="parquet",partitioning = "ValidatedStateOrProvince_X") %>% 
  mutate(BirthDate = ymd(BirthDate),
         PatientDurableKey = as.numeric(PatientDurableKey)) %>% 
  mutate(AdultDate = BirthDate + dyears(18))

retinopathy = rfd05 %>% 
  left_join(rfd06 %>% 
              dplyr::select(PatientDurableKey,AdultDate,BirthDate),
            by="PatientDurableKey")  %>% 
    left_join(rfd07a %>% 
              rename(count_minus2y = n),
            by=c("PatientDurableKey","StartDateKey")) %>%
  left_join(rfd07b %>% 
              rename(count_minus1y = n),
            by=c("PatientDurableKey","StartDateKey")) %>% 
  to_duckdb()  %>% 
  # dplyr::filter(str_detect(ICD_Value,"(E10|E11)\\.(31|32|33|34|35|37)")) %>% 
  # After meeting with AH and FJP by JSV on 17th May 2024
  # Restrict to Nild/Moderate NPDR without DME
  dplyr::filter(str_detect(ICD_Value,"(E10|E11)\\.(319|329|339)")) %>% 
  group_by(PatientDurableKey) %>%
  mutate(n_dr_dx = n()) %>% 
  dplyr::filter(StartDateKey == min(StartDateKey)) %>% 
  ungroup() %>% 
  mutate(count_minus2y = case_when(is.na(count_minus2y) ~ 0,
                                   TRUE ~ count_minus2y),
         count_minus1y = case_when(is.na(count_minus1y) ~ 0,
                                   TRUE ~ count_minus1y)) %>% 
  dplyr::filter(StartDateKey > 20150000 & StartDateKey < 20221200,
                diag_date >= AdultDate,
                count_minus2y >= 1, count_minus1y >= 1) %>% 
  group_by(PatientDurableKey) %>% 
  dplyr::filter(StartDateKey == min(StartDateKey)) %>% 
  ungroup() %>%
  distinct(PatientDurableKey,StartDateKey,diag_date,AdultDate,BirthDate,n_dr_dx)  %>% 
  collect() %>% 
  mutate(age = as.numeric(difftime(diag_date,BirthDate,units="days")/365.25)) %>% 
  dplyr::filter(age >= 18, age <100)

# retinopathy_with_counts = 

  
retinopathy %>% head(n = 1000)  %>% View()
retinopathy %>% tally() 

retinopathy %>% 
  mutate(StartDateKey_ymd = ymd(StartDateKey)) %>% 
  write_parquet(.,paste0(path_retinopathy_fragmentation_folder,"/working/rfd08/eligible patients.parquet"))
retinopathy %>% 
  dplyr::select(PatientDurableKey,StartDateKey) %>% 
  write_csv(.,paste0(path_retinopathy_fragmentation_folder,"/working/rfd08/eligible patients.csv"))



