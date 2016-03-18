# Survey metadata analysis
# Andrew <andrew.flowers@fivethirtyeight.com>

setwd("~/survey-fraud/")

require(readr)
require(dplyr)
require(tidyr)
require(stringr)
require(ggplot2)

bfData <- read_csv("./results/replication_summary_031716.csv") # Bialik and Flowers's data
rkData <- read_csv("Results_File_Cleaned_1209.csv") # Robbins and Kuriakose's data

rawData <- bfData # Change to bfData when ready

# Add tally above 85%
rawData <- rawData %>% mutate(pct_at_85=(dup_observations_at_85/final_observations)*100)

# Number of survey questions
survey_questions <- rawData %>% ggplot(aes(x=final_variables, y=pct_at_85)) +
  geom_point() + geom_smooth(method="lm") + 
  xlab("Number of tested survey questions") + ylab("Percentmatch at 85%") +
  ggtitle("Survyes with lots of questions have similar percentmatch shares")
survey_questions

ggsave(plot=survey_questions, filename = "./charts/survey_questions.png")

# Number of survey respondents
survey_respondents <- rawData %>% ggplot(aes(x=final_observations, y=pct_at_85)) +
  geom_point() + geom_smooth(method="lm") + 
  xlab("Number of tested respondents") + ylab("Percentmatch at 85%") +
  ggtitle("Survyes with lots of respondents have similar percentmatch shares")
survey_respondents

ggsave(plot=survey_respondents, filename = "./charts/survey_respondents.png")
       
# Number of response options
response_options <- rawData %>% ggplot(aes(x=median_num_resp, y=pct_at_85)) +
  geom_point() + geom_smooth(method="lm") + 
  xlab("Median number of response options") + ylab("Percentmatch at 85%") +
  ggtitle("Survyes with more response options have slightly smaller percentmatch shares")
response_options

ggsave(plot=response_options, filename = "./charts/response_options.png")

summary(lm(data=rawData, formula = pct_at_85 ~ median_num_resp))
summary(lm(data=rawData, formula = pct_at_85 ~ median_num_resp + final_variables + final_observations))
