***********************************************************************
***   Partnership and income inequality   *****************************
***   Elina Kilpi-Jakonen & Jani Erola    *****************************
***********************************************************************

global dir1 "W:\01_Data_U0208B\Basic data sets wide format"
global dir2 "W:\Partnership and income inequality"
global dir3 "W:\Partnership and income inequality\temp"
global dir4 "W:\Partnership and income inequality\data"
global dir5 "W:\Partnership and income inequality\output"


set matsize 9000

*** Figures 6 & 7 

foreach var in emp2 idcasm2 par1 chi1 idorigin3{
	file open res using "$dir5/Theil-individ-`var'.txt", write replace
	file write res "year" _tab "between" _tab "low" _tab "high" _n
	forvalues g = 0/1 {
		forvalues y = 1991/2014 {
			use if vuosi==`y' & female==`g' using "$dir4/otos2"
			display `y'
			qui bootstrap (r(between_T)): theildeco hhincdeq, byg(`var')
			matrix m1 = r(table)
			scalar b1 = m1[1,1]
			scalar l1 = m1[5,1]
			scalar h1 = m1[6,1]
			file write res %4s "`y'" _tab %7,5f (b1) _tab ///
				%7,5f (l1) _tab %7,5f (h1) _n
			}
		}
	}
file close res	

***Not shown: tests of which variable most increases between-group inequality at each step

***Figures 8 & 9

*First two steps for men

file open res using "$dir5/Theil-cumul_m1.txt", write replace
file write res "year" _tab "between" _tab "low" _tab "high" _n
forvalues y = 1991/2014 {
			use if vuosi==`y' & female==0 using "$dir4/otos2"
			display `y' `g'
			qui bootstrap (r(between_T)): theildeco hhincdeq, byg(emp2)
			matrix m1 = r(table)
			scalar b1 = m1[1,1]
			scalar l1 = m1[5,1]
			scalar h1 = m1[6,1]
			file write res %4s "`y'" _tab %7,5f (b1) _tab ///
				%7,5f (l1) _tab %7,5f (h1) _n
			}
file close res


file open res using "$dir5/Theil-cumul_m2.txt", write replace
file write res "year" _tab "between" _tab "low" _tab "high" _n
forvalues y = 1991/2014 {
			use if vuosi==`y' & female==0 using "$dir4/otos2"
			display `y' `g'
			qui bootstrap (r(between_T)): theildeco hhincdeq, byg(ed2)
			matrix m1 = r(table)
			scalar b1 = m1[1,1]
			scalar l1 = m1[5,1]
			scalar h1 = m1[6,1]
			file write res %4s "`y'" _tab %7,5f (b1) _tab ///
				%7,5f (l1) _tab %7,5f (h1) _n
			}
file close res


*First two steps for women

file open res using "$dir5/Theil-cumul_f1.txt", write replace
file write res "year" _tab "between" _tab "low" _tab "high" _n
forvalues y = 1991/2014 {
			use if vuosi==`y' & female==1 using "$dir4/otos2"
			display `y' `g'
			qui bootstrap (r(between_T)): theildeco hhincdeq, byg(par1)
			matrix m1 = r(table)
			scalar b1 = m1[1,1]
			scalar l1 = m1[5,1]
			scalar h1 = m1[6,1]
			file write res %4s "`y'" _tab %7,5f (b1) _tab ///
				%7,5f (l1) _tab %7,5f (h1) _n
			}
file close res


file open res using "$dir5/Theil-cumul_f2.txt", write replace
file write res "year" _tab "between" _tab "low" _tab "high" _n
forvalues y = 1991/2014 {
			use if vuosi==`y' & female==1 using "$dir4/otos2"
			display `y' `g'
			qui bootstrap (r(between_T)): theildeco hhincdeq, byg(par2)
			matrix m1 = r(table)
			scalar b1 = m1[1,1]
			scalar l1 = m1[5,1]
			scalar h1 = m1[6,1]
			file write res %4s "`y'" _tab %7,5f (b1) _tab ///
				%7,5f (l1) _tab %7,5f (h1) _n
			}
file close res



*From here same variables for men and women

file open res using "$dir5/Theil-cumul3.txt", write replace
	file write res "year" _tab "between" _tab "low" _tab "high" _n
	forvalues g = 0/1 {
		forvalues y = 1991/2014 {
			use if vuosi==`y' & female==`g' using "$dir4/otos2"
			display `y' `g'
			qui bootstrap (r(between_T)): theildeco hhincdeq, byg(par3)
			matrix m1 = r(table)
			scalar b1 = m1[1,1]
			scalar l1 = m1[5,1]
			scalar h1 = m1[6,1]
			file write res %4s "`y'" _tab %7,5f (b1) _tab ///
				%7,5f (l1) _tab %7,5f (h1) _n
			}
		}
file close res

file open res using "$dir5/Theil-cumul4.txt", write replace
	file write res "year" _tab "between" _tab "low" _tab "high" _n
	forvalues g = 0/1 {
		forvalues y = 1991/2014 {
			use if vuosi==`y' & female==`g' using "$dir4/otos2"
			display `y' `g'
			qui bootstrap (r(between_T)): theildeco hhincdeq, byg(chi4)
			matrix m1 = r(table)
			scalar b1 = m1[1,1]
			scalar l1 = m1[5,1]
			scalar h1 = m1[6,1]
			file write res %4s "`y'" _tab %7,5f (b1) _tab ///
				%7,5f (l1) _tab %7,5f (h1) _n
			}
		}
file close res

file open res using "$dir5/Theil-cumul5.txt", write replace
	file write res "year" _tab "between" _tab "low" _tab "high" _n
	forvalues g = 0/1 {
		forvalues y = 1991/2014 {
			use if vuosi==`y' & female==`g' using "$dir4/otos2"
			display `y' `g'
			qui bootstrap (r(between_T)): theildeco hhincdeq, byg(sem5)
			matrix m1 = r(table)
			scalar b1 = m1[1,1]
			scalar l1 = m1[5,1]
			scalar h1 = m1[6,1]
			file write res %4s "`y'" _tab %7,5f (b1) _tab ///
				%7,5f (l1) _tab %7,5f (h1) _n
			}
		}
file close res

file open res using "$dir5/Theil-cumul6.txt", write replace
	file write res "year" _tab "between" _tab "low" _tab "high" _n
	forvalues g = 0/1 {
		forvalues y = 1991/2014 {
			use if vuosi==`y' & female==`g' using "$dir4/otos2"
			display `y' `g'
			qui bootstrap (r(between_T)): theildeco hhincdeq, byg(sed6)
			matrix m1 = r(table)
			scalar b1 = m1[1,1]
			scalar l1 = m1[5,1]
			scalar h1 = m1[6,1]
			file write res %4s "`y'" _tab %7,5f (b1) _tab ///
				%7,5f (l1) _tab %7,5f (h1) _n
			}
		}file close res

***These results not included in the figures

file open res using "$dir5/Theil-cumul7.txt", write replace
	file write res "year" _tab "between" _tab "low" _tab "high" _n
	forvalues g = 0/1 {
		forvalues y = 1991/2014 {
			use if vuosi==`y' & female==`g' using "$dir4/otos2"
			display `y' `g'
			qui bootstrap (r(between_T)): theildeco hhincdeq, byg(sor7)
			matrix m1 = r(table)
			scalar b1 = m1[1,1]
			scalar l1 = m1[5,1]
			scalar h1 = m1[6,1]
			file write res %4s "`y'" _tab %7,5f (b1) _tab ///
				%7,5f (l1) _tab %7,5f (h1) _n
			}
		}
file close res
	
file open res using "$dir5/Theil-cumul8.txt", write replace
	file write res "year" _tab "between" _tab "low" _tab "high" _n
	forvalues g = 0/1 {
		forvalues y = 1991/2014 {
			use if vuosi==`y' & female==`g' using "$dir4/otos2"
			display `y' `g'
			qui bootstrap (r(between_T)): theildeco hhincdeq, byg(or8)
			matrix m1 = r(table)
			scalar b1 = m1[1,1]
			scalar l1 = m1[5,1]
			scalar h1 = m1[6,1]
			file write res %4s "`y'" _tab %7,5f (b1) _tab ///
				%7,5f (l1) _tab %7,5f (h1) _n
			}
		}
file close res
