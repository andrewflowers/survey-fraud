# Functions for survey fraud analysis
# Andrew <andrew.flowers@fivethirtyeight.com>

setwd("~/survey-fraud/")

require(stringr)
require(dplyr)

clean_country_string <- function(country_column){
  
  country_column <- str_extract(country_column, pattern='[^-]+$')
  country_column <- gsub(".", "", country_column,fixed=TRUE) 
  country_column <- gsub("/", "_", country_column, fixed=TRUE)
  country_column <- gsub("-", "_", country_column, fixed=TRUE) 
  country_column <- gsub("(", "", country_column, fixed=TRUE)
  country_column <- gsub(")", "", country_column, fixed=TRUE)
  country_column <- str_trim(country_column)
  
  return(country_column)
}