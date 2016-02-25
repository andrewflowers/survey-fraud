# Analysis of Pew survey of muslims
# Andrew <andrew.flowers@fivethirtyeight.com>

setwd("~/survey-fraud/")

require(readr)
require(dplyr)
require(tidyr)
require(stringr)
require(ggplot2)

bfData <- read_csv("./results/replication_summary_022416.csv") # Bialik and Flowers's data
rkData <- read_csv("Results_File_Cleaned_1209.csv") # Robbins and Kuriakose's data

rawData <- bfData # Change to bfData when ready

# Add tally above 85%
rawData <- rawData %>% mutate(pct_at_85=(dup_observations_at_85/final_observations)*100)

pew_muslims <- 'pewreligion_muslims'

rawData %>% 
  filter(dataset==pew_muslims) %>% 
  ggplot(aes(pct_at_85)) + geom_dotplot() 
  