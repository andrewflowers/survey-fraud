# FiveThirtyEight version of percentmatch algorithm
# Andrew <andrew.flowers@fivethirtyeight.com>

setwd("~/survey-fraud/")

require(readr)
require(Rcpp)

# Note: use data.matrix to convert factor matrix to numeric codes

# exData <- data.matrix(countryData[, 3:ncol(countryData)]) - 5

# Example: Zimbabwe from World Values Survey #6

percentmatchR <- function(matrix){
  
  matrix <- t(matrix)
  
  cols <- ncol(matrix)
  rows <- nrow(matrix)
  
  pmatch <- data.frame(entry=seq(1, cols), match=NA)
  
  for (c in 1:cols){
    
    comp <- matrix == matrix[,c]
    
    pmatch$match[c] <- max(colSums(comp[,-c])/rows)
    
  }
  
  return(pmatch)
  
#   print(paste0("100% matches: ", pmatch %>% filter(match==1) %>% tally()))
#   print(paste0("95% matches: ", pmatch %>% filter(match>.95) %>% tally()))
#   print(paste0("90% matches: ", pmatch %>% filter(match>.90) %>% tally()))
#   print(paste0("85% matches: ", pmatch %>% filter(match>.85) %>% tally()))
  
}

# pmatch_ex <- percentmatchR(exData)
# 
# pmatch_ex %>% filter(match==1) %>% tally()
# pmatch_ex %>% filter(match>.95) %>% tally()
# pmatch_ex %>% filter(match>.90) %>% tally()
# pmatch_ex %>% filter(match>.85) %>% tally()




####################################################################################################
#################         Write percentmatch algorithm in CPP                 ######################
####################################################################################################

## CPP Function
# cppFunction('LogicalVector percentmatch(NumericMatrix x) {
#             
#             int nrow = x.nrow(), ncol = x.ncol();
#             
#             LogicalVector comparisons(nrow);
#             
#             for (int i = 0; i < nrow; i++) {
# 
#               NumericMatrix::Row tmp0 = x(i, _);
#               NumericMatrix::Row tmp1 = x(i, _);
#               comparisons[i] = tmp0 == tmp1
#             }
#             
#             return comparisons;
# 
#             }')
# 
# percentmatch(countryData2)
# 
# 
# cppFunction("Logical test(){
#             
#       NumericVector xx = NumericVector::create(1.0, 2.0, 3.0, 4.0 );
#       NumericVector xy = NumericVector::create(1.0, 3.0, 3.0, 4.0 );
# 
#       return xx == xy;
# 
# }")

