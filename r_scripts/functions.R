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

pmatchSummary <- function(pmatch, c){
  
  summaryVector <- data.frame(
    c,
    pmatch %>% filter(match>.85) %>% tally(),
    pmatch %>% filter(match>.90) %>% tally(),
    pmatch %>% filter(match>.95) %>% tally(),
    pmatch %>% filter(match==1) %>% tally()
  )
  
  names(summaryVector) <- c("country", "dup_observations_at_85", 
                            "dup_observations_at_90", "dup_observations_at_95", 
                            "dup_observations_at_100")
  
  return(summaryVector)
}

numRespCat <- function(rawmatrix){
  
  numResp <- c()
  
  for(i in ncol(rawmatrix)){
    numResp <- append(numResp, length(table(rawmatrix[,i])))
  }
  
  return(median(numResp))
  
}

longestRepeatSeq <- function(matrix){
  
  matrix <- t(matrix)
  
  cols <- ncol(matrix)
  rows <- nrow(matrix)
  
  repeateSeq <- data.frame(respondent=seq(1, cols), length=NA)
  
  for (c in 1:cols){
    
    comp <- matrix == matrix[,c]
    
    repeateSeq$length[c] <- comp  ### write algorithm for longest sequence
    
  }
  
  return(repeateSeq)
  
}

