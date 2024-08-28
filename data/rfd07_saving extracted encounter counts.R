rm(list=ls());gc();source(".Rprofile")

source("H:/code/functions/cosmos/encounter_distinct_Range_index.R")


t = Sys.time()
for(year in c(2013:2023)){
  print(year)
  encounter_distinct_Range_index(connection_Cosmos = con_Cosmos,filter_year = year,IndexDateKey_Var="StartDateKey",
              project_string = "PROJECTS.ProjectD0C076.dbo.DR_PATIENTS",LowerInterval = -2,UpperInterval = -1) %>% 
    write_dataset(.,path=paste0(path_retinopathy_fragmentation_folder,"/working/rfd07a"),partitioning = c("Year"))
  
  encounter_distinct_Range_index(connection_Cosmos = con_Cosmos,filter_year = year,IndexDateKey_Var="StartDateKey",
              project_string = "PROJECTS.ProjectD0C076.dbo.DR_PATIENTS",LowerInterval = -1,UpperInterval = 0) %>% 
    write_dataset(.,path=paste0(path_retinopathy_fragmentation_folder,"/working/rfd07b"),partitioning = c("Year"))
  
  
}
t - Sys.time()


open_dataset(paste0(path_retinopathy_fragmentation_folder,"/working/rfd07a"),format = "parquet",partitioning = "Year") %>% 
  head() %>% 
  collect()

open_dataset(paste0(path_retinopathy_fragmentation_folder,"/working/rfd07a"),format = "parquet",partitioning = "Year") %>% 
  tally() %>% 
  collect()
