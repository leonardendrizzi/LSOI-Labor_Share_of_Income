********Labor share of income: an empirical analysis*******
/* Leonardo Endrizzi, Samuli Salonen, Francisco Alvarez */
*Preamble
clear all
ssc install estout, replace //For Latex writing
ssc install outreg2 //for results
net sj 3-2 st0039         
net install st0039    

cd "SET DIRECTORY"
**Opening the dataset from directory with data from Penn World Table
use "pwt100.dta"

***Merging the datasets from two sources (ILOSTAT, WORLD BANK AND PWT)
merge 1:1 country year using "ilostat_lsoi.dta"

***Dropping data from years before 2004, we drop the variable lsoi==. since the data we have is only since 2004
drop if lsoi==.

***Dummy for year of crisis, we chose 2009 after looking at the data
generate crisis = 0 
replace crisis = 1 if year==2009

***Creating the variable openess
gen openess= csh_x+csh_m

****************Declaring panel****************
encode country, gen(id_country)
xtset id_country year

***World labor share of income dynamics
label var lsoi "Labor Share of Income"
egen wlsoi = mean(lsoi), by(year)
label var wlsoi "Mean for the World Labor Share of Income"
egen incomelsoi = mean(lsoi), by(year incomegroup)
label var incomelsoi "World Labor Share of Income by Incomegroup"
egen regionlsoi = mean(lsoi), by(year Region)
label var regionlsoi "World Labor Share of Income by Region"

***Trend World Labor Share of Income graph
twoway (line wlsoi year,sort), xtitle("Year") ytitle("Percentage") xlabel(,labsize(small)) ylabel(,labsize(small))  note("Source: Own elaboration with data from International Labor Organization (1/10/2022), and PWT" ) scheme(s2mono)
graph export "$out\World.png", replace

****Heterogenety of LSOI accross years
twoway scatter lsoi year, msymbol(circle_hollow) || connected wlsoi year, msymbol(diamond) || , xtitle("Year") ytitle("Percentage") xlabel(,labsize(small)) ylabel(,labsize(small)) note("Source: Own elaboration with data from International Labor Organization (1/10/2022), and PWT") scheme(s2mono)
graph export "$out\heterogenety.png", replace

***Graphing LSOI by Incomegroup
twoway connected incomelsoi year if incomegroup=="High income", sort || connected incomelsoi year if incomegroup == "Low income", sort || connected incomelsoi year if incomegroup == "Lower middle income", sort || connected incomelsoi year if incomegroup == "Upper middle income", sort legend(order(1 "High income" 2 "Low income" 3 "Lower middle income" 4 "Upper middle income")) xtitle("Year") ytitle("Percentage") xlabel(,labsize(small)) ylabel(,labsize(small)) note("Source: Own elaboration with data from International Labor Organization (1/10/2022), and PWT") scheme(s2mono)
graph export "$out\Income.png", replace

***Graphing LSOI by Region
twoway connected regionlsoi year if Region=="East Asia & Pacific", sort || connected regionlsoi year if Region == "Europe & Central Asia", sort || connected regionlsoi year if Region == "Latin America & Caribbean", sort || connected regionlsoi year if Region == "Middle East & North Africa", sort || connected regionlsoi year if Region == "North America", sort || connected regionlsoi year if Region == "South Asia", sort || connected regionlsoi year if Region == "Sub-Saharan Africa", sort legend(order(1 "East Asia & Pacific" 2 "Europe & Central Asia" 3 "Latin America & Caribbean" 4 "Middle East & North Africa" 5 "North America" 6 "South Asia" 7 "Sub-Saharan Africa")) xtitle("Year") ytitle("Percentage") xlabel(,labsize(small)) ylabel(,labsize(small)) note("Source: Own elaboration with data from International Labor Organization (1/10/2022), and PWT") scheme(s2mono)
graph export "$out\Region.png", replace

***Graphing for all countries
xtline lsoi if id_country>150  & id_country<=180 , xtitle("Year") ytitle("Percentage") xlabel(,labsize(small)) ylabel(,labsize(small))  byopts(note("Source: Elaborated data from International Labor Organization (1/10/2022)" )) scheme(s2mono)

xtline lsoi if id_country>120  & id_country<=153 , xtitle("Year") ytitle("Percentage") xlabel(,labsize(small)) ylabel(,labsize(small))  byopts(note("Source: Elaborated data from International Labor Organization (1/10/2022)" )) scheme(s2mono)

xtline lsoi if id_country>90  & id_country<=120 , xtitle("Year") ytitle("Percentage") xlabel(,labsize(small)) ylabel(,labsize(small))  byopts(note("Source: Elaborated data from International Labor Organization (1/10/2022)" )) scheme(s2mono)

xtline lsoi if id_country>60  & id_country<=90 , xtitle("Year") ytitle("Percentage") xlabel(,labsize(small)) ylabel(,labsize(small))  byopts(note("Source: Elaborated data from International Labor Organization (1/10/2022)" )) scheme(s2mono)

xtline lsoi if id_country>30  & id_country<=60 , xtitle("Year") ytitle("Percentage") xlabel(,labsize(small)) ylabel(,labsize(small))  byopts(note("Source: Elaborated data from International Labor Organization (1/10/2022)" )) scheme(s2mono)

xtline lsoi if id_country<=30, xtitle("Year") ytitle("Percentage") xlabel(,labsize(small)) ylabel(,labsize(small))  byopts(note("Source: Elaborated data from International Labor Organization (1/10/2022)" )) scheme(s2mono)

***Generating means for each year
egen tfpme = mean(ctfp), by(year)
label var tfpme "Mean tfpme"

***Generating dummy variable for values above the mean
generate dtfp=0 
replace dtfp = 1 if (ctfp>tfpme & ctfp!=.)
label var dtfp "Dummy variable tfp above the mean"

***Generating Capital intensity which is defined as real capital stock divided by number of people engaged.
generate capitalint=cn/emp
label var capitalint "Capital intensity defined as real capital stock divided by number of people engaged"

***Generating Log of Capital intensity which is defined as real capital stock divided by number of people engaged
generate lcapitalint=log(capitalint)
label var lcapitalint "Log of capital intensity"

***Generating the log of the TFP
generate lctfp=log(ctfp)
label var lctfp "Log of TFP"

***Summary statistics for lsoi and general
xtsum lsoi

est clear  // clear the stored estimates
estpost tabstat lsoi dtfp openess lcapitalint, statistics(mean sd min max) columns(statistics)
ereturn list // list the stored locals
esttab using sum.tex,replace  ///
   cells("mean(fmt(%6.2fc)) sd(fmt(%6.2fc)) min max") nonumber ///
   nomtitle nonote noobs collabels("Mean" "SD" "Min" "Max")
***Summary statistics by Region
est clear  // clear the stored estimates
estpost tabstat lsoi rgdpna ctfp openess lcapitalint, by(Region) statistics(mean sd min max) columns(statistics)
ereturn list // list the stored locals
esttab using descregion.tex,replace  ///
   cells("mean(fmt(%6.2fc)) sd(fmt(%6.2fc)) min max") nonumber ///
   nomtitle nonote noobs collabels("Mean" "SD" "Min" "Max")

***Summary statistics by Incomegroup
est clear  // clear the stored estimates
estpost tabstat lsoi rgdpna ctfp openess lcapitalint, by(incomegroup) statistics(mean sd min max) columns(statistics)
ereturn list // list the stored locals
esttab using descincome.tex,replace  ///
   cells("mean(fmt(%6.2fc)) sd(fmt(%6.2fc)) min max") nonumber ///
   nomtitle nonote noobs collabels("Mean" "SD" "Min" "Max")
   
***REGRESSIONS WITH POOLED RE FE****
reg lsoi openess dtfp lcapitalint,robust
outreg2 using firstreg.tex, replace ctitle(OLS)
estimates store ols //storing estimates
xtreg lsoi openess dtfp lcapitalint, re robust
outreg2 using firstreg.tex, append ctitle(Random Effects)
estimates store re
xtreg lsoi openess dtfp lcapitalint, fe robust
outreg2 using firstreg.tex, append ctitle(Fixed Effects) 
estimates store fe
hausman fe re //running hausman test, we reject the null hypothesis that the difference in the coefficients is not systematic, so the fixed effects model is more appropriate
estimates table ols fe re, se //comparison of different estimated results


***REGRESSIONS WITH POOLED RE FE and crisis****
reg lsoi openess dtfp lcapitalint crisis,robust
outreg2 using secondreg.tex, replace ctitle(OLS)
estimates store ols //storing estimates
xtreg lsoi openess dtfp lcapitalint crisis, re robust
outreg2 using secondreg.tex, append ctitle(Random Effects)
estimates store re
xtreg lsoi openess dtfp lcapitalint crisis, fe robust
outreg2 using secondreg.tex, append ctitle(Fixed Effects) 
estimates store fe
hausman fe re /*running hausman test, we reject the null hypothesis that the difference in the coefficients is not systematic so the fixed effects model is more appropriate */
estimates table ols fe re, se //comparison of different estimated results

*****Generating dummy for incomegroup 
encode incomegroup, generate(incg)
egen highwlsoi = mean(lsoi) if incomegroup== "High income", by(year) 
egen lowwlsoi = mean(lsoi) if incomegroup== "Low income", by(year) 
egen lowmidwlsoi = mean(lsoi) if incomegroup== "Lower middle income", by(year) 
egen uppmidwlsoi = mean(lsoi) if incomegroup== "Upper middle income", by(year)

***REGRESSIONS WITH POOLED RE FE for incomegroup******

reg lsoi openess dtfp lcapitalint incg crisis,robust
outreg2 using thirdreg.tex, replace ctitle(OLS)
estimates store ols //storing estimates
xtreg lsoi openess dtfp lcapitalint incg crisis, re robust
outreg2 using thirdreg.tex, append ctitle(Random Effects)
estimates store re
xtreg lsoi openess dtfp lcapitalint incg crisis, fe robust
outreg2 using thirdreg.tex, append ctitle(Fixed Effects) 
estimates store fe
hausman fe re //running hausman test, we reject the null hypothesis that the difference in the coefficients is not systematic, so the fixed effects model is more appropriate
estimates table ols fe re, se //comparison of different estimated results

***heteroskedasticity test on our basic model
xtreg lsoi openess dtfp lcapitalint, fe

xtgls lsoi openess dtfp lcapitalint, panels(heteroskedastic)
estimates store hetero

**Autocorrelation test
xtserial lsoi openess dtfp lcapitalint

****Ommited variable test for basic regression
quietly reg lsoi openess dtfp lcapitalint incg crisis,robust
estat ovtest



