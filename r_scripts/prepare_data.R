# Prepare data for percentmatch algorithm
# Andrew <andrew.flowers@fivethirtyeight.com>

setwd("~/survey-fraud/")

source("./r_scripts/percentmatch.R")
source("./r_scripts/read_data.R")

require(foreign)
require(readr)
require(stringr)
require(dplyr)

# Load survey metadata file
survey_metadata <- read_csv("survey_metadata_for_cleaning.csv")
# survey_metadata <- read_csv("./miscellaneous/survey_metadata_for_cleaning_AB.csv") # For Arab Barometer test

data_files <- list.files("./raw_survey_data", full.names=TRUE, recursive=TRUE)

summaryData <- data.frame()

for (df in data_files){
  
  #df <- data_files[2] # For manual inspection
  # df <- "./miscellaneous/arab_barometer_to_test.sav"
  
  rawData <- readData(df) # Calls readData function in read_data.R file
  
  # Step 1: Record initial variable count, dataset name
  
  orig_dat_vars <- ncol(rawData)
  dataset <- str_sub(str_extract(df, pattern='[^/]+$'), end = -5) 
  
  old_country_var <- survey_metadata %>% filter(survey==dataset) %>% dplyr::select(country_var) %>% as.character()
  country_var <- rawData %>% dplyr::select(contains(old_country_var)) # Fix this to be exactly filtered for the country_var
  country_var[, old_country_var] <- gsub(".", "", country_var[, old_country_var], fixed=TRUE) 
  new_country_var <- country_var[, old_country_var]
  if ("country" %in% names(rawData)) {rawData$country <- NULL }
  rawData <- new_country_var %>% cbind(rawData)
  names(rawData)[1] <- 'country'
  rawData <- rawData %>% arrange(country)
  rawData <- rawData %>% mutate(country=str_extract(country, pattern='[^-]+$'))
  rawData <- rawData %>% mutate(country=str_trim(country))
 
  # Add ballot options to names -- NOTE: May want to break this out as a separate function
  
  ballot_var <- survey_metadata %>% filter(survey==dataset) %>% dplyr::select(ballot_var) %>% as.character()
  ballot_resp <- survey_metadata %>% filter(survey==dataset) %>% dplyr::select(ballot_resp) %>% str_split(" ") %>% unlist %>% as.character()
  
  if (!is.na(ballot_var)){
    for (i in 1:nrow(rawData)){
      
      # Test whether there are 1 or 2 ballot resposnes
      if (length(ballot_resp)==1){
        rawData$country[i] <- ifelse(rawData[i, ballot_var] == ballot_resp,
          paste0(rawData$country[i], "_", ballot_resp), as.character(rawData$country[i]))
      } 
      
      if(length(ballot_resp)==2){
        if (is.na(rawData[i, ballot_var])){
          rawData$country[i] <- as.character(rawData$country[i])
        } else {
        rawData$country[i] <- ifelse(rawData[i, ballot_var] == gsub("_", " ", ballot_resp[2]), 
              paste0(rawData$country[i], "_", ballot_resp[2]),
              ifelse(rawData[i, ballot_var] == gsub("_", " ", ballot_resp[1]),
              paste0(rawData$country[i], "_", ballot_resp[1]), as.character(rawData$country[i])))
        }
        }
      }
    }
    
  # View(table(rawData$country))
  
  # Step 3: Drop unncessary variables (id, demographic, weight, and other metadata variables)
  
  earlyDropVars <- survey_metadata %>% filter(survey==dataset) %>% dplyr::select(early_drop_vars) %>% str_split(" ") %>% unlist() %>% as.character()
  finalDropVar <- survey_metadata %>% filter(survey==dataset) %>% dplyr::select(final_drop_var) %>% as.character()
  
  ifelse(is.na(finalDropVar), 
         dropVars <- which(colnames(rawData) %in% earlyDropVars),
         dropVars <-  c(which(colnames(rawData) %in% earlyDropVars), grep(finalDropVar, names(rawData)):length(names(rawData)))
                       )
  
  subData <- rawData %>% dplyr::select(-dropVars)
  
  # Check that this is right!
  # For Afrobarometer, it's -1. But that's maybe because Afrobarometer has a correct country variable already
  # The do script doesn't change the country variable
  substantive_dat_vars <- ncol(subData) -1 
  
  # Step 4: Recode missing variables
  
  missing_code <- survey_metadata %>% filter(survey==dataset) %>% dplyr::select(missing_code) %>% as.numeric()
  if (!is.na(missing_code)) { subData[(data.matrix(subData)) == missing_code]  <- NA } # NOTE: May need -5 calculation is a weird but necessary adjustment; it might be a Stata-only issue, though.
  subData$country <- rawData$country # Check that this works with WorldValues surveys. It's meant to prevent an override of Algeria as NA
  
  # Step 5: Remove variables than have only one unique non-missing value & variables with >=10% missing data
  
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
    countryData <- countryData[(rowSums(is.na(countryData))/ncol(countryData)) <= 0.25,]
    
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
  
 
  print(paste0(dataset, " is complete"))
  
} # Note: this ends loop through ONE data set.  
  
# Fix Americas Barometer country codes
abCountryCodes <- read_csv("./miscellaneous/americasbarometer_countrycodes.csv")

summaryData2 <- summaryData %>%
  mutate(country=ifelse(is.na(abCountryCodes[match(country, abCountryCodes$country_code),]$country_name), 
                        as.character(country),
                        abCountryCodes[match(country, abCountryCodes$country_code),]$country_name))

# Write out summary data file
write_csv(summaryData2, "./results/replication_summary.csv")
