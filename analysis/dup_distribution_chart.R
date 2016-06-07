# Chart of duplicate distribution for all surveys

setwd("~/survey-fraud/analysis/")

require(readr)
require(plyr)
require(dplyr)
require(ggplot2)
require(tidyr)
require(lubridate)

summary_data <- read_csv("../results/replication_summary_051816.csv")

base_num <- summary_data[,8]

for (i in 8:28){
  summary_data[,i] <- summary_data[,i]/base_num  
}

summary_data2 <- summary_data %>% 
  select(1:2, 8:28) %>% 
  rename(dup_observations_exact = dup_observations_at_100) %>% 
  gather(dup_level, dup_amount, 3:23) %>% 
  mutate(survey_name=paste0(country, "_", dataset))

summary_data2$dup_level[summary_data2$dup_level=='dup_observations_exact'] <- 100
summary_data2$dup_level[summary_data2$dup_level=='dup_observations_at_95'] <- 95
summary_data2$dup_level[summary_data2$dup_level=='dup_observations_at_90'] <- 90
summary_data2$dup_level[summary_data2$dup_level=='dup_observations_at_85'] <- 85
summary_data2$dup_level[summary_data2$dup_level=='dup_observations_at_80'] <- 80
summary_data2$dup_level[summary_data2$dup_level=='dup_observations_at_75'] <- 75
summary_data2$dup_level[summary_data2$dup_level=='dup_observations_at_70'] <- 70
summary_data2$dup_level[summary_data2$dup_level=='dup_observations_at_65'] <- 65
summary_data2$dup_level[summary_data2$dup_level=='dup_observations_at_60'] <- 60
summary_data2$dup_level[summary_data2$dup_level=='dup_observations_at_55'] <- 55
summary_data2$dup_level[summary_data2$dup_level=='dup_observations_at_50'] <- 50
summary_data2$dup_level[summary_data2$dup_level=='dup_observations_at_45'] <- 45
summary_data2$dup_level[summary_data2$dup_level=='dup_observations_at_40'] <- 40
summary_data2$dup_level[summary_data2$dup_level=='dup_observations_at_35'] <- 35
summary_data2$dup_level[summary_data2$dup_level=='dup_observations_at_30'] <- 30
summary_data2$dup_level[summary_data2$dup_level=='dup_observations_at_25'] <- 25
summary_data2$dup_level[summary_data2$dup_level=='dup_observations_at_20'] <- 20
summary_data2$dup_level[summary_data2$dup_level=='dup_observations_at_15'] <- 15
summary_data2$dup_level[summary_data2$dup_level=='dup_observations_at_10'] <- 10
summary_data2$dup_level[summary_data2$dup_level=='dup_observations_at_05'] <- 5
summary_data2$dup_level[summary_data2$dup_level=='dup_observations_at_0'] <- 0

summary_data2$dup_level <- as.numeric(summary_data2$dup_level)

summary_data2 %>% 
  group_by(survey_name) %>% 
  #filter(survey_name=='Uzbekistan_worldvaluessurvey_wave6' | survey_name=='Yemen_worldvaluessurvey_wave6') %>% 
  #filter(country=="Yemen") %>% 
  ggplot(aes(dup_level, dup_amount, group= survey_name, color=survey_name)) + 
  geom_line() + #geom_smooth(method="lm") +
  theme(legend.position="none") + ggtitle("Survey Response Duplication At 5% Levels") +
  xlab("Dupblication threshold") + ylab("Percent of responses duplicated at that level") +
  xlim(c(40, 100))
