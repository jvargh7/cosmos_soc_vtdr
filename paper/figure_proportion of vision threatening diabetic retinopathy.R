rm(list=ls());gc();source(".Rprofile")

# From rfa_analytic sample preprocessing.R
source("analysis/rfa_analytic sample preprocessing.R")

fig_df_overall = analytic %>% 
  group_by(region,historical_hba1c_group) %>% 
  summarize(value = 100*mean(outcome)) %>% 
  mutate(raceeth = "Overall")

fig_df_raceeth = analytic %>% 
  group_by(region,raceeth,historical_hba1c_group) %>% 
  summarize(value = 100*mean(outcome))



fig_df_overall = bind_rows(
  fig_df_overall,
  fig_df_raceeth
) %>% 
  mutate(raceeth = factor(raceeth,levels=c("Overall","NHWhite","NHBlack","Hispanic","NHOther"),
                          labels = c("Overall","NH White","NH Black","Hispanic","NH Other")))

write_csv(fig_df_overall,"paper/table_proportion of vision threatening retinopathy.csv")


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
  ggsave(.,filename=paste0(path_retinopathy_fragmentation_folder,"/figures/proportion of vision threatening diabetic retinopathy.jpg"),width=10,height=8)

