
library(odbc)
library(DBI)
library(tidyverse)
library(dbplyr)
library(lubridate)
library(arrow)
if(Sys.info()["user"]=="shdw_1208_jvargh1"){
  path_retinopathy_fragmentation_folder <- "Z:/Project D0C076/Retinopathy and Fragmentation"
  path_retinopathy_fragmentation_repo <- "H:/code/retinopathy_fragmentation"
}

if(Sys.info()["user"]=="shdw_1208_rvishn1"){
  path_retinopathy_fragmentation_folder <- "Z:/Project D0C076/Retinopathy and Fragmentation"
  path_retinopathy_fragmentation_repo <- "H:/Code/retinopathy_fragmentation"
}

# LOCAL -------
if(Sys.info()["user"]=="JVARGH7){

path_retinopathy_fragmentation_folder = "C:/Cloud/OneDrive - Emory University/Papers/COSMOS Retinopathy Fragmentation"
path_retinopathy_fragmentation_box = "C:/Users/jvargh7/Box/Papers/COSMOS Retinopathy Fragmentation"

}

con_Cosmos <- dbConnect(odbc(), .connection_string = 
                          "Driver={ODBC Driver 17 for SQL Server};
   Server=tcp:COSMOS;
   Database=Cosmos;
   Trusted_Connection=yes;",
                        timeout = 1000)

con_ProjectD0C076 <- dbConnect(odbc(), .connection_string = 
                                 "Driver={ODBC Driver 17 for SQL Server};
                 Server=tcp:PROJECTS;
                 Database=ProjectD0C076; 
                 Trusted_Connection=yes;",
                               timeout = 10)

sbp_valid = c(50,400)
dbp_valid = c(30,400)

# Useful LOINCs ----
glucose_loinc <- c("2345-7", # Glucose [Mass/volume] in Serum or Plasma
                   "2339-0", # Glucose [Mass/volume] in Blood
                   "41653-7", # Glucose [Mass/volume] in Capillary blood by Glucometer
                   "2340-8", # Glucose [Mass/volume] in Blood by Automated test strip
                   "27353-2", # Glucose mean value [Mass/volume] in Blood Estimated
                   "1547-9") # Glucose [Mass/volume] in Serum or Plasma

fastingglucose_loinc <- c("1558-6", # Fasting glucose [Mass/volume] in Serum or Plasma
                          "76629-5", # Fasting glucose [Moles/volume] in Blood
                          "77145-1", # Fasting glucose [Moles/volume] in serum, plasma or blood
                          "1556-0", # Fasting glucose [Mass/volume] in Capillary blood
                          "35184-1", #Fasting glucose [Mass or Moles/volume] in Serum or Plasma -- Discouraged
                          "14771-0" # Fasting glucose [Moles/volume] in serum or plasma
)

hba1c_loinc <- c("4548-4","41995-2","55454-3",
                 "71875-9","549-2","17856-6",
                 "59261-6","62388-4","17855-8",
                 #10839-9 was not included in Weise 2018
                 "10839-9")

ldl_loinc <- c("13457-7","18262-6","2089-1","11054-4")
hdl_loinc <- c("18263-4","2085-9")
tgl_loinc <- c("12951-0","2571-8")
alt_loinc <- c("1742-6","1744-2")
ast_loinc <- c("1920-8")
creatinine_loinc <- c("2160-0")


icd10_dm_qualifying <- c("E11\\.")

# Used for paste0() --> str_detect()
# Any code ending in \\. has a wildcard '*'
icd10_otherdm_excluding <- c("R73\\.01", "R73.02", "R73\\.0", "R81\\.", "E88\\.81", "Z13\\.1", "E13\\.", "E08\\.", "E09\\.")
icd10_t1dm <- c("E10\\.")
icd10_gdm <- c("O24\\.")

confounding_class = c('ANTIHYPERGLYCEMIC, BIGUANIDE TYPE',
                      'ANTIHYPERGLYCEMIC,THIAZOLIDINEDIONE(PPARG AGONIST)',
                      'ANTIHYPERGLY,INCRETIN MIMETIC(GLP-1 RECEP.AGONIST)',
                      'ANTIHYPERGLYCEMIC - INCRETIN MIMETICS COMBINATION')

monthyear_unique = paste0(rep(sprintf("%02d",c(1:12)),times=(2023-2012+1))," ",rep(2012:2023,each=12))


# Get diagnosis codes
htn_dx_codes <- c("E78")
hld_dx_codes <- c("I10","I11","I12","I13","I15","I16","I1A")
cerebro_dx_codes <- c("G45.0", "G45.1", "G45.8", "G45.9", "I67.89", "I60.9", "I61.9", "I63.30", "I63.40")
cardiovascular_dx_codes <- c("I24","I25","I20","I44","I45","I47","I48","I49",
                             "I05","I06","I08","I34","I35",
                             "I70","I72","I77","I75","I73")
pulmonary_dx_codes <- c("J96","I26.9","I27",
                        "J41","J42","J43","J44")
obesity_dx_codes <- c("E66.0","E66.1","E66.2","E66.8","E66.9")
