***********************************************************************
***   Partnership and income inequality   *****************************
***   Elina Kilpi-Jakonen & Jani Erola    *****************************
***********************************************************************

global dir1 "W:\01_Data_U0208B\Basic data sets wide format"
global dir2 "W:\Partnership and income inequality"
global dir3 "W:\Partnership and income inequality\temp"
global dir4 "W:\Partnership and income inequality\data"
global dir5 "W:\Partnership and income inequality\output"

**** All the information that is needed from both the sample members (children) and their parents

use "$dir1/all_individuals", clear 
merge 1:1 TK_nro using "$dir1/completed education wide", keepusing(casmin*) keep(match master) nogen
merge 1:1 TK_nro using "$dir1/occupational variables", keepusing(isei* egp*) keep(match master) nogen 

**** Make everyone both a child and a parent

gen id=TK_nro
gen yb=syntyv // year of birth

foreach t in m f { 
gen `t'id=id
gen `t'id_yb=yb
}

foreach t of num 1975 1980 1985 1987/2014 {
	foreach p in id mid fid { 	
	quietly gen `p'casm`t'=casmin`t'
	quietly gen `p'casm_y`t'=casmin_years`t'
	}
}

foreach t of num 1975 1985 1990 1993 1995 2000 2004/2014 {
	foreach p in id mid fid {
	quietly gen `p'isei`t' = isei`t'
	quietly gen `p'egp`t' = egp5`t'
	}
}	

compress
save "$dir3/inddata", replace

**** Sample person data

use "$dir1/children_of_spers.dta", clear

** use the biological children of the original data sample persons 
** cohorts 1951-1979 (35-40 years old in 1991-2014)

keep if mbio_spers==1 | fbio_spers==1 
keep if syntyv >= 1951 & syntyv <= 1979

ren TK_nro id
ren mid_bio mid
ren fid_bio fid

keep id mid fid female
save "$dir4/otos", replace

** merge information from self, mother and father

merge 1:1 id using "$dir3/inddata", keepusing(yb idcasm* idisei* idegp*) keep(match master) nogen
merge m:1 mid using "$dir3/inddata", keepusing(midcasm* midisei* midegp* mid_yb) keep(match master) nogen
merge m:1 fid using "$dir3/inddata", keepusing(fidcasm* fidisei* fidegp* fid_yb) keep(match master) nogen
ren id TK_nro
merge 1:1 TK_nro using "$dir1/income kela and tax variables", keepusing(svatv_eki* svatv_netto_ekit* tyotu_eki* tyrtu_eki*) keep(match master) nogen
merge 1:1 TK_nro using "$dir1/occupational variables", keepusing(ptoim1* optuki* tyo* tyke*) keep(match master) nogen 
merge 1:1 TK_nro using "$dir1/fucodes.dta", keepusing(pekoko* pety* a18lkm*) keep(match master) nogen
ren TK_nro id

**reshape from wide to long and add age

reshape long ptoim1 optuki tyo tyokk tyke svatv_eki svatv_netto_ekit tyotu_eki tyrtu_eki idcasm idcasm_y midcasm midcasm_y fidcasm fidcasm_y idisei midisei fidisei idegp midegp fidegp pekoko pety a18lkm,  i(id) j(vuosi)
drop tyot1975 tyot1985 

gen age = vuosi - yb

compress
save "$dir4/otos", replace



***** Spouses and their parents

use "$dir1/u0208_b_asuinliito_07jun2017.dta", clear

** select only spouses of individuals (cohorts) in our sample

merge m:1 TK_nro using "$dir1/children_of_spers.dta", keepusing(syntyv fbio_spers mbio_spers) keep(match master) nogen
keep if mbio_spers==1 | fbio_spers==1 
keep if syntyv >= 1951 & syntyv <= 1979
keep PU_nro 
duplicates drop

** match parents to spouses

rename PU_nro TK_nro
merge 1:1 TK_nro using "$dir1/mothers_bio.dta", keepusing(mid_bio) keep(match master) nogen 
merge 1:1 TK_nro using "$dir1/fathers_bio.dta", keepusing(fid_bio) keep(match master) nogen
merge 1:1 TK_nro using "$dir1/mothers_adopt.dta", keepusing(mid_adopt) keep(match master) nogen
merge 1:1 TK_nro using "$dir1/fathers_adopt.dta", keepusing(fid_adopt) keep(match master) nogen

** keep only one mother and father

foreach par in mid fid {
	gen `par' = ""
	replace `par' = `par'_adopt
	replace `par' = `par'_bio if `par'=="" 
}

rename TK_nro id
keep id mid fid
compress 
save "$dir3/spouses", replace

** match spouses' own data and that of their parents

merge 1:1 id using "$dir3/inddata", keepusing(yb idcasm* idisei* idegp*) keep(match master) nogen
merge m:1 mid using "$dir3/inddata", keepusing(midcasm* midisei* midegp* mid_yb) keep(match master) nogen
merge m:1 fid using "$dir3/inddata", keepusing(fidcasm* fidisei* fidegp* fid_yb) keep(match master) nogen
ren id TK_nro
merge 1:1 TK_nro using "$dir1/income kela and tax variables", keepusing(svatv_eki* svatv_netto_ekit* tyotu_eki* tyrtu_eki*) keep(match master) nogen
merge 1:1 TK_nro using "$dir1/occupational variables", keepusing(ptoim1* optuki* tyo* tyke*) keep(match master) nogen 
ren TK_nro id

** reshape from wide to long, carry (missing) information forward and rename

reshape long ptoim1 optuki tyo tyokk tyke svatv_eki svatv_netto_ekit tyotu_eki tyrtu_eki idcasm idcasm_y midcasm midcasm_y fidcasm fidcasm_y idisei midisei fidisei idegp midegp fidegp,  i(id) j(vuosi)
drop tyot1975 tyot1985 

foreach var of varlis idisei-fidegp{ // huom. from spuses only isei and egp, from parents all information
	bys id (vuosi): replace `var' = `var'[_n-1] if `var' == .  
	}
	
rename id spid
rename ptoim1 spptoim1
rename optuki spoptuki
rename svatv_eki spincome                
rename svatv_netto_ekit spincnet   
rename tyotu_eki spearn
rename tyrtu_eki spself
rename yb spyb               
rename idcasm spcasm                              
rename idisei spisei                 
rename idegp spegp                 
rename idcasm_y spcasm_y                 
rename mid_yb sm_yb                 
rename midcasm smcasm                
rename midisei smisei                 
rename midegp smegp                 
rename midcasm_y smcasm_y               
rename fid_yb sf_yb                 
rename fidcasm sfcasm                
rename fidisei sfisei                 
rename fidegp sfegp                 
rename fidcasm_y sfcasm_y               

drop mid fid	

compress
save "$dir3/spousedata", replace	


**** Partnership information for sample persons 

use "$dir4/otos", clear

ren id TK_nro
merge 1:1 TK_nro vuosi using "$dir1/u0208_b_asuinliito_07jun2017.dta", keepusing(PU_nro) keep(match master) nogen
rename TK_nro id
rename PU_nro spid
merge m:1 spid vuosi using "$dir3/spousedata", keep(match master) nogen

**** Carry forward missing information similarly as for spouses

foreach var of varlis idisei-fidegp{ // huom. "lapselta" vain isei ja egp, vanhemmilta kaikki tiedot
	bys id (vuosi): replace `var' = `var'[_n-1] if `var' == .  
	}

** Drop unnecessary years and ages

keep if age >=35 & age <=40
keep if vuosi >= 1991

** Some data cleaning etc.

drop if idcasm == .
drop if ptoim1 == "" // missing main activity; all of these individuals also have missing income information

replace pekoko = 1 if pekoko == .

label define casmin 1 "basic education" 2 "vocational upper secondary" ///
	3 "general upper secondary (yo)" 4 "postsecondary non-HE (alin korkea aste/opisto)" ///
	5 "bachelor's degree (AMK+yliop)" 6 "master's degree (AMK+yliop), lic.+Phd"
label values idcasm casmin
label values spcasm casmin
label values midcasm casmin
label values fidcasm casmin
label values smcasm casmin
label values sfcasm casmin

label define egp5 1 "Upper service (I)" 2 "Lower service (II)" 3 "Skilled non-manual/manual (IIIa+V+VI)" ///
	4 "Self-employed/farmers (IVabc)" 5 "Semi-/unskilled (IIIb+VII)"
label values idegp egp5
label values spegp egp5
label values midegp egp5
label values fidegp egp5
label values smegp egp5
label values sfegp egp5

rename svatv_eki idincome                
rename svatv_netto_ekit idincnet   
rename tyotu_eki idearn
rename tyrtu_eki idself

save "$dir4/otos", replace
	
