rm(list=ls());gc();source(".Rprofile")

outcome_vars = c("Ophthalmology_both","PrimaryCare_both",
                 "hba1c_both","bp_both","ldl_both")

hb_group = c("<7","7-9",">=9","Unavailable")

fig_df_soc <- read_csv("paper/table_age adjusted receiving standards of care.csv") %>% 
  mutate(label_pos = value*0.8)
fig_df_vtdr <- read_csv("paper/table_age adjusted proportion of vision threatening retinopathy.csv") %>% 
  mutate(label_pos = value*0.8)


fig_rural_soc =  fig_df_soc %>% 
  dplyr::filter(region == "Rural") %>% 
  ggplot(data=.,aes(x=variable,group=raceeth)) +
  geom_col(aes(fill=raceeth,y=value),position = position_dodge(width=0.9)) +
  geom_text(aes(y=label_pos,label=round(value,1)),position = position_dodge(width=0.9),size = 2)+
  theme_bw() +
  xlab("") +
  ylab("Percentage (%)") +
  scale_y_continuous(limits=c(0,100))   +
  theme(axis.text = element_text(size = 8.5),
        legend.text = element_text(size = 8.5)) +
  scale_fill_manual("",values=c("#FF7968",rgb(242/255,173/255,0/255),rgb(90/255,188/255,214/255),rgb(1/255,160/255,138/255),rgb(114/255,148/255,212/255)))

fig_urban_soc = fig_df_soc %>% 
  dplyr::filter(region == "Urban") %>% 
  ggplot(data=.,aes(x=variable,group=raceeth)) +
  geom_col(aes(fill=raceeth,y=value),position = position_dodge(width=0.9)) +
  geom_text(aes(y=label_pos,label=round(value,1)),position = position_dodge(width=0.9),size = 2)+
  theme_bw() +
  xlab("") +
  ylab("Percentage (%)")  +
  theme(axis.text = element_text(size = 8.5),
        legend.text = element_text(size = 8.5)) +
  scale_y_continuous(limits=c(0,100)) +
  scale_fill_manual("",values=c("#FF7968",rgb(242/255,173/255,0/255),rgb(90/255,188/255,214/255),rgb(1/255,160/255,138/255),rgb(114/255,148/255,212/255)))



fig_rural_vtdr = fig_df_vtdr %>%  
  dplyr::filter(region == "Rural") %>% 
  ggplot(data=.,aes(x=historical_hba1c_group,group=raceeth)) +
  geom_col(aes(fill=raceeth,y=value),position = position_dodge(width=0.9)) +
  geom_text(aes(y=label_pos,label=round(value,1)),position = position_dodge(width=0.9),size = 2)+
  theme_bw() +
  xlab("") +
  ylab("Percentage (%)") +
  scale_y_continuous(limits=c(0,30)) +
  theme(axis.text = element_text(size = 8.5),
        legend.text = element_text(size = 8.5)) +
  scale_fill_manual("",values=c("#FF7968",rgb(242/255,173/255,0/255),rgb(90/255,188/255,214/255),rgb(1/255,160/255,138/255),rgb(114/255,148/255,212/255)))


fig_urban_vtdr = fig_df_vtdr %>% 
  dplyr::filter(region == "Urban") %>% 
  ggplot(data=.,aes(x=historical_hba1c_group,group=raceeth)) +
  geom_col(aes(fill=raceeth,y=value),position = position_dodge(width=0.9)) +
  geom_text(aes(y=label_pos,label=round(value,1)),position = position_dodge(width=0.9),size = 2) +
  theme_bw() +
  xlab("") +
  ylab("Percentage (%)") +
  scale_y_continuous(limits=c(0,30)) +
  theme(axis.text = element_text(size = 8.5),
        legend.text = element_text(size = 8.5)) +
  scale_fill_manual("",values=c("#FF7968",rgb(242/255,173/255,0/255),rgb(90/255,188/255,214/255),rgb(1/255,160/255,138/255),rgb(114/255,148/255,212/255)))

library(ggpubr)

ggarrange(fig_rural_soc,
          fig_rural_vtdr,
          fig_urban_soc,
          fig_urban_vtdr,
          labels=c("A","B","C","D"),
          legend="bottom",
          nrow=2,
          ncol=2,
          common.legend = TRUE) %>% 
  ggsave(.,filename=paste0(path_retinopathy_fragmentation_folder,"/figures/age adjusted combined soc vtdr.jpg"),width=12,height=8)

