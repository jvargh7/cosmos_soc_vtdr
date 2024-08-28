
rm(list=ls());gc();source(".Rprofile")

# From rfa_analytic sample preprocessing.R
source("analysis/rfa_analytic sample preprocessing.R")

c_vars = c("age","SviHouseholdCharacteristicsPctlRankByZip2020_X","SviRacialEthnicMinorityStatusPctlRankByZip2020_X",
           "SviOverallPctlRankByZip2020_X","BodyMassIndex",
           "SystolicBloodPressure","DiastolicBloodPressure","hba1c","ldl","hdl",
           "n_total_Y1","n_total_Y2",
           "bbi_Y1","bbi_Y2",
           "bp_Y1","bp_Y2",
           "hba1c_Y1","hba1c_Y2",
           "ldl_Y1","ldl_Y2",
           "Ophthalmology_Y1","Ophthalmology_Y2",
           "PrimaryCare_Y1","PrimaryCare_Y2",
           "standards_year1","standards_year2"
           )

p_vars = c("female","t1dm","t2dm","dx_detected_t1dm","supreme_detected_t2dm",
           "insurance_medicare","insurance_medicaid","insurance_other","insurance_selfpay",
           "mild_npdr_nodme","moderate_npdr_nodme","svi_ge75","bbi_Y1_ge70","bbi_Y2_ge70",
           "htn_dx","hld_dx","cerebro_dx","pulmonary_dx","cardiovascular_dx","obesity_dx",
           "htn_rx","hld_rx","statin_rx","insulin_rx","otherdm_rx","depres_rx","psych_rx",
           
           "soc_both","n_total_eq0_both","bbi_ge70_both"
           )

g_vars_to_dummy = c("raceeth")

g_vars = c("SourceCountry_X","ValidatedStateOrProvince_X","YearMonth","region")

id_vars = c("PatientDurableKey","StartDateKey","diag_date","AdultDate","DeathDate","Status")

before_imputation = analytic %>% 
  dplyr::select(one_of(id_vars,c_vars,p_vars,g_vars,g_vars_to_dummy)) %>% 
  mutate(raceeth_2 = case_when(raceeth == "NHBlack" ~ 1,
                               TRUE ~ 0),
         raceeth_3 = case_when(raceeth == "Hispanic" ~ 1,
                               TRUE ~ 0),
         raceeth_4 = case_when(raceeth == "NHOther" ~ 1,
                               TRUE ~ 0)) %>% 
  mutate(region_raceeth_2 = case_when(region == "Urban" & raceeth_2 == 1 ~ 1,
                                     TRUE ~ 0),
         svi_ge75_raceeth_2 = case_when(svi_ge75 == 1 & raceeth_2 == 1 ~ 1,
                                        TRUE ~ 0),
         region_raceeth_3 = case_when(region == "Urban" & raceeth_3 == 1 ~ 1,
                                     TRUE ~ 0),
         svi_ge75_raceeth_3 = case_when(svi_ge75 == 1 & raceeth_3 == 1 ~ 1,
                                        TRUE ~ 0),
         region_raceeth_4 = case_when(region == "Urban" & raceeth_4 == 1 ~ 1,
                                     TRUE ~ 0),
         svi_ge75_raceeth_4 = case_when(svi_ge75 == 1 & raceeth_4 == 1 ~ 1,
                                        TRUE ~ 0)) %>% 
  dplyr::select(-raceeth)

new_dummy_terms = c("raceeth_2","raceeth_3","raceeth_4")

interaction_terms = c("region_raceeth_2","svi_ge75_raceeth_2",
                      "region_raceeth_3","svi_ge75_raceeth_3",
                      "region_raceeth_4","svi_ge75_raceeth_4")

library(mice)
mi_null <- mice(before_imputation,
                maxit = 0)

method = mi_null$method
pred = mi_null$predictorMatrix

method[id_vars] <- ""

method[p_vars] <- map(method[p_vars],.f=function(x) case_when(x=="" ~ "",
                                            TRUE ~ "logreg")) %>% unlist()


method[g_vars] <- map(method[g_vars],.f=function(x) case_when(x=="" ~ "",
                                                              TRUE ~ "polyreg")) %>% unlist()
pred[id_vars,] <- 0
pred[,id_vars] <- 0



# Impute via equation and do not use for imputation , --------

method["svi_ge75"] <- "~I((SviOverallPctlRankByZip2020_X>=0.75)*1)"
method["soc_both"] <- "~I(standards_year1 >=2)*I(standards_year2 >=2)*1"
method["bbi_ge70_both"] <- "~I(bbi_Y1 >=0.70)*I(bbi_Y2 >=0.70)*1"
pred[c("svi_ge75"),] <- 0
pred[,c("svi_ge75")] <- 0


for(i_t in interaction_terms){
  print(i_t)
  exposure_term = str_extract(i_t,"^(region|svi_ge75)")
  em_term = str_replace(i_t,pattern=paste0(exposure_term,"_"),replacement = "")
  method[i_t] = paste0("~I(",exposure_term,"*",em_term,")")
  
  # Do not use interaction terms for imputation of the source variables
  pred[c(exposure_term,em_term),i_t] <- 0
}

# Takes ~4h
mi_dfs <- mice(before_imputation,
               method = method,
               pred = pred,
               m=10,maxit=30,seed=500)

saveRDS(mi_dfs, paste0(path_retinopathy_fragmentation_folder,"/working/rfa003_multiple imputation of analytic.RDS"))
