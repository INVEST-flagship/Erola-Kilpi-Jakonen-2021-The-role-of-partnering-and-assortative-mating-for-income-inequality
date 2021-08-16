***********************************************************************
***   Partnership and income inequality   *****************************
***   Elina Kilpi-Jakonen & Jani Erola    *****************************
***   This part of the analysis based on  *****************************
***   do-files kindly provided by         *****************************
***   Diederik Boertien                   *****************************
***********************************************************************

global dir1 "W:\01_Data_U0208B\Basic data sets wide format"
global dir2 "W:\Partnership and income inequality" 
global dir3 "W:\Partnership and income inequality\temp"
global dir4 "W:\Partnership and income inequality\data"
global dir5 "W:\Partnership and income inequality\output"

set dp comma

*** Counterfactuals for years 1991 - 2000 + 2003 - 2014 
use if vuosi == 1991 | vuosi == 2000 | vuosi == 2003 | vuosi == 2014 using "$dir4/otos2", clear

/*** Variables required
xj - mean income for each group
pj - proportion in each group
GElj - within-group Theil value
*/

*For three main factors: employment, education, partnership

*Mean income
bys vuosi female par3: egen xj = mean(hhincdeq) 

*Proportion in each group
bys vuosi female: gen pop = _N
bys vuosi female par3: gen subpop = _N
gen pj = subpop/pop

*Within-group Theil value
gen in1 = [hhincdeq/xj] * ln(hhincdeq/xj)
bys vuosi female par3: egen in2 = total(in1)
gen GElj = in2 / subpop

*Data for counterfactuals
collapse xj pj GElj, by(vuosi female par3)

foreach var in xj pj GElj {
	foreach y in 1991 2000 2003 2014 {
		forvalues g = 0/1 {
			gen t_`var'_`y'_`g' = `var' if vuosi == `y' & female == `g'
			bys par3: egen `var'_`y'_`g' = max(t_`var'_`y'_`g')
		}
	}
}
drop t_*


*Observed Theils for each year
gen newxl = xj*pj
bys vuosi female: egen c8 = total(newxl) // average overall income 
gen c9 = (pj*(xj/c8))*(ln(xj/c8))
bys vuosi female: egen BGI = sum(c9) // between group inequality
gen c10 = pj*(xj/c8)*GElj
bys vuosi female: egen WGI = sum(c10) // within group inequality

gen Theil = BGI+WGI 

table vuosi female, contents(mean Theil mean BGI mean WGI)  


*Counterfactual Theils
*Change within-group Theil

***For all analyses below, need to choose correct start and end years and comment out unncessary ones

local start 1991
local end 2000

local start 2003
local end 2014

drop newxl c* Theil BGI* WGI*
gen newxl = xj*pj 
egen c8 = total(newxl) if vuosi==`start' & female==0 // average overall income 
egen c8b = total(newxl) if vuosi==`start' & female==1 // average overall income 
replace c8 = c8b if vuosi==`start' & female==1
gen c9 = (pj*(xj/c8))*(ln(xj/c8))
egen BGI = sum(c9)  if vuosi==`start' & female==0 // between group inequality
egen BGIb = sum(c9)  if vuosi==`start' & female==1 // between group inequality
replace BGI = BGIb if vuosi==`start' & female==1
gen c10 = pj*(xj/c8)*GElj_`end'_0 if vuosi==`start' & female==0 
replace c10 = pj*(xj/c8)*GElj_`end'_1 if vuosi==`start' & female==1
egen WGI = sum(c10)  if vuosi==`start' & female==0 // within group inequality
egen WGIb = sum(c10)  if vuosi==`start' & female==1 // within group inequality
replace WGI = WGIb if vuosi==`start' & female==1
gen Theil = BGI+WGI 
table vuosi female, contents(mean Theil mean BGI mean WGI)  

*Change mean earnings

local start 1991
local end 2000

local start 2003
local end 2014

drop newxl c* Theil BGI* WGI*
gen newxl = xj_`end'_0*pj if vuosi==`start' & female==0 
replace newxl = xj_`end'_1*pj if vuosi==`start' & female==1
egen c8 = total(newxl) if vuosi==`start' & female==0 // average overall income 
egen c8b = total(newxl) if vuosi==`start' & female==1 // average overall income 
replace c8 = c8b if vuosi==`start' & female==1
gen c9 = (pj*(xj_`end'_0/c8))*(ln(xj_`end'_0/c8)) if vuosi==`start' & female==0 
replace c9 = (pj*(xj_`end'_1/c8))*(ln(xj_`end'_1/c8)) if vuosi==`start' & female==1 
egen BGI = sum(c9)  if vuosi==`start' & female==0 // between group inequality
egen BGIb = sum(c9)  if vuosi==`start' & female==1 // between group inequality
replace BGI = BGIb if vuosi==`start' & female==1
gen c10 = pj*(xj_`end'_0/c8)*GElj if vuosi==`start' & female==0 
replace c10 = pj*(xj_`end'_1/c8)*GElj if vuosi==`start' & female==1
egen WGI = sum(c10) if vuosi==`start' & female==0 // within group inequality
egen WGIb = sum(c10) if vuosi==`start' & female==1 // within group inequality
replace WGI = WGIb if vuosi==`start' & female==1
gen Theil = BGI+WGI 
table vuosi female, contents(mean Theil mean BGI mean WGI)  

*Change population shares

local start 1991
local end 2000

local start 2003
local end 2014

drop newxl c* Theil BGI* WGI*
gen newxl = xj*pj_`end'_0 if vuosi==`start' & female==0 
replace newxl = xj*pj_`end'_1 if vuosi==`start' & female==1
egen c8 = total(newxl) if vuosi==`start' & female==0 // average overall income 
egen c8b = total(newxl) if vuosi==`start' & female==1 // average overall income 
replace c8 = c8b if vuosi==`start' & female==1
gen c9 = (pj_`end'_0*(xj/c8))*(ln(xj/c8)) if vuosi==`start' & female==0 
replace c9 = (pj_`end'_1*(xj/c8))*(ln(xj/c8)) if vuosi==`start' & female==1 
egen BGI = sum(c9)  if vuosi==`start' & female==0 // between group inequality
egen BGIb = sum(c9)  if vuosi==`start' & female==1 // between group inequality
replace BGI = BGIb if vuosi==`start' & female==1
gen c10 = pj_`end'_0*(xj/c8)*GElj if vuosi==`start' & female==0 
replace c10 = pj_`end'_1*(xj/c8)*GElj if vuosi==`start' & female==1
egen WGI = sum(c10) if vuosi==`start' & female==0 // within group inequality
egen WGIb = sum(c10) if vuosi==`start' & female==1 // within group inequality
replace WGI = WGIb if vuosi==`start' & female==1
gen Theil = BGI+WGI 
table vuosi female, contents(mean Theil mean BGI mean WGI)  

****Change associations
***Same as above, run code multiple times with correct start and end years

use "$dir4/otos2", clear

sort vuosi female par3 // par3 includes own education, employment and partnership

bysort vuosi female par3: gen nj=_N
bysort vuosi female (par3): gen n=_N
gen pj=nj/n

bysort vuosi female par3: egen xj=mean(hhincdeq)

gen c1=(hhincdeq/xj)*(ln(hhincdeq/xj))
bysort vuosi female par3: egen c2=sum(c1)
gen GE1j=(1/nj)*c2

bysort vuosi female par3: keep if _n==1
drop c1 c2

/*Theil as observed
gen c8=xj*pj
by vuosi female: egen x=sum(c8)

gen c9=(pj*(xj/x))*(ln(xj/x))
gen c10=pj*(xj/x)*GE1j

by vuosi female: egen c11=sum(c9)
by vuosi female: egen c12=sum(c10)

gen nGE1=c11+c12

sum nGE1 c11 c12 if vuosi==2014 & female==0
sum nGE1 c11 c12 if vuosi==2014 & female==1

sum nGE1 c11 c12 if vuosi==1991 & female==0
sum nGE1 c11 c12 if vuosi==1991 & female==1

drop c8 x c9 c10 c11 c12
*/

*Simulating change over time

local start 1991
local end 2000

local start 2003
local end 2014

keep if vuosi==`end' | vuosi==`start'

bysort female vuosi ed2: egen currow=sum(pj)
bysort female vuosi partner: egen curcol=sum(pj)

bysort female par3 (vuosi): gen opj=pj[_n-1] if vuosi==`end'

gen totcol=. 
gen totrow=.
forvalues i=1/2000{
	qui: drop totcol totrow
	qui: bysort female vuosi partner: egen totcol=sum(opj)
	qui: replace opj=opj*(curcol/totcol)
	qui: bysort female vuosi ed2: egen totrow=sum(opj)
	qui: replace opj=opj*(currow/totrow)
	}

*Calculate new Theils

sort vuosi female
gen c8=xj*opj
bysort vuosi female: egen x=sum(c8)

gen c9=(opj*(xj/x))*(ln(xj/x))
gen c10=opj*(xj/x)*GE1j

bysort vuosi female: egen c11=sum(c9)
bysort vuosi female: egen c12=sum(c10)

gen oGE1=c11+c12

sum oGE1 c11 c12 if vuosi==`end' & female==0
sum oGE1 c11 c12 if vuosi==`end' & female==1

drop c8 x c9 c10 c11 c12
