### Questions to resolve

1. How and where did you get your raw data for the Americas Barometer surveys?
  * I downloaded the merged dataset, containing all surveys from 2004 to 2014, from the [LAPOP website](http://datasets.americasbarometer.org/database-login/usersearch.php?year=2004). But the number of original variables my data has (1791) is much higher than you report (494). And even after filtering out unnecessary variables, my substantive variable count is lower than yours (301 versus 369).
2. Inconsistencies in some Pew Stata scripts for 2011 and 2012
  * As shown in the `notes` column in the `suvey_metadata_for_cleaning` file, there are some inconsistnecies in the Stata do scripts for some Pew surveys
  * In the Pew Global Attitudes 2011 Stata do script, the last dropped variable is Q154BRA, but this **does not exist** in the data set. I inferred that the correct final drop variable is Q120BRA. Is that right? Am I using a different data set?
  * In the Pew Global Attitudes 2012 Stata do script, the last dropped variable is Q164BRA, but this **does not exist** in the data set. I inferred that the correct final drop variable is Q164. Is that right? Am I using a different data set? This do script seems to be a replica of the Pew 2013 Stata script.
    * This results in a mismatch in the substantive variables: 514 in FiveThirtyEight's analysis vs. 424 in Robbins and Kuriakose's work.
  * ~~In the Pew Pentecostals Stata do script, none of the variable names match what I'm seeing. Am I using the wrong data set?~~
3. Replicated results don't match
  * Sadat 2003 -- Egypt, Jordan and UAE: the final_observations and final_variables seem to match, but the results don't.
4. Some country names in the internationalsocialsurvey data sets are not being properly cleaned:
	* `e_germany_east` --> `east`
	* `wal_belgium_wallonia` --> `wallonia`
	* `fla_belgium_flanders` --> `flanders`
	* `w_germany_east` --> `west`
	* `cyprus (t)` --> `cyprus t`
	* `gbn_great britain and_or united kingdom` --> `great britain and_or united kingdom`
	* `gbn_great britain` --> `great britain`
5. internationalsocialsurvey_2009 and internationalsocialsurvey_2012 seem off
  * For internationalsocialsurvey_2009: the final_observations FiveThirtyEight gets are much higher, but the final_variables are lower
  * For internationalsocialsurvey_2012: the final_observations match, but FiveThirtyEight gets much higher final_variables
  
