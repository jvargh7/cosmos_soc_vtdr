rm(list=ls());gc();source(".Rprofile")

source("H:/code/functions/cosmos/medications_distinct_Year_index.R")


t = Sys.time()
for(year in c(2013:2023)){
  print(year)
  print("Lookback")
  medications_distinct_Year_index(con_Cosmos,project_string = "PROJECTS.ProjectD0C076.[ET4003\\shdw_1208_jvargh1].rfd08",IndexDateKey_Var = "StartDateKey",
                                  LookBackInterval = 1,FollowUpInterval = 0,filter_year = year) %>% 
    write_dataset(.,path=paste0(path_retinopathy_fragmentation_folder,"/working/rfc03a"),partitioning = c("Year"))
  
  print("Follow-up")
  medications_distinct_Year_index(con_Cosmos,project_string = "PROJECTS.ProjectD0C076.[ET4003\\shdw_1208_jvargh1].rfd08",IndexDateKey_Var = "StartDateKey",
                                  LookBackInterval = 0,FollowUpInterval = 2,filter_year = year) %>% 
    write_dataset(.,path=paste0(path_retinopathy_fragmentation_folder,"/working/rfc03b"),partitioning = c("Year"))
  
}
t - Sys.time()

open_dataset(paste0(path_retinopathy_fragmentation_folder,"/working/rfc03a"),partitioning = c("Year")) %>%
  arrange(PatientDurableKey,Year) %>%
  head(n= 1000) %>%
  collect() %>% View()
