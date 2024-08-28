
rm(list=ls());gc();source(".Rprofile")

# Eligible adults before excluding historical Severe NPDR, DME, PDR ######
# rfd08 is the group of individuals with at least one encounter in each of prior years, for the earliest record of Diabetic Retinopathy
rfd08 <- open_dataset(paste0(path_retinopathy_fragmentation_folder,"/working/rfd08/eligible patients.parquet")) %>% 
  mutate(PatientDurableKey = as.numeric(PatientDurableKey)) %>% 
  mutate(YearMonth = str_sub(as.character(StartDateKey),1,6),
         StartDateKey_plus1y = StartDateKey + 10000,
         StartDateKey_plus2y = StartDateKey + 20000
         )
rfd08 %>% 
  head() %>% 
  collect()

rfd08 %>% dim()

## rfd04. T1DM -------
rfd04 <- open_dataset(paste0(path_retinopathy_fragmentation_folder,"/working/rfd04"),format="parquet") %>% collect()

## rfd03. SUPREME-DM -----------
rfd03 <- read_parquet(paste0(path_retinopathy_fragmentation_folder,"/working/rfd03/combined cp before encounter check.parquet"))

## rfd06. PatientDim ------------
rfd06 <- open_dataset(paste0(path_retinopathy_fragmentation_folder,"/working/rfd06"),format="parquet",partitioning = "ValidatedStateOrProvince_X") %>% 
  mutate(PatientDurableKey = as.numeric(PatientDurableKey)) %>% 
  mutate(raceeth = case_when(Ethnicity == "Hispanic or Latino" ~ 3,
                             FirstRace == "Black or African American" | 
                               SecondRace == "Black or African American" | 
                               ThirdRace == "Black or African American" ~ 2,
                             FirstRace == "White" & SecondRace == "" ~ 1,
                             TRUE ~ 4),
         female = case_when(Sex == "Female" ~ 1,
                            TRUE ~ 0))


## rfd05. All retinopathy cases to select NPDR no-DME  -------------
# Ideally the earliest detected case should be an NPDR-NODME
# Restrict to group_by(PatientDurableKey) and filter to min(StartDateKey)
earliest_rfd05 <- open_dataset(paste0(path_retinopathy_fragmentation_folder,"/working/rfd05"),format = "parquet",partitioning = "Year") %>% 
  mutate(PatientDurableKey = as.numeric(PatientDurableKey)) %>% 
  to_duckdb() %>% 
  dplyr::filter(str_detect(ICD_Value,"(E10|E11)\\.(31|32|33|34|35|37)")) %>% 
  group_by(PatientDurableKey) %>% 
  dplyr::filter(StartDateKey == min(StartDateKey),StartDateKey > 20150000 & StartDateKey < 20230000,ICD_Type == "ICD-10-CM") %>% 
  ungroup() %>%
  group_by(PatientDurableKey) %>%
  summarize(ICD_Value = str_flatten(ICD_Value,collapse=";"),
            StartDateKey = min(StartDateKey)) %>% 
  ungroup() %>% 
  collect() %>% 
  mutate(npdr_nodme = case_when(str_detect(ICD_Value,"\\.(319|329|339)") ~ 1,
                                TRUE ~ 0),
         npdr_dme = case_when(str_detect(ICD_Value,"\\.(311|321|331)") ~ 1,
                              TRUE ~ 0),
         severe_npdr = case_when(str_detect(ICD_Value,"\\.(34)") ~ 1,
                                 TRUE ~ 0),
         pdr = case_when(str_detect(ICD_Value,"\\.(35)") ~ 1,
                         TRUE ~ 0),
         dme = case_when(str_detect(ICD_Value,"\\.(37)") ~ 1,
                         TRUE ~ 0),
         t1dm = case_when(str_detect(ICD_Value,"E10") ~ 1,
                          TRUE ~ 0),
         t2dm = case_when(str_detect(ICD_Value,"E11") ~ 1,
                          TRUE ~ 0)
  )

# analytic_before_historycheck --------------
analytic_before_historycheck <- rfd08 %>% 
  left_join(rfd06,
            by="PatientDurableKey") %>% 
  collect() %>% 
  left_join(earliest_rfd05,
            by=c("PatientDurableKey","StartDateKey")) %>% 
  # History Check: Is the earliest only NPDR w/o DME
  dplyr::filter(npdr_dme == 0, severe_npdr == 0, pdr == 0, dme == 0)

# EXPOSURE: Y1 and Y2 ----------



## rfc06b. Physician Visit -------------
physician_visit <- open_dataset(paste0(path_retinopathy_fragmentation_folder,"/working/rfc06b"),partitioning = c("Year","SourceKey")) %>%
  mutate(PatientDurableKey = as.numeric(PatientDurableKey)) %>% 
  left_join(rfd08 %>% 
              dplyr::select(PatientDurableKey,StartDateKey,StartDateKey_plus1y, StartDateKey_plus2y),
            by = c("PatientDurableKey")) %>% 
  mutate(Ophthalmology = case_when(PrimarySpecialty == "Ophthalmology" ~ 1,
                                   SecondSpecialty == "Ophthalmology" ~ 1,
                                   TRUE ~ 0),
         PrimaryCare = case_when(PrimarySpecialty %in% c("Family Medicine","Internal Medicine","Endocrinology",
                                                         "Nurse Practitioner","General Practice","Primary Care",
                                                         "Geriatric Medicine","Diabetes Services","Gerontology",
                                                         "Endocrinology, Diabetes & Metabolism","Preventative Medicine") ~ 1,
                                 SecondSpecialty %in% c("Family Medicine","Internal Medicine","Endocrinology",
                                                        "Nurse Practitioner","General Practice","Primary Care",
                                                        "Geriatric Medicine","Diabetes Services","Gerontology",
                                                        "Endocrinology, Diabetes & Metabolism","Preventative Medicine") ~ 1,
                                 TRUE ~ 0),
         YearMonthKey = paste0(YearMonth,"01")) %>%
  mutate(YearMonthKey = as.numeric(YearMonthKey))  %>% 
  mutate(period = case_when(YearMonthKey >= StartDateKey & YearMonthKey < StartDateKey_plus1y ~ "Y1",
                            YearMonthKey >= StartDateKey_plus1y & YearMonthKey < StartDateKey_plus2y ~ "Y2",
                            TRUE ~ "Y3 or later")) %>% 
  dplyr::filter((Ophthalmology == 1|PrimaryCare == 1) & period %in% c("Y1","Y2")) %>% 
  group_by(PatientDurableKey,period) %>% 
  # How many months in each period was an Ophthalmology or PrimaryCare visit recorded
  summarize(Ophthalmology = sum(Ophthalmology),PrimaryCare = sum(PrimaryCare)) %>% 
  ungroup() %>% 
  collect() %>% 
  pivot_wider(names_from=period,values_from=c(Ophthalmology,PrimaryCare),values_fill = 0)

## rfc06b. Continuity of care -------------

care_continuity = open_dataset(paste0(path_retinopathy_fragmentation_folder,"/working/rfc06b"),partitioning = c("Year","SourceKey")) %>%
  mutate(PatientDurableKey = as.numeric(PatientDurableKey),
         YearMonthKey = paste0(YearMonth,"01")) %>% 
  mutate(YearMonthKey = as.numeric(YearMonthKey))  %>% 
  left_join(rfd08 %>% 
              dplyr::select(PatientDurableKey,StartDateKey,StartDateKey_plus1y, StartDateKey_plus2y),
            by = c("PatientDurableKey")) %>%
  mutate(period = case_when(YearMonthKey >= StartDateKey & YearMonthKey < StartDateKey_plus1y ~ "Y1",
                            YearMonthKey >= StartDateKey_plus1y & YearMonthKey < StartDateKey_plus2y ~ "Y2",
                            TRUE ~ "Y3 or later")) %>% 
  dplyr::filter(period %in% c("Y1","Y2")) %>% 
  to_duckdb() %>% 
  group_by(PatientDurableKey,SourceKey,period) %>% 
  tally() %>%   
  ungroup() %>% 
  group_by(PatientDurableKey,period) %>% 
  summarize(sigma_vi_sq = sum(n^2),
            n_total = sum(n)) %>% 
  ungroup() %>% 
  mutate(bbi = (sigma_vi_sq - n_total)/(n_total*(n_total-1))) %>% 
  collect() %>% 
  pivot_wider(names_from=period,values_from=c(bbi,sigma_vi_sq,n_total))

## rfc01b. Blood Pressure visit ---------
blood_pressure = open_dataset(paste0(path_retinopathy_fragmentation_folder,"/working/rfc01b"),partitioning = c("Year")) %>% 
  mutate(PatientDurableKey = as.numeric(PatientDurableKey),
         YearMonthKey = paste0(YearMonth,"01")) %>% 
  left_join(rfd08 %>% 
              dplyr::select(PatientDurableKey,StartDateKey,StartDateKey_plus1y, StartDateKey_plus2y),
            by = c("PatientDurableKey")) %>% 
  mutate(
    SystolicBloodPressure = case_when(SystolicBloodPressure > 300 | SystolicBloodPressure < 50 ~ NA_real_,
                                      TRUE ~ SystolicBloodPressure),
    DiastolicBloodPressure = case_when(DiastolicBloodPressure > 300 | DiastolicBloodPressure < 30 ~ NA_real_,
                                       TRUE ~ DiastolicBloodPressure)) %>% 
  to_duckdb()  %>%
  mutate(period = case_when(YearMonthKey >= StartDateKey & YearMonthKey < StartDateKey_plus1y ~ "Y1",
                            YearMonthKey >= StartDateKey_plus1y & YearMonthKey < StartDateKey_plus2y ~ "Y2",
                            TRUE ~ "Y3 or later")) %>% 
  dplyr::filter(period %in% c("Y1","Y2"),!is.na(SystolicBloodPressure),!is.na(DiastolicBloodPressure)) %>% 
  group_by(PatientDurableKey,period) %>% 
  tally() %>%   
  ungroup()  %>% 
  collect() %>% 
  pivot_wider(names_from=period,values_from=n,values_fill = 0)


mean_blood_pressure = open_dataset(paste0(path_retinopathy_fragmentation_folder,"/working/rfc01b"),partitioning = c("Year")) %>% 
  mutate(PatientDurableKey = as.numeric(PatientDurableKey),
         YearMonthKey = paste0(YearMonth,"01")) %>% 
  left_join(rfd08 %>% 
              dplyr::select(PatientDurableKey,StartDateKey,StartDateKey_plus1y, StartDateKey_plus2y),
            by = c("PatientDurableKey")) %>% 
  mutate(
    SystolicBloodPressure = case_when(SystolicBloodPressure > 300 | SystolicBloodPressure < 50 ~ NA_real_,
                                      TRUE ~ SystolicBloodPressure),
    DiastolicBloodPressure = case_when(DiastolicBloodPressure > 300 | DiastolicBloodPressure < 30 ~ NA_real_,
                                       TRUE ~ DiastolicBloodPressure)) %>% 
  to_duckdb()  %>%
  mutate(period = case_when(YearMonthKey >= StartDateKey & YearMonthKey < StartDateKey_plus1y ~ "Y1",
                            YearMonthKey >= StartDateKey_plus1y & YearMonthKey < StartDateKey_plus2y ~ "Y2",
                            TRUE ~ "Y3 or later")) %>% 
  dplyr::filter(period %in% c("Y1"),!is.na(SystolicBloodPressure),!is.na(DiastolicBloodPressure)) %>% 
  group_by(PatientDurableKey) %>% 
  summarize(mean_sbp = mean(SystolicBloodPressure),
            mean_dbp = mean(DiastolicBloodPressure)) %>%   
  ungroup()  %>% 
  collect() 


## rfc02ab. HbA1c visit ---------------
hba1c <- open_dataset(paste0(path_retinopathy_fragmentation_folder,"/working/rfc02ab"),partitioning = c("Year")) %>% 
  mutate(PatientDurableKey = as.numeric(PatientDurableKey),
         YearMonthKey = paste0(YearMonth,"01")) %>% 
  left_join(rfd08 %>% 
              dplyr::select(PatientDurableKey,StartDateKey,StartDateKey_plus1y, StartDateKey_plus2y),
            by = c("PatientDurableKey")) %>%
  mutate(NumericValue = as.numeric(NumericValue)) %>% 
  to_duckdb()  %>%
  mutate(hba1c_value = case_when(NumericValue >= 3 & NumericValue <= 20 ~ NumericValue,
                                 TRUE ~ NA_real_)) %>%
  mutate(period = case_when(YearMonthKey >= StartDateKey & YearMonthKey < StartDateKey_plus1y ~ "Y1",
                            YearMonthKey >= StartDateKey_plus1y & YearMonthKey < StartDateKey_plus2y ~ "Y2",
                            TRUE ~ "Y3 or later")) %>% 
  dplyr::filter(period %in% c("Y1","Y2"),!is.na(hba1c_value)) %>% 
  group_by(PatientDurableKey,period) %>% 
  tally() %>%   
  ungroup()  %>% 
  collect() %>% 
  pivot_wider(names_from=period,values_from=n,values_fill = 0)

mean_hba1c <- open_dataset(paste0(path_retinopathy_fragmentation_folder,"/working/rfc02ab"),partitioning = c("Year")) %>% 
  mutate(PatientDurableKey = as.numeric(PatientDurableKey),
         YearMonthKey = paste0(YearMonth,"01")) %>% 
  left_join(rfd08 %>% 
              dplyr::select(PatientDurableKey,StartDateKey,StartDateKey_plus1y, StartDateKey_plus2y),
            by = c("PatientDurableKey")) %>%
  mutate(NumericValue = as.numeric(NumericValue)) %>% 
  to_duckdb()  %>%
  mutate(hba1c_value = case_when(NumericValue >= 3 & NumericValue <= 20 ~ NumericValue,
                                 TRUE ~ NA_real_)) %>%
  mutate(period = case_when(YearMonthKey >= StartDateKey & YearMonthKey < StartDateKey_plus1y ~ "Y1",
                            YearMonthKey >= StartDateKey_plus1y & YearMonthKey < StartDateKey_plus2y ~ "Y2",
                            TRUE ~ "Y3 or later")) %>% 
  dplyr::filter(period %in% c("Y1","Y2"),!is.na(hba1c_value)) %>% 
  group_by(PatientDurableKey) %>% 
  summarize(mean_hba1c = mean(hba1c_value)) %>%   
  ungroup()  %>% 
  collect()

## rfc02db. LDL visit ---------------

ldl <- open_dataset(paste0(path_retinopathy_fragmentation_folder,"/working/rfc02db"),partitioning = c("Year")) %>% 
  mutate(PatientDurableKey = as.numeric(PatientDurableKey),
         YearMonthKey = paste0(YearMonth,"01")) %>% 
  left_join(rfd08 %>% 
              dplyr::select(PatientDurableKey,StartDateKey,StartDateKey_plus1y, StartDateKey_plus2y),
            by = c("PatientDurableKey")) %>%
  mutate(NumericValue = as.numeric(NumericValue)) %>% 
  to_duckdb()  %>%
  mutate(ldl_value = case_when(NumericValue >= 10 & NumericValue <= 500 ~ NumericValue,
                               TRUE ~ NA_real_)) %>%
  mutate(period = case_when(YearMonthKey >= StartDateKey & YearMonthKey < StartDateKey_plus1y ~ "Y1",
                            YearMonthKey >= StartDateKey_plus1y & YearMonthKey < StartDateKey_plus2y ~ "Y2",
                            TRUE ~ "Y3 or later")) %>% 
  dplyr::filter(period %in% c("Y1","Y2"),!is.na(ldl_value)) %>% 
  group_by(PatientDurableKey,period) %>% 
  tally() %>%   
  ungroup()  %>% 
  collect() %>% 
  pivot_wider(names_from=period,values_from=n,values_fill = 0)


## rfc02db. HDL visit ---------------
hdl <- open_dataset(paste0(path_retinopathy_fragmentation_folder,"/working/rfc02eb"),partitioning = c("Year")) %>% 
  mutate(PatientDurableKey = as.numeric(PatientDurableKey),
         YearMonthKey = paste0(YearMonth,"01")) %>% 
  left_join(rfd08 %>% 
              dplyr::select(PatientDurableKey,StartDateKey,StartDateKey_plus1y, StartDateKey_plus2y),
            by = c("PatientDurableKey")) %>%
  mutate(NumericValue = as.numeric(NumericValue)) %>% 
  to_duckdb()  %>%
  mutate(hdl_value = case_when(NumericValue >= 10 & NumericValue <= 500 ~ NumericValue,
                               TRUE ~ NA_real_)) %>%
  mutate(period = case_when(YearMonthKey >= StartDateKey & YearMonthKey < StartDateKey_plus1y ~ "Y1",
                            YearMonthKey >= StartDateKey_plus1y & YearMonthKey < StartDateKey_plus2y ~ "Y2",
                            TRUE ~ "Y3 or later")) %>% 
  dplyr::filter(period %in% c("Y1","Y2"),!is.na(hdl_value)) %>% 
  group_by(PatientDurableKey,period) %>% 
  tally() %>%   
  ungroup()  %>% 
  collect() %>% 
  pivot_wider(names_from=period,values_from=n,values_fill = 0)



# BEFORE EXPOSURE #######################################


## rfc01a. Vitals before exposure --------
rfc01a = open_dataset(paste0(path_retinopathy_fragmentation_folder,"/working/rfc01a"),partitioning = c("Year")) %>% 
  mutate(BodyMassIndex = case_when(BodyMassIndex >50 | BodyMassIndex <12 ~ NA_real_,
                                   TRUE ~ BodyMassIndex),
         SystolicBloodPressure = case_when(SystolicBloodPressure > 300 | SystolicBloodPressure < 50 ~ NA_real_,
                                           TRUE ~ SystolicBloodPressure),
         DiastolicBloodPressure = case_when(DiastolicBloodPressure > 300 | DiastolicBloodPressure < 30 ~ NA_real_,
                                            TRUE ~ DiastolicBloodPressure)) %>% 
  to_duckdb() %>% 
  arrange(PatientDurableKey,YearMonth) %>% 
  group_by(PatientDurableKey) %>% 
  mutate(BodyMassIndex = case_when(is.na(BodyMassIndex) ~ dplyr::lag(BodyMassIndex),
                                   TRUE ~ BodyMassIndex),
         SystolicBloodPressure = case_when(is.na(SystolicBloodPressure) ~ dplyr::lag(SystolicBloodPressure),
                                           TRUE ~ SystolicBloodPressure),
         DiastolicBloodPressure = case_when(is.na(DiastolicBloodPressure) ~ dplyr::lag(DiastolicBloodPressure),
                                            TRUE ~ DiastolicBloodPressure)) %>% 
  dplyr::filter(YearMonth == max(YearMonth)) %>% 
  ungroup() %>% 
  collect()



## rfc02aa. HbA1c before exposure ------

rfc02aa <- open_dataset(paste0(path_retinopathy_fragmentation_folder,"/working/rfc02aa"),partitioning = c("Year")) %>% 
  mutate(NumericValue = as.numeric(NumericValue)) %>% 
  dplyr::filter(NumericValue >= 3, NumericValue <= 20) %>% 
  to_duckdb() %>% 
  group_by(PatientDurableKey) %>% 
  dplyr::filter(YearMonth == max(YearMonth)) %>% 
  ungroup() %>% 
  collect()

## rfc02da. LDL before exposure ---------
rfc02da <- open_dataset(paste0(path_retinopathy_fragmentation_folder,"/working/rfc02da"),partitioning = c("Year")) %>% 
  dplyr::filter(NumericValue >= 10, NumericValue <= 500) %>% 
  to_duckdb() %>% 
  group_by(PatientDurableKey) %>% 
  dplyr::filter(YearMonth == max(YearMonth)) %>% 
  ungroup() %>% 
  collect()

## rfc02ea. HDL before exposure ---------
rfc02ea <- open_dataset(paste0(path_retinopathy_fragmentation_folder,"/working/rfc02ea"),partitioning = c("Year")) %>% 
  dplyr::filter(NumericValue >= 10, NumericValue <= 500) %>% 
  to_duckdb() %>% 
  group_by(PatientDurableKey) %>% 
  dplyr::filter(YearMonth == max(YearMonth)) %>% 
  ungroup() %>% 
  collect()

## rfc05. Insurance before exposure ---------
rfc05 <- open_dataset(paste0(path_retinopathy_fragmentation_folder,"/working/rfc05"),partitioning = c("Year")) %>% 
  mutate(PatientDurableKey = as.numeric(PatientDurableKey)) %>% 
  mutate(insurance_medicare = case_when(CoverageFinancialClass == "Medicare" ~ 1,
                                        TRUE ~ 0),
         insurance_other = case_when(CoverageFinancialClass == "Miscellaneous/Other" ~ 1,
                                     TRUE ~ 0),
         insurance_medicaid = case_when(CoverageFinancialClass == "Medicaid" ~ 1,
                                        TRUE ~ 0),
         insurance_selfpay = case_when(CoverageFinancialClass == "Self-Pay" ~ 1,
                                       TRUE ~ 0)) %>% 
  group_by(PatientDurableKey,YearMonth) %>% 
  summarize(insurance_medicare = sum(insurance_medicare),
            insurance_other = sum(insurance_other),
            insurance_medicaid = sum(insurance_medicaid),
            insurance_selfpay = sum(insurance_selfpay)) %>% 
  collect() %>% 
  group_by(PatientDurableKey) %>% 
  dplyr::filter(YearMonth == max(YearMonth)) %>% 
  ungroup()


## rfc04a. Diagnosis codes before exposure -------------


rfc04a <- open_dataset(paste0(path_retinopathy_fragmentation_folder,"/working/rfc04a"),partitioning = c("Year","Value_Grouper2")) %>% 
  mutate(htn_dx = case_when(Value_Grouper %in% htn_dx_codes ~ 1,
                            TRUE ~ 0),
         hld_dx = case_when(Value_Grouper %in% hld_dx_codes ~ 1,
                            TRUE ~ 0),
         cerebro_dx = case_when(ICD10_Value %in% cerebro_dx_codes ~ 1,
                                TRUE ~ 0),
         cardiovascular_dx = case_when(Value_Grouper %in% cardiovascular_dx_codes ~ 1,
                                       TRUE ~ 0),
         pulmonary_dx = case_when(Value_Grouper %in% pulmonary_dx_codes ~ 1,
                                  ICD10_Value %in% pulmonary_dx_codes ~ 1,
                                  TRUE ~ 0),
         obesity_dx = case_when(ICD10_Value %in% obesity_dx_codes ~ 1,
                                TRUE ~ 0)) %>% 
  group_by(PatientDurableKey) %>% 
  summarize(htn_dx = sum(htn_dx),
            hld_dx = sum(hld_dx),
            cerebro_dx = sum(cerebro_dx),
            cardiovascular_dx = sum(cardiovascular_dx),
            pulmonary_dx = sum(pulmonary_dx),
            obesity_dx = sum(obesity_dx)) %>% 
  collect() %>% 
  mutate(across(ends_with("dx"),.f=function(x) case_when(x>=1 ~ 1,
                                                         TRUE ~ 0)))

summary(rfc04a)
  
## rfc03a.Prescriptions before exposure ---------
rfc03a <- open_dataset(paste0(path_retinopathy_fragmentation_folder,"/working/rfc03a"),partitioning = c("Year")) %>% 
  mutate(depres_rx = case_when(str_detect(PharmaceuticalClass,"ANTIDEPRES") ~ 1,
                            TRUE ~ 0),
         psych_rx = case_when(str_detect(PharmaceuticalClass,"ANTIPSYCH") ~ 1,
                               TRUE ~ 0),
         htn_rx = case_when(str_detect(PharmaceuticalClass,"ANTIHYPERTENSIVE") ~ 1,
                               TRUE ~ 0),
         hld_rx = case_when(str_detect(PharmaceuticalClass,"ANTIHYPERLIPID") ~ 1,
                               TRUE ~ 0),
         statin_rx = case_when(str_detect(PharmaceuticalClass,"STATIN") ~ 1,
                               TRUE ~ 0),
         insulin_rx = case_when(str_detect(PharmaceuticalClass,"INSULINS") ~ 1,
                                TRUE ~ 0),
         otherdm_rx = case_when(str_detect(PharmaceuticalClass,"ANTIHYPERGLY") & 
                                  !str_detect(PharmaceuticalClass,"INSULINS") ~ 1,
                                TRUE ~ 0)
         ) %>% 
  group_by(PatientDurableKey) %>% 
  summarize(htn_rx = sum(htn_rx),
            hld_rx = sum(hld_rx),
            statin_rx = sum(statin_rx),
            depres_rx = sum(depres_rx),
            psych_rx = sum(psych_rx),
            insulin_rx = sum(insulin_rx),
            otherdm_rx = sum(otherdm_rx)) %>% 
  collect() %>% 
  mutate(across(ends_with("rx"),.f=function(x) case_when(x>=1 ~ 1,
                                                         TRUE ~ 0)))

summary(rfc03a)

# POST EXPOSURE NPDR/PDR/DME ---------
# The outcome has to be one of the following: NPDR w/ DME, Severe NPDR, PDR, DME
post_exposure_outcome = open_dataset(paste0(path_retinopathy_fragmentation_folder,"/working/rfc04b"),partitioning = c("Year","Value_Grouper2")) %>% 
  mutate(npdr_nodme = case_when(str_detect(ICD10_Value,"^E(10|11)\\.(319|329|339)") ~ 1,
                                TRUE ~ 0),
         npdr_dme = case_when(str_detect(ICD10_Value,"^E(10|11)\\.(311|321|331)") ~ 1,
                              TRUE ~ 0),
         severe_npdr = case_when(str_detect(ICD10_Value,"^E(10|11)\\.(34)") ~ 1,
                                 TRUE ~ 0),
         pdr = case_when(str_detect(ICD10_Value,"^E(10|11)\\.(35)") ~ 1,
                         TRUE ~ 0),
         dme = case_when(str_detect(ICD10_Value,"^E(10|11)\\.(37)") ~ 1,
                         TRUE ~ 0)) %>% 
  to_duckdb() %>% 
  dplyr::filter(npdr_dme == 1 |severe_npdr == 1 | pdr == 1| dme == 1) %>%  
  group_by(PatientDurableKey) %>% 
  dplyr::filter(YearMonth == min(YearMonth)) %>% 
  ungroup() %>% 
  collect() %>% 
  group_by(PatientDurableKey,YearMonth) %>% 
  summarize(ICD10_Value = paste0(ICD10_Value,collapse=";"),
            npdr_dme = sum(npdr_dme),
            severe_npdr = sum(severe_npdr),
            pdr = sum(pdr),
            dme = sum(dme))

censored <- open_dataset(paste0(path_retinopathy_fragmentation_folder,"/working/rfc04b"),partitioning = c("Year","Value_Grouper2")) %>% 
  dplyr::filter(!PatientDurableKey %in% post_exposure_outcome$PatientDurableKey) %>% 
  to_duckdb() %>% 
  group_by(PatientDurableKey) %>% 
  dplyr::filter(YearMonth == max(YearMonth)) %>% 
  ungroup() %>% 
  distinct(PatientDurableKey,YearMonth) %>% 
  collect() %>% 
  mutate(censor_YearMonth_ymd = ymd(paste0(YearMonth,"01")))

# analytic_after_historycheck -----------

analytic_after_historycheck <- 
  analytic_before_historycheck  %>% 
  dplyr::filter(SourceCountry_X == "United States of America") %>% 
  dplyr::select(-StartDateKey_plus1y,-StartDateKey_plus2y,-StartDateKey_ymd,
                -Ethnicity,-FirstRace,-SecondRace,-ThirdRace,
                -Sex,-SexAssignedAtBirth,-npdr_nodme,-npdr_dme,
                -severe_npdr,-pdr,-dme) %>% 
  mutate(dx_detected_t1dm = case_when(PatientDurableKey %in% rfd04$PatientDurableKey ~ 1,
                                      TRUE ~ 0),
         supreme_detected_t2dm = case_when(PatientDurableKey %in% rfd03$PatientDurableKey ~ 1,
                                           TRUE ~ 0)) %>% 
  
  left_join(rfc01a %>% dplyr::select(-Year) %>% rename(bmi_YearMonth = YearMonth),
            by=c("PatientDurableKey")) %>% 
  left_join(rfc02aa %>% dplyr::select(-Year,-LoincCode) %>% rename(hba1c_YearMonth = YearMonth,hba1c = NumericValue),
            by=c("PatientDurableKey")) %>% 
  left_join(rfc02da %>% dplyr::select(-Year,-LoincCode) %>% rename(ldl_YearMonth = YearMonth,ldl = NumericValue),
            by=c("PatientDurableKey")) %>% 
  left_join(rfc02ea %>% dplyr::select(-Year,-LoincCode) %>% rename(hdl_YearMonth = YearMonth,hdl = NumericValue),
            by=c("PatientDurableKey")) %>% 
  left_join(rfc05 %>% rename(insurance_YearMonth = YearMonth),
            by=c("PatientDurableKey")) %>% 
  left_join(rfc03a,
            by=c("PatientDurableKey")) %>% 
  left_join(rfc04a,
            by=c("PatientDurableKey")) %>% 
  left_join(blood_pressure %>% 
              rename(bp_Y1 = Y1,
                     bp_Y2 = Y2),
  by=c("PatientDurableKey")) %>% 
  left_join(hba1c %>% 
              rename(hba1c_Y1 = Y1,
                     hba1c_Y2 = Y2),
  by=c("PatientDurableKey")) %>% 
  left_join(mean_hba1c,
  by=c("PatientDurableKey")) %>% 
  left_join(mean_blood_pressure,
    by=c("PatientDurableKey")) %>% 
  left_join(hdl %>% 
              rename(hdl_Y1 = Y1,
                     hdl_Y2 = Y2),
            by=c("PatientDurableKey")) %>% 
  left_join(ldl %>% 
              rename(ldl_Y1 = Y1,
                     ldl_Y2 = Y2),
            by=c("PatientDurableKey")) %>% 
  left_join(care_continuity,
            by="PatientDurableKey") %>% 
  left_join(physician_visit,
            by="PatientDurableKey")  %>% 
  left_join(post_exposure_outcome %>% 
              rename_with(~paste0("o_",.)),
            by=c("PatientDurableKey"="o_PatientDurableKey")) %>% 
  mutate(outcome = case_when(is.na(o_ICD10_Value) ~ 0,
                             TRUE ~ 1),
         o_YearMonth_ymd = ymd(paste0(o_YearMonth,"01"))) %>% 
  mutate(months_to_event = as.numeric(difftime(o_YearMonth_ymd, diag_date,units = "weeks"))/4) %>% 
  left_join(censored %>% dplyr::select(-YearMonth),
            by=c("PatientDurableKey")) %>% 
  mutate(months_to_event = as.numeric(difftime(o_YearMonth_ymd, diag_date,units = "weeks"))/4)%>% 
  mutate(months_to_censor = as.numeric(difftime(censor_YearMonth_ymd, diag_date,units = "weeks"))/4) %>% 
  mutate(t = case_when(!is.na(months_to_event) ~ months_to_event,
                       TRUE ~ months_to_censor)) %>% 
  collect() %>% 
  mutate(raceeth = factor(raceeth, levels=c(1:4),labels=c("NHWhite","NHBlack","Hispanic","NHOther"))) 

table(analytic_after_historycheck$t1dm) 
table(analytic_after_historycheck$t1dm,analytic_after_historycheck$supreme_detected_t2dm) 




saveRDS(analytic_after_historycheck,paste0(path_retinopathy_fragmentation_folder,"/working/rfa001_analytic sample.RDS"))
saveRDS(analytic_before_historycheck,paste0(path_retinopathy_fragmentation_folder,"/working/rfa001_sample before history check.RDS"))
saveRDS(earliest_rfd05,paste0(path_retinopathy_fragmentation_folder,"/working/rfa001_earliest NPDR cases.RDS"))


# analytic_before_historycheck <- readRDS(paste0(path_retinopathy_fragmentation_folder,"/working/rfa001_sample before history check.RDS"))
table(analytic_before_historycheck$PatientDurableKey %in% rfd04$PatientDurableKey)


## rfc06b. Any encounters in Y1 and Y2 ----------
any_encounters <- open_dataset(paste0(path_retinopathy_fragmentation_folder,"/working/rfc06b"),partitioning = c("Year","SourceKey")) %>%
  mutate(PatientDurableKey = as.numeric(PatientDurableKey),
         YearMonthKey = paste0(YearMonth,"01")) %>% 
  mutate(YearMonthKey = as.numeric(YearMonthKey))  %>% 
  left_join(rfd08 %>% 
              dplyr::select(PatientDurableKey,StartDateKey,StartDateKey_plus1y, StartDateKey_plus2y),
            by = c("PatientDurableKey")) %>%
  mutate(period = case_when(YearMonthKey >= StartDateKey & YearMonthKey < StartDateKey_plus1y ~ "Y1",
                            YearMonthKey >= StartDateKey_plus1y & YearMonthKey < StartDateKey_plus2y ~ "Y2",
                            TRUE ~ "Y3 or later")) %>% 
  collect() %>% 
  distinct(PatientDurableKey,period) %>% 
  mutate(value = 1) %>% 
  pivot_wider(names_from=period,values_from=value,values_fill=0)

saveRDS(any_encounters,paste0(path_retinopathy_fragmentation_folder,"/working/rfa001_any_encounters in y1 to 3.RDS"))

