### Survey Metadata Instructions

To run the percentmatch algorithm on a survey data set, one must first enter some survey metadata into the file `survey_metadata_for_cleaning.csv`. All variables are case-sensitive.

Column | Description
----- | --------
survey | Name of the survey data file, excluding the file extentsion (.csv, .dta, .sas)
country_var | The variable which indicates the country name 
ballot_var | For when two surveys of the same country where taken; few surveys will have this option. This is the specific variable name to indicate which 
ballot_resp | For when two surveys of the same country where taken; few surveys will have this option.  This is the response that distinguishes one country-survey set from another
early_drop_var | The variables that will be dropped; must be separated by a single space (" ")
final_drop_var | The column/variable from which all variables including and after it will be dropped
vars_to_ignore | This includes the the country_var as well as "country"
notes | Notes on how FiveThirtyEight's replication differs from Robbins and Kuriakose's work