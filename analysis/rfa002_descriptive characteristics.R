
rm(list=ls());gc();source(".Rprofile")

# From rfa_analytic sample preprocessing.R
source("analysis/rfa_analytic sample preprocessing.R")
source("H:/code/functions/nhst/table1_summary.R")


c_vars = c("age","SviOverallPctlRankByZip2020_X","SviHouseholdCharacteristicsPctlRankByZip2020_X",
           "SviRacialEthnicMinorityStatusPctlRankByZip2020_X","bbi_Y1",
           "bbi_Y2","n_total_Y1","n_total_Y2",
           "Ophthalmology_Y1","Ophthalmology_Y2",
           "PrimaryCare_Y1","PrimaryCare_Y2",
           "hba1c_Y1","hba1c_Y2",
           "bp_Y1","bp_Y2",
           "ldl_Y1","ldl_Y2",
           "BodyMassIndex","SystolicBloodPressure",
           "DiastolicBloodPressure","hba1c",
           "ldl","hdl",
           "t")

p_vars = c("female","t1dm","t2dm",
           "supreme_detected_t2dm","dx_detected_t1dm",
           "insurance_medicare","insurance_other",
           "insurance_medicaid","insurance_selfpay",
           "mild_npdr_nodme","moderate_npdr_nodme",
           "n_total_Y1_eq0","n_total_Y2_eq0",
           "bbi_Y1_ge70","bbi_Y2_ge70","svi_ge75",
           "Ophthalmology_Y1_ge1","Ophthalmology_Y2_ge1",
           "PrimaryCare_Y1_ge1","PrimaryCare_Y2_ge1",
           "hba1c_Y1_ge1","hba1c_Y2_ge1","bp_Y1_ge1","bp_Y2_ge1",
           "ldl_Y1_ge1","ldl_Y2_ge1","standards_year1_ge2","standards_year2_ge2",
           "ABC_Y1_ge1","ABC_Y2_ge1","Ophthalmology_both","PrimaryCare_both",
           "ABC_both","soc_both","htn_dx","hld_dx","cerebro_dx",
           "pulmonary_dx","cardiovascular_dx","obesity_dx",
           "htn_rx","hld_rx","statin_rx","insulin_rx",
           "otherdm_rx","depres_rx","psych_rx","outcome",
           "o_severe_npdr","o_npdr_dme","o_pdr","o_dme"
           )

g_vars = c("raceeth","eligibility","historical_hba1c_group",
           "historical_bp_group","historical_ldl_group","ValidatedStateOrProvince_X")

table1_df_region = analytic %>% 
  mutate(SviOverallPctlRankByZip2020_X = SviOverallPctlRankByZip2020_X*100,
         SviHouseholdCharacteristicsPctlRankByZip2020_X = SviHouseholdCharacteristicsPctlRankByZip2020_X*100,
         SviRacialEthnicMinorityStatusPctlRankByZip2020_X = SviRacialEthnicMinorityStatusPctlRankByZip2020_X*100) %>% 
  table1_summary(.,c_vars=c_vars,p_vars=p_vars,g_vars=g_vars,
                 id_vars="region")

table1_df_total = analytic %>% 
  mutate(SviOverallPctlRankByZip2020_X = SviOverallPctlRankByZip2020_X*100,
         SviHouseholdCharacteristicsPctlRankByZip2020_X = SviHouseholdCharacteristicsPctlRankByZip2020_X*100,
         SviRacialEthnicMinorityStatusPctlRankByZip2020_X = SviRacialEthnicMinorityStatusPctlRankByZip2020_X*100) %>% 
  table1_summary(df=.,c_vars=c_vars,p_vars=p_vars,g_vars=g_vars) 
  


bind_rows(table1_df_region,
          table1_df_total %>% mutate(region = "Total")) %>% 
  mutate(value = case_when(est == "freq" & value <= 10 ~ 11,
                           est == "missing" & value == 0 ~ NA_real_,
                           est == "missing" & value <= 10 ~ -1,
                          TRUE ~ value)) %>% 
  write_csv(.,"analysis/rfa002_descriptive characteristics.csv")

