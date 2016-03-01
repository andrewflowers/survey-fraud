# FiveThirtyEight version of percentmatch algorithm
# Andrew <andrew.flowers@fivethirtyeight.com>

setwd("~/survey-fraud/")

require(readr)
require(Rcpp)
require(inline)

# Note: use data.matrix to convert factor matrix to numeric codes

# exData <- data.matrix(countryData[, 3:ncol(countryData)]) - 5

percentmatchR <- function(matrix){
  
  matrix <- t(matrix)
  
  cols <- ncol(matrix)
  rows <- nrow(matrix)
  
  pmatch <- data.frame(entry=seq(1, cols), match=NA)
  
  for (c in 1:cols){
    
    comp <- matrix == matrix[,c]
    
    pmatch$match[c] <- max(colSums(comp[,-c], na.rm=TRUE)/rows, na.rm=TRUE)
    
  }
  
  return(pmatch)
  
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


####################################################################################################
#################           Percentmatch algorithm in CPP                     ######################
####################################################################################################

## CPP Function

percentmatchCpp <- cxxfunction(
  signature(x="numeric"),
  body='
    Rcpp::NumericMatrix xx(x);
    int nr = xx.nrow();
    NumericMatrix out(nr,nr);
    for( int i = 0; i < nr; i++ ){
      for( int j = 0; j < nr; j++ ){
        out(i,j) = sum( xx(i,_) == xx(j,_) );
      }
    }
    return out;
  ', plugin="Rcpp"
)


