### Survey Metadata Instructions

To run the percentmatch algorithm on a survey data set, one must first enter some survey metadata into the file `survey_metadata_for_cleaning.csv`. All variables are case-sensitive.

Column | Description
----- | --------
survey | Name of the survey data file, excluding the file extentsion (.csv, .dta, .sav)
country_var | The variable which indicates the country name 
ballot_var | For when two surveys of the same country where taken (e.g., "Colombia" and "Colombia_2"); only a few surveys will require this option. `ballot_var` is the specific variable name in the survey used to distinguish sub-country surveys from one another 
ballot_resp | For when two surveys of the same country where taken (e.g., "Colombia" and "Colombia_2"); only a few surveys will require this option.  `ballot_resp` is the specific variable **response** that distinguishes one country-survey set from another. If there is more than one option, they should be separated by a single space (" ") 
early_drop_var | The variables that will be dropped; must be separated by a single space (" ")
final_drop_var | The variable from which all variables following it will be dropped
missing_code | The specific code which indicates that data is missing, and will be coverted to NA; most surveys do not have this explicity, and "NA" should be entered 
vars_to_ignore | This includes the country_var, as well as "country," along with other variables that are not to be dropped, but just ignored
notes | Notes on how FiveThirtyEight's replication differs from Robbins and Kuriakose's work. See the [Questions to resolve](https://github.com/andrewflowers/survey-fraud/blob/master/questions_to_resolve.md) file for further details

#### Example: Pew Global Attitudes 2007

After loading the raw survey data, it's clear that the variable `country` provides data on just that. The variable "Form" is entered in the column `ballot_var`, as it indicates whether a survey has two separate sub-components (i.e., is a ballot survey); and if it does, the response should be "Form_A" or "Form B." In the column `early_drop_vars` there are several variable names ("RID", "Form") separated by a single space (" "). And then "Q107" is the `final_drop_var` -- meaning all variables from "Q107" to the end of the survey will be dropped from the analysis. This Pew survey doesn't have any `missing_code`, so there is just an "NA" in its place. Finally, the `vars_to_ignore` column contains just "country" to be excluded from the analysis.
