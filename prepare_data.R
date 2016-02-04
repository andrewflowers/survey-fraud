# Prepare data for percentmatch algorithm
# Andrew <andrew.flowers@fivethirtyeight.com>

setwd("~/survey-fraud/")

require(foreign)
require(readr)
require(dplyr)
require(stringr)

source("percentmatch.R")

# Load survey metadata file
survey_metadata <- read_csv("survey_metadata_for_cleaning.csv")

# Example: World Values Survey, Wave 1-6

data_files <- dir("./survey_data_files", full.names=TRUE)

rawData <- read.dta(file = data_files[6])

# Step 1: Record initial variable count, dataset name

orig_dat_vars <- ncol(rawData)
dataset <- str_extract(data_files[6], pattern='[^/]+$')
file_for_analysis <- paste0(dataset, "_temp", ".dta") # Note: do we need this?

# Step 2: Create clean country variable

# old_country_var <- 'V2A' # Note: automate this for all surveys later
old_country_var <- survey_metadata %>% filter(survey==dataset) %>% select(country_var) %>% as.character()

country_var <- rawData %>% select(contains(old_country_var))
country_var[, old_country_var] <- gsub(".", "", country_var[, old_country_var], fixed=TRUE)
new_country_var <- country_var[, old_country_var]
rawData <- new_country_var %>% cbind(rawData)
names(rawData)[1] <- 'country'
rawData <- rawData %>% arrange(country)

# Step 3: Drop unncessary variables

# earlyDropVars <- c("V1", "V2", "V3")
earlyDropVars <- survey_metadata %>% filter(survey==dataset) %>% select(early_drop_vars) %>% str_split(" ") %>% unlist() %>% as.character()

# finalDropVar <- "V229"
finalDropVar <- survey_metadata %>% filter(survey==dataset) %>% select(final_drop_var) %>% as.character()

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
  
  



