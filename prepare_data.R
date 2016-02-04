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
# NOTE: Will loop through ALL data_files to automate this process.

# Step 1: Record initial variable count, dataset name

orig_dat_vars <- ncol(rawData)
dataset <- str_extract(data_files[6], pattern='[^/]+$')
file_for_analysis <- gsub(".dta", "_temp.dta", dataset) # Note: do we need this?

# Step 2: Create clean country variable

old_country_var <- survey_metadata %>% filter(survey==dataset) %>% select(country_var) %>% as.character()
country_var <- rawData %>% select(contains(old_country_var))
country_var[, old_country_var] <- gsub(".", "", country_var[, old_country_var], fixed=TRUE)
new_country_var <- country_var[, old_country_var]
rawData <- new_country_var %>% cbind(rawData)
names(rawData)[1] <- 'country'
rawData <- rawData %>% arrange(country)

# Step 3: Drop unncessary variables (id, demographic, weight, and other metadata variables)

earlyDropVars <- survey_metadata %>% filter(survey==dataset) %>% select(early_drop_vars) %>% str_split(" ") %>% unlist() %>% as.character()
finalDropVar <- survey_metadata %>% filter(survey==dataset) %>% select(final_drop_var) %>% as.character()
dropVars <- c(which(colnames(rawData) %in% earlyDropVars), grep(finalDropVar, names(rawData)):length(names(rawData))) 
subData <- rawData %>% select(-dropVars)
substantive_dat_vars <- ncol(subData)-1

# Step 4: Recode missing variables

missing_code <- survey_metadata %>% filter(survey==dataset) %>% select(missing_code) %>% as.numeric()
subData[(data.matrix(subData) - 5) <= missing_code]  <- NA # NOTE: The -5 calculation is a weird but necessary adjustment.
subData$country <- new_country_var # This is because the -5 calculation above makes Algeria (and potentially other countries) NA

# Step 5: Remove variables than have only one  unique non-missing value & variables with >10% missing data

varsToIgnore <- survey_metadata %>% filter(survey==dataset) %>% select(vars_to_ignore) %>% str_split(" ") %>% unlist() %>% as.character()
varsToInspect <- setdiff(names(subData), varsToIgnore) 

countries <- unique(subData$country)

summaryData <- data.frame()

for (c in countries){
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
  
# Summary data, write to file
  
  sumData <- pmatchSummary(pmatch, c)
  print(sumData) # Unnecessary
  summaryData <- rbind(sumData, summaryData)
  
}

# This is incomplete because I should add a `dataset` column
write_csv(summaryData %>% arrange(desc(country_id)), "replication_summary.csv")



