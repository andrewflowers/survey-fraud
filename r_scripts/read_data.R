# Read survey data 
# Andrew <andrew.flowers@fivethirtyeight.com>

setwd("~/survey-fraud/")

require(stringr)
require(stringi)
require(foreign)
require(readr)
require(Hmisc)
require(memisc)
require(dplyr)


readData <- function(dataFile){
  
  rawData <- data.frame()
  
  fileType <- substr(dataFile, nchar(dataFile)-2, nchar(dataFile))
  
  if (fileType=="dta"){
    library(foreign)
    rawData <- read.dta(file=dataFile)
  } else if (fileType=="csv"){
    rawData <- read_csv(file=dataFile)
  } else if (fileType=="sav"){
    rawData <- spss.get(file=dataFile)
  }
  
  return(rawData)
}


# Testing 

# dtaFile <- readData("./survey_data_files/worldvaluessurvey_wave1.dta")
# dim(dtaFile)
# savFile <- readData("./pew_data/sav_files/Pew Research Global Attitudes Project Spring 2012 Dataset for web.sav")
# dim(savFile)
# csvFile <- readData("./sadat_data/Sadat_2003.csv")
# dim(csvFile)
