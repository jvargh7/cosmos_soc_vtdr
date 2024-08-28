rm(list = ls()); gc(); source(".Rprofile")
library(arrow)
con <- dbConnect(odbc(), .connection_string = 
                   "Driver={ODBC Driver 17 for SQL Server};
                 Server=tcp:PROJECTS;
                 Database=ProjectD0C076; 
                 Trusted_Connection=yes;",
                 timeout = 10)

if(Sys.info()["user"]=="shdw_1208_rvishn1"){
  con2 <- dbConnect(odbc(), .connection_string = 
                      "Driver={ODBC Driver 17 for SQL Server};
                 Server=tcp:PROJECTS;
                 Database=ProjectD3A05D; 
                 Trusted_Connection=yes;",
                    timeout = 10)
}


# filterCat1 -------
tbl(con,"filterCat1") %>% 
  dplyr::select(patientdurablekey,monthyear) %>% 
  collect() %>% 
  write_parquet(.,paste0(path_retinopathy_fragmentation_folder,"/working/filterCat1.parquet"))


read_parquet(paste0(path_retinopathy_fragmentation_folder,"/working/filterCat1.parquet")) %>% 
  collect() %>% 
  saveRDS(.,paste0(path_retinopathy_fragmentation_folder,"/working/filterCat1.RDS"))

filterCat1 <- readRDS(paste0(path_retinopathy_fragmentation_folder,"/working/filterCat1.RDS"))

# filterCat2 -------
tbl(con,"filterCat2") %>% 
  dplyr::select(patientdurablekey,monthyear) %>% 
  collect() %>% 
  write_parquet(.,paste0(path_retinopathy_fragmentation_folder,"/working/filterCat2.parquet"))


read_parquet(paste0(path_retinopathy_fragmentation_folder,"/working/filterCat2.parquet")) %>% 
  collect() %>% 
  saveRDS(.,paste0(path_retinopathy_fragmentation_folder,"/working/filterCat2.RDS"))
filterCat2 <- readRDS(paste0(path_retinopathy_fragmentation_folder,"/working/filterCat2.RDS"))


# filterCat3 -------
tbl(con,"filterCat3") %>% 
  dplyr::select(patientdurablekey,monthyear) %>% 
  collect() %>% 
  write_parquet(.,paste0(path_retinopathy_fragmentation_folder,"/working/filterCat3.parquet"))

read_parquet(paste0(path_retinopathy_fragmentation_folder,"/working/filterCat3.parquet")) %>% 
  collect() %>% 
  saveRDS(.,paste0(path_retinopathy_fragmentation_folder,"/working/filterCat3.RDS"))

filterCat3 <- readRDS(paste0(path_retinopathy_fragmentation_folder,"/working/filterCat3.RDS"))

# filterCat4a-c -------
tbl(con,"filterCat4a") %>% 
  dplyr::select(patientdurablekey,monthyear) %>% 
  collect() %>% 
  write_parquet(.,paste0(path_retinopathy_fragmentation_folder,"/working/filterCat4a.parquet"))

read_parquet(paste0(path_retinopathy_fragmentation_folder,"/working/filterCat4a.parquet")) %>% 
  collect() %>% 
  saveRDS(.,paste0(path_retinopathy_fragmentation_folder,"/working/filterCat4a.RDS"))

filterCat4a <- readRDS(paste0(path_retinopathy_fragmentation_folder,"/working/filterCat4a.RDS"))


tbl(con,"filterCat4b") %>% 
  dplyr::select(patientdurablekey,monthyear) %>% 
  collect() %>% 
  write_parquet(.,paste0(path_retinopathy_fragmentation_folder,"/working/filterCat4b.parquet"))

read_parquet(paste0(path_retinopathy_fragmentation_folder,"/working/filterCat4b.parquet")) %>% 
  collect() %>% 
  saveRDS(.,paste0(path_retinopathy_fragmentation_folder,"/working/filterCat4b.RDS"))

filterCat4b <- readRDS(paste0(path_retinopathy_fragmentation_folder,"/working/filterCat4b.RDS"))


tbl(con2,"filterCat4c") %>%
  dplyr::select(patientdurablekey,monthyear) %>%
  collect() %>%
  write_parquet(.,paste0(path_retinopathy_fragmentation_folder,"/working/filterCat4c.parquet"))

read_parquet(paste0(path_retinopathy_fragmentation_folder,"/working/filterCat4c.parquet")) %>% 
  collect() %>% 
  saveRDS(.,paste0(path_retinopathy_fragmentation_folder,"/working/filterCat4c.RDS"))

filterCat4c <- readRDS(paste0(path_retinopathy_fragmentation_folder,"/working/filterCat4c.RDS"))


# filterCat5a-b -------
tbl(con2,"filterCat5a") %>%
  dplyr::select(patientdurablekey,monthyear) %>%
  collect() %>%
  write_parquet(.,paste0(path_retinopathy_fragmentation_folder,"/working/filterCat5a.parquet"))

tbl(con2,"filterCat5b") %>%
  dplyr::select(patientdurablekey,monthyear) %>%
  collect() %>%
  write_parquet(.,paste0(path_retinopathy_fragmentation_folder,"/working/filterCat5b.parquet"))

