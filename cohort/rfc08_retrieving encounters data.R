rm(list=ls());gc();source(".Rprofile")

source("H:/code/functions/cosmos/encounter_count_Range_index.R")


t = Sys.time()
for(year in c(2013:2023)){
  print(year)
  print("Lookback 2 year")
  encounter_count_Range_index(connection_Cosmos = con_Cosmos,filter_year = year,IndexDateKey_Var="StartDateKey",
                                 project_string = "PROJECTS.ProjectD0C076.[ET4003\\shdw_1208_jvargh1].rfd08",LowerInterval = -2,UpperInterval = -1) %>% 
    write_dataset(.,path=paste0(path_retinopathy_fragmentation_folder,"/working/rfc08a"),partitioning = c("Year"))
  
  print("Lookback 1 year")
  
  encounter_count_Range_index(connection_Cosmos = con_Cosmos,filter_year = year,IndexDateKey_Var="StartDateKey",
                                 project_string = "PROJECTS.ProjectD0C076.[ET4003\\shdw_1208_jvargh1].rfd08",LowerInterval = -1,UpperInterval = 0) %>% 
    write_dataset(.,path=paste0(path_retinopathy_fragmentation_folder,"/working/rfc08b"),partitioning = c("Year"))
  
  print("Followup 1 year")
  
  encounter_count_Range_index(connection_Cosmos = con_Cosmos,filter_year = year,IndexDateKey_Var="StartDateKey",
                              project_string = "PROJECTS.ProjectD0C076.[ET4003\\shdw_1208_jvargh1].rfd08",LowerInterval = 0,UpperInterval = 1) %>% 
    write_dataset(.,path=paste0(path_retinopathy_fragmentation_folder,"/working/rfc08c"),partitioning = c("Year"))
  
  print("Followup 2 year")
  
  encounter_count_Range_index(connection_Cosmos = con_Cosmos,filter_year = year,IndexDateKey_Var="StartDateKey",
                              project_string = "PROJECTS.ProjectD0C076.[ET4003\\shdw_1208_jvargh1].rfd08",LowerInterval = 1,UpperInterval = 2) %>% 
    write_dataset(.,path=paste0(path_retinopathy_fragmentation_folder,"/working/rfc08d"),partitioning = c("Year"))
  
  
}

open_dataset(paste0(path_retinopathy_fragmentation_folder,"/working/rfc08b"),partitioning = c("Year")) %>% 
  arrange(PatientDurableKey,Year) %>% 
  head(n = 1000) %>% 
  collect() %>% 
  View()
