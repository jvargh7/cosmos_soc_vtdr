rm(list=ls());gc();source(".Rprofile")

source("H:/code/functions/cosmos/labs_index.R")

t = Sys.time()
for(year in c(2013:2024)){
  print(year)
  print("Lookback hba1c")
  labs_YearMonth_index(con_Cosmos,project_string = "PROJECTS.ProjectD0C076.[ET4003\\shdw_1208_jvargh1].rfd08",type = "hba1c",
                       IndexDateKey_Var = "StartDateKey",
                       LookBackInterval = 1,FollowUpInterval = 0,filter_year = year) %>% 
    write_dataset(.,path=paste0(path_retinopathy_fragmentation_folder,"/working/rfc02aa"),partitioning = c("Year"))
  print("Followup hba1c")
  labs_YearMonth_index(con_Cosmos,project_string = "PROJECTS.ProjectD0C076.[ET4003\\shdw_1208_jvargh1].rfd08",type = "hba1c",
                       IndexDateKey_Var = "StartDateKey",
                       LookBackInterval = 0,FollowUpInterval = 2,filter_year = year) %>% 
    write_dataset(.,path=paste0(path_retinopathy_fragmentation_folder,"/working/rfc02ab"),partitioning = c("Year"))
  
  print("Lookback fpg")
  labs_YearMonth_index(con_Cosmos,project_string = "PROJECTS.ProjectD0C076.[ET4003\\shdw_1208_jvargh1].rfd08",type = "fpg",
                       IndexDateKey_Var = "StartDateKey",
                       LookBackInterval = 1,FollowUpInterval = 0,filter_year = year) %>% 
    write_dataset(.,path=paste0(path_retinopathy_fragmentation_folder,"/working/rfc02ba"),partitioning = c("Year"))
  print("Followup fpg")
  labs_YearMonth_index(con_Cosmos,project_string = "PROJECTS.ProjectD0C076.[ET4003\\shdw_1208_jvargh1].rfd08",type = "fpg",
                       IndexDateKey_Var = "StartDateKey",
                       LookBackInterval = 0,FollowUpInterval = 2,filter_year = year) %>% 
    write_dataset(.,path=paste0(path_retinopathy_fragmentation_folder,"/working/rfc02bb"),partitioning = c("Year"))
  
  
  print("Lookback ldl")
  labs_YearMonth_index(con_Cosmos,project_string = "PROJECTS.ProjectD0C076.[ET4003\\shdw_1208_jvargh1].rfd08",type = "ldl",
                       IndexDateKey_Var = "StartDateKey",
                       LookBackInterval = 1,FollowUpInterval = 0,filter_year = year) %>% 
    write_dataset(.,path=paste0(path_retinopathy_fragmentation_folder,"/working/rfc02da"),partitioning = c("Year"))
  print("Followup ldl")
  labs_YearMonth_index(con_Cosmos,project_string = "PROJECTS.ProjectD0C076.[ET4003\\shdw_1208_jvargh1].rfd08",type = "ldl",
                       IndexDateKey_Var = "StartDateKey",
                       LookBackInterval = 0,FollowUpInterval = 2,filter_year = year) %>% 
    write_dataset(.,path=paste0(path_retinopathy_fragmentation_folder,"/working/rfc02db"),partitioning = c("Year"))
  
  
  print("Lookback hdl")
  labs_YearMonth_index(con_Cosmos,project_string = "PROJECTS.ProjectD0C076.[ET4003\\shdw_1208_jvargh1].rfd08",type = "hdl",
                       IndexDateKey_Var = "StartDateKey",
                       LookBackInterval = 1,FollowUpInterval = 0,filter_year = year) %>% 
    write_dataset(.,path=paste0(path_retinopathy_fragmentation_folder,"/working/rfc02ea"),partitioning = c("Year"))
  print("Followup hdl")
  labs_YearMonth_index(con_Cosmos,project_string = "PROJECTS.ProjectD0C076.[ET4003\\shdw_1208_jvargh1].rfd08",type = "hdl",
                       IndexDateKey_Var = "StartDateKey",
                       LookBackInterval = 0,FollowUpInterval = 2,filter_year = year) %>% 
    write_dataset(.,path=paste0(path_retinopathy_fragmentation_folder,"/working/rfc02eb"),partitioning = c("Year"))
  
  
  print("Lookback tgl")
  labs_YearMonth_index(con_Cosmos,project_string = "PROJECTS.ProjectD0C076.[ET4003\\shdw_1208_jvargh1].rfd08",type = "tgl",
                       IndexDateKey_Var = "StartDateKey",
                       LookBackInterval = 1,FollowUpInterval = 0,filter_year = year) %>% 
    write_dataset(.,path=paste0(path_retinopathy_fragmentation_folder,"/working/rfc02fa"),partitioning = c("Year"))
  print("Followup tgl")
  labs_YearMonth_index(con_Cosmos,project_string = "PROJECTS.ProjectD0C076.[ET4003\\shdw_1208_jvargh1].rfd08",type = "tgl",
                       IndexDateKey_Var = "StartDateKey",
                       LookBackInterval = 0,FollowUpInterval = 2,filter_year = year) %>% 
    write_dataset(.,path=paste0(path_retinopathy_fragmentation_folder,"/working/rfc02fb"),partitioning = c("Year"))
  
  print("Lookback alt")
  labs_YearMonth_index(con_Cosmos,project_string = "PROJECTS.ProjectD0C076.[ET4003\\shdw_1208_jvargh1].rfd08",type = "alt",
                       IndexDateKey_Var = "StartDateKey",
                       LookBackInterval = 1,FollowUpInterval = 0,filter_year = year) %>% 
    write_dataset(.,path=paste0(path_retinopathy_fragmentation_folder,"/working/rfc02ga"),partitioning = c("Year"))
  print("Followup alt")
  labs_YearMonth_index(con_Cosmos,project_string = "PROJECTS.ProjectD0C076.[ET4003\\shdw_1208_jvargh1].rfd08",type = "alt",
                       IndexDateKey_Var = "StartDateKey",
                       LookBackInterval = 0,FollowUpInterval = 2,filter_year = year) %>% 
    write_dataset(.,path=paste0(path_retinopathy_fragmentation_folder,"/working/rfc02gb"),partitioning = c("Year"))
  
  print("Lookback ast")
  labs_YearMonth_index(con_Cosmos,project_string = "PROJECTS.ProjectD0C076.[ET4003\\shdw_1208_jvargh1].rfd08",type = "ast",
                       IndexDateKey_Var = "StartDateKey",
                       LookBackInterval = 1,FollowUpInterval = 0,filter_year = year) %>% 
    write_dataset(.,path=paste0(path_retinopathy_fragmentation_folder,"/working/rfc02ha"),partitioning = c("Year"))
  print("Followup ast")
  labs_YearMonth_index(con_Cosmos,project_string = "PROJECTS.ProjectD0C076.[ET4003\\shdw_1208_jvargh1].rfd08",type = "ast",
                       IndexDateKey_Var = "StartDateKey",
                       LookBackInterval = 0,FollowUpInterval = 2,filter_year = year) %>% 
    write_dataset(.,path=paste0(path_retinopathy_fragmentation_folder,"/working/rfc02hb"),partitioning = c("Year"))
  
  print("Lookback creatinine")
  labs_YearMonth_index(con_Cosmos,project_string = "PROJECTS.ProjectD0C076.[ET4003\\shdw_1208_jvargh1].rfd08",type = "creatinine",
                       IndexDateKey_Var = "StartDateKey",
                       LookBackInterval = 1,FollowUpInterval = 0,filter_year = year) %>% 
    write_dataset(.,path=paste0(path_retinopathy_fragmentation_folder,"/working/rfc02ia"),partitioning = c("Year"))
  print("Followup creatinine")
  labs_YearMonth_index(con_Cosmos,project_string = "PROJECTS.ProjectD0C076.[ET4003\\shdw_1208_jvargh1].rfd08",type = "creatinine",
                       IndexDateKey_Var = "StartDateKey",
                       LookBackInterval = 0,FollowUpInterval = 2,filter_year = year) %>% 
    write_dataset(.,path=paste0(path_retinopathy_fragmentation_folder,"/working/rfc02ib"),partitioning = c("Year"))
  
}
Sys.time() - t


# open_dataset(paste0(path_retinopathy_fragmentation_folder,"/working/rfc02aa"),partitioning = c("Year")) %>%
#   arrange(PatientDurableKey,YearMonth) %>%
#   head(n= 1000) %>%
#   collect() %>% View()
