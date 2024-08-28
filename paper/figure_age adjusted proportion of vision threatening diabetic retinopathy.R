rm(list=ls());gc();source(".Rprofile")

# From rfa_analytic sample preprocessing.R
source("analysis/rfa_analytic sample preprocessing.R")

outcome_vars = c("Ophthalmology_both","PrimaryCare_both",
                 "hba1c_both","bp_both","ldl_both")

hb_group = c("<7","7-9",">=9","Unavailable")


fig_df_raceeth <- map_dfr(hb_group,
                          function(h){
                            
                              df_urban = analytic %>% dplyr::filter(region == "Urban",historical_hba1c_group == h)
                              df_rural = analytic %>% dplyr::filter(region == "Rural",historical_hba1c_group == h)
                              
                              mod_urban = glm(formula = as.formula(paste0("outcome ~ age*raceeth")),data=df_urban)
                              mod_rural = glm(formula = as.formula(paste0("outcome ~ age*raceeth")),data=df_rural)
                            
                          
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
                                     historical_hba1c_group = h) %>% 
                              return(.)
                            
                            
                            
                          })  

fig_df_total = analytic %>% 
  group_by(region,historical_hba1c_group) %>% 
  summarize(value = 100*mean(outcome)) %>% 
  mutate(raceeth = "Overall")




fig_df_overall = bind_rows(
  fig_df_total,
  fig_df_raceeth
) %>% 
  mutate(raceeth = factor(raceeth,levels=c("Overall","NHWhite","NHBlack","Hispanic","NHOther"),
                          labels = c("Overall","NH White","NH Black","Hispanic","NH Other")),
         historical_hba1c_group = factor(historical_hba1c_group,levels=hb_group))

write_csv(fig_df_overall,"paper/table_age adjusted proportion of vision threatening retinopathy.csv")


fig_rural = fig_df_overall %>%  
  dplyr::filter(region == "Rural") %>% 
  ggplot(data=.,aes(x=historical_hba1c_group,group=raceeth)) +
  geom_text(aes(y=(value+2),label=round(value,1)),position = position_dodge(width=0.9))+
  geom_col(aes(fill=raceeth,y=value),position = position_dodge(width=0.9)) +
  theme_bw() +
  xlab("") +
  ylab("Percentage (%)") +
  scale_y_continuous(limits=c(0,30)) +
  theme(axis.text = element_text(size = 14),
        legend.text = element_text(size = 14)) +
  scale_fill_manual("",values=c("#FF7968",rgb(242/255,173/255,0/255),rgb(90/255,188/255,214/255),rgb(1/255,160/255,138/255),rgb(114/255,148/255,212/255)))


fig_urban = fig_df_overall %>% 
  dplyr::filter(region == "Urban") %>% 
  ggplot(data=.,aes(x=historical_hba1c_group,group=raceeth)) +
  geom_text(aes(y=(value+2),label=round(value,1)),position = position_dodge(width=0.9))+
  geom_col(aes(fill=raceeth,y=value),position = position_dodge(width=0.9)) +
  theme_bw() +
  xlab("") +
  ylab("Percentage (%)") +
  scale_y_continuous(limits=c(0,30)) +
  theme(axis.text = element_text(size = 14),
        legend.text = element_text(size = 14)) +
  scale_fill_manual("",values=c("#FF7968",rgb(242/255,173/255,0/255),rgb(90/255,188/255,214/255),rgb(1/255,160/255,138/255),rgb(114/255,148/255,212/255)))

fig_rural

library(ggpubr)

ggarrange(fig_rural,
          fig_urban,
          labels=c("A","B"),
          legend="bottom",
          nrow=2,
          ncol=1,
          common.legend = TRUE) %>% 
  ggsave(.,filename=paste0(path_retinopathy_fragmentation_folder,"/figures/age adjusted proportion of vision threatening diabetic retinopathy.jpg"),width=10,height=8)

