rm(list=ls());gc();source(".Rprofile")



fig_df <- bind_rows(
  read_csv("analysis/rfa005_survival estimates.csv") %>% 
    mutate(coef = exp(estimate),
           lci = exp(estimate - 1.96*std.error),
           uci = exp(estimate + 1.96*std.error)) %>% 
    dplyr::filter(type %in% c("adjusted"),
                  str_detect(term,"(hba1c)")) %>% 
    mutate(raceeth = "Overall",
           hba1c = str_replace(term,"historical_hba1c_group","")),
  
  read_csv("analysis/rfa005_contrast of survival estimates.csv") %>% 
  rename(coef_ci = HR) %>% 
  mutate(hba1c = str_replace(exposure,"historical_hba1c_group",""),
         raceeth = str_replace(modifier,"raceeth",""),
         coef = exp(theta_D))
  ) %>% 
  bind_rows(.,
            data.frame(coef = 1.00,
                       lci = 1.00,
                       uci = 1.00,
                       hba1c = "<7",
                       raceeth = "NHWhite")) %>% 
  mutate(hba1c = factor(hba1c,levels=c("<7","7-9",">=9","Unavailable"),
                        labels=c("<7%","7-9%",">=9%","Unavailable")),
         raceeth = factor(raceeth,levels=c("Overall","NHWhite","NHBlack","Hispanic","NHOther"),
                          labels=c("Overall [Ref: <7%]","NH White","NH Black","Hispanic","NH Other")))


write_csv(fig_df,"paper/table_contrast survival estimates.csv")


fig_contrast = fig_df %>% 
  ggplot(data=.,aes(x=coef,xmin=lci,xmax=uci,y=hba1c,col=raceeth)) +
  geom_point(position = position_dodge(width = 0.9)) +
  geom_errorbarh(height = 0.1,position = position_dodge(width = 0.9)) +
  scale_y_discrete(limits=rev) +
  geom_vline(xintercept = 1.0,col="grey60",linetype = 2) +
  scale_color_manual("",breaks = c("Overall [Ref: <7%]","NH White","NH Black","Hispanic","NH Other"),
                     values=c("#FF7968",rgb(242/255,173/255,0/255),rgb(90/255,188/255,214/255),rgb(1/255,160/255,138/255),rgb(114/255,148/255,212/255))) +
  xlab("Hazard Ratio (95% Confidence Interval)") +
  ylab("") +
  theme_bw() + 
  theme(axis.text = element_text(size = 14),
        legend.text = element_text(size = 14)) 

fig_contrast

fig_contrast %>% 
  ggsave(.,filename=paste0(path_retinopathy_fragmentation_folder,"/figures/contrast survival estimates.jpg"),width=8,height = 6)
