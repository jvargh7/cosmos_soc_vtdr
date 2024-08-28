

rm(list=ls());gc();source(".Rprofile")

source("H:/code/functions/cosmos/demographics.R")


demographics(con_Cosmos, 
             project_string = "PROJECTS.ProjectD0C076.dbo.DR_PATIENTS") %>% 
  write_dataset(.,path=paste0(path_retinopathy_fragmentation_folder,"/working/rfd06"),partitioning = "ValidatedStateOrProvince_X")

open_dataset(paste0(path_retinopathy_fragmentation_folder,"/working/rfd06"),format="parquet",partitioning = "ValidatedStateOrProvince_X") %>% 
  dim()

open_dataset(paste0(path_retinopathy_fragmentation_folder,"/working/rfd06"),format="parquet",partitioning = "ValidatedStateOrProvince_X") %>% 
  distinct(PatientDurableKey) %>%
  collect() %>% 
  dim()

open_dataset(paste0(path_retinopathy_fragmentation_folder,"/working/rfd06"),format="parquet",partitioning = "ValidatedStateOrProvince_X") %>% 
  dplyr::filter(PrimaryRUCA_X != "*Unspecified") %>% 
  head() %>%
  collect()
