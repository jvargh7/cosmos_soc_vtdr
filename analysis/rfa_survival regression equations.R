
dx_rx = c("htn_dx","hld_dx","cerebro_dx","pulmonary_dx","cardiovascular_dx","obesity_dx",
          "htn_rx","hld_rx","statin_rx","insulin_rx","otherdm_rx","depres_rx","psych_rx")

covariates = paste0(" + SviOverallPctlRankByZip2020_X + historical_bp_group + age + female + supreme_detected_t2dm + 
                      + ldl + BodyMassIndex + 
                      insurance_medicare + insurance_medicaid + insurance_other + factor(ValidatedStateOrProvince_X)"," + ",paste0(dx_rx,collapse=" + "))


outcome_main = c("Surv(t,outcome) ~ ")
exposure_main = c("historical_hba1c_group + raceeth + region")
exposure_interaction = c("historical_hba1c_group*raceeth + region")