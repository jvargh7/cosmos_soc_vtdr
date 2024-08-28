rm(list=ls());gc();source(".Rprofile")

library(survival)
library(mice)
library(lmtest)
library(sandwich)
library(emmeans)
# From rfa_analytic sample preprocessing.R
source("analysis/rfa_analytic sample preprocessing.R")

source("analysis/rfa_survival regression equations.R")

source("H:/code/functions/imputation/clean_mi_contrasts.R")

mi_dfs <- readRDS(paste0(path_retinopathy_fragmentation_folder,"/working/rfa003_multiple imputation of analytic.RDS"))



# Define a function to fit Poisson regression and extract robust SE
fit_coxph <- function(data,f) {
  model <- coxph(as.formula(f), data = data)
  # coxph_output = model %>% 
  #   broom::tidy(.)
  return(model)
}



mice_fit_coxph <- function(mids_dfs, formula = formula,est_contrasts = FALSE
                           ){
  
  # fits = mice:::with.mids(mids_dfs,fit_poisson_robust(f=formula))
  
  fits = mice::as.mira(
    map(complete(mids_dfs,"all"),
        function(df){
          df2 = df %>% 
            left_join(analytic %>% 
                        dplyr::select(PatientDurableKey,historical_hba1c_group,historical_bp_group,raceeth,
                                      outcome,t),
                      by=c("PatientDurableKey")) %>% 
            dplyr::filter(!is.na(t),t>=1)
          
          # if(est_emmeans){
          #   fit_coxph_emmeans(df2,f=formula)
          #   
          # }else{
            fit_coxph(df2,f=formula)
            
          # }
        })
    
    
    
  )
  
  # Pool the results to obtain combined estimates and robust standard errors
  pooled_estimates <- pool(fits) %>% broom::tidy()
  
  if(est_contrasts){
    
    difference_grid_hba1c_raceeth = expand.grid(exposure = c("historical_hba1c_group<7",
                                                             "historical_hba1c_group7-9",
                                                             "historical_hba1c_group>=9","historical_hba1c_groupUnavailable"),
                                                modifier = c("raceethNHWhite","raceethNHBlack","raceethHispanic","raceethNHOther"))
    
    pooled_contrasts = map2_dfr(difference_grid_hba1c_raceeth$exposure,difference_grid_hba1c_raceeth$modifier,
             function(x,y){
               clean_mi_contrasts(fits$analyses,link="coxph",
                                  modifier  = y,exposure=x) %>% 
                 mutate(exposure = x,
                        modifier = y)
               
             })
    
    pooled_contrasts_flipped = map2_dfr(difference_grid_hba1c_raceeth$exposure,difference_grid_hba1c_raceeth$modifier,
                                        function(x,y){
                                          clean_mi_contrasts(fits$analyses,link="coxph",
                                                             modifier  = x,exposure=y) %>% 
                                            mutate(exposure = y,
                                                   modifier = x)
                                          
                                        })
    
    return(list(estimates = pooled_estimates,
                contrasts = pooled_contrasts,
                contrasts_flipped = pooled_contrasts_flipped))
      
    } else{
    return(pooled_estimates)
  }
  
}


hba1c_main0 <- mice_fit_coxph(mids_dfs = mi_dfs,formula = paste0(outcome_main,exposure_main))
hba1c_main1 <- mice_fit_coxph(mids_dfs = mi_dfs,formula = paste0(outcome_main,exposure_main,covariates))
hba1c_main2 <- mice_fit_coxph(mids_dfs = mi_dfs,formula = paste0(outcome_main,exposure_interaction,covariates),est_contrasts = TRUE)


(rfa005 <- bind_rows(
 hba1c_main0 %>% mutate(model = "Main",type = "unadjusted"),
 hba1c_main1 %>% mutate(model = "Main",type = "adjusted"),
 hba1c_main2$estimates %>% mutate(model = "Main",type = "interaction"))) %>% 
   write_csv(.,"analysis/rfa005_survival estimates.csv")


contrast_estimates <- bind_rows(hba1c_main2$contrasts %>% 
                                  dplyr::filter(iv == "Contrast 2",!is.nan(gamma_D)),
                                hba1c_main2$contrasts_flipped %>% 
                                  dplyr::filter(iv == "Contrast 2",!is.nan(gamma_D),modifier == "historical_hba1c_group<7") %>% 
                                  rename(modifier_new = exposure,
                                         exposure_new = modifier) %>% 
                                  rename(modifier = modifier_new,
                                         exposure = exposure_new))


contrast_estimates %>% 
  write_csv(.,"analysis/rfa005_contrast of survival estimates.csv")
