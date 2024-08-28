
dx_rx = c("htn_dx","hld_dx","cerebro_dx","pulmonary_dx","cardiovascular_dx","obesity_dx",
          "htn_rx","hld_rx","statin_rx","insulin_rx","otherdm_rx","depres_rx","psych_rx")

# covariates = paste0(" + SviOverallPctlRankByZip2020_X + historical_bp_group + age + female + raceeth_2 + raceeth_3 + raceeth_4 + supreme_detected_t2dm + 
#                       hba1c + ldl + BodyMassIndex + SystolicBloodPressure +
#                       insurance_medicare + insurance_medicaid + insurance_other + factor(ValidatedStateOrProvince_X)"," + ",paste0(dx_rx,collapse=" + "))

covariates = paste0(" + SviOverallPctlRankByZip2020_X  + age + female + supreme_detected_t2dm + 
                      + ldl + BodyMassIndex + 
                      insurance_medicare + insurance_medicaid + insurance_other + factor(ValidatedStateOrProvince_X)"," + ",paste0(dx_rx,collapse=" + "))


exposure_main = c("historical_hba1c_group + raceeth + region")
outcome_cause_specific = c("Surv(t_sens,outcome_cause_specific) ~ ")
outcome_subdistribution = c("Surv(t_sens,event_type) ~ ")

exposure_interaction = c("historical_hba1c_group*raceeth + region")