## Survey Fraud

This repository contains the files behind FiveThirtyEight's analysis of international surveys using the percentmatch algorithm developed by Michael Robbins and Noble Kuriakose.

Here is a guide to the folder structure:

Folder | Description
---- | --------------
r_scripts | Contains three R scripts, see below for further details.
raw_survey_data | This contains 41 raw survey data files, organized in sub-folders by survey administrator. **THESE FILES ARE NOT TO BE RELEASED PUBLICLY.**
results | Contains replication summary files, organized by survey administrator.
papers | Includes PDF files of Robbins and Kuriakose's paper, as well as a resposne by Pew.
stata_files | Stata versions of the percentmatch algorithm, along with a sub-folder (`do_scripts`) with Stata do scripts for specific survey administrators. **THE DO SCRIPTS ARE NOT TO BE RELEASED PUBLICLY.**

The `r_scripts` folder contains the following files:

File | Description
---- | --------------
`percentmatch.R` | An R version of the percentmatch algorithm, along with other functions, too.
`prepare_data.R` | An R script that takes raw data files taken from `survey_data_files` and cleans/preapres them for the percentmatch algorithm.
`read_data.R` | An R function that reads in data from a range of file formats, like .csv, Stata (.dta) or SPSS (.sav).

The original results file, from Robbins and Kuriakose, is `Results_File_Cleaned_1209.csv`. **THIS FILE IS NOT TO BE RELEASED PUBLICLY.**


### How to make sense of these results

Two crucial files are worth explaining in more detail.

(1) `survey_metadata_for_cleaning.csv`, which lists each survey by row and metadata by column. The metadata entered -- which variables to drop, the name of the country variable, etc. -- are used by the `prepare_data.R` script to clean the raw data files.

(2) `replication_summary.csv` in the `results` folder is an attempt to replicate Robbins and Kuriakose's results, as found in `Results_File_Cleaned_1209.csv`. **AS OF NOW, THE REPLICATION IS IMPERFECT.**

