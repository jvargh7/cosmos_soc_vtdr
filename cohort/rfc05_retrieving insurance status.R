rm(list=ls());gc();source(".Rprofile")

source("H:/code/functions/cosmos/insurance_distinct_Range_index.R")


t = Sys.time()
for(year in c(2013:2023)){
  print(year)
  print("Lookback 1 year")
  insurance_distinct_Range_index(con_Cosmos,project_string = "PROJECTS.ProjectD0C076.[ET4003\\shdw_1208_jvargh1].rfd08",
                                  filter_year = year,IndexDateKey_Var="StartDateKey",
                                 LowerInterval = -1,UpperInterval = 0,lower_geq = FALSE,upper_leq = TRUE) %>% 
    write_dataset(.,path=paste0(path_retinopathy_fragmentation_folder,"/working/rfc05"),partitioning = c("Year"))
  
  
}
t - Sys.time()

open_dataset(paste0(path_retinopathy_fragmentation_folder,"/working/rfc05"),partitioning = c("Year")) %>%
  arrange(PatientDurableKey,Year) %>%
  head(n= 1000) %>%
  collect() %>% View()
