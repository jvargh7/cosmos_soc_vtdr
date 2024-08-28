rm(list=ls());gc();source(".Rprofile")

cp1 <- bind_rows(
  read_parquet(paste0(path_retinopathy_fragmentation_folder,"/working/rfd01/filterCat6a.parquet")),
  read_parquet(paste0(path_retinopathy_fragmentation_folder,"/working/rfd01/filterCat6b.parquet"))) %>% 
  mutate(my = my(monthyear)) %>% 
  group_by(patientdurablekey) %>%
  dplyr::summarize(n_dm_diagnosis = n(),
                   criterion1_date = min(my))  %>%
  mutate(
    diagnosis_date = criterion1_date,
    criterion2_date = NA_Date_) %>%
  mutate(criterion1_date_minus549 = criterion1_date - dmonths(18)) %>% 
  collect()

write_parquet(cp1,paste0(path_retinopathy_fragmentation_folder,"/working/rfd03/cp1 before encounter check.parquet"))
saveRDS(cp1,paste0(path_retinopathy_fragmentation_folder,"/working/rfd03/cp1 before encounter check.RDS"))
write_csv(cp1,paste0(path_retinopathy_fragmentation_folder,"/working/rfd03/cp1 before encounter check.csv"))

# CP2------------
rm(list=ls());gc();source(".Rprofile")

filterCat1 <- open_dataset(paste0(path_retinopathy_fragmentation_folder,"/working/rfd01/filterCat1.parquet"),
                           schema = schema(patientdurablekey = int64(),
                                           monthyear = string(),
                                           hba1c = double())) %>% 
  dplyr::select(patientdurablekey,monthyear) %>% 
  mutate(hba1c = 1)

filterCat2 <- open_dataset(paste0(path_retinopathy_fragmentation_folder,"/working/rfd01/filterCat2.parquet"),
                           schema = schema(patientdurablekey = int64(),
                                           monthyear = string(),
                                           fpg = double()))%>% 
  dplyr::select(patientdurablekey,monthyear) %>% 
  mutate(fpg = 1) 


filterCat3 <- open_dataset(paste0(path_retinopathy_fragmentation_folder,"/working/rfd01/filterCat3.parquet"),
                           schema = schema(patientdurablekey = int64(),
                                           monthyear = string(),
                                           rpg = double())) %>%
  dplyr::select(patientdurablekey,monthyear) %>% 
  mutate(rpg = 1) 

filterCat4 <- open_dataset(paste0(path_retinopathy_fragmentation_folder,"/working/rfd02/filterCat4"),partitioning = "monthyear",
                           schema = schema(patientdurablekey = int64(),
                                           monthyear = string(),
                                           op = double())) %>%
  dplyr::select(patientdurablekey,monthyear) %>% 
  mutate(op = 1) 
filterCat5 <- open_dataset(paste0(path_retinopathy_fragmentation_folder,"/working/rfd02/filterCat5"),partitioning = "monthyear",
                           schema = schema(patientdurablekey = int64(),
                                           monthyear = string(),
                                           confoundingrx = double(),
                                           dmrx = double())) %>%
  dplyr::select(patientdurablekey,monthyear,confoundingrx,dmrx) %>% 
  mutate(medication = 1)



m_y = "01 2015"

for(m_y in monthyear_unique){
  print(m_y)
  

  filterCat1 %>% dplyr::filter(monthyear == m_y) %>% 
    full_join(
      filterCat2 %>% dplyr::filter(monthyear == m_y) %>% dplyr::select(-monthyear),
      by = c("patientdurablekey")) %>% 
    # # Somehow the rpg dataset makes this pipe crash! 
    # # Excluding it in the CP dataset
    # full_join(filterCat3 %>% dplyr::filter(monthyear == m_y) %>% dplyr::select(-monthyear),
    #           by=c("patientdurablekey")) %>% 
    
    full_join(filterCat4 %>% dplyr::filter(monthyear == m_y) %>% dplyr::select(-monthyear),
              by=c("patientdurablekey")) %>% 
    
    full_join(filterCat5 %>% dplyr::filter(monthyear == m_y) %>% dplyr::select(-monthyear),
              by=c("patientdurablekey")) %>% 
    mutate(hba1c = case_when(is.na(hba1c) ~ 0,
                             TRUE ~ hba1c),
           fpg = case_when(is.na(fpg) ~ 0,
                           TRUE ~ fpg),
           # rpg = case_when(is.na(rpg) ~ 0,
           #                 TRUE ~ rpg),
           op = case_when(is.na(op) ~ 0,
                          TRUE ~ op),
           medication = case_when(is.na(medication) ~ 0,
                                  TRUE ~ medication),
           confoundingrx = case_when(is.na(confoundingrx) ~ 0,
                                     TRUE ~ confoundingrx),
           dmrx = case_when(is.na(dmrx) ~ 0,
                            TRUE ~ dmrx)
    ) %>% 
    mutate(score = 1, # Every row is imputed with 1
           
           others_true = hba1c + fpg + # rpg + 
             op + dmrx,
           
           procedures_true = hba1c + fpg + #rpg + 
             op,
           
           otherrx_true = dmrx,
           
           confoundingrx_true = confoundingrx,
           
           any_true = 1,
           
           my = my(monthyear)
    )  %>% 
    write_dataset(.,paste0(path_retinopathy_fragmentation_folder,"/working/rfd03/step1_merged by my"),partitioning="monthyear")
  
}

open_dataset(paste0(path_retinopathy_fragmentation_folder,"/working/rfd03/step1_merged by my"),partitioning="monthyear") %>% 
  dplyr::filter(procedures_true == 1,otherrx_true == 0) %>% 
  group_by(hba1c,op) %>% 
  tally() %>% 
  collect() %>% 
  View()


# STEP 2 ---------------  
# https://dplyr.tidyverse.org/reference/join_by.html
# join_condition = join_by(patientdurablekey, my < criterion2_date, my_plus2y >= criterion2_date)

patientdurablekey_my = open_dataset(paste0(path_retinopathy_fragmentation_folder,"/working/rfd03/step1_merged by my"),partitioning = "monthyear")

# patientdurablekey_my %>% dplyr::filter(monthyear == m_y) %>% 
#   group_by(monthyear) %>% 
#   tally() %>% collect()



for(m_y in monthyear_unique){
  print(m_y)
  patientdurablekey_my %>% dplyr::filter(monthyear == m_y) %>% 
    mutate(my_plus2y = my + dyears(2)) %>% 
    inner_join(.,
               patientdurablekey_my %>%
                 dplyr::select(patientdurablekey,my,
                               # procedures_true,
                               others_true,
                               confoundingrx_true,
                               any_true) %>% 
                 # rename columns to avoid duplication
                 rename(criterion2_date = my,
                        # c2_procedures_true = procedures_true,
                        c2_others_true = others_true,
                        c2_confoundingrx_true = confoundingrx_true,
                        c2_any_true = any_true
                 ),
               by = "patientdurablekey") %>%
    mutate(others_true = as.numeric(others_true),
           confoundingrx_true = as.numeric(confoundingrx_true),
           any_true = as.numeric(any_true),
           c2_others_true = as.numeric(c2_others_true),
           c2_confoundingrx_true = as.numeric(c2_confoundingrx_true),
           c2_any_true = as.numeric(c2_any_true)
           ) %>% 
    to_duckdb() %>% 
    # # Restrict to instances when different encounters occur on separate days within 2 years (730 days) of each other
    dplyr::filter(my < criterion2_date,criterion2_date <= my_plus2y) %>%
    mutate(incident_dm = case_when(
      # Same day criteria (included_date) ---
      procedures_true > 1 ~ 10, # Any combination of A1c, FPG, RPG or Dx on same day
      procedures_true == 1 & otherrx_true >= 1 ~ 10, # Only one of A1c, FPP, RPG or Dx + Any non-confounding RX
      confoundingrx_true >= 1 & others_true >= 1 ~ 10, # Any confounding Rx + Any of A1c, FPG, RPG or Dx or non-confounding Rx
      # Later day criteria (included_date + criterion2_date) ----
      others_true >= 1 & c2_others_true >= 1 ~ 20,
      confoundingrx_true >= 1 & c2_others_true >= 1 ~ 20,
      others_true >= 1 & c2_confoundingrx_true >= 1 ~ 20,
      TRUE ~ 0)) %>%
    # # Take the earliest date of displaying an incident_dm
    # # Assumption: If the earliest my doesn't have encounters preceding it, then we shouldn't count it as incident --------
    rename(criterion1_date = my) %>%
    dplyr::filter(incident_dm %in%  c(10,20)) %>% 
    group_by(patientdurablekey) %>%
    dplyr::filter(criterion1_date == min(criterion1_date)) %>%
    mutate(diagnosis_date = case_when(incident_dm == 10 ~ criterion1_date,
                                      TRUE ~ criterion2_date)) %>%
    dplyr::filter(diagnosis_date == min(diagnosis_date)) %>% 
    ungroup() %>%
    mutate(dm = 1) %>%
    to_arrow() %>% 
    write_dataset(.,paste0(path_retinopathy_fragmentation_folder,"/working/rfd03/step2_minimum for each my"),partitioning="monthyear")
    # Are there encounters in the previous 1.5 years?
  
}

open_dataset(paste0(path_retinopathy_fragmentation_folder,"/working/rfd03/step2_minimum for each my"),partitioning="monthyear") %>% 
  distinct(patientdurablekey) %>% 
  collect() %>% 
  nrow();gc()

open_dataset(paste0(path_retinopathy_fragmentation_folder,"/working/rfd03/step2_minimum for each my"),partitioning="monthyear") %>% 
  group_by(incident_dm) %>% 
  tally() %>% 
  collect()

# df = read_parquet(paste0(path_retinopathy_fragmentation_folder,"/working/rfd03/step2_minimum for each my/monthyear=01%202012/part-0.parquet"))

# STEP 3---------------  
rm(list=ls());gc();source(".Rprofile")

step2_minimum_each_my <- open_dataset(paste0(path_retinopathy_fragmentation_folder,"/working/rfd03/step2_minimum for each my"),partitioning="monthyear")

step2_minimum_each_my %>% 
  nrow()

for(m_y in monthyear_unique[1:2]){
  print(m_y)
  m_y_ts = my(m_y)
  
  step2_minimum_each_my %>% 
    dplyr::filter(monthyear == m_y)  %>% 
    to_duckdb() %>% 
    # Earlier used to be step2_minimum_each_my which was used to anti_join
    anti_join(step2_minimum_each_my %>% 
                to_duckdb() %>% 
                dplyr::filter(criterion1_date < m_y_ts),
              by = "patientdurablekey"
    ) %>% 
    to_arrow() %>% 
    write_dataset(.,paste0(path_retinopathy_fragmentation_folder,"/working/rfd03/step3_detection for each my"),partitioning="monthyear")
  
  gc();
  
}
# The above code suddenly fails at "08 2020" probably because of accumulation of data
# I now start querying relative to 'step3_detection for each my' to account for this data storage issue 

step3_detection_each_my %>%
  nrow()

for(m_y in monthyear_unique[3:144]){
  print(m_y)
  m_y_ts = my(m_y)
  step3_detection_each_my <- open_dataset(paste0(path_retinopathy_fragmentation_folder,"/working/rfd03/step3_detection for each my"),partitioning="monthyear")

    step2_minimum_each_my %>%
      dplyr::filter(monthyear == m_y)  %>%
      to_duckdb() %>%
      anti_join(step3_detection_each_my %>%
                  to_duckdb() %>%
                  dplyr::filter(criterion1_date < m_y_ts),
                by = "patientdurablekey"
      ) %>%
      to_arrow() %>%
      write_dataset(.,paste0(path_retinopathy_fragmentation_folder,"/working/rfd03/step3_detection for each my"),partitioning="monthyear")

  gc();

}


cp2 <- step3_detection_each_my %>% 
  to_duckdb() %>% 
  group_by(patientdurablekey) %>% 
  mutate(min_dd = min(diagnosis_date,na.rm=TRUE)) %>% 
  dplyr::filter(diagnosis_date == min_dd) %>% 
  ungroup() %>% 
  collect()


write_parquet(cp2,paste0(path_retinopathy_fragmentation_folder,"/working/rfd03/cp2 before encounter check.parquet"))
saveRDS(cp2,paste0(path_retinopathy_fragmentation_folder,"/working/rfd03/cp2 before encounter check.RDS"))
write_csv(cp2,paste0(path_retinopathy_fragmentation_folder,"/working/rfd03/cp2 before encounter check.csv"))


open_dataset(paste0(path_retinopathy_fragmentation_folder,"/working/rfd03/cp2 before encounter check.parquet")) %>% 
  nrow() 


# STEP4. CP1 and CP2 combined  -----
rm(list=ls());gc();source(".Rprofile")

cp1 <- readRDS(paste0(path_retinopathy_fragmentation_folder,"/working/rfd03/cp1 before encounter check.RDS"))
cp2 <- readRDS(paste0(path_retinopathy_fragmentation_folder,"/working/rfd03/cp2 before encounter check.RDS"))
combined_cp <- bind_rows(
  cp1,
  cp2) %>% 
  group_by(patientdurablekey) %>% 
  mutate(min_dd = min(diagnosis_date,na.rm=TRUE)) %>% 
  dplyr::filter(diagnosis_date == min_dd) %>% 
  ungroup() %>% 
  mutate(diagnosis_datekey = paste0(year(diagnosis_date),sprintf("%02d",month(diagnosis_date)),"00"),
         diagnosis_date_minus18months = diagnosis_date - dmonths(18),
         
         criterion1_datekey = paste0(year(criterion1_date),sprintf("%02d",month(criterion1_date)),"00"),
         criterion1_date_minus18months = criterion1_date - dmonths(18)
         ) %>% 
  mutate(diagnosis_datekey_minus18months = as.numeric(paste0(year(diagnosis_date_minus18months),sprintf("%02d",month(diagnosis_date_minus18months)),"00")),
         criterion1_datekey_minus18months = as.numeric(paste0(year(criterion1_date_minus18months),sprintf("%02d",month(criterion1_date_minus18months)),"00")),
         diagnosis_datekey = as.numeric(diagnosis_datekey)) %>% 
  dplyr::rename(PatientDurableKey = patientdurablekey) %>% 
  distinct(PatientDurableKey,diagnosis_datekey,.keep_all=TRUE) 

write_parquet(combined_cp,paste0(path_retinopathy_fragmentation_folder,"/working/rfd03/combined cp before encounter check.parquet"))
saveRDS(combined_cp,paste0(path_retinopathy_fragmentation_folder,"/working/rfd03/combined cp before encounter check.RDS"))
# write_csv(combined_cp,paste0(path_retinopathy_fragmentation_folder,"/working/rfd03/combined cp before encounter check.csv"))


cp = readRDS(paste0(path_retinopathy_fragmentation_folder,"/working/rfd03/combined cp before encounter check.RDS")) %>% 
  dplyr::select(PatientDurableKey, criterion1_date, criterion2_date, diagnosis_date, diagnosis_datekey, criterion1_datekey) 

 cp %>% 
  write_csv(.,paste0(path_retinopathy_fragmentation_folder,"/working/rfd03/combined cp before encounter check restricted columns.csv"))

readRDS(paste0(path_retinopathy_fragmentation_folder,"/working/rfd03/combined cp before encounter check.RDS")) %>% 
  nrow()

year_dd <- open_dataset(paste0(path_retinopathy_fragmentation_folder,"/working/rfd03/combined cp before encounter check.parquet")) %>% 
  to_duckdb() %>% 
  group_by(year(diagnosis_date)) %>% 
  tally() %>% 
  collect()

ggplot(data=year_dd,aes(x=))