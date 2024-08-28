
rm(list=ls());gc();source(".Rprofile")

# From rfa_analytic sample preprocessing.R
source("analysis/rfa_analytic sample preprocessing.R")



fig_df_total = analytic %>% 
  group_by(region) %>% 
  summarize(across(one_of(c("Ophthalmology_both","PrimaryCare_both",
                            "hba1c_both","bp_both","ldl_both")),~100*mean(.))) %>% 
  pivot_longer(cols=-one_of("region"),names_to="variable",values_to="value") %>%
  mutate(variable = factor(variable,levels=c("Ophthalmology_both","PrimaryCare_both",
                                             "hba1c_both","bp_both","ldl_both"),
                           labels=c("Ophthalmology","Primary Care",
                                    "HbA1c","Blood Pressure","LDL cholesterol"))) %>% 
  mutate(raceeth = "Overall")

fig_df_raceeth = analytic  %>% 
  group_by(region,raceeth) %>% 
  summarize(across(one_of(c("Ophthalmology_both","PrimaryCare_both",
                            "hba1c_both","bp_both","ldl_both")),~100*mean(.))) %>% 
  pivot_longer(cols=-one_of("region","raceeth"),names_to="variable",values_to="value") %>%
  mutate(variable = factor(variable,levels=c("Ophthalmology_both","PrimaryCare_both",
                                             "hba1c_both","bp_both","ldl_both"),
                           labels=c("Ophthalmology","Primary Care",
                                    "HbA1c","Blood Pressure","LDL cholesterol")))


fig_df_overall = bind_rows(fig_df_total,
                           fig_df_raceeth) %>% 
  mutate(raceeth = factor(raceeth,levels=c("Overall","NHWhite","NHBlack","Hispanic","NHOther"),
                          labels = c("Overall","NH White","NH Black","Hispanic","NH Other")))

write_csv(fig_df_overall,"paper/table_receiving standards of care.csv")

fig_rural =  fig_df_overall %>% 
  dplyr::filter(region == "Rural") %>% 
  ggplot(data=.,aes(x=variable,group=raceeth)) +
  geom_text(aes(y=(value+5),label=round(value,1)),position = position_dodge(width=0.9))+
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
  geom_text(aes(y=(value+5),label=round(value,1)),position = position_dodge(width=0.9))+
  geom_col(aes(fill=raceeth,y=value),position = position_dodge(width=0.9)) +
  theme_bw() +
  xlab("") +
  ylab("Percentage (%)")  +
  theme(axis.text = element_text(size = 14),
        legend.text = element_text(size = 14)) +
  scale_y_continuous(limits=c(0,100)) +
  scale_fill_manual("",values=c("#FF7968",rgb(242/255,173/255,0/255),rgb(90/255,188/255,214/255),rgb(1/255,160/255,138/255),rgb(114/255,148/255,212/255)))

library(ggpubr)

ggarrange(fig_rural,
          fig_urban,
          labels=c("A","B"),
          legend="bottom",
          nrow=2,
          ncol=1,
          common.legend = TRUE) %>% 
  ggsave(.,filename=paste0(path_retinopathy_fragmentation_folder,"/figures/receiving standards of care.jpg"),width=10,height=8)
fig_rural  
