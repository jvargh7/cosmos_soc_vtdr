
# rm(list=ls());gc();source(".Rprofile")


poisson_df <- read_csv("analysis/rfa004_poisson estimates.csv") %>% 
  dplyr::filter(type %in% c("adjusted","unadjusted"),
                str_detect(term,"(hba1c|raceeth|region)")) %>% 
  mutate(coef_ci = paste0(round(coef,2)," (",
                          round(lci,2),", ",
                          round(uci,2),")")) %>% 
  dplyr::select(year,term,type,outcome,coef_ci) %>% 
  pivot_wider(names_from = c(type,year,outcome),values_from=coef_ci) %>% 
  dplyr::select(term,contains("Y1"),contains("Y2"),contains("BOTH"))

survival_df <- read_csv("analysis/rfa005_survival estimates.csv") %>% 
  mutate(coef = exp(estimate),
         lci = exp(estimate - 1.96*std.error),
         uci = exp(estimate + 1.96*std.error)) %>% 
  dplyr::filter(type %in% c("adjusted","unadjusted"),
                str_detect(term,"(hba1c|raceeth|region)")) %>% 
  mutate(coef_ci = paste0(round(coef,2)," (",
                          round(lci,2),", ",
                          round(uci,2),")")) %>% 
  dplyr::select(term,type,coef_ci) %>% 
  pivot_wider(names_from = type,values_from=coef_ci)

write_csv(poisson_df,"paper/table_poisson associations.csv")
write_csv(survival_df,"paper/table_survival associations.csv")
