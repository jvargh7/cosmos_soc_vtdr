
rm(list=ls());gc();source(".Rprofile")

# From rfa_analytic sample preprocessing.R
source("analysis/rfa_analytic sample preprocessing.R")


analytic %>% 
  head() %>% 
  dplyr::select(c(age,female,raceeth,
                  SviOverallPctlRankByZip2020_X,
                  supreme_detected_t2dm,dx_detected_t1dm,
                  t1dm, t2dm,
                  bbi_Y1,bbi_Y2,
                  n_total_Y1, n_total_Y2,
                  Ophthalmology_Y1, Ophthalmology_Y2,
                  PrimaryCare_Y1, PrimaryCare_Y2,
                  hba1c_Y1, hba1c_Y2,
                  bp_Y1, bp_Y2,
                  ldl_Y1, ldl_Y2,
                  
                  insurance_medicare,
                  insurance_other,
                  insurance_medicaid,
                  insurance_selfpay,
                  
                  BodyMassIndex, SystolicBloodPressure, DiastolicBloodPressure,
                  hba1c, ldl, hdl,
                  
                  mild_npdr_nodme, moderate_npdr_nodme,
                  n_total_Y1_eq0, n_total_Y2_eq0,
                  bbi_Y1_ge70, bbi_Y2_ge70,
                  svi_ge75,
                  
                  Ophthalmology_Y1_ge1, Ophthalmology_Y2_ge1,
                  PrimaryCare_Y1_ge1, PrimaryCare_Y2_ge1,
                  hba1c_Y1_ge1, hba1c_Y2_ge1,
                  bp_Y1_ge1, bp_Y2_ge1,
                  ldl_Y1_ge1, ldl_Y2_ge1,
                  standards_year1_ge2, standards_year2_ge2,
                  
                  ABC_Y1_ge1, ABC_Y2_ge1,
                  Ophthalmology_both, PrimaryCare_both, ABC_both,
                  soc_both,
                  
                  eligibility,
                  
                  htn_dx,hld_dx,cerebro_dx,pulmonary_dx,cardiovascular_dx,obesity_dx,
                  htn_rx,hld_rx,statin_rx,insulin_rx,otherdm_rx,depres_rx,psych_rx,
                  
                  historical_hba1c_group, outcome,t,
                  
                  o_severe_npdr, o_npdr_dme, o_pdr, o_dme,
                  ValidatedStateOrProvince_X
  ))

with(analytic,table(supreme_detected_t2dm,dx_detected_t1dm))

# Table generation -------
library(gtsummary)

(rfa01_descriptives <- analytic %>% 
    mutate(SviOverallPctlRankByZip2020_X = SviOverallPctlRankByZip2020_X*100) %>% 
  tbl_summary(by=region,
              include = c(age,female,raceeth,
                          SviOverallPctlRankByZip2020_X,
                          supreme_detected_t2dm,dx_detected_t1dm,
                          t1dm, t2dm,
                          bbi_Y1,bbi_Y2,
                          n_total_Y1, n_total_Y2,
                          Ophthalmology_Y1, Ophthalmology_Y2,
                          PrimaryCare_Y1, PrimaryCare_Y2,
                          hba1c_Y1, hba1c_Y2,
                          bp_Y1, bp_Y2,
                          ldl_Y1, ldl_Y2,
                          
                          
                          insurance_medicare,
                          insurance_other,
                          insurance_medicaid,
                          insurance_selfpay,
                          
                          BodyMassIndex, SystolicBloodPressure, DiastolicBloodPressure,
                          hba1c, ldl, hdl,
                          
                          mild_npdr_nodme, moderate_npdr_nodme,
                          n_total_Y1_eq0, n_total_Y2_eq0,
                          bbi_Y1_ge70, bbi_Y2_ge70,
                          svi_ge75,
                          
                          Ophthalmology_Y1_ge1, Ophthalmology_Y2_ge1,
                          PrimaryCare_Y1_ge1, PrimaryCare_Y2_ge1,
                          hba1c_Y1_ge1, hba1c_Y2_ge1,
                          bp_Y1_ge1, bp_Y2_ge1,
                          ldl_Y1_ge1, ldl_Y2_ge1,
                          standards_year1_ge2, standards_year2_ge2,
                          
                          ABC_Y1_ge1, ABC_Y2_ge1,
                          Ophthalmology_both, PrimaryCare_both, ABC_both,
                          soc_both,
                          
                          eligibility,
                          
                          htn_dx,hld_dx,cerebro_dx,pulmonary_dx,cardiovascular_dx,obesity_dx,
                          htn_rx,hld_rx,statin_rx,insulin_rx,otherdm_rx,depres_rx,psych_rx,
                          
                          historical_hba1c_group, outcome,t,
                          
                          o_severe_npdr, o_npdr_dme, o_pdr, o_dme,
                          ValidatedStateOrProvince_X
                          ),
              missing = "ifany",
              missing_text = "Missing",
              type = list(age ~ "continuous",
                          female ~ "dichotomous",
                          raceeth ~ "categorical",
                          SviOverallPctlRankByZip2020_X ~ "continuous2",
                          bbi_Y1 ~ "continuous2",bbi_Y2 ~ "continuous2",
                          n_total_Y1 ~ "continuous2",n_total_Y1 ~ "continuous2",
                          Ophthalmology_Y1 ~ "continuous2",Ophthalmology_Y2 ~ "continuous2",
                          PrimaryCare_Y1 ~ "continuous2",PrimaryCare_Y2 ~ "continuous2",
                          hba1c_Y1 ~ "continuous2", hba1c_Y2 ~ "continuous2",
                          bp_Y1 ~ "continuous2", bp_Y2 ~ "continuous2",
                          ldl_Y1 ~ "continuous2", ldl_Y2 ~ "continuous2",
                          
                          
                          t1dm ~ "dichotomous",
                          t2dm ~ "dichotomous",
                          supreme_detected_t2dm ~ "dichotomous",
                          dx_detected_t1dm ~ "dichotomous",
                          
                          insurance_medicare ~ "dichotomous",
                          insurance_other ~ "dichotomous",
                          insurance_medicaid ~ "dichotomous",
                          insurance_selfpay ~ "dichotomous",
                          
                          BodyMassIndex ~ "continuous", SystolicBloodPressure ~ "continuous", DiastolicBloodPressure ~ "continuous",
                          hba1c ~ "continuous2", ldl ~ "continuous", hdl ~ "continuous",
                          
                          mild_npdr_nodme ~ "dichotomous", moderate_npdr_nodme ~ "dichotomous",
                          n_total_Y1_eq0 ~ "dichotomous", n_total_Y2_eq0 ~ "dichotomous",
                          bbi_Y1_ge70 ~ "dichotomous", bbi_Y2_ge70 ~ "dichotomous",
                          svi_ge75 ~ "dichotomous",
                          
                          Ophthalmology_Y1_ge1 ~ "dichotomous", Ophthalmology_Y2_ge1 ~ "dichotomous",
                          PrimaryCare_Y1_ge1 ~ "dichotomous", PrimaryCare_Y2_ge1 ~ "dichotomous",
                          hba1c_Y1_ge1 ~ "dichotomous", hba1c_Y2_ge1 ~ "dichotomous",
                          bp_Y1_ge1 ~ "dichotomous", bp_Y2_ge1 ~ "dichotomous",
                          ldl_Y1_ge1 ~ "dichotomous", ldl_Y2_ge1 ~ "dichotomous",
                          standards_year1_ge2 ~ "dichotomous", standards_year2_ge2 ~ "dichotomous",
                          
                          ABC_Y1_ge1 ~ "dichotomous", ABC_Y2_ge1 ~ "dichotomous",
                          
                          Ophthalmology_both ~ "dichotomous", PrimaryCare_both ~ "dichotomous", ABC_both ~ "dichotomous",
                          soc_both ~ "dichotomous",
                          
                          eligibility ~ "categorical",
                          
                          htn_dx~ "dichotomous",hld_dx~ "dichotomous",cerebro_dx~ "dichotomous",pulmonary_dx~ "dichotomous",
                          cardiovascular_dx~ "dichotomous",obesity_dx~ "dichotomous",
                          htn_rx~ "dichotomous",hld_rx~ "dichotomous",statin_rx~ "dichotomous",insulin_rx~ "dichotomous",
                          otherdm_rx~ "dichotomous",depres_rx~ "dichotomous",psych_rx~ "dichotomous",
                          
                          historical_hba1c_group  ~ "categorical", outcome ~ "dichotomous", t ~ "continuous2",
                          
                          o_severe_npdr ~ "dichotomous", o_npdr_dme ~ "dichotomous", o_pdr ~ "dichotomous", o_dme ~ "dichotomous"
                          ),
              digits = list(age ~ c(1,1),
                            bbi_Y1 ~ c(1,1,1,1,1),bbi_Y2 ~ c(1,1,1,1,1),
                            n_total_Y1 ~ c(1,1,1,1,1),n_total_Y2 ~ c(1,1,1,1,1),
                            Ophthalmology_Y1 ~ c(1,1,1,1,1),Ophthalmology_Y2 ~ c(1,1,1,1,1),
                            PrimaryCare_Y1 ~ c(1,1,1,1,1),PrimaryCare_Y2 ~ c(1,1,1,1,1),
                            hba1c_Y1 ~ c(1,1,1,1,1),hba1c_Y2 ~ c(1,1,1,1,1),
                            bp_Y1 ~ c(1,1,1,1,1),bp_Y2 ~ c(1,1,1,1,1),
                            ldl_Y1 ~ c(1,1,1,1,1),ldl_Y2 ~ c(1,1,1,1,1),
                            
                            SviOverallPctlRankByZip2020_X ~ c(1,1,1,1,1),

                            
                            
                            BodyMassIndex ~ c(1,1), SystolicBloodPressure ~ c(1,1), DiastolicBloodPressure ~ c(1,1),
                            hba1c ~ c(1,1,1,1,1), ldl ~ c(1,1), hdl ~ c(1,1), t ~ c(1,1,1,1,1)
                            ),
              statistic = list(all_continuous() ~ "{mean} ({sd})",
                               all_continuous2() ~ c("{median} ({p25}, {p75})", "{min}, {max}"))
              ) %>% 
  add_n() %>% 
  add_overall()) %>%
  as_gt() %>%
  gt::gtsave(filename = "analysis/rfa002_descriptive characteristics.html")
