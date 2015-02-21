/* Created by: 	Katherine Hoffmann, 2015.02.21
Goal: 			Extrapolate Ebola growth at the chiefdom level, using district-level projections */

clear all
capture log close

version 12.0
set more off

cd "C:\Users\khoffmann.IPA\Documents\GitHub\ebola-data-jam\"
local filename	extrapolate_pop

* Bring in SL census projections from 2004 at district level
	insheet using "data/sierra_leone_district_population_2005_2014.csv", names

	foreach var of varlist v* {
		local newname "`:variable label `var''"
		local newname = "population_" + "`newname'"
		rename `var' `newname'
	}	
	
	destring population*, ignore(,) replace

	replace district = regexr(district, "District", "")
	replace district = trim(itrim(proper(district)))	
	replace district = "Urban" if district=="Western Urban"
	replace district = "Rural" if district=="Western Rural"
	
	rename district merge_var
	drop if inlist(merge_var, "Western Province", "Northern Province", "Southern Province", "Eastern Province", "Western Area", "Sierra Leone")
	
	save "data/sl_district_projections.dta", replace

* Bring in existing map file units
	insheet using "data/sle_administrative_boundary_areas_merge.csv", clear
	gen merge_var = district
	
		replace merge_var = chiefdom if inlist(chiefdom, "Bo Town", "Bonthe Town", "Kenema Town", "Koidu New Sembehum", "Makeni Town")
		
	merge m:1 merge_var using "data/sl_district_projections.dta"
	save "data/sl_district_projections.dta", replace
	
	drop _merge
	
* Now, figure out the weight of every chiefdom within the district
* Come out with an estimated population of every chiefdom within the district
	
	bysort merge_var: egen population_2004 = sum(total)	
	gen chiefdom_weight = total/population_2004	
	gen total_estimated_2015 = chiefdom_weight*population_2014
	
	outsheet using "data/sle_administrative_boundary_areas_merge_2014.csv", comma replace
	
exit
		
/* Before the war the distribution of the population was determined by regional imbalances in economic endowment; with high concentrations in places like Kono, Kenema and Port Loko Districts as well as Freetown. During the war forced migration contributed to the distortion of both spatial distribution and population movement patterns. For instance Kono District, which used to have high population next to Freetown, has a decline in population from 389,657 in 1985 to 335,401 in 2004. This was certainly as a result of movement of people from the district at the time of the census to Bombali District in search of diamond. Subsequently, Bombali District has more than proportionate increase in population from 317,729 in 1985 to 408,390 in 2004. Freetown, which was regarded as the safest place during the war, also attracted a large influx of people such that by the time of the census the population has increased by 64.5 percent, from 469,779 in 1985 to 772,873 in 2004 */


