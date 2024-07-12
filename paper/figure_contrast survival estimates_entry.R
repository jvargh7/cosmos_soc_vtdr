
fig_contrast = readxl::read_excel("paper/figure_contrast survival estimates_entry.xlsx") %>% 
  mutate(hba1c = factor(hba1c,levels = c("<7%","7-9%",">=9%","Unavailable")),
         raceeth = factor(raceeth,levels=c("Overall [Ref: <7%]","NH White","NH Black","Hispanic","NH Other"))) %>% 
  ggplot(data=.,aes(x=coef,xmin=lci,xmax=uci,y=hba1c,col=raceeth)) +
  geom_point(position = position_dodge(width = 0.9)) +
  geom_errorbarh(height=0.1,position = position_dodge(width=0.9)) +
  scale_y_discrete(limits=rev) +
  geom_vline(xintercept =1.0,col="grey60",linetype =2) +
  scale_color_manual("",breaks=c("Overall [Ref: <7%]","NH White","NH Black","Hispanic","NH Other"),
                     values=c("#FF7968",
                              rgb(242/255,173/255,0/255),
                              rgb(90/255,188/255,214/255),
                              rgb(1/255,160/255,138/255),
                              rgb(114/255,148/255,212/255))) +
  xlab("Hazard Ratio (95% Confidence Interval)") +
  ylab("") +
  theme_bw() +
  theme(axis.text = element_text(size = 14),
        legend.text = element_text(size = 14))

fig_contrast

fig_contrast %>% 
  ggsave(.,filename=paste0(path_retinopathy_fragmentation_folder,"/figures/contrast survival estimates_entry.tif"),width = 8,height =6)

fig_contrast %>% 
  ggsave(.,filename=paste0(path_retinopathy_fragmentation_folder,"/writing/Diabetes Care R1/Figure 2 updated_manual entry.tif"),width = 8,height =6)
