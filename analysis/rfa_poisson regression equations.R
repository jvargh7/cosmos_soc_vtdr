
dx_rx = c("htn_dx","hld_dx","cerebro_dx","pulmonary_dx","cardiovascular_dx","obesity_dx",
          "htn_rx","hld_rx","statin_rx","insulin_rx","otherdm_rx","depres_rx","psych_rx")

# covariates = paste0(" + SviOverallPctlRankByZip2020_X + historical_bp_group + age + female + raceeth_2 + raceeth_3 + raceeth_4 + supreme_detected_t2dm + 
#                       hba1c + ldl + BodyMassIndex + SystolicBloodPressure +
#                       insurance_medicare + insurance_medicaid + insurance_other + factor(ValidatedStateOrProvince_X)"," + ",paste0(dx_rx,collapse=" + "))

covariates = paste0(" + SviOverallPctlRankByZip2020_X  + age + female + supreme_detected_t2dm + 
                      + ldl + BodyMassIndex + 
                      insurance_medicare + insurance_medicaid + insurance_other + factor(ValidatedStateOrProvince_X)"," + ",paste0(dx_rx,collapse=" + "))




year1_covariates = "+ n_total_Y1"
year2_covariates = "+ n_total_Y2"

exposure_main = c("historical_hba1c_group + raceeth + region")



outcome_soc_both = "soc_both ~ "
outcome_soc_y1 = "I(standards_year1 >= 2) ~ "
outcome_soc_y2 = "I(standards_year2 >= 2) ~ "


# outcome_hc_both = "n_total_eq0_both ~ "
# outcome_hc_y1 = "I(n_total_Y1 == 0) ~ "
# outcome_hc_y2 = "I(n_total_Y2 == 0) ~ "
# 
# 
# outcome_cc_both = "bbi_ge70_both ~ "
# 
# outcome_cc_y1 = "I(bbi_Y1 >= 0.70) ~ "
# outcome_cc_y2 = "I(bbi_Y2 >= 0.70) ~ "
