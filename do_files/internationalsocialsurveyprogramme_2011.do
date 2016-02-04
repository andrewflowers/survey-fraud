use "internationalsocialsurveyprogramme_2011.dta", clear

*record initial variable count, dataset name
local orig_dat_vars `c(k)'
local dataset "internationalsocialsurvey_2011"
local file_for_analysis = "`dataset'" + "_temp" + ".dta"

*create clean country variable
decode V3, gen(country_var)
replace country_var = substr(country_var, strpos(country_var, "-")+1,.)
replace country_var = subinstr(country_var, "-","_",.)
replace country_var = subinstr(country_var, ".","",.)
replace country_var = subinstr(country_var, "(","",.)
replace country_var = subinstr(country_var, ")","",.)
encode country_var, gen(country)
order country

*remove id, demographic, weight, and metadata Variables
drop V1 - C_ALPHA SEX - country_var

*record non-demographic variable count
local substantive_dat_vars `c(k)'

*create missing Code
foreach var of varlist V5 - V69{
	quietly replace `var' = . if `var'==0
}

*create temporary data for analysis
save "`file_for_analysis'", replace

forvalues i=1/34 {
	use "`file_for_analysis'", clear
	
	*keeping only 1 country per loop logic
	quietly keep if country==`i'
	
	*remove variables that have only 1 unique non-missing value
	*remove variables with >=10% missing data 
	foreach newvar of varlist V5 - V69 {
		quietly fre `newvar'
		if ((`r(N_valid)'/`r(N)')<.9) | (`r(r)'<2){
			 noisily drop `newvar'
			}
		}
		
	*passing in the first and last variable names for percentmatch
	quietly ds
	local lastvar: word `c(k)' of `r(varlist)'
	local firstvar: word 2 of `r(varlist)'
	
	*passing in country name
	local countryname: label country `i'
	di "`countryname'"
	
	*recording initial observation count, final variable count
	local initial_observations `c(N)'
	local final_dat_vars = (`c(k)')-1
	
	*removing observations with >25% missingness
	egen num_missing = rowmiss(`firstvar' - `lastvar')
	drop if num_missing>(0.25*(`c(k)'-1))
	drop num_missing
	
	*creating id var
	gen id_for_pmatch = _n
	
	percentmatch `firstvar'-`lastvar', id(id_for_pmatch) gen(match_percent) matchedid(matched_id_for_pm)
	
	*recording results
	local final_observations `r(N)'
	capture file close recording
	file open recording using results.txt, write append text
	file write recording ("`dataset'") ";" (`i') ";" ("`countryname'") ";" (`initial_observations') ";" (`final_observations') ";" ///
							(`orig_dat_vars') ";" (`substantive_dat_vars') ";" (`final_dat_vars') ";"  ///
							(`r(p85)') ";" (`r(p90)') ";" (`r(p95)') ";" (`r(p100)') ";" ///
							("`r(varlist)'") _n
	file close recording
	
	*saving histogram
	local graph_name = "`dataset'" + "_" + "`countryname'" + ".png"
	histogram match_percent, xlabel(.4(.2)1) 
	graph export "`graph_name'"
	}
