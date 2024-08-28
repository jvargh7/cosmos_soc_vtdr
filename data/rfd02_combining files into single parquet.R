# rm(list=ls());gc();source(".Rprofile")
# 
# filterCat1 <- read_parquet(paste0(path_retinopathy_fragmentation_folder,"/working/rfd01/filterCat1.parquet")) %>%
#   mutate(hba1c = 1,
#          my = my(monthyear),
#          type = "hba1c") %>% 
#   collect()
# write_dataset(filterCat1,paste0(path_retinopathy_fragmentation_folder,"/working/rfd02/filterCat1"),partitioning = "monthyear")
# 
# filterCat2 <- read_parquet(paste0(path_retinopathy_fragmentation_folder,"/working/rfd01/filterCat2.parquet")) %>%
#   mutate(fpg = 1,
#          my = my(monthyear),
#          type = "fpg")
# write_dataset(filterCat2,paste0(path_retinopathy_fragmentation_folder,"/working/rfd02/filterCat2"),partitioning = "monthyear")
# 
# filterCat <- read_parquet(paste0(path_retinopathy_fragmentation_folder,"/working/rfd01/filterCat3.parquet")) %>%
#   mutate(rpg = 1,
#          my = my(monthyear),
#          type = "rpg")
# write_dataset(filterCat3,paste0(path_retinopathy_fragmentation_folder,"/working/rfd02/filterCat3"),partitioning = "monthyear")


rm(list=ls());gc();source(".Rprofile")

filterCat4a <- read_parquet(paste0(path_retinopathy_fragmentation_folder,"/working/rfd01/filterCat4a.parquet")) %>%
  mutate(op = 1,
         my = my(monthyear),
         type = "op") %>% 
  collect()
write_dataset(filterCat4a,paste0(path_retinopathy_fragmentation_folder,"/working/rfd02/filterCat4"),partitioning = "monthyear")

filterCat4b <- read_parquet(paste0(path_retinopathy_fragmentation_folder,"/working/rfd01/filterCat4b.parquet")) %>%
  mutate(op = 1,
         my = my(monthyear),
         type = "op")
write_dataset(filterCat4b,paste0(path_retinopathy_fragmentation_folder,"/working/rfd02/filterCat4"),partitioning = "monthyear")

filterCat4c <- read_parquet(paste0(path_retinopathy_fragmentation_folder,"/working/rfd01/filterCat4c.parquet")) %>%
  mutate(op = 1,
         my = my(monthyear),
         type = "op")
write_dataset(filterCat4c,paste0(path_retinopathy_fragmentation_folder,"/working/rfd02/filterCat4"),partitioning = "monthyear")



# filterCat5----------------
rm(list=ls());gc();source(".Rprofile")



filterCat5a <- read_parquet(paste0(path_retinopathy_fragmentation_folder,"/working/rfd01/filterCat5a.parquet")) %>%
  arrange(patientdurablekey,monthyear) %>% 
  dplyr::select(patientdurablekey,monthyear,flagged_PharmaceuticalClass) %>%
  mutate(drug_class = case_when(flagged_PharmaceuticalClass == "CONFOUNDING CLASS"  ~ "confoundingrx",
                                flagged_PharmaceuticalClass %in% confounding_class ~ "confoundingrx",
                                TRUE ~ "dmrx")) %>%
  group_by(patientdurablekey,monthyear,drug_class) %>%
  tally() %>% 
  ungroup() %>% 
  mutate(type = "medication") %>% 
  pivot_wider(names_from=drug_class,values_from=n)
write_dataset(filterCat5a,paste0(path_retinopathy_fragmentation_folder,"/working/rfd02/filterCat5"),partitioning = "monthyear")

rm(list=ls());gc();source(".Rprofile")

filterCat5b_1 <- read_parquet(paste0(path_retinopathy_fragmentation_folder,"/working/rfd01/filterCat5b_1.parquet")) %>%
  arrange(patientdurablekey,monthyear) %>% 
  dplyr::select(patientdurablekey,monthyear,flagged_PharmaceuticalClass) %>%
  mutate(drug_class = case_when(flagged_PharmaceuticalClass == "CONFOUNDING CLASS"  ~ "confoundingrx",
                                flagged_PharmaceuticalClass %in% confounding_class  ~ "confoundingrx",
                                TRUE ~ "dmrx")) %>%
  group_by(patientdurablekey,monthyear,drug_class) %>%
  tally() %>% 
  ungroup() %>% 
  mutate(type = "medication") %>% 
  pivot_wider(names_from=drug_class,values_from=n)
write_dataset(filterCat5b_1,paste0(path_retinopathy_fragmentation_folder,"/working/rfd02/filterCat5"),partitioning = "monthyear")

rm(list=ls());gc();source(".Rprofile")

filterCat5b_2 <- read_parquet(paste0(path_retinopathy_fragmentation_folder,"/working/rfd01/filterCat5b_2.parquet")) %>%
  arrange(patientdurablekey,monthyear) %>% 
  dplyr::select(patientdurablekey,monthyear,flagged_PharmaceuticalClass) %>%
  mutate(drug_class = case_when(flagged_PharmaceuticalClass == "CONFOUNDING CLASS"  ~ "confoundingrx",
                                flagged_PharmaceuticalClass %in% confounding_class ~ "confoundingrx",
                                TRUE ~ "dmrx")) %>%
  group_by(patientdurablekey,monthyear,drug_class) %>%
  tally() %>% 
  ungroup() %>% 
  mutate(type = "medication") %>% 
  pivot_wider(names_from=drug_class,values_from=n)
write_dataset(filterCat5b_2,paste0(path_retinopathy_fragmentation_folder,"/working/rfd02/filterCat5"),partitioning = "monthyear")

rm(list=ls());gc();source(".Rprofile")

filterCat5c <- read_parquet(paste0(path_retinopathy_fragmentation_folder,"/working/rfd01/filterCat5c.parquet")) %>%
  arrange(patientdurablekey,monthyear) %>% 
  dplyr::select(patientdurablekey,monthyear,flagged_PharmaceuticalClass) %>%
  mutate(drug_class = case_when(flagged_PharmaceuticalClass == "CONFOUNDING CLASS"  ~ "confoundingrx",
                                flagged_PharmaceuticalClass %in% confounding_class ~ "confoundingrx",
                                TRUE ~ "dmrx")) %>%
  group_by(patientdurablekey,monthyear,drug_class) %>%
  tally() %>% 
  ungroup() %>% 
  mutate(type = "medication") %>% 
  pivot_wider(names_from=drug_class,values_from=n)
write_dataset(filterCat5c,paste0(path_retinopathy_fragmentation_folder,"/working/rfd02/filterCat5"),partitioning = "monthyear")

