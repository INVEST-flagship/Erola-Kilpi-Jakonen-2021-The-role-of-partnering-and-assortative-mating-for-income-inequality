***********************************************************************
***   Partnership and income inequality   *****************************
***   Elina Kilpi-Jakonen & Jani Erola    *****************************
***********************************************************************

global dir1 "W:\01_Data_U0208B\Basic data sets wide format"
global dir2 "W:\Partnership and income inequality"
global dir3 "W:\Partnership and income inequality\temp"
global dir4 "W:\Partnership and income inequality\data"
global dir5 "W:\Partnership and income inequality\output"

use "$dir4/otos", clear

** Household incomes

foreach var in idincome idincnet idearn idself spincome spself spearn spincnet {
	gen `var'2 = `var'
	replace `var'2 = 0 if `var' == .
}

gen hhinc = idincome2 + spincome2
gen hhinceq = hhinc/sqrt(pekoko)
gen hhincdis = idincnet2 + spincnet2
replace hhincdis = 0 if hhincdis < 0
gen hhincdeq = hhincdis/sqrt(pekoko)
gen incemp = idearn2 + idself2 
	
label variable hhinceq "Household income, family size equivalized"
label variable hhincdeq "Disposable household income, family size equivalized"
label variable incemp "Individual income from earnings and self-employment"

egen perc_hhinc = xtile(hhinceq), by(vuosi) nq(100) 
egen perc_hhdis = xtile(hhincdeq), by(vuosi) nq(100) 
egen perc_inemp = xtile(incemp), by(vuosi) nq(100) 

** Existence of spouse and children

gen partner = (spid!="")
gen child = (a18lkm > 0 & a18lkm < .)

** Education categories

recode idcasm (3 = 4 ), gen (idcasm2)
recode spcasm (3 = 4 ), gen (spcasm2)
label values idcasm2 casmin
label values spcasm2 casmin
replace spcasm2 = 99 if spid == ""

** Employment

gen emp2 = (ptoim1 == "11")
label variable emp2 "Employment based on end of year activity"
label define emp2 0 "Non-employed" 1 "Employed"
label values emp2 emp2

gen spemp2 = (spptoim1 == "11")
replace spemp2 = . if partner == 0


** Intergenerational variables

*Parents' egp (dominance: 1 2 4 3 5)
recode fidegp (1 = 1 "I") (2 = 2 "II") (4 = 3 "IV") (3 = 4 "IIIa+V+VI") (5 = 5 "IIIb+VII"), gen(idorigin)
replace idorigin = 1 if midegp == 1 
replace idorigin = 2 if midegp == 2 & fidegp != 1
replace idorigin = 3 if midegp == 4 & idorigin > 3
replace idorigin = 4 if midegp == 3 & idorigin > 4
replace idorigin = 5 if midegp == 5 & idorigin > 5
*If egp missing, use presumed using parental education and modal values of egp
/*Modal values 
1 basic education --> egp5 5
2 vocational upper secondary --> egp5 mothers 5, fathers 3
3 general upper secondary (yo) --> egp5 2
4 postsecondary non-HE (alin korkea aste/opisto) --> egp5 2
5 bachelor's degree (AMK+yliop) --> egp5 mothers 2, fathers 1
6 master's degree (AMK+yliop), lic.+Phd --> egp5 mothers 2, fathers 1
*/
recode fidcasm (1 = 5) (2 = 3) (3 4 = 2) (5 6 = 1), gen(fidegp_ed)
recode midcasm (1 2 = 5) (3/6 = 2), gen(midegp_ed)
recode fidegp_ed (1 = 1 "I") (2 = 2 "II") (4 = 3 "IV") (3 = 4 "IIIa+V+VI") (5 = 5 "IIIb+VII"), gen(idorigin_ed)
replace idorigin_ed = 2 if midegp_ed == 2 & fidegp_ed != 1
replace idorigin_ed = 5 if midegp_ed == 5 & idorigin_ed > 5

gen idorigin2 = idorigin
label values idorigin2 idorigin
replace idorigin2 = idorigin_ed if idorigin==.
drop if idorigin2==. 

recode idorigin2 (1 2 = 1 "Salariat") (3 4 = 2 "Intermediate") (5 = 3 "Working"), gen(idorigin3)

*Similarly for spouses
recode sfegp (1 = 1 "I") (2 = 2 "II") (4 = 3 "IV") (3 = 4 "IIIa+V+VI") (5 = 5 "IIIb+VII"), gen(sporigin)
replace sporigin = 1 if smegp == 1 
replace sporigin = 2 if smegp == 2 & sfegp != 1
replace sporigin = 3 if smegp == 4 & sporigin > 3
replace sporigin = 4 if smegp == 3 & sporigin > 4
replace sporigin = 5 if smegp == 5 & sporigin > 5
recode sfcasm (1 = 5) (2 = 3) (3 4 = 2) (5 6 = 1), gen(sfegp_ed)
recode smcasm (1 2 = 5) (3/6 = 2), gen(smegp_ed)
recode sfegp_ed (1 = 1 "I") (2 = 2 "II") (4 = 3 "IV") (3 = 4 "IIIa+V+VI") (5 = 5 "IIIb+VII"), gen(sporigin_ed)
replace sporigin_ed = 2 if smegp_ed == 2 & sfegp_ed != 1
replace sporigin_ed = 5 if smegp_ed == 5 & sporigin_ed > 5

gen sporigin2 = sporigin
label values sporigin2 sporigin
replace sporigin2 = sporigin_ed if sporigin==.
replace sporigin2 = 6 if sporigin2==. & spid!=""

recode sporigin2 (1 2 = 1 "Salariat") (3 4 = 2 "Intermediate") (5 = 3 "Working") (6 = 4), gen(sporigin3)
replace sporigin3 = 5 if spid==""


compress
save "$dir4/otos", replace

drop if perc_hhdis==100 // dropped for stability of estimates
drop if idorigin2==. 
gen par1 = partner+1
gen chi1 = child+1
replace emp2 = emp2+1
egen ed2= group(emp2 idcasm2), missing
egen par2 = group(emp2 partner), missing
egen par3 = group(ed2 partner), missing
egen chi4 = group(par3 child), missing
egen sem5= group(chi4 spemp2), missing
egen sed6= group(sem5 spcasm2), missing
egen sor7 = group(sed6 sporigin3), missing
egen or8 = group(sor7 idorigin3), missing

save "$dir4/otos2", replace


