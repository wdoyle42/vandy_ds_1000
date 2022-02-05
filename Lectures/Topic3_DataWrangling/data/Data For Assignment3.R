# Data Wrangling for Assignment 3
library(tidyverse)

load("/Users/clintojd/GitHub/vandy_ds_1000_materials/Lectures/Topic3_DataWrangling/data/PA.Rdata")
load("/Users/clintojd/GitHub/vandy_ds_1000_materials/Lectures/Topic3_DataWrangling/data/NC.Rdata")
load("/Users/clintojd/GitHub/vandy_ds_1000_materials/Lectures/Topic3_DataWrangling/data/FL.Rdata")
load("/Users/clintojd/GitHub/vandy_ds_1000_materials/Lectures/Topic3_DataWrangling/data/TX.Rdata")

ExitPolls <- bind_rows(d.pa,d.fl,d.tx,d.nc)

saveRDS(ExitPolls,file = "/Users/clintojd/GitHub/vandy_ds_1000_materials/Lectures/Topic3_DataWrangling/data/ExitPolls.Rds")