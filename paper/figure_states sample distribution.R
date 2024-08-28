
rm(list=ls());gc();source(".Rprofile")

# From rfa_analytic sample preprocessing.R
source("analysis/rfa_analytic sample preprocessing.R")

library(tigris)


fips = fips_codes %>% 
  as.data.frame() %>% 
  distinct(state,state_code,state_name)

state_counts <- analytic %>% 
  group_by(ValidatedStateOrProvince_X) %>% 
  tally() %>% 
  left_join(fips,
            by=c("ValidatedStateOrProvince_X" = "state_name")) %>% 
  mutate(n_category = case_when(n < 100 ~ 1,
                                n < 1000 ~ 2,
                                n < 5000 ~ 3,
                                TRUE ~ 4 )) %>% 
  mutate(n_category = factor(n_category,levels=c(1:4),labels=c("<100","100-999","1000-4999",">=5000")))



write_csv(state_counts,"paper/table_state sample distribution.csv")

# state_boundaries <- st_read(dsn = paste0(path_cms_mdpp_folder,"/working/tl_2022_us_state")) 
state_boundaries <- tigris::states(class = "sf", cb = TRUE) %>% 
  tigris::shift_geometry() %>% 
  dplyr::filter(GEOID < 60) %>% 
  left_join(state_counts,
            by=c("GEOID"="state_code"))

figA <- ggplot() +
  geom_sf(data=state_boundaries,aes(fill = n_category),col="black")  +
  # https://stackoverflow.com/questions/66031935/ggplot2-and-sf-geom-sf-text-within-limits-set-by-coord-sf
  # coord_sf(xlim = c(-140,-60), ylim = c(22,50)) +
  coord_sf(crs = 5070, datum = NA) +
  theme_bw() +
  xlab("") +
  ylab("") +
  scale_fill_manual(name="",values=c("<100" = "#C1DDF3","100-999" = "#AAD8EB","1000-4999" = "#A3BDED",">=5000" = "#8792AE"),na.value="grey90") +
  theme(legend.position = "bottom")

figA

figA %>% 
  ggsave(.,filename=paste0(path_retinopathy_fragmentation_folder,"/figures/state sample distribution.jpg"),width=5*1.685,height=5)
