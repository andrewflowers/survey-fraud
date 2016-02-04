# Prepare data for percentmatch algorithm
# Andrew <andrew.flowers@fivethirtyeight.com>

setwd("~/data-analysis/survey-fraud/")

require(foreign)
require(readr)
require(dplyr)
require(stringr)

source("percentmatch.R")

# Example .dta data set

dtaFile <- './survey_data_files/worldvaluessurvey_wave6.dta'
rawData <- read.dta(file = dtaFile)

# Step 1: Record initial variable count, dataset name

orig_dat_vars <- ncol(rawData)
dataset <- 'worldvaluessurvey_wave6'
file_for_analysis <- paste0(dataset, "_temp", ".dta")

# Step 2: Create clean country variable

old_country_var <- 'V2A' # Note: automate this for all surveys later
country_var <- rawData %>% select(contains(old_country_var))
country_var[, old_country_var] <- gsub(".", "", country_var[, old_country_var], fixed=TRUE)
new_country_var <- country_var[, old_country_var]
rawData <- new_country_var %>% cbind(rawData)
names(rawData)[1] <- 'country'
rawData <- rawData %>% arrange(country)

# Step 3: Drop unncessary variables

earlyDropVars <- c("V1", "V2", "V3")
finalDropVar <- "V229"

dropVars <- c(which(colnames(rawData) %in% earlyDropVars), grep(finalDropVar, names(rawData)):length(names(rawData))) # id, demographic, weight, and metadata variables
subData <- rawData %>% select(-dropVars)

substantive_dat_vars <- ncol(subData)-1

# Step 4: Recode missing variables

# missingResponse <- c('Not asked in survey', 'Missing; RU: Inappropriate response{Inappropriate}')
# subData[subData %in% missingResponse] <- NA
subData[(data.matrix(subData) - 5) <= -4]  <- NA

# Step 5: Remove variables than have only 1 unique non-missing value & variables with >1=10% missing data

varsToIgnore <- c("country", "V2A") # Note: this might change depending on the survey
varsToInspect <- setdiff(names(subData), varsToIgnore) 

countries <- levels(subData$country)

for (c in countries[1]){
  countryData <- subData %>% filter(country==c)
  
  for (var in varsToInspect){
    if ( ((sum(!is.na(countryData[,var]))/length(countryData[,var])) < 0.90) | (length(unique(as.character(countryData[,var]))) < 2)){
      countryData[,var] <- NULL
    }
  }
 
# Step 6: Remove observations with >25% missing
  countryData <- countryData[(rowSums(is.na(countryData))/ncol(countryData)) < 0.25,]
  
# Step 7: Send data to percentmatch algorithm
  pmatch <- percentmatchR(countryData)
  
 
}
  
  



