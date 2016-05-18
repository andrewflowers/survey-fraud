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
    pmatch %>% filter(match>0) %>% tally(), # new
    pmatch %>% filter(match>.05) %>% tally(), # new
    pmatch %>% filter(match>.10) %>% tally(), # new
    pmatch %>% filter(match>.15) %>% tally(), # new
    pmatch %>% filter(match>.20) %>% tally(), # new
    pmatch %>% filter(match>.25) %>% tally(), # new
    pmatch %>% filter(match>.30) %>% tally(), # new
    pmatch %>% filter(match>.35) %>% tally(), # new
    pmatch %>% filter(match>.40) %>% tally(), # new
    pmatch %>% filter(match>.45) %>% tally(), # new
    pmatch %>% filter(match>.50) %>% tally(), # new
    pmatch %>% filter(match>.55) %>% tally(), # new
    pmatch %>% filter(match>.60) %>% tally(), # new
    pmatch %>% filter(match>.65) %>% tally(), # new
    pmatch %>% filter(match>.70) %>% tally(), # new
    pmatch %>% filter(match>.75) %>% tally(), # new
    pmatch %>% filter(match>.80) %>% tally(), # new
    pmatch %>% filter(match>.85) %>% tally(),
    pmatch %>% filter(match>.90) %>% tally(),
    pmatch %>% filter(match>.95) %>% tally(),
    pmatch %>% filter(match==1) %>% tally()
  )
  
  names(summaryVector) <- c("country", "dup_observations_at_0", 
                            "dup_observations_at_05", "dup_observations_at_10", 
                            "dup_observations_at_15", "dup_observations_at_20", 
                            "dup_observations_at_25", "dup_observations_at_30", 
                            "dup_observations_at_35", "dup_observations_at_40", 
                            "dup_observations_at_45", "dup_observations_at_50", 
                            "dup_observations_at_55", "dup_observations_at_60", 
                            "dup_observations_at_65", "dup_observations_at_70", 
                            "dup_observations_at_75", "dup_observations_at_80", 
                            "dup_observations_at_85", "dup_observations_at_90", 
                            "dup_observations_at_95", "dup_observations_at_100")
  
  return(summaryVector)
}

numRespCat <- function(rawmatrix, var_list){
  
#   numResp <- c()
  
#   for(i in var_list){
#     numResp <- append(numResp, length(table(rawmatrix[,i])))
#     # print(numResp)
#   }
#   
#   return(median(numResp))

  return(median(sapply(rawmatrix[,var_list], function(x) length(table(x)))))
  
}

# The following method is inspired by a paper from Ali Mushtaq (Datafugue) at DataFab 2016

longestRepeatSeq <- function(matrix){
  # Possible improvement: http://stackoverflow.com/questions/19933788/r-compare-all-the-columns-pairwise-in-matrix
  
  matrix <- t(matrix)
  
  cols <- ncol(matrix)
  
  repeateSeq <- data.frame(respondent=seq(1, cols), length=NA)
  
  for (c in 1:cols){
    
    comp <- as.data.frame(matrix == matrix[,c])
    
    repeateSeq$length[c] <- max(sapply(comp[,-c], function(x) {max(sapply(split(x, cumsum(x==0)), length)-1)}))
    print(paste0(c, " is finished. Longest sequence is: ", repeateSeq$length[c]))
    
    # The above function is complicated: the original data matrix is transposed, and every columns is compared 
    # to every other column to get a boolean matrix -- this represents matches. Then, for each column, we use
    # sapply to split that column into separate sub-lists (with split) at each instance of FALSE. These sub-lists 
    # have a length equal to the number of sequential TRUE entries (+1). So we subtract one (-1) and take the max.
    # This max is the longest repeated match sequence.
  }
  
  return(repeateSeq)
  
}

stringToVector <- function(dataframe, dataset, variable){
  
  vector <- dataframe %>% filter(survey==dataset) %>% dplyr::select(variable) %>% str_split(" ") %>% unlist %>% as.character()
  
  return(vector)
}
