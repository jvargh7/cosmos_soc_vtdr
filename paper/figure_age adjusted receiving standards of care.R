rm(list=ls());gc();source(".Rprofile")

# From rfa_analytic sample preprocessing.R
source("analysis/rfa_analytic sample preprocessing.R")

outcome_vars = c("Ophthalmology_both","PrimaryCare_both",
                 "hba1c_both","bp_both","ldl_both")
fig_df_raceeth <- map_dfr(outcome_vars,
                          function(o){
                            
                            df_urban = analytic %>% dplyr::filter(region == "Urban")
                            df_rural = analytic %>% dplyr::filter(region == "Rural")
                            
                            mod_urban = glm(formula = as.formula(paste0(o,"~ age*raceeth")),data=df_urban)
                            mod_rural = glm(formula = as.formula(paste0(o,"~ age*raceeth")),data=df_rural)
                            
                            
                            est_NHWhite_urban = df_urban %>% 
                              mutate(raceeth = "NHWhite") %>%
                              predict(mod_urban,newdata=.,type="response") %>% 
                              mean(.)
                            
                            est_NHBlack_urban = df_urban %>% 
                              mutate(raceeth = "NHBlack") %>%
                              predict(mod_urban,newdata=.,type="response") %>% 
                              mean(.)
                            
                            est_Hispanic_urban = df_urban %>% 
                              mutate(raceeth = "Hispanic") %>%
                              predict(mod_urban,newdata=.,type="response") %>% 
                              mean(.)
                            
                            est_NHOther_urban = df_urban %>% 
                              mutate(raceeth = "NHOther") %>%
                              predict(mod_urban,newdata=.,type="response") %>% 
                              mean(.)
                            
                            est_NHWhite_rural = df_rural %>% 
                              mutate(raceeth = "NHWhite") %>%
                              predict(mod_rural,newdata=.,type="response") %>% 
                              mean(.)
                            
                            est_NHBlack_rural = df_rural %>% 
                              mutate(raceeth = "NHBlack") %>%
                              predict(mod_rural,newdata=.,type="response") %>% 
                              mean(.)
                            
                            est_Hispanic_rural = df_rural %>% 
                              mutate(raceeth = "Hispanic") %>%
                              predict(mod_rural,newdata=.,type="response") %>% 
                              mean(.)
                            
                            est_NHOther_rural = df_rural %>% 
                              mutate(raceeth = "NHOther") %>%
                              predict(mod_rural,newdata=.,type="response") %>% 
                              mean(.)
                            
                            data.frame(
                              region = rep(c("Urban","Rural"),each=4),
                              raceeth = rep(c("NHWhite","NHBlack","Hispanic","NHOther"),times=2),
                              value = c(est_NHWhite_urban,est_NHBlack_urban,est_Hispanic_urban,est_NHOther_urban,
                                        est_NHWhite_rural,est_NHBlack_rural,est_Hispanic_rural,est_NHOther_rural)
                            ) %>% 
                              mutate(value = value*100,
                                     variable = o) %>% 
                              return(.)
                            
                            
                            
                          })  %>% 
  mutate(variable = factor(variable,levels=outcome_vars,
                           labels=c("Ophthalmology","Primary Care",
                                    "HbA1c","Blood Pressure","LDL cholesterol")))

fig_df_total = analytic %>% 
  group_by(region) %>% 
  summarize(across(one_of(outcome_vars),~100*mean(.))) %>% 
  pivot_longer(cols=-one_of("region"),names_to="variable",values_to="value") %>%
  mutate(variable = factor(variable,levels=c("Ophthalmology_both","PrimaryCare_both",
                                             "hba1c_both","bp_both","ldl_both"),
                           labels=c("Ophthalmology","Primary Care",
                                    "HbA1c","Blood Pressure","LDL cholesterol"))) %>% 
  mutate(raceeth = "Overall")



fig_df_overall = bind_rows(fig_df_total,
                           fig_df_raceeth) %>% 
  mutate(raceeth = factor(raceeth,levels=c("Overall","NHWhite","NHBlack","Hispanic","NHOther"),
                          labels = c("Overall","NH White","NH Black","Hispanic","NH Other")))

write_csv(fig_df_overall,"paper/table_age adjusted receiving standards of care.csv")


fig_rural =  fig_df_overall %>% 
  dplyr::filter(region == "Rural") %>% 
  ggplot(data=.,aes(x=variable,group=raceeth)) +
  geom_text(aes(y=(value+10),label=round(value,1)),position = position_dodge(width=0.9),size=3)+
  geom_col(aes(fill=raceeth,y=value),position = position_dodge(width=0.9)) +
  theme_bw() +
  xlab("") +
  ylab("Percentage (%)") +
  scale_y_continuous(limits=c(0,100))   +
  theme(axis.text = element_text(size = 14),
        legend.text = element_text(size = 14)) +
  scale_fill_manual("",values=c("#FF7968",rgb(242/255,173/255,0/255),rgb(90/255,188/255,214/255),rgb(1/255,160/255,138/255),rgb(114/255,148/255,212/255)))

fig_urban = fig_df_overall %>% 
  dplyr::filter(region == "Urban") %>% 
  ggplot(data=.,aes(x=variable,group=raceeth)) +
  geom_text(aes(y=(value+10),label=round(value,1)),position = position_dodge(width=0.9),size=3)+
  geom_col(aes(fill=raceeth,y=value),position = position_dodge(width=0.9)) +
  theme_bw() +
  xlab("") +
  ylab("Percentage (%)")  +
  theme(axis.text = element_text(size = 14),
        legend.text = element_text(size = 14)) +
  scale_y_continuous(limits=c(0,100)) +
  scale_fill_manual("",values=c("#FF7968",rgb(242/255,173/255,0/255),rgb(90/255,188/255,214/255),rgb(1/255,160/255,138/255),rgb(114/255,148/255,212/255)))

library(ggpubr)

ggarrange(fig_rural_A,
          fig_urban_C,
          labels=c("A","B"),
          legend="bottom",
          nrow=2,
          ncol=1,
          common.legend = TRUE) %>% 
  ggsave(.,filename=paste0(path_retinopathy_fragmentation_folder,"/figures/age adjusted receiving standards of care.jpg"),width=10,height=8)
fig_rural  
