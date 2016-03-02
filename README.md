## Survey Fraud

This repository contains the files behind FiveThirtyEight's analysis of international surveys using the percentmatch algorithm developed by Michael Robbins and Noble Kuriakose.

Here is a guide to the folder structure:

Folder | Description
---- | --------------
analysis | Contains several R scripts for post-replication analysis. In particular, the `compare_replication.R` script compares Robbins and Kuriakose's original findings with FiveThirtyEight's replicated results
charts | R charts as generated from various analysis scripts
miscellaneous | Random files. Importantly, the 	`americasbarometer_countrycodes.csv` file is used by the `prepare_data.R` script to convert the numerical country codes in Americas Barometer surveys to country names
papers | Includes PDF files of Robbins and Kuriakose's paper, as well as a response by Pew
r_scripts | Contains three R scripts, see below for further details
raw_survey_data | This contains 40 raw survey data files, organized in sub-folders by survey administrator. **THESE FILES ARE NOT TO BE RELEASED PUBLICLY.**
results | Contains replication summary files
stata_files | Stata versions of the percentmatch algorithm, along with a sub-folder (`do_scripts`) with Stata do scripts for specific surveys. **THE DO SCRIPTS ARE NOT TO BE RELEASED PUBLICLY.**

The `r_scripts` folder contains the following files:

File | Description
---- | --------------
`percentmatch.R` | R versions of the percentmatch algorithm, along with other functions. There are two versions of the algorithm: percentmatchR and percentmatchCpp. The former is written in base R, while the latter uses RCpp (compiled C++ run through R). **percentmatchCpp is still in development**
`prepare_data.R` | An R script that takes raw data files  from `survey_data_files` and cleans/preapres them for the percentmatch algorithm. This script was written off the `stata_files/do_scripts` as provided by Robbins and Kuriakose. To run it, one must enter survey metadta in the file `survey_metadata_for_cleaning.csv`
`read_data.R` | An R function that reads in data from a range of file formats, like .csv, Stata (.dta) or SPSS (.sav).

The original results file, from Robbins and Kuriakose, is `Results_File_Cleaned_1209.csv`. **THIS FILE IS NOT TO BE RELEASED PUBLICLY.**

### How to make sense of these results

Two crucial files are worth explaining in more detail.

(1) `survey_metadata_for_cleaning.csv`: [Click here for instructions](https://github.com/andrewflowers/survey-fraud/blob/master/survey_metadata_instructions.md). This file lists each survey by row and metadata by column. The metadata entered -- which variables to drop, the name of the country variable, etc. -- are used by the `prepare_data.R` script to clean the raw data files. See 

(2) `replication_summary_MMDDYY.csv`: These are dated replication files in the `results` folder, from FiveThirtyEight's attempt to replicate Robbins and Kuriakose's results, as found in `Results_File_Cleaned_1209.csv`. **AS OF NOW, THE REPLICATION IS CLOSE BUT IMPERFECT.**

