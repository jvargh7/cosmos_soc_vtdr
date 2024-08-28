rm(list=ls());gc();source(".Rprofile")

source("H:/code/functions/cosmos/procedures_distinct_Year_index.R")

selected_codes <- c(67028, 67030, 67031, 67036,
                    c(67039:67043), 67101, 67105, 67107, 67108, 67110,
                    67113, 67121, 67141, 67145, 67208, 67210, 67218,
                    67220, 67221, 67227, 67228, 92002, 92004, 92012,
                    92014, 92018, 92019, 92134, 92225:92228, 92230,
                    92235, 92240, 92250, 92260, 99203:99205, c(99213:99215),c(99242:99245),
                    paste0(c(2022:2026,2033,3072),"F"))

t = Sys.time()
for(year in c(2013:2023)){
  print(year)
  print("Lookback")
  procedures_distinct_Year_index(con_Cosmos,project_string = "PROJECTS.ProjectD0C076.[ET4003\\shdw_1208_jvargh1].rfd08",IndexDateKey_Var = "StartDateKey",
                                LookBackInterval = 2,FollowUpInterval = 0,filter_year = year,
                                by_codes = FALSE,cpt_codes=NULL,
                                detection_string = "procd.CptCode") %>% 
    write_dataset(.,path=paste0(path_retinopathy_fragmentation_folder,"/working/rfc07a"),partitioning = c("Year"))
  
  print("Followup")
  procedures_distinct_YearMonth_index(con_Cosmos,project_string = "PROJECTS.ProjectD0C076.[ET4003\\shdw_1208_jvargh1].rfd08",IndexDateKey_Var = "StartDateKey",
                                     LookBackInterval = 0,FollowUpInterval = 3,filter_year = year,
                                     by_codes = TRUE,cpt_codes=selected_codes,
                                     detection_string = "procd.CptCode") %>% 
    write_dataset(.,path=paste0(path_retinopathy_fragmentation_folder,"/working/rfc07b"),partitioning = c("Year"))
}
t - Sys.time()

open_dataset(paste0(path_retinopathy_fragmentation_folder,"/working/rfc07b"),partitioning = c("Year")) %>%
  arrange(PatientDurableKey,Year) %>%
  head(n= 1000) %>%
  collect() %>% View()
