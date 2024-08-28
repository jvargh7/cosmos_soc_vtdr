rm(list=ls());gc();source(".Rprofile")

source("H:/code/functions/cosmos/diagnosis_distinct_Year_index.R")


t = Sys.time()
for(year in c(2013:2023)){
  print(year)
  print("Lookback")
  diagnosis_distinct_Year_index(con_Cosmos,project_string = "PROJECTS.ProjectD0C076.[ET4003\\shdw_1208_jvargh1].rfd08",IndexDateKey_Var = "StartDateKey",
                                LookBackInterval = 2,FollowUpInterval = 0,filter_year = year) %>% 
    write_dataset(.,path=paste0(path_retinopathy_fragmentation_folder,"/working/rfc04a"),partitioning = c("Year","Value_Grouper2"))
  
  print("Followup")
  diagnosis_distinct_YearMonth_index(con_Cosmos,project_string = "PROJECTS.ProjectD0C076.[ET4003\\shdw_1208_jvargh1].rfd08",IndexDateKey_Var = "StartDateKey",
                                LookBackInterval = 0,FollowUpInterval = 10,filter_year = year,
                                by_letters = TRUE,alphabets=c("H","E"),
                                detection_string = "SUBSTRING(dtd.Value,1,1)") %>% 
    write_dataset(.,path=paste0(path_retinopathy_fragmentation_folder,"/working/rfc04b"),partitioning = c("Year","Value_Grouper2"))
}
t - Sys.time()

open_dataset(paste0(path_retinopathy_fragmentation_folder,"/working/rfc04b"),partitioning = c("Year","Value_Grouper2")) %>%
  arrange(PatientDurableKey,Year) %>%
  head(n= 1000) %>%
  collect() %>% View()
