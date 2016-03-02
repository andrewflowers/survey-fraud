# Compare replicated data to Robbins and Kuriakose's data
# Andrew <andrew.flowers@fivethirtyeight.com>

setwd("~/survey-fraud/")

require(readr)
require(dplyr)
require(tidyr)
require(stringr)
require(ggplot2)

bfData <- read_csv("./results/replication_summary_030116.csv") # Bialik and Flowers's data
rkData <- read_csv("Results_File_Cleaned_1209.csv") # Robbins and Kuriakose's data

# Change country names to lower case
bfData$country <- tolower(bfData$country)
rkData$country <- tolower(rkData$country)

# Compare dataset names
View(cbind(sort(unique(rkData$dataset)), sort(unique(bfData$dataset))))

# Match by dataset and country
joinData <- rkData %>% 
  left_join(bfData, by = c("dataset" = "dataset", "country" = "country"))

# Compare replicated and original data sets
compData <- joinData %>% 
  mutate(comp_at_85=dup_observations_at_85.x==dup_observations_at_85.y,
         comp_at_90=dup_observations_at_90.x==dup_observations_at_90.y,
         comp_at_95=dup_observations_at_95.x==dup_observations_at_95.y,
         comp_at_100=dup_observations_at_100.x==dup_observations_at_100.y) 

# Calculate error rates
compData %>% 
  select(23:26) %>% 
  summarize(error_at_85=1-sum(comp_at_85, na.rm=T)/n(),
            error_at_90=1-sum(comp_at_90, na.rm=T)/n(),
            error_at_95=1-sum(comp_at_95, na.rm=T)/n(),
            error_at_100=1-sum(comp_at_100, na.rm=T)/n())

#### Read specific data sets into