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

set dp comma

* Figure 1 (Gini)

ineqdec0 hhinceq if perc_hhinc!=100, by(vuosi) // gross
ineqdec0 hhincdeq if perc_hhdis!=100, by(vuosi) // net

file open res using "$dir5/Theil-descr.txt", write replace
file write res "year" _tab "index" _n
forvalues y = 1991/2014 {
	use if vuosi==`y' & perc_hhinc!=100 using "$dir4/otos"
	theildeco hhinceq, byg(emp2) // doesn't matter which group is chosen for calculating overall Theil
	file write res %4s "`y'" _tab %7,5f (r(Theil)) _n
	}
forvalues y = 1991/2014 {
	use if vuosi==`y' & perc_hhdis!=100=100 using "$dir4/otos"
	theildeco hhincdeq, byg(emp2) // doesn't matter which group is chosen for calculating overall Theil
	file write res %4s "`y'" _tab %7,5f (r(Theil)) _n
	}
file close res	


** Figure 2 (education, origin and employment)

tab vuosi idcasm2 
tab vuosi idcasm2, row nofreq
tab vuosi idcasm2 if female==0, row nofreq
tab vuosi idcasm2 if female==1, row nofreq

tab vuosi idorigin2
tab vuosi idorigin2, row nofreq
tab vuosi idorigin2 if female==0, row nofreq
tab vuosi idorigin2 if female==1, row nofreq

tab vuosi emp2, row nofreq
tab vuosi emp2 if female==0, row nofreq
tab vuosi emp2 if female==1, row nofreq

** Figure 3 (partnership and children)

tab vuosi partner, row nofreq
tab vuosi partner if female==0, row nofreq
tab vuosi partner if female==1, row nofreq

tab vuosi child, row nofreq
tab vuosi child if female==0, row nofreq
tab vuosi child if female==1, row nofreq

** Figures 4 & 5

set dp period

graph bar (mean) partner if female==0 & [vuosi==1991 | vuosi==2000 | vuosi==2003 | vuosi==2014], over(vuosi) over(idcasm2, relabel(1 "compulsory" 2 "vocational" 3 "post-sec." 4 "bachelor" 5 "master's") lab(labs(medsmall))) over(emp2) /// 
	ytitle("Proportion partnered") ///
	ylabel(0(0.1)0.8) ytick(0.(0.05)0.8, grid) ///
	scheme(s2mono) xsize(9) ///
	legend(rows(1)) ///
	saving(Men-ed-emp-part-change)
graph export "$dir5/Men-ed-emp-part-change.pdf"
graph export "$dir5/Men-ed-emp-part-change.png"

graph bar (mean) partner if female==1 & [vuosi==1991 | vuosi==2000 | vuosi==2003 | vuosi==2014], over(vuosi) over(idcasm2, relabel(1 "compulsory" 2 "vocational" 3 "post-sec." 4 "bachelor" 5 "master's") lab(labs(medsmall))) over(emp2) /// 
	ytitle("Proportion partnered") ///
	ylabel(0(0.1)0.8) ytick(0.(0.05)0.8, grid) ///
	scheme(s2mono) xsize(9) ///
	legend(rows(1)) ///
	saving(Women-ed-emp-part-change)
graph export "$dir5/Women-ed-emp-part-change.pdf"
graph export "$dir5/Women-ed-emp-part-change.png"

set dp comma


*Other descriptives

bys vuosi: spearman idcasm2 spcasm2 if partner == 1

gen homogamous = (idcasm2 == spcasm2)
replace homogamous = . if partner == 0
tab vuosi homogamous, row nofreq

bys vuosi: corr idincome2 spincome2 if partner == 1


