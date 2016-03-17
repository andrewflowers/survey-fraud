# FiveThirtyEight version of percentmatch algorithm
# Andrew <andrew.flowers@fivethirtyeight.com>

setwd("~/survey-fraud/")

require(Rcpp)
require(inline)

# Note: may want to use data.matrix to convert factor matrix to numeric codes

percentmatchR <- function(matrix){
  
  # Possible improvement: http://stackoverflow.com/questions/19933788/r-compare-all-the-columns-pairwise-in-matrix
  
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

####################################################################################################
#################           Percentmatch algorithm in CPP                     ######################
####################################################################################################

### NOTE: this function is still in development and does NOT work properly as of March 2, 2016


## CPP Function
# Source: https://github.com/jwbowers/kuriakoserobins/blob/master/KuriakoseRobins.Rmd

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


