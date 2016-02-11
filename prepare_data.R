# Prepare data for percentmatch algorithm
# Andrew <andrew.flowers@fivethirtyeight.com>

setwd("~/survey-fraud/")

require(foreign)
require(readr)
require(dplyr)
require(stringr)

source("percentmatch.R")
source("read_data.R")

# Load survey metadata file
survey_metadata <- read_csv("survey_metadata_for_cleaning.csv")

# Testing on pew data sets

data_files <- dir("./sadat_data", full.names=TRUE)

summaryData <- data.frame()

for (df in data_files){
  
  rawData <- readData(data_files[2]) # Calls readData function in read_data.R file
  
  # Step 1: Record initial variable count, dataset name
  
  orig_dat_vars <- ncol(rawData)
  dataset <- str_sub(str_extract(df, pattern='[^/]+$'), end = -5) 
  
  # Step 2: Create clean country variable, including ballot options
  
  old_country_var <- survey_metadata %>% filter(survey==dataset) %>% dplyr::select(country_var) %>% as.character()
  country_var <- rawData %>% dplyr::select(contains(old_country_var)) # Fix this to be exactly filtered for the country_var
  country_var[, old_country_var] <- gsub(".", "", country_var[, old_country_var], fixed=TRUE) 
  new_country_var <- country_var[, old_country_var]
  if ("country" %in% names(rawData)) {rawData$country <- NULL }
  rawData <- new_country_var %>% cbind(rawData)
  names(rawData)[1] <- 'country'
  rawData <- rawData %>% arrange(country)
  
  # Add ballot options to names -- NOTE: May want to break this out as a separate function
  
  ballot_var <- survey_metadata %>% filter(survey==dataset) %>% dplyr::select(ballot_var) %>% as.character()
  ballot_resp <- survey_metadata %>% filter(survey==dataset) %>% dplyr::select(ballot_resp) %>% as.character()
  
  if (!is.na(ballot_var)){
    rawData$country <- ifelse(!is.na(rawData[,ballot_var]), 
            ifelse(rawData[,ballot_var] == ballot_resp,
                   paste0(rawData$country, "_ballot_a"),
                   paste0(rawData$country, "_ballot_b")),
            paste0(rawData$country))
  }
  
  # Step 3: Drop unncessary variables (id, demographic, weight, and other metadata variables)
  
  earlyDropVars <- survey_metadata %>% filter(survey==dataset) %>% dplyr::select(early_drop_vars) %>% str_split(" ") %>% unlist() %>% as.character()
  finalDropVar <- survey_metadata %>% filter(survey==dataset) %>% dplyr::select(final_drop_var) %>% as.character()
  dropVars <- ifelse(!is.na(finalDropVar), 
                     c(which(colnames(rawData) %in% earlyDropVars), grep(finalDropVar, names(rawData)):length(names(rawData))),
                       which(colnames(rawData) %in% earlyDropVars))
  subData <- rawData %>% dplyr::select(-dropVars)
  substantive_dat_vars <- ncol(subData) # Check that this is right!
  
  # Step 4: Recode missing variables
  
  missing_code <- survey_metadata %>% filter(survey==dataset) %>% dplyr::select(missing_code) %>% as.numeric()
  if (!is.na(missing_code)) { subData[(data.matrix(subData) - 5) <= missing_code]  <- NA } # NOTE: The -5 calculation is a weird but necessary adjustment; it might be a Stata-only issue, though.
  subData$country <- rawData$country # Check that this works with WorldValues surveys. It's meant to prevent an override of Algeria as NA
  
  # Step 5: Remove variables than have only one  unique non-missing value & variables with >10% missing data
  
  varsToIgnore <- survey_metadata %>% filter(survey==dataset) %>% dplyr::select(vars_to_ignore) %>% str_split(" ") %>% unlist() %>% as.character()
  varsToInspect <- setdiff(names(subData), varsToIgnore) 
  
  countries <- sort(unique(subData$country))
  
  for (c in countries){
    countryData <- subData %>% filter(country==c)  
    
    initial_observations <- nrow(countryData)
    
    for (var in varsToInspect){
      if ( ((sum(!is.na(countryData[,var]))/length(countryData[,var])) < 0.90) | (length(unique(as.character(countryData[,var]))) < 2)){
        countryData[,var] <- NULL
      }
    }
  
    final_variables <- ncol(countryData)-1
    
  # Step 6: Remove observations with >25% missing
    countryData <- countryData[(rowSums(is.na(countryData))/ncol(countryData)) < 0.25,]
    
    final_observations <- nrow(countryData)
    
  # Step 7: Send data to percentmatch algorithm
    pmatch <- percentmatchR(countryData) # Calls percentmatchR function in percentmatch.R file
    
  # Write summary data to file, after adding other metadata and cleaning 
    
    sumData <- pmatchSummary(pmatch, c)
    # print(sumData) # Unnecessary
    allData <- cbind(dataset, 
                     initial_observations, 
                     final_observations,
                     orig_dat_vars, 
                     substantive_dat_vars,
                     final_variables,
                     sumData) 
    
    allData <- allData %>% 
      dplyr::select(1, 7, 2:6, 8:11) 
    
    summaryData <- rbind(allData, summaryData)
    # summaryData <- arrange(dataset, desc(country_id)) # Better sort summary data
  }
  
 
  print(paste0(df, " is complete"))
  
} # Note: this ends loop through ONE data set.  
  
# Write out summary data file
write_csv(summaryData, "replication_summary_sadat.csv")
