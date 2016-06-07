# Compare replicated data to Robbins and Kuriakose's data
# Andrew Flowers <andrew.flowers@fivethirtyeight.com>

setwd("~/survey-fraud/")

require(readr)
require(dplyr)
require(tidyr)
require(stringr)
require(ggplot2)

bfData <- read_csv("./results/replication_summary_031716.csv") # Bialik and Flowers's data
rkData <- read_csv("Results_File_Cleaned_1209.csv") # Robbins and Kuriakose's data

# Change country names to lower case
bfData$country <- tolower(bfData$country)
rkData$country <- tolower(rkData$country)

# Test country name differences 
setdiff(bfData$country, rkData$country)
setdiff(rkData$country, bfData$country)

# Compare dataset names
# View(cbind(sort(unique(rkData$dataset)), sort(unique(bfData$dataset))))

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
  dplyr::select(comp_at_85, comp_at_90, comp_at_95, comp_at_100) %>% 
  dplyr::summarize(error_at_85=1-sum(comp_at_85, na.rm=T)/n(),
            error_at_90=1-sum(comp_at_90, na.rm=T)/n(),
            error_at_95=1-sum(comp_at_95, na.rm=T)/n(),
            error_at_100=1-sum(comp_at_100, na.rm=T))

# Dataset-by-dataset error rate
error_by_dataset <- compData %>% 
  group_by(dataset) %>% 
    dplyr::summarize(error_at_85=1-sum(comp_at_85, na.rm=T)/n(),
            error_at_90=1-sum(comp_at_90, na.rm=T)/n(),
            error_at_95=1-sum(comp_at_95, na.rm=T)/n(),
            error_at_100=1-sum(comp_at_100, na.rm=T)/n()) %>% 
  filter(error_at_100>0) %>% arrange(desc(error_at_100))

error_by_dataset
# Check ISSP names
View(compData %>% filter(dataset %in% c("internationalsocialsurvey_2008", 
                                      "internationalsocialsurvey_2009",
                                      "internationalsocialsurvey_2010",
                                      "internationalsocialsurvey_2011",
                                      "internationalsocialsurvey_2012"
                                      )) %>% 
  select(dataset, country, initial_observations.x, initial_observations.y) %>% 
  filter(is.na(initial_observations.y)))

View(bfData %>% filter(dataset %in% c("internationalsocialsurvey_2008", 
                                        "internationalsocialsurvey_2009",
                                        "internationalsocialsurvey_2010",
                                        "internationalsocialsurvey_2011",
                                        "internationalsocialsurvey_2012"
)) %>% distinct(country))

# Export comparison sheet
write_csv(compData, "comparisons.csv")


# Analyze variable list differences -- CAN'T DO THIS UNTIL NOBLE RE-RUN'S HIS REPLICATION FOOD

# compData$var_diff <- NA
# 
# compData$var_match <- compData$var_list == compData$varlist
# 
# for (dataset in compData){
#   
#   var_diff <- setdiff(compData$varlist[dataset] %>% str_split(" ") %>% unlist %>% as.character(), 
#                       compData$var_list[dataset] %>% str_split(" ") %>% unlist %>% as.character())  
#   
# }



# Compare top line results

topLine <- compData %>% 
  mutate(org_share_85=dup_observations_at_85.x/initial_observations.x,
         rep_share_85=dup_observations_at_85.y/initial_observations.y,
         org_5pt=ifelse(org_share_85>=0.05, 1, 0),
         rep_5pt=ifelse(rep_share_85>=0.05, 1, 0))

sum(topLine$org_5pt)/nrow(topLine) 
sum(topLine$rep_5pt, na.rm=T)/nrow(topLine) 



##### Pew counter analysis #####

chartbuilder <- compData %>% 
  # group_by(dataset) %>% 
  summarize(org_pct_at_85=sum(dup_observations_at_85.x, na.rm=T)/sum(final_observations.x, na.rm=T),
            rep_pct_at_85=sum(dup_observations_at_85.y, na.rm=T)/sum(final_observations.y, na.rm=T))

# # %>% gather(method, pct, -dataset) %>% 
#   ggplot(aes(dataset, stat_count(pct), fill=method)) + geom_bar(position='dodge')


write_csv(chartbuilder, "chart_data.csv")

worst <- compData %>% 
  group_by(dataset, country) %>% 
  mutate(difference=abs(dup_observations_at_100.x-dup_observations_at_100.y)) %>% 
  ungroup() %>% 
  select(dataset, country, dup_observations_at_100.x, dup_observations_at_100.y, difference) %>% 
  filter(dup_observations_at_100.x> dup_observations_at_100.y) %>% 
  arrange(desc(difference))
