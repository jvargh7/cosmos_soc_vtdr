rm(list=ls());gc();source(".Rprofile")

library(survival)
library(mice)
library(lmtest)
library(sandwich)
# From rfa_analytic sample preprocessing.R
source("analysis/rfa_analytic sample preprocessing.R")

source("analysis/rfa_poisson regression equations.R")

mi_dfs <- readRDS(paste0(path_retinopathy_fragmentation_folder,"/working/rfa003_multiple imputation of analytic.RDS"))


# Define a function to fit Poisson regression and extract robust SE
fit_poisson_robust <- function(data,f) {
  model <- glm(as.formula(f), data = data, family = poisson)
  robust_se <- coeftest(model, vcov = vcovHC(model, type = "HC0"))
  return(robust_se)
}

mice_fit_poisson_robust <- function(mids_dfs, formula = formula){
  
  # fits = mice:::with.mids(mids_dfs,fit_poisson_robust(f=formula))

  fits = mice::as.mira(
    map(complete(mids_dfs,"all"),
        function(df){
          
          df2 = df %>% 
            left_join(analytic %>% 
                        dplyr::select(PatientDurableKey,historical_hba1c_group,raceeth),
                      by=c("PatientDurableKey"))
          
          fit_poisson_robust(df2,f=formula)
        })
    
  )
  
  
  # Pool the results to obtain combined estimates and robust standard errors
  pooled_estimates <- pool(fits) %>% broom::tidy()
  
  return(pooled_estimates)
}




soc0_y1 = mice_fit_poisson_robust(mids_dfs = mi_dfs,
                                        formula = paste0(outcome_soc_y1,exposure_main))
soc0_y2 = mice_fit_poisson_robust(mids_dfs = mi_dfs,
                                        formula = paste0(outcome_soc_y2,exposure_main))
soc0_both = mice_fit_poisson_robust(mids_dfs = mi_dfs,
                                        formula = paste0(outcome_soc_both,exposure_main))


soc1_y1 = mice_fit_poisson_robust(mids_dfs = mi_dfs,
                                         formula = paste0(outcome_soc_y1,exposure_main,covariates,year1_covariates))

soc1_y2 = mice_fit_poisson_robust(mids_dfs = mi_dfs,
                                         formula = paste0(outcome_soc_y2,exposure_main,covariates,year2_covariates))
soc1_both = mice_fit_poisson_robust(mids_dfs = mi_dfs,
                                         formula = paste0(outcome_soc_both,exposure_main,covariates,year1_covariates,year2_covariates))


rfa004 <- bind_rows(
  soc0_y1 %>% mutate(outcome = "soc",type="unadjusted",year = "Y1"),
  soc0_y2 %>% mutate(outcome = "soc",type="unadjusted",year = "Y2"),
  soc0_both %>% mutate(outcome = "soc",type="unadjusted",year = "BOTH"),
  soc1_y1 %>% mutate(outcome = "soc",type = "adjusted", year = "Y1"),
  soc1_y2 %>% mutate(outcome = "soc",type = "adjusted", year = "Y2"),
  soc1_both %>% mutate(outcome = "soc",type = "adjusted", year = "BOTH")

) %>% 
  
  mutate(coef = exp(estimate),
         lci = exp(estimate - 1.96*std.error),
         uci = exp(estimate + 1.96*std.error))


rfa004 %>% 
  write_csv(.,"analysis/rfa004_poisson estimates.csv")
