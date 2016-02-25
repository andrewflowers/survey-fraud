# Survey metadata analysis
# Andrew <andrew.flowers@fivethirtyeight.com>

setwd("~/survey-fraud/")

require(readr)
require(dplyr)
require(tidyr)
require(stringr)
require(ggplot2)

bfData <- read_csv("./results/replication_summary_022416.csv") # Our data
rkData <- read_csv("Results_File_Cleaned_1209.csv") # Robbins and Kuriakose's data

rawData <- rkData # Change to bfData when ready

# Add tally above 85%
rawData <- rawData %>% mutate(pct_at_85=(dup_observations_at_85/final_observations)*100)

# Number of survey questions
rawData %>% ggplot(aes(x=final_variables, y=pct_at_85)) +
  geom_point() + geom_smooth(method="lm") + 
  xlab("Number of tested survey questions") + ylab("Percentmatch at 85%") +
  ggtitle("Survyes with lots of questions have similar percentmatch shares")


# Number of survey respondents
rawData %>% ggplot(aes(x=final_observations, y=pct_at_85)) +
  geom_point() + geom_smooth(method="lm") + 
  xlab("Number of tested respondents") + ylab("Percentmatch at 85%") +
  ggtitle("Survyes with lots of respondents have similar percentmatch shares")
