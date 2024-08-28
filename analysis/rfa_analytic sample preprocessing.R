analytic <- readRDS(paste0(path_retinopathy_fragmentation_folder,"/working/rfa001_analytic sample.RDS")) %>% 
  dplyr::select(-contains("_YearMonth"),-Country,-ValidatedCountry_X) %>% 
  mutate(eligibility = case_when(is.na(DeathDate) ~ "no death recorded",
                                 diag_date < (DeathDate - dyears(1)) ~ "death within 1 year",
                                 diag_date < (DeathDate - dyears(2)) ~ "death within 2 years",
                                 TRUE ~ "no death within 2 years")) %>% 
  dplyr::filter(eligibility %in% c("no death recorded","no death within 2 years")) %>% 
  # Sensible imputations
  mutate(across(one_of(c("n_total_Y1","n_total_Y2",
                         "bp_Y1","bp_Y2",
                         "hba1c_Y1","hba1c_Y2",
                         "ldl_Y1","ldl_Y2",
                         "Ophthalmology_Y1","Ophthalmology_Y2",
                         "PrimaryCare_Y1","PrimaryCare_Y2")),.fns=function(x){case_when(is.na(x) ~ 0,
                                                                                        TRUE ~ x)})) %>% 
  mutate(across(ends_with("rx"),.fns=function(x){case_when(is.na(x) ~ 0,
                                                           TRUE ~ x)})) %>% 
  mutate(across(ends_with("dx"),.fns=function(x){case_when(is.na(x) ~ 0,
                                                           TRUE ~ x)})) %>% 
  
  mutate(region = case_when(PrimaryRUCA_X %in% as.character(c(1:6)) ~ "Urban",
                            PrimaryRUCA_X %in% as.character(c(7:10)) ~ "Rural",
                            TRUE ~ "Urban"),
         historical_hba1c_group = case_when(hba1c <7 ~ 1,
                                      hba1c <9 ~ 2,
                                      hba1c >=9 ~ 3,
                                      TRUE ~ 4),
         mean_hba1c_group = case_when(mean_hba1c <7 ~ 1,
                                      mean_hba1c <9 ~ 2,
                                      mean_hba1c >=9 ~ 3,
                                      TRUE ~ 4),

         historical_bp_group = case_when(SystolicBloodPressure >= 160 | DiastolicBloodPressure >= 100 ~ 3,
                                         SystolicBloodPressure >= 140 | DiastolicBloodPressure >= 90 ~ 2,
                                         SystolicBloodPressure < 140 & DiastolicBloodPressure < 90 ~ 1,
                                   TRUE ~ 4),
         mean_bp_group = case_when(mean_sbp >= 160 | mean_dbp >= 100 ~ 3,
                                   mean_sbp >= 140 | mean_dbp >= 90 ~ 2,
                                   mean_sbp < 140 & mean_dbp < 90 ~ 1,
                                   TRUE ~ 4),
         historical_ldl_group = case_when(ldl <100 ~ 1,
                                            ldl <130 ~ 2,
                                            ldl <160 ~ 3,
                                            ldl >=160 ~ 4,
                                            TRUE ~ 5),
         mild_npdr_nodme = case_when(str_detect(ICD_Value,"\\.(319|329)") ~ 1,
                                     TRUE ~ 0),
         moderate_npdr_nodme = case_when(str_detect(ICD_Value,"\\.(339)") ~ 1,
                                         TRUE ~ 0),
         
         n_total_Y1_eq0 = case_when(is.na(n_total_Y1) ~ 1,
                                    n_total_Y1 == 0 ~ 1,
                                    TRUE ~ 0),
         
         n_total_Y2_eq0 = case_when(is.na(n_total_Y2) ~ 1,
                                    n_total_Y2 == 0 ~ 1,
                                    TRUE ~ 0),
         
         bbi_Y1_ge70 = case_when(is.na(n_total_Y1) | n_total_Y1 == 0 ~ NA_real_,
                                 n_total_Y1 == 1 ~ 1,
                                 bbi_Y1 >= 0.7 ~ 1,
                                 TRUE ~ 0),
         
         bbi_Y2_ge70 = case_when(is.na(n_total_Y2) | n_total_Y2 == 0 ~ NA_real_,
                                 n_total_Y2 == 1 ~ 1,
                                 bbi_Y2 >= 0.7 ~ 1,
                                 TRUE ~ 0),
         
         svi_ge75 = case_when(is.na(SviOverallPctlRankByZip2020_X) ~ NA_real_,
                              SviOverallPctlRankByZip2020_X >= 0.75 ~ 1,
                              SviOverallPctlRankByZip2020_X < 0.75 ~ 0,
                              TRUE ~ NA_real_)
         
  ) %>% 
  mutate(historical_hba1c_group = factor(historical_hba1c_group,levels=c(1:4),labels=c("<7","7-9",">=9","Unavailable")),
         mean_hba1c_group = factor(mean_hba1c_group,levels=c(1:4),labels=c("<7","7-9",">=9","Unavailable")),
         mean_bp_group = factor(mean_bp_group,levels=c(1:4),labels=c("<140/90","<160/100",">=160/100","Unavailable")),
         historical_bp_group = factor(historical_bp_group,levels=c(1:4),labels=c("<140/90","<160/100",">=160/100","Unavailable")),
         historical_ldl_group = factor(historical_ldl_group,levels=c(1:5),labels=c("<100","<130","<160",">=160","Unavailable")),
         ) %>% 
  mutate(across(one_of(c("bp_Y1","bp_Y2",
                         "hba1c_Y1","hba1c_Y2",
                         "ldl_Y1","ldl_Y2",
                         "Ophthalmology_Y1","Ophthalmology_Y2",
                         "PrimaryCare_Y1","PrimaryCare_Y2")),.names = "{col}_ge1",.fns=function(x){case_when(is.na(x) ~ 0,
                                                                                                             x == 0 ~ 0,
                                                                                                             TRUE ~ 1)})) %>% 
  mutate(
         ABC_Y1_ge1 = case_when(hba1c_Y1_ge1 == 1 & bp_Y1_ge1 == 1 & ldl_Y1_ge1 == 1 ~ 1,
                                hba1c_Y1_ge1 == 0 | bp_Y1_ge1 == 0 | ldl_Y1_ge1 == 0 ~ 0,
                                TRUE ~ NA_real_),
         ABC_Y2_ge1 = case_when(hba1c_Y2_ge1 == 1 & bp_Y2_ge1 == 1 & ldl_Y2_ge1 == 1 ~ 1,
                                hba1c_Y2_ge1 == 0 | bp_Y2_ge1 == 0 | ldl_Y2_ge1 == 0 ~ 0,
                                TRUE ~ NA_real_)) %>% 
  dplyr::select(-sigma_vi_sq_Y1,-sigma_vi_sq_Y2) %>% 
  mutate(
         standards_year1 = rowSums(.[,str_detect(colnames(.),pattern="(ABC|Ophthalmology|PrimaryCare)_Y1_ge1$")]),
         standards_year2 = rowSums(.[,str_detect(colnames(.),pattern="(ABC|Ophthalmology|PrimaryCare)_Y2_ge1$")]),
         region = case_when(PrimaryRUCA_X %in% as.character(c(1:6)) ~ "Urban",
                            PrimaryRUCA_X %in% as.character(c(7:10)) ~ "Rural",
                            TRUE ~ "Urban")) %>% 
  mutate(standards_year1_ge2 = case_when(standards_year1 >= 2 ~ 1,
                                         TRUE ~ 0),
         standards_year2_ge2 = case_when(standards_year2 >= 2 ~ 1,
                                         TRUE ~ 0)) %>% 
  mutate(across(one_of("o_npdr_dme","o_severe_npdr","o_pdr","o_dme"),.f=function(x) case_when(x >= 1 ~ 1,
                                                                                              x == 0 ~ 0,
                                                                                              TRUE ~ NA_real_))) %>% 
  mutate(Ophthalmology_both = case_when(Ophthalmology_Y1 >= 1 & Ophthalmology_Y2 >= 1 ~ 1,
                                        TRUE ~ 0),
         PrimaryCare_both = case_when(PrimaryCare_Y1 >= 1 & PrimaryCare_Y2 >= 1 ~ 1,
                                      TRUE ~ 0),
         hba1c_both = case_when(hba1c_Y1 >= 1 & hba1c_Y2 >= 1 ~ 1,
                                TRUE ~ 0),
         bp_both = case_when(bp_Y1 >= 1 & bp_Y2 >= 1 ~ 1,
                             TRUE ~ 0),
         ldl_both = case_when(ldl_Y1 >= 1 & ldl_Y2 >= 1 ~ 1,
                              TRUE ~ 0),
         ABC_both = case_when(ABC_Y1_ge1 == 1 & ABC_Y2_ge1 == 1 ~ 1,
                              TRUE ~ 0),
         
         soc_both = case_when(standards_year1 >= 2 & standards_year2 >= 2 ~ 1,
                              standards_year1 < 2 | standards_year2 <2 ~ 0,
                              TRUE ~ NA_real_),
         n_total_eq0_both = case_when(n_total_Y1 == 0 & n_total_Y2 == 0 ~ 1,
                                      TRUE ~ 0),
         bbi_ge70_both = case_when(bbi_Y1 >= 0.7 & bbi_Y2 >= 0.7 ~ 1,
                                   bbi_Y1 < 0.7 | bbi_Y2 < 0.7 ~ 0,
                                   TRUE ~ NA_real_))
