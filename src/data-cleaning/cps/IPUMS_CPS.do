version 13.0
set more off
clear
capture log close
log using IPUMS_CPS.log, replace

global datpath "../../../data/cps/raw/"
global clnpath "../../../data/cps/cleaned/"

!gunzip -f ${datpath}cps_00018.dat.gz
quietly infix              ///
  int     year      1-4    ///
  long    serial    5-9    ///
  byte    month     10-11  ///
  double  cpsid     12-25  ///
  byte    asecflag  26-26  ///
  byte    hflag     27-27  ///
  double  asecwth   28-38  ///
  byte    pernum    39-40  ///
  double  cpsidp    41-54  ///
  double  asecwt    55-65  ///
  byte    age       66-67  ///
  byte    sex       68-68  ///
  int     race      69-71  ///
  int     occ2010   72-75  ///
  int     ind       76-79  ///
  int     educ      80-82  ///
  byte    educ99    83-84  ///
  using `"${datpath}cps_00018.dat"'
!gzip -f ${datpath}cps_00018.dat

gen hwtsupp  = asecwth  / 10000
gen wtsupp   = asecwt   / 10000

format hwtsupp  %11.4f
format cpsid    %14.0f
format cpsidp   %14.0f
format wtsupp   %11.4f

label var year     `"Survey year"'
label var serial   `"Household serial number"'
label var hwtsupp  `"Household weight, Supplement"'
label var cpsid    `"CPSID, household record"'
label var asecflag `"Flag for ASEC"'
label var hflag    `"Flag for the 3/8 file 2014"'
label var month    `"Month"'
label var pernum   `"Person number in sample unit"'
label var cpsidp   `"CPSID, person record"'
label var wtsupp   `"Supplement Weight"'
label var age      `"Age"'
label var sex      `"Sex"'
label var race     `"Race"'
label var educ     `"Educational attainment recode"'
label var educ99   `"Educational attainment, 1990"'
label var occ2010  `"Occupation, 2010 basis"'
label var ind      `"Industry"'

label define asecflag_lbl 1 `"ASEC"'
label define asecflag_lbl 2 `"March Basic"', add
label values asecflag asecflag_lbl

label define hflag_lbl 0 `"5/8 file"'
label define hflag_lbl 1 `"3/8 file"', add
label values hflag hflag_lbl

label define month_lbl 01 `"January"'
label define month_lbl 02 `"February"', add
label define month_lbl 03 `"March"', add
label define month_lbl 04 `"April"', add
label define month_lbl 05 `"May"', add
label define month_lbl 06 `"June"', add
label define month_lbl 07 `"July"', add
label define month_lbl 08 `"August"', add
label define month_lbl 09 `"September"', add
label define month_lbl 10 `"October"', add
label define month_lbl 11 `"November"', add
label define month_lbl 12 `"December"', add
label values month month_lbl

label define age_lbl 00 `"Under 1 year"'
label define age_lbl 01 `"1"', add
label define age_lbl 02 `"2"', add
label define age_lbl 03 `"3"', add
label define age_lbl 04 `"4"', add
label define age_lbl 05 `"5"', add
label define age_lbl 06 `"6"', add
label define age_lbl 07 `"7"', add
label define age_lbl 08 `"8"', add
label define age_lbl 09 `"9"', add
label define age_lbl 10 `"10"', add
label define age_lbl 11 `"11"', add
label define age_lbl 12 `"12"', add
label define age_lbl 13 `"13"', add
label define age_lbl 14 `"14"', add
label define age_lbl 15 `"15"', add
label define age_lbl 16 `"16"', add
label define age_lbl 17 `"17"', add
label define age_lbl 18 `"18"', add
label define age_lbl 19 `"19"', add
label define age_lbl 20 `"20"', add
label define age_lbl 21 `"21"', add
label define age_lbl 22 `"22"', add
label define age_lbl 23 `"23"', add
label define age_lbl 24 `"24"', add
label define age_lbl 25 `"25"', add
label define age_lbl 26 `"26"', add
label define age_lbl 27 `"27"', add
label define age_lbl 28 `"28"', add
label define age_lbl 29 `"29"', add
label define age_lbl 30 `"30"', add
label define age_lbl 31 `"31"', add
label define age_lbl 32 `"32"', add
label define age_lbl 33 `"33"', add
label define age_lbl 34 `"34"', add
label define age_lbl 35 `"35"', add
label define age_lbl 36 `"36"', add
label define age_lbl 37 `"37"', add
label define age_lbl 38 `"38"', add
label define age_lbl 39 `"39"', add
label define age_lbl 40 `"40"', add
label define age_lbl 41 `"41"', add
label define age_lbl 42 `"42"', add
label define age_lbl 43 `"43"', add
label define age_lbl 44 `"44"', add
label define age_lbl 45 `"45"', add
label define age_lbl 46 `"46"', add
label define age_lbl 47 `"47"', add
label define age_lbl 48 `"48"', add
label define age_lbl 49 `"49"', add
label define age_lbl 50 `"50"', add
label define age_lbl 51 `"51"', add
label define age_lbl 52 `"52"', add
label define age_lbl 53 `"53"', add
label define age_lbl 54 `"54"', add
label define age_lbl 55 `"55"', add
label define age_lbl 56 `"56"', add
label define age_lbl 57 `"57"', add
label define age_lbl 58 `"58"', add
label define age_lbl 59 `"59"', add
label define age_lbl 60 `"60"', add
label define age_lbl 61 `"61"', add
label define age_lbl 62 `"62"', add
label define age_lbl 63 `"63"', add
label define age_lbl 64 `"64"', add
label define age_lbl 65 `"65"', add
label define age_lbl 66 `"66"', add
label define age_lbl 67 `"67"', add
label define age_lbl 68 `"68"', add
label define age_lbl 69 `"69"', add
label define age_lbl 70 `"70"', add
label define age_lbl 71 `"71"', add
label define age_lbl 72 `"72"', add
label define age_lbl 73 `"73"', add
label define age_lbl 74 `"74"', add
label define age_lbl 75 `"75"', add
label define age_lbl 76 `"76"', add
label define age_lbl 77 `"77"', add
label define age_lbl 78 `"78"', add
label define age_lbl 79 `"79"', add
label define age_lbl 80 `"80"', add
label define age_lbl 81 `"81"', add
label define age_lbl 82 `"82"', add
label define age_lbl 83 `"83"', add
label define age_lbl 84 `"84"', add
label define age_lbl 85 `"85"', add
label define age_lbl 86 `"86"', add
label define age_lbl 87 `"87"', add
label define age_lbl 88 `"88"', add
label define age_lbl 89 `"89"', add
label define age_lbl 90 `"90 (90+, 1988-2002)"', add
label define age_lbl 91 `"91"', add
label define age_lbl 92 `"92"', add
label define age_lbl 93 `"93"', add
label define age_lbl 94 `"94"', add
label define age_lbl 95 `"95"', add
label define age_lbl 96 `"96"', add
label define age_lbl 97 `"97"', add
label define age_lbl 98 `"98"', add
label define age_lbl 99 `"99+"', add
label values age age_lbl

label define sex_lbl 1 `"Male"'
label define sex_lbl 2 `"Female"', add
label define sex_lbl 9 `"NIU"', add
label values sex sex_lbl

label define race_lbl 100 `"White"'
label define race_lbl 200 `"Black/Negro"', add
label define race_lbl 300 `"American Indian/Aleut/Eskimo"', add
label define race_lbl 650 `"Asian or Pacific Islander"', add
label define race_lbl 651 `"Asian only"', add
label define race_lbl 652 `"Hawaiian/Pacific Islander only"', add
label define race_lbl 700 `"Other (single) race, n.e.c."', add
label define race_lbl 801 `"White-Black"', add
label define race_lbl 802 `"White-American Indian"', add
label define race_lbl 803 `"White-Asian"', add
label define race_lbl 804 `"White-Hawaiian/Pacific Islander"', add
label define race_lbl 805 `"Black-American Indian"', add
label define race_lbl 806 `"Black-Asian"', add
label define race_lbl 807 `"Black-Hawaiian/Pacific Islander"', add
label define race_lbl 808 `"American Indian-Asian"', add
label define race_lbl 809 `"Asian-Hawaiian/Pacific Islander"', add
label define race_lbl 810 `"White-Black-American Indian"', add
label define race_lbl 811 `"White-Black-Asian"', add
label define race_lbl 812 `"White-American Indian-Asian"', add
label define race_lbl 813 `"White-Asian-Hawaiian/Pacific Islander"', add
label define race_lbl 814 `"White-Black-American Indian-Asian"', add
label define race_lbl 815 `"American Indian-Hawaiian/Pacific Islander"', add
label define race_lbl 816 `"White-Black--Hawaiian/Pacific Islander"', add
label define race_lbl 817 `"White-American Indian-Hawaiian/Pacific Islander"', add
label define race_lbl 818 `"Black-American Indian-Asian"', add
label define race_lbl 819 `"White-American Indian-Asian-Hawaiian/Pacific Islander"', add
label define race_lbl 820 `"Two or three races, unspecified"', add
label define race_lbl 830 `"Four or five races, unspecified"', add
label define race_lbl 999 `"Blank"', add
label values race race_lbl

label define educ_lbl 000 `"NIU or no schooling"'
label define educ_lbl 001 `"NIU or blank"', add
label define educ_lbl 002 `"None or preschool"', add
label define educ_lbl 010 `"Grades 1, 2, 3, or 4"', add
label define educ_lbl 011 `"Grade 1"', add
label define educ_lbl 012 `"Grade 2"', add
label define educ_lbl 013 `"Grade 3"', add
label define educ_lbl 014 `"Grade 4"', add
label define educ_lbl 020 `"Grades 5 or 6"', add
label define educ_lbl 021 `"Grade 5"', add
label define educ_lbl 022 `"Grade 6"', add
label define educ_lbl 030 `"Grades 7 or 8"', add
label define educ_lbl 031 `"Grade 7"', add
label define educ_lbl 032 `"Grade 8"', add
label define educ_lbl 040 `"Grade 9"', add
label define educ_lbl 050 `"Grade 10"', add
label define educ_lbl 060 `"Grade 11"', add
label define educ_lbl 070 `"Grade 12"', add
label define educ_lbl 071 `"12th grade, no diploma"', add
label define educ_lbl 072 `"12th grade, diploma unclear"', add
label define educ_lbl 073 `"High school diploma or equivalent"', add
label define educ_lbl 080 `"1 year of college"', add
label define educ_lbl 081 `"Some college but no degree"', add
label define educ_lbl 090 `"2 years of college"', add
label define educ_lbl 091 `"Associates degree, occupational/vocational program"', add
label define educ_lbl 092 `"Associates degree, academic program"', add
label define educ_lbl 100 `"3 years of college"', add
label define educ_lbl 110 `"4 years of college"', add
label define educ_lbl 111 `"Bachelors degree"', add
label define educ_lbl 120 `"5+ years of college"', add
label define educ_lbl 121 `"5 years of college"', add
label define educ_lbl 122 `"6+ years of college"', add
label define educ_lbl 123 `"Masters degree"', add
label define educ_lbl 124 `"Professional school degree"', add
label define educ_lbl 125 `"Doctorate degree"', add
label define educ_lbl 999 `"Missing/Unknown"', add
label values educ educ_lbl

label define educ99_lbl 00 `"NIU"'
label define educ99_lbl 01 `"No school completed"', add
label define educ99_lbl 04 `"1st-4th grade"', add
label define educ99_lbl 05 `"5th-8th grade"', add
label define educ99_lbl 06 `"9th grade"', add
label define educ99_lbl 07 `"10th grade"', add
label define educ99_lbl 08 `"11th grade"', add
label define educ99_lbl 09 `"12th grade, no diploma"', add
label define educ99_lbl 10 `"High school graduate, or GED"', add
label define educ99_lbl 11 `"Some college, no degree"', add
label define educ99_lbl 12 `"Associate degree, type of program not specified"', add
label define educ99_lbl 13 `"Associate degree, occupational program"', add
label define educ99_lbl 14 `"Associate degree, academic program"', add
label define educ99_lbl 15 `"Bachelors degree"', add
label define educ99_lbl 16 `"Masters degree"', add
label define educ99_lbl 17 `"Professional degree"', add
label define educ99_lbl 18 `"Doctorate degree"', add
label values educ99 educ99_lbl

label define occ2010_lbl 0010 `"Chief executives and legislators/public administration"'
label define occ2010_lbl 0020 `"General and Operations Managers"', add
label define occ2010_lbl 0030 `"Managers in Marketing, Advertising, and Public Relations"', add
label define occ2010_lbl 0100 `"Administrative Services Managers"', add
label define occ2010_lbl 0110 `"Computer and Information Systems Managers"', add
label define occ2010_lbl 0120 `"Financial Managers"', add
label define occ2010_lbl 0130 `"Human Resources Managers"', add
label define occ2010_lbl 0140 `"Industrial Production Managers"', add
label define occ2010_lbl 0150 `"Purchasing Managers"', add
label define occ2010_lbl 0160 `"Transportation, Storage, and Distribution Managers"', add
label define occ2010_lbl 0205 `"Farmers, Ranchers, and Other Agricultural Managers"', add
label define occ2010_lbl 0220 `"Constructions Managers"', add
label define occ2010_lbl 0230 `"Education Administrators"', add
label define occ2010_lbl 0300 `"Architectural and Engineering Managers"', add
label define occ2010_lbl 0310 `"Food Service and Lodging Managers"', add
label define occ2010_lbl 0320 `"Funeral Directors"', add
label define occ2010_lbl 0330 `"Gaming Managers"', add
label define occ2010_lbl 0350 `"Medical and Health Services Managers"', add
label define occ2010_lbl 0360 `"Natural Science Managers"', add
label define occ2010_lbl 0410 `"Property, Real Estate, and Community Association Managers"', add
label define occ2010_lbl 0420 `"Social and Community Service Managers"', add
label define occ2010_lbl 0430 `"Managers, nec (including Postmasters)"', add
label define occ2010_lbl 0500 `"Agents and Business Managers of Artists, Performers, and Athletes"', add
label define occ2010_lbl 0510 `"Buyers and Purchasing Agents, Farm Products"', add
label define occ2010_lbl 0520 `"Wholesale and Retail Buyers, Except Farm Products"', add
label define occ2010_lbl 0530 `"Purchasing Agents, Except Wholesale, Retail, and Farm Products"', add
label define occ2010_lbl 0540 `"Claims Adjusters, Appraisers, Examiners, and Investigators"', add
label define occ2010_lbl 0560 `"Compliance Officers, Except Agriculture"', add
label define occ2010_lbl 0600 `"Cost Estimators"', add
label define occ2010_lbl 0620 `"Human Resources, Training, and Labor Relations Specialists"', add
label define occ2010_lbl 0700 `"Logisticians"', add
label define occ2010_lbl 0710 `"Management Analysts"', add
label define occ2010_lbl 0720 `"Meeting and Convention Planners"', add
label define occ2010_lbl 0730 `"Other Business Operations and Management Specialists"', add
label define occ2010_lbl 0800 `"Accountants and Auditors"', add
label define occ2010_lbl 0810 `"Appraisers and Assessors of Real Estate"', add
label define occ2010_lbl 0820 `"Budget Analysts"', add
label define occ2010_lbl 0830 `"Credit Analysts"', add
label define occ2010_lbl 0840 `"Financial Analysts"', add
label define occ2010_lbl 0850 `"Personal Financial Advisors"', add
label define occ2010_lbl 0860 `"Insurance Underwriters"', add
label define occ2010_lbl 0900 `"Financial Examiners"', add
label define occ2010_lbl 0910 `"Credit Counselors and Loan Officers"', add
label define occ2010_lbl 0930 `"Tax Examiners and Collectors, and Revenue Agents"', add
label define occ2010_lbl 0940 `"Tax Preparers"', add
label define occ2010_lbl 0950 `"Financial Specialists, nec"', add
label define occ2010_lbl 1000 `"Computer Scientists and Systems Analysts/Network systems Analysts/Web Developers"', add
label define occ2010_lbl 1010 `"Computer Programmers"', add
label define occ2010_lbl 1020 `"Software Developers, Applications and Systems Software"', add
label define occ2010_lbl 1050 `"Computer Support Specialists"', add
label define occ2010_lbl 1060 `"Database Administrators"', add
label define occ2010_lbl 1100 `"Network and Computer Systems Administrators"', add
label define occ2010_lbl 1200 `"Actuaries"', add
label define occ2010_lbl 1220 `"Operations Research Analysts"', add
label define occ2010_lbl 1230 `"Statisticians"', add
label define occ2010_lbl 1240 `"Mathematical science occupations, nec"', add
label define occ2010_lbl 1300 `"Architects, Except Naval"', add
label define occ2010_lbl 1310 `"Surveyors, Cartographers, and Photogrammetrists"', add
label define occ2010_lbl 1320 `"Aerospace Engineers"', add
label define occ2010_lbl 1350 `"Chemical Engineers"', add
label define occ2010_lbl 1360 `"Civil Engineers"', add
label define occ2010_lbl 1400 `"Computer Hardware Engineers"', add
label define occ2010_lbl 1410 `"Electrical and Electronics Engineers"', add
label define occ2010_lbl 1420 `"Environmental Engineers"', add
label define occ2010_lbl 1430 `"Industrial Engineers, including Health and Safety"', add
label define occ2010_lbl 1440 `"Marine Engineers and Naval Architects"', add
label define occ2010_lbl 1450 `"Materials Engineers"', add
label define occ2010_lbl 1460 `"Mechanical Engineers"', add
label define occ2010_lbl 1520 `"Petroleum, mining and geological engineers, including mining safety engineers"', add
label define occ2010_lbl 1530 `"Engineers, nec"', add
label define occ2010_lbl 1540 `"Drafters"', add
label define occ2010_lbl 1550 `"Engineering Technicians, Except Drafters"', add
label define occ2010_lbl 1560 `"Surveying and Mapping Technicians"', add
label define occ2010_lbl 1600 `"Agricultural and Food Scientists"', add
label define occ2010_lbl 1610 `"Biological Scientists"', add
label define occ2010_lbl 1640 `"Conservation Scientists and Foresters"', add
label define occ2010_lbl 1650 `"Medical Scientists, and Life Scientists, All Other"', add
label define occ2010_lbl 1700 `"Astronomers and Physicists"', add
label define occ2010_lbl 1710 `"Atmospheric and Space Scientists"', add
label define occ2010_lbl 1720 `"Chemists and Materials Scientists"', add
label define occ2010_lbl 1740 `"Environmental Scientists and Geoscientists"', add
label define occ2010_lbl 1760 `"Physical Scientists, nec"', add
label define occ2010_lbl 1800 `"Economists and market researchers"', add
label define occ2010_lbl 1820 `"Psychologists"', add
label define occ2010_lbl 1830 `"Urban and Regional Planners"', add
label define occ2010_lbl 1840 `"Social Scientists, nec"', add
label define occ2010_lbl 1900 `"Agricultural and Food Science Technicians"', add
label define occ2010_lbl 1910 `"Biological Technicians"', add
label define occ2010_lbl 1920 `"Chemical Technicians"', add
label define occ2010_lbl 1930 `"Geological and Petroleum Technicians, and Nuclear Technicians"', add
label define occ2010_lbl 1960 `"Life, Physical, and Social Science Technicians, nec"', add
label define occ2010_lbl 1980 `"Professional, Research, or Technical Workers, nec"', add
label define occ2010_lbl 2000 `"Counselors"', add
label define occ2010_lbl 2010 `"Social Workers"', add
label define occ2010_lbl 2020 `"Community and Social Service Specialists, nec"', add
label define occ2010_lbl 2040 `"Clergy"', add
label define occ2010_lbl 2050 `"Directors, Religious Activities and Education"', add
label define occ2010_lbl 2060 `"Religious Workers, nec"', add
label define occ2010_lbl 2100 `"Lawyers, and judges, magistrates, and other judicial workers"', add
label define occ2010_lbl 2140 `"Paralegals and Legal Assistants"', add
label define occ2010_lbl 2150 `"Legal Support Workers, nec"', add
label define occ2010_lbl 2200 `"Postsecondary Teachers"', add
label define occ2010_lbl 2300 `"Preschool and Kindergarten Teachers"', add
label define occ2010_lbl 2310 `"Elementary and Middle School Teachers"', add
label define occ2010_lbl 2320 `"Secondary School Teachers"', add
label define occ2010_lbl 2330 `"Special Education Teachers"', add
label define occ2010_lbl 2340 `"Other Teachers and Instructors"', add
label define occ2010_lbl 2400 `"Archivists, Curators, and Museum Technicians"', add
label define occ2010_lbl 2430 `"Librarians"', add
label define occ2010_lbl 2440 `"Library Technicians"', add
label define occ2010_lbl 2540 `"Teacher Assistants"', add
label define occ2010_lbl 2550 `"Education, Training, and Library Workers, nec"', add
label define occ2010_lbl 2600 `"Artists and Related Workers"', add
label define occ2010_lbl 2630 `"Designers"', add
label define occ2010_lbl 2700 `"Actors, Producers, and Directors"', add
label define occ2010_lbl 2720 `"Athletes, Coaches, Umpires, and Related Workers"', add
label define occ2010_lbl 2740 `"Dancers and Choreographers"', add
label define occ2010_lbl 2750 `"Musicians, Singers, and Related Workers"', add
label define occ2010_lbl 2760 `"Entertainers and Performers, Sports and Related Workers, All Other"', add
label define occ2010_lbl 2800 `"Announcers"', add
label define occ2010_lbl 2810 `"Editors, News Analysts, Reporters, and Correspondents"', add
label define occ2010_lbl 2825 `"Public Relations Specialists"', add
label define occ2010_lbl 2840 `"Technical Writers"', add
label define occ2010_lbl 2850 `"Writers and Authors"', add
label define occ2010_lbl 2860 `"Media and Communication Workers, nec"', add
label define occ2010_lbl 2900 `"Broadcast and Sound Engineering Technicians and Radio Operators, and media and communication equipment workers, all other"', add
label define occ2010_lbl 2910 `"Photographers"', add
label define occ2010_lbl 2920 `"Television, Video, and Motion Picture Camera Operators and Editors"', add
label define occ2010_lbl 3000 `"Chiropractors"', add
label define occ2010_lbl 3010 `"Dentists"', add
label define occ2010_lbl 3030 `"Dieticians and Nutritionists"', add
label define occ2010_lbl 3040 `"Optometrists"', add
label define occ2010_lbl 3050 `"Pharmacists"', add
label define occ2010_lbl 3060 `"Physicians and Surgeons"', add
label define occ2010_lbl 3110 `"Physician Assistants"', add
label define occ2010_lbl 3120 `"Podiatrists"', add
label define occ2010_lbl 3130 `"Registered Nurses"', add
label define occ2010_lbl 3140 `"Audiologists"', add
label define occ2010_lbl 3150 `"Occupational Therapists"', add
label define occ2010_lbl 3160 `"Physical Therapists"', add
label define occ2010_lbl 3200 `"Radiation Therapists"', add
label define occ2010_lbl 3210 `"Recreational Therapists"', add
label define occ2010_lbl 3220 `"Respiratory Therapists"', add
label define occ2010_lbl 3230 `"Speech Language Pathologists"', add
label define occ2010_lbl 3240 `"Therapists, nec"', add
label define occ2010_lbl 3250 `"Veterinarians"', add
label define occ2010_lbl 3260 `"Health Diagnosing and Treating Practitioners, nec"', add
label define occ2010_lbl 3300 `"Clinical Laboratory Technologists and Technicians"', add
label define occ2010_lbl 3310 `"Dental Hygienists"', add
label define occ2010_lbl 3320 `"Diagnostic Related Technologists and Technicians"', add
label define occ2010_lbl 3400 `"Emergency Medical Technicians and Paramedics"', add
label define occ2010_lbl 3410 `"Health Diagnosing and Treating Practitioner Support Technicians"', add
label define occ2010_lbl 3500 `"Licensed Practical and Licensed Vocational Nurses"', add
label define occ2010_lbl 3510 `"Medical Records and Health Information Technicians"', add
label define occ2010_lbl 3520 `"Opticians, Dispensing"', add
label define occ2010_lbl 3530 `"Health Technologists and Technicians, nec"', add
label define occ2010_lbl 3540 `"Healthcare Practitioners and Technical Occupations, nec"', add
label define occ2010_lbl 3600 `"Nursing, Psychiatric, and Home Health Aides"', add
label define occ2010_lbl 3610 `"Occupational Therapy Assistants and Aides"', add
label define occ2010_lbl 3620 `"Physical Therapist Assistants and Aides"', add
label define occ2010_lbl 3630 `"Massage Therapists"', add
label define occ2010_lbl 3640 `"Dental Assistants"', add
label define occ2010_lbl 3650 `"Medical Assistants and Other Healthcare Support Occupations, nec"', add
label define occ2010_lbl 3700 `"First-Line Supervisors of Correctional Officers"', add
label define occ2010_lbl 3710 `"First-Line Supervisors of Police and Detectives"', add
label define occ2010_lbl 3720 `"First-Line Supervisors of Fire Fighting and Prevention Workers"', add
label define occ2010_lbl 3730 `"Supervisors, Protective Service Workers, All Other"', add
label define occ2010_lbl 3740 `"Firefighters"', add
label define occ2010_lbl 3750 `"Fire Inspectors"', add
label define occ2010_lbl 3800 `"Sheriffs, Bailiffs, Correctional Officers, and Jailers"', add
label define occ2010_lbl 3820 `"Police Officers and Detectives"', add
label define occ2010_lbl 3900 `"Animal Control"', add
label define occ2010_lbl 3910 `"Private Detectives and Investigators"', add
label define occ2010_lbl 3930 `"Security Guards and Gaming Surveillance Officers"', add
label define occ2010_lbl 3940 `"Crossing Guards"', add
label define occ2010_lbl 3950 `"Law enforcement workers, nec"', add
label define occ2010_lbl 4000 `"Chefs and Cooks"', add
label define occ2010_lbl 4010 `"First-Line Supervisors of Food Preparation and Serving Workers"', add
label define occ2010_lbl 4030 `"Food Preparation Workers"', add
label define occ2010_lbl 4040 `"Bartenders"', add
label define occ2010_lbl 4050 `"Combined Food Preparation and Serving Workers, Including Fast Food"', add
label define occ2010_lbl 4060 `"Counter Attendant, Cafeteria, Food Concession, and Coffee Shop"', add
label define occ2010_lbl 4110 `"Waiters and Waitresses"', add
label define occ2010_lbl 4120 `"Food Servers, Nonrestaurant"', add
label define occ2010_lbl 4130 `"Food preparation and serving related workers, nec"', add
label define occ2010_lbl 4140 `"Dishwashers"', add
label define occ2010_lbl 4150 `"Host and Hostesses, Restaurant, Lounge, and Coffee Shop"', add
label define occ2010_lbl 4200 `"First-Line Supervisors of Housekeeping and Janitorial Workers"', add
label define occ2010_lbl 4210 `"First-Line Supervisors of Landscaping, Lawn Service, and Groundskeeping Workers"', add
label define occ2010_lbl 4220 `"Janitors and Building Cleaners"', add
label define occ2010_lbl 4230 `"Maids and Housekeeping Cleaners"', add
label define occ2010_lbl 4240 `"Pest Control Workers"', add
label define occ2010_lbl 4250 `"Grounds Maintenance Workers"', add
label define occ2010_lbl 4300 `"First-Line Supervisors of Gaming Workers"', add
label define occ2010_lbl 4320 `"First-Line Supervisors of Personal Service Workers"', add
label define occ2010_lbl 4340 `"Animal Trainers"', add
label define occ2010_lbl 4350 `"Nonfarm Animal Caretakers"', add
label define occ2010_lbl 4400 `"Gaming Services Workers"', add
label define occ2010_lbl 4420 `"Ushers, Lobby Attendants, and Ticket Takers"', add
label define occ2010_lbl 4430 `"Entertainment Attendants and Related Workers, nec"', add
label define occ2010_lbl 4460 `"Funeral Service Workers and Embalmers"', add
label define occ2010_lbl 4500 `"Barbers"', add
label define occ2010_lbl 4510 `"Hairdressers, Hairstylists, and Cosmetologists"', add
label define occ2010_lbl 4520 `"Personal Appearance Workers, nec"', add
label define occ2010_lbl 4530 `"Baggage Porters, Bellhops, and Concierges"', add
label define occ2010_lbl 4540 `"Tour and Travel Guides"', add
label define occ2010_lbl 4600 `"Childcare Workers"', add
label define occ2010_lbl 4610 `"Personal Care Aides"', add
label define occ2010_lbl 4620 `"Recreation and Fitness Workers"', add
label define occ2010_lbl 4640 `"Residential Advisors"', add
label define occ2010_lbl 4650 `"Personal Care and Service Workers, All Other"', add
label define occ2010_lbl 4700 `"First-Line Supervisors of Sales Workers"', add
label define occ2010_lbl 4720 `"Cashiers"', add
label define occ2010_lbl 4740 `"Counter and Rental Clerks"', add
label define occ2010_lbl 4750 `"Parts Salespersons"', add
label define occ2010_lbl 4760 `"Retail Salespersons"', add
label define occ2010_lbl 4800 `"Advertising Sales Agents"', add
label define occ2010_lbl 4810 `"Insurance Sales Agents"', add
label define occ2010_lbl 4820 `"Securities, Commodities, and Financial Services Sales Agents"', add
label define occ2010_lbl 4830 `"Travel Agents"', add
label define occ2010_lbl 4840 `"Sales Representatives, Services, All Other"', add
label define occ2010_lbl 4850 `"Sales Representatives, Wholesale and Manufacturing"', add
label define occ2010_lbl 4900 `"Models, Demonstrators, and Product Promoters"', add
label define occ2010_lbl 4920 `"Real Estate Brokers and Sales Agents"', add
label define occ2010_lbl 4930 `"Sales Engineers"', add
label define occ2010_lbl 4940 `"Telemarketers"', add
label define occ2010_lbl 4950 `"Door-to-Door Sales Workers, News and Street Vendors, and Related Workers"', add
label define occ2010_lbl 4965 `"Sales and Related Workers, All Other"', add
label define occ2010_lbl 5000 `"First-Line Supervisors of Office and Administrative Support Workers"', add
label define occ2010_lbl 5010 `"Switchboard Operators, Including Answering Service"', add
label define occ2010_lbl 5020 `"Telephone Operators"', add
label define occ2010_lbl 5030 `"Communications Equipment Operators, All Other"', add
label define occ2010_lbl 5100 `"Bill and Account Collectors"', add
label define occ2010_lbl 5110 `"Billing and Posting Clerks"', add
label define occ2010_lbl 5120 `"Bookkeeping, Accounting, and Auditing Clerks"', add
label define occ2010_lbl 5130 `"Gaming Cage Workers"', add
label define occ2010_lbl 5140 `"Payroll and Timekeeping Clerks"', add
label define occ2010_lbl 5150 `"Procurement Clerks"', add
label define occ2010_lbl 5160 `"Bank Tellers"', add
label define occ2010_lbl 5165 `"Financial Clerks, nec"', add
label define occ2010_lbl 5200 `"Brokerage Clerks"', add
label define occ2010_lbl 5220 `"Court, Municipal, and License Clerks"', add
label define occ2010_lbl 5230 `"Credit Authorizers, Checkers, and Clerks"', add
label define occ2010_lbl 5240 `"Customer Service Representatives"', add
label define occ2010_lbl 5250 `"Eligibility Interviewers, Government Programs"', add
label define occ2010_lbl 5260 `"File Clerks"', add
label define occ2010_lbl 5300 `"Hotel, Motel, and Resort Desk Clerks"', add
label define occ2010_lbl 5310 `"Interviewers, Except Eligibility and Loan"', add
label define occ2010_lbl 5320 `"Library Assistants, Clerical"', add
label define occ2010_lbl 5330 `"Loan Interviewers and Clerks"', add
label define occ2010_lbl 5340 `"New Account Clerks"', add
label define occ2010_lbl 5350 `"Correspondent clerks and order clerks"', add
label define occ2010_lbl 5360 `"Human Resources Assistants, Except Payroll and Timekeeping"', add
label define occ2010_lbl 5400 `"Receptionists and Information Clerks"', add
label define occ2010_lbl 5410 `"Reservation and Transportation Ticket Agents and Travel Clerks"', add
label define occ2010_lbl 5420 `"Information and Record Clerks, All Other"', add
label define occ2010_lbl 5500 `"Cargo and Freight Agents"', add
label define occ2010_lbl 5510 `"Couriers and Messengers"', add
label define occ2010_lbl 5520 `"Dispatchers"', add
label define occ2010_lbl 5530 `"Meter Readers, Utilities"', add
label define occ2010_lbl 5540 `"Postal Service Clerks"', add
label define occ2010_lbl 5550 `"Postal Service Mail Carriers"', add
label define occ2010_lbl 5560 `"Postal Service Mail Sorters, Processors, and Processing Machine Operators"', add
label define occ2010_lbl 5600 `"Production, Planning, and Expediting Clerks"', add
label define occ2010_lbl 5610 `"Shipping, Receiving, and Traffic Clerks"', add
label define occ2010_lbl 5620 `"Stock Clerks and Order Fillers"', add
label define occ2010_lbl 5630 `"Weighers, Measurers, Checkers, and Samplers, Recordkeeping"', add
label define occ2010_lbl 5700 `"Secretaries and Administrative Assistants"', add
label define occ2010_lbl 5800 `"Computer Operators"', add
label define occ2010_lbl 5810 `"Data Entry Keyers"', add
label define occ2010_lbl 5820 `"Word Processors and Typists"', add
label define occ2010_lbl 5840 `"Insurance Claims and Policy Processing Clerks"', add
label define occ2010_lbl 5850 `"Mail Clerks and Mail Machine Operators, Except Postal Service"', add
label define occ2010_lbl 5860 `"Office Clerks, General"', add
label define occ2010_lbl 5900 `"Office Machine Operators, Except Computer"', add
label define occ2010_lbl 5910 `"Proofreaders and Copy Markers"', add
label define occ2010_lbl 5920 `"Statistical Assistants"', add
label define occ2010_lbl 5940 `"Office and administrative support workers, nec"', add
label define occ2010_lbl 6005 `"First-Line Supervisors of Farming, Fishing, and Forestry Workers"', add
label define occ2010_lbl 6010 `"Agricultural Inspectors"', add
label define occ2010_lbl 6040 `"Graders and Sorters, Agricultural Products"', add
label define occ2010_lbl 6050 `"Agricultural workers, nec"', add
label define occ2010_lbl 6100 `"Fishing and hunting workers"', add
label define occ2010_lbl 6120 `"Forest and Conservation Workers"', add
label define occ2010_lbl 6130 `"Logging Workers"', add
label define occ2010_lbl 6200 `"First-Line Supervisors of Construction Trades and Extraction Workers"', add
label define occ2010_lbl 6210 `"Boilermakers"', add
label define occ2010_lbl 6220 `"Brickmasons, Blockmasons, and Stonemasons"', add
label define occ2010_lbl 6230 `"Carpenters"', add
label define occ2010_lbl 6240 `"Carpet, Floor, and Tile Installers and Finishers"', add
label define occ2010_lbl 6250 `"Cement Masons, Concrete Finishers, and Terrazzo Workers"', add
label define occ2010_lbl 6260 `"Construction Laborers"', add
label define occ2010_lbl 6300 `"Paving, Surfacing, and Tamping Equipment Operators"', add
label define occ2010_lbl 6320 `"Construction equipment operators except paving, surfacing, and tamping equipment operators"', add
label define occ2010_lbl 6330 `"Drywall Installers, Ceiling Tile Installers, and Tapers"', add
label define occ2010_lbl 6355 `"Electricians"', add
label define occ2010_lbl 6360 `"Glaziers"', add
label define occ2010_lbl 6400 `"Insulation Workers"', add
label define occ2010_lbl 6420 `"Painters, Construction and Maintenance"', add
label define occ2010_lbl 6430 `"Paperhangers"', add
label define occ2010_lbl 6440 `"Pipelayers, Plumbers, Pipefitters, and Steamfitters"', add
label define occ2010_lbl 6460 `"Plasterers and Stucco Masons"', add
label define occ2010_lbl 6500 `"Reinforcing Iron and Rebar Workers"', add
label define occ2010_lbl 6515 `"Roofers"', add
label define occ2010_lbl 6520 `"Sheet Metal Workers, metal-working"', add
label define occ2010_lbl 6530 `"Structural Iron and Steel Workers"', add
label define occ2010_lbl 6600 `"Helpers, Construction Trades"', add
label define occ2010_lbl 6660 `"Construction and Building Inspectors"', add
label define occ2010_lbl 6700 `"Elevator Installers and Repairers"', add
label define occ2010_lbl 6710 `"Fence Erectors"', add
label define occ2010_lbl 6720 `"Hazardous Materials Removal Workers"', add
label define occ2010_lbl 6730 `"Highway Maintenance Workers"', add
label define occ2010_lbl 6740 `"Rail-Track Laying and Maintenance Equipment Operators"', add
label define occ2010_lbl 6765 `"Construction workers, nec"', add
label define occ2010_lbl 6800 `"Derrick, rotary drill, and service unit operators, and roustabouts, oil, gas, and mining"', add
label define occ2010_lbl 6820 `"Earth Drillers, Except Oil and Gas"', add
label define occ2010_lbl 6830 `"Explosives Workers, Ordnance Handling Experts, and Blasters"', add
label define occ2010_lbl 6840 `"Mining Machine Operators"', add
label define occ2010_lbl 6940 `"Extraction workers, nec"', add
label define occ2010_lbl 7000 `"First-Line Supervisors of Mechanics, Installers, and Repairers"', add
label define occ2010_lbl 7010 `"Computer, Automated Teller, and Office Machine Repairers"', add
label define occ2010_lbl 7020 `"Radio and Telecommunications Equipment Installers and Repairers"', add
label define occ2010_lbl 7030 `"Avionics Technicians"', add
label define occ2010_lbl 7040 `"Electric Motor, Power Tool, and Related Repairers"', add
label define occ2010_lbl 7100 `"Electrical and electronics repairers, transportation equipment, and industrial and utility"', add
label define occ2010_lbl 7110 `"Electronic Equipment Installers and Repairers, Motor Vehicles"', add
label define occ2010_lbl 7120 `"Electronic Home Entertainment Equipment Installers and Repairers"', add
label define occ2010_lbl 7125 `"Electronic Repairs, nec"', add
label define occ2010_lbl 7130 `"Security and Fire Alarm Systems Installers"', add
label define occ2010_lbl 7140 `"Aircraft Mechanics and Service Technicians"', add
label define occ2010_lbl 7150 `"Automotive Body and Related Repairers"', add
label define occ2010_lbl 7160 `"Automotive Glass Installers and Repairers"', add
label define occ2010_lbl 7200 `"Automotive Service Technicians and Mechanics"', add
label define occ2010_lbl 7210 `"Bus and Truck Mechanics and Diesel Engine Specialists"', add
label define occ2010_lbl 7220 `"Heavy Vehicle and Mobile Equipment Service Technicians and Mechanics"', add
label define occ2010_lbl 7240 `"Small Engine Mechanics"', add
label define occ2010_lbl 7260 `"Vehicle and Mobile Equipment Mechanics, Installers, and Repairers, nec"', add
label define occ2010_lbl 7300 `"Control and Valve Installers and Repairers"', add
label define occ2010_lbl 7315 `"Heating, Air Conditioning, and Refrigeration Mechanics and Installers"', add
label define occ2010_lbl 7320 `"Home Appliance Repairers"', add
label define occ2010_lbl 7330 `"Industrial and Refractory Machinery Mechanics"', add
label define occ2010_lbl 7340 `"Maintenance and Repair Workers, General"', add
label define occ2010_lbl 7350 `"Maintenance Workers, Machinery"', add
label define occ2010_lbl 7360 `"Millwrights"', add
label define occ2010_lbl 7410 `"Electrical Power-Line Installers and Repairers"', add
label define occ2010_lbl 7420 `"Telecommunications Line Installers and Repairers"', add
label define occ2010_lbl 7430 `"Precision Instrument and Equipment Repairers"', add
label define occ2010_lbl 7510 `"Coin, Vending, and Amusement Machine Servicers and Repairers"', add
label define occ2010_lbl 7540 `"Locksmiths and Safe Repairers"', add
label define occ2010_lbl 7550 `"Manufactured Building and Mobile Home Installers"', add
label define occ2010_lbl 7560 `"Riggers"', add
label define occ2010_lbl 7610 `"Helpers--Installation, Maintenance, and Repair Workers"', add
label define occ2010_lbl 7630 `"Other Installation, Maintenance, and Repair Workers Including Wind Turbine Service Technicians, and Commercial Divers, and Signal and Track Switch Repairers"', add
label define occ2010_lbl 7700 `"First-Line Supervisors of Production and Operating Workers"', add
label define occ2010_lbl 7710 `"Aircraft Structure, Surfaces, Rigging, and Systems Assemblers"', add
label define occ2010_lbl 7720 `"Electrical, Electronics, and Electromechanical Assemblers"', add
label define occ2010_lbl 7730 `"Engine and Other Machine Assemblers"', add
label define occ2010_lbl 7740 `"Structural Metal Fabricators and Fitters"', add
label define occ2010_lbl 7750 `"Assemblers and Fabricators, nec"', add
label define occ2010_lbl 7800 `"Bakers"', add
label define occ2010_lbl 7810 `"Butchers and Other Meat, Poultry, and Fish Processing Workers"', add
label define occ2010_lbl 7830 `"Food and Tobacco Roasting, Baking, and Drying Machine Operators and Tenders"', add
label define occ2010_lbl 7840 `"Food Batchmakers"', add
label define occ2010_lbl 7850 `"Food Cooking Machine Operators and Tenders"', add
label define occ2010_lbl 7855 `"Food Processing, nec"', add
label define occ2010_lbl 7900 `"Computer Control Programmers and Operators"', add
label define occ2010_lbl 7920 `"Extruding and Drawing Machine Setters, Operators, and Tenders, Metal and Plastic"', add
label define occ2010_lbl 7930 `"Forging Machine Setters, Operators, and Tenders, Metal and Plastic"', add
label define occ2010_lbl 7940 `"Rolling Machine Setters, Operators, and Tenders, metal and Plastic"', add
label define occ2010_lbl 7950 `"Cutting, Punching, and Press Machine Setters, Operators, and Tenders, Metal and Plastic"', add
label define occ2010_lbl 7960 `"Drilling and Boring Machine Tool Setters, Operators, and Tenders, Metal and Plastic"', add
label define occ2010_lbl 8000 `"Grinding, Lapping, Polishing, and Buffing Machine Tool Setters, Operators, and Tenders, Metal and Plastic"', add
label define occ2010_lbl 8010 `"Lathe and Turning Machine Tool Setters, Operators, and Tenders, Metal and Plastic"', add
label define occ2010_lbl 8030 `"Machinists"', add
label define occ2010_lbl 8040 `"Metal Furnace Operators, Tenders, Pourers, and Casters"', add
label define occ2010_lbl 8060 `"Model Makers and Patternmakers, Metal and Plastic"', add
label define occ2010_lbl 8100 `"Molders and Molding Machine Setters, Operators, and Tenders, Metal and Plastic"', add
label define occ2010_lbl 8130 `"Tool and Die Makers"', add
label define occ2010_lbl 8140 `"Welding, Soldering, and Brazing Workers"', add
label define occ2010_lbl 8150 `"Heat Treating Equipment Setters, Operators, and Tenders, Metal and Plastic"', add
label define occ2010_lbl 8200 `"Plating and Coating Machine Setters, Operators, and Tenders, Metal and Plastic"', add
label define occ2010_lbl 8210 `"Tool Grinders, Filers, and Sharpeners"', add
label define occ2010_lbl 8220 `"Metal workers and plastic workers, nec"', add
label define occ2010_lbl 8230 `"Bookbinders, Printing Machine Operators, and Job Printers"', add
label define occ2010_lbl 8250 `"Prepress Technicians and Workers"', add
label define occ2010_lbl 8300 `"Laundry and Dry-Cleaning Workers"', add
label define occ2010_lbl 8310 `"Pressers, Textile, Garment, and Related Materials"', add
label define occ2010_lbl 8320 `"Sewing Machine Operators"', add
label define occ2010_lbl 8330 `"Shoe and Leather Workers and Repairers"', add
label define occ2010_lbl 8340 `"Shoe Machine Operators and Tenders"', add
label define occ2010_lbl 8350 `"Tailors, Dressmakers, and Sewers"', add
label define occ2010_lbl 8400 `"Textile bleaching and dyeing, and cutting machine setters, operators, and tenders"', add
label define occ2010_lbl 8410 `"Textile Knitting and Weaving Machine Setters, Operators, and Tenders"', add
label define occ2010_lbl 8420 `"Textile Winding, Twisting, and Drawing Out Machine Setters, Operators, and Tenders"', add
label define occ2010_lbl 8450 `"Upholsterers"', add
label define occ2010_lbl 8460 `"Textile, Apparel, and Furnishings workers, nec"', add
label define occ2010_lbl 8500 `"Cabinetmakers and Bench Carpenters"', add
label define occ2010_lbl 8510 `"Furniture Finishers"', add
label define occ2010_lbl 8530 `"Sawing Machine Setters, Operators, and Tenders, Wood"', add
label define occ2010_lbl 8540 `"Woodworking Machine Setters, Operators, and Tenders, Except Sawing"', add
label define occ2010_lbl 8550 `"Woodworkers including model makers and patternmakers, nec"', add
label define occ2010_lbl 8600 `"Power Plant Operators, Distributors, and Dispatchers"', add
label define occ2010_lbl 8610 `"Stationary Engineers and Boiler Operators"', add
label define occ2010_lbl 8620 `"Water Wastewater Treatment Plant and System Operators"', add
label define occ2010_lbl 8630 `"Plant and System Operators, nec"', add
label define occ2010_lbl 8640 `"Chemical Processing Machine Setters, Operators, and Tenders"', add
label define occ2010_lbl 8650 `"Crushing, Grinding, Polishing, Mixing, and Blending Workers"', add
label define occ2010_lbl 8710 `"Cutting Workers"', add
label define occ2010_lbl 8720 `"Extruding, Forming, Pressing, and Compacting Machine Setters, Operators, and Tenders"', add
label define occ2010_lbl 8730 `"Furnace, Kiln, Oven, Drier, and Kettle Operators and Tenders"', add
label define occ2010_lbl 8740 `"Inspectors, Testers, Sorters, Samplers, and Weighers"', add
label define occ2010_lbl 8750 `"Jewelers and Precious Stone and Metal Workers"', add
label define occ2010_lbl 8760 `"Medical, Dental, and Ophthalmic Laboratory Technicians"', add
label define occ2010_lbl 8800 `"Packaging and Filling Machine Operators and Tenders"', add
label define occ2010_lbl 8810 `"Painting Workers and Dyers"', add
label define occ2010_lbl 8830 `"Photographic Process Workers and Processing Machine Operators"', add
label define occ2010_lbl 8850 `"Adhesive Bonding Machine Operators and Tenders"', add
label define occ2010_lbl 8860 `"Cleaning, Washing, and Metal Pickling Equipment Operators and Tenders"', add
label define occ2010_lbl 8910 `"Etchers, Engravers, and Lithographers"', add
label define occ2010_lbl 8920 `"Molders, Shapers, and Casters, Except Metal and Plastic"', add
label define occ2010_lbl 8930 `"Paper Goods Machine Setters, Operators, and Tenders"', add
label define occ2010_lbl 8940 `"Tire Builders"', add
label define occ2010_lbl 8950 `"Helpers--Production Workers"', add
label define occ2010_lbl 8965 `"Other production workers including semiconductor processors and cooling and freezing equipment operators"', add
label define occ2010_lbl 9000 `"Supervisors of Transportation and Material Moving Workers"', add
label define occ2010_lbl 9030 `"Aircraft Pilots and Flight Engineers"', add
label define occ2010_lbl 9040 `"Air Traffic Controllers and Airfield Operations Specialists"', add
label define occ2010_lbl 9050 `"Flight Attendants and Transportation Workers and Attendants"', add
label define occ2010_lbl 9100 `"Bus and Ambulance Drivers and Attendants"', add
label define occ2010_lbl 9130 `"Driver/Sales Workers and Truck Drivers"', add
label define occ2010_lbl 9140 `"Taxi Drivers and Chauffeurs"', add
label define occ2010_lbl 9150 `"Motor Vehicle Operators, All Other"', add
label define occ2010_lbl 9200 `"Locomotive Engineers and Operators"', add
label define occ2010_lbl 9230 `"Railroad Brake, Signal, and Switch Operators"', add
label define occ2010_lbl 9240 `"Railroad Conductors and Yardmasters"', add
label define occ2010_lbl 9260 `"Subway, Streetcar, and Other Rail Transportation Workers"', add
label define occ2010_lbl 9300 `"Sailors and marine oilers, and ship engineers"', add
label define occ2010_lbl 9310 `"Ship and Boat Captains and Operators"', add
label define occ2010_lbl 9350 `"Parking Lot Attendants"', add
label define occ2010_lbl 9360 `"Automotive and Watercraft Service Attendants"', add
label define occ2010_lbl 9410 `"Transportation Inspectors"', add
label define occ2010_lbl 9420 `"Transportation workers, nec"', add
label define occ2010_lbl 9510 `"Crane and Tower Operators"', add
label define occ2010_lbl 9520 `"Dredge, Excavating, and Loading Machine Operators"', add
label define occ2010_lbl 9560 `"Conveyor operators and tenders, and hoist and winch operators"', add
label define occ2010_lbl 9600 `"Industrial Truck and Tractor Operators"', add
label define occ2010_lbl 9610 `"Cleaners of Vehicles and Equipment"', add
label define occ2010_lbl 9620 `"Laborers and Freight, Stock, and Material Movers, Hand"', add
label define occ2010_lbl 9630 `"Machine Feeders and Offbearers"', add
label define occ2010_lbl 9640 `"Packers and Packagers, Hand"', add
label define occ2010_lbl 9650 `"Pumping Station Operators"', add
label define occ2010_lbl 9720 `"Refuse and Recyclable Material Collectors"', add
label define occ2010_lbl 9750 `"Material moving workers, nec"', add
label define occ2010_lbl 9800 `"Military Officer Special and Tactical Operations Leaders"', add
label define occ2010_lbl 9810 `"First-Line Enlisted Military Supervisors"', add
label define occ2010_lbl 9820 `"Military Enlisted Tactical Operations and Air/Weapons Specialists and Crew Members"', add
label define occ2010_lbl 9830 `"Military, Rank Not Specified"', add
label define occ2010_lbl 9920 `"Unemployed, with No Work Experience in the Last 5 Years or Earlier or Never Worked"', add
label define occ2010_lbl 9999 `"Unknown"', add
label values occ2010 occ2010_lbl

label define occ2010_3d_lbl 001 "Chief executives and legislators/public administration" 002 "General and Operations Managers" 003 "Managers in Marketing, Advertising, and Public Relations" 010 "Administrative Services Managers" 011 "Computer and Information Systems Managers" 012 "Financial Managers" 013 "Human Resources Managers" 014 "Industrial Production Managers" 015 "Purchasing Managers" 016 "Transportation, Storage, and Distribution Managers" 020 "Farmers, Ranchers, and Other Agricultural Managers" 022 "Constructions Managers" 023 "Education Administrators" 030 "Architectural and Engineering Managers" 031 "Food Service and Lodging Managers" 032 "Funeral Directors" 033 "Gaming Managers" 035 "Medical and Health Services Managers" 036 "Natural Science Managers" 041 "Property, Real Estate, and Community Association Managers" 042 "Social and Community Service Managers" 043 "Managers, nec (including Postmasters)" 050 "Agents and Business Managers of Artists, Performers, and Athletes" 051 "Buyers and Purchasing Agents, Farm Products" 052 "Wholesale and Retail Buyers, Except Farm Products" 053 "Purchasing Agents, Except Wholesale, Retail, and Farm Products" 054 "Claims Adjusters, Appraisers, Examiners, and Investigators" 056 "Compliance Officers, Except Agriculture" 060 "Cost Estimators" 062 "Human Resources, Training, and Labor Relations Specialists" 070 "Logisticians" 071 "Management Analysts" 072 "Meeting and Convention Planners" 073 "Other Business Operations and Management Specialists" 080 "Accountants and Auditors" 081 "Appraisers and Assessors of Real Estate" 082 "Budget Analysts" 083 "Credit Analysts" 084 "Financial Analysts" 085 "Personal Financial Advisors" 086 "Insurance Underwriters" 090 "Financial Examiners" 091 "Credit Counselors and Loan Officers" 093 "Tax Examiners and Collectors, and Revenue Agents" 094 "Tax Preparers" 095 "Financial Specialists, nec" 100 "Computer Scientists and Systems Analysts/Network systems Analysts/Web Developers" 101 "Computer Programmers" 102 "Software Developers, Applications and Systems Software" 105 "Computer Support Specialists" 106 "Database Administrators" 110 "Network and Computer Systems Administrators" 120 "Actuaries" 122 "Operations Research Analysts" 123 "Statisticians" 124 "Mathematical science occupations, nec" 130 "Architects, Except Naval" 131 "Surveyors, Cartographers, and Photogrammetrists" 132 "Aerospace Engineers" 135 "Chemical Engineers" 136 "Civil Engineers" 140 "Computer Hardware Engineers" 141 "Electrical and Electronics Engineers" 142 "Environmental Engineers" 143 "Industrial Engineers, including Health and Safety" 144 "Marine Engineers and Naval Architects" 145 "Materials Engineers" 146 "Mechanical Engineers" 152 "Petroleum, mining and geological engineers, including mining safety engineers" 153 "Engineers, nec" 154 "Drafters" 155 "Engineering Technicians, Except Drafters" 156 "Surveying and Mapping Technicians" 160 "Agricultural and Food Scientists" 161 "Biological Scientists" 164 "Conservation Scientists and Foresters" 165 "Medical Scientists, and Life Scientists, All Other" 170 "Astronomers and Physicists" 171 "Atmospheric and Space Scientists" 172 "Chemists and Materials Scientists" 174 "Environmental Scientists and Geoscientists" 176 "Physical Scientists, nec" 180 "Economists and market researchers" 182 "Psychologists" 183 "Urban and Regional Planners" 184 "Social Scientists, nec" 190 "Agricultural and Food Science Technicians" 191 "Biological Technicians" 192 "Chemical Technicians" 193 "Geological and Petroleum Technicians, and Nuclear Technicians" 196 "Life, Physical, and Social Science Technicians, nec" 198 "Professional, Research, or Technical Workers, nec" 200 "Counselors" 201 "Social Workers" 202 "Community and Social Service Specialists, nec" 204 "Clergy" 205 "Directors, Religious Activities and Education" 206 "Religious Workers, nec" 210 "Lawyers, and judges, magistrates, and other judicial workers" 214 "Paralegals and Legal Assistants" 215 "Legal Support Workers, nec" 220 "Postsecondary Teachers" 230 "Preschool and Kindergarten Teachers" 231 "Elementary and Middle School Teachers" 232 "Secondary School Teachers" 233 "Special Education Teachers" 234 "Other Teachers and Instructors" 240 "Archivists, Curators, and Museum Technicians" 243 "Librarians" 244 "Library Technicians" 254 "Teacher Assistants" 255 "Education, Training, and Library Workers, nec" 260 "Artists and Related Workers" 263 "Designers" 270 "Actors, Producers, and Directors" 272 "Athletes, Coaches, Umpires, and Related Workers" 274 "Dancers and Choreographers" 275 "Musicians, Singers, and Related Workers" 276 "Entertainers and Performers, Sports and Related Workers, All Other" 280 "Announcers" 281 "Editors, News Analysts, Reporters, and Correspondents" 282 "Public Relations Specialists" 284 "Technical Writers" 285 "Writers and Authors" 286 "Media and Communication Workers, nec" 290 "Broadcast and Sound Engineering Technicians and Radio Operators, and media and communication equipment workers, all other" 291 "Photographers" 292 "Television, Video, and Motion Picture Camera Operators and Editors" 300 "Chiropractors" 301 "Dentists" 303 "Dieticians and Nutritionists" 304 "Optometrists" 305 "Pharmacists" 306 "Physicians and Surgeons" 311 "Physician Assistants" 312 "Podiatrists" 313 "Registered Nurses" 314 "Audiologists" 315 "Occupational Therapists" 316 "Physical Therapists" 320 "Radiation Therapists" 321 "Recreational Therapists" 322 "Respiratory Therapists" 323 "Speech Language Pathologists" 324 "Therapists, nec" 325 "Veterinarians" 326 "Health Diagnosing and Treating Practitioners, nec" 330 "Clinical Laboratory Technologists and Technicians" 331 "Dental Hygienists" 332 "Diagnostic Related Technologists and Technicians" 340 "Emergency Medical Technicians and Paramedics" 341 "Health Diagnosing and Treating Practitioner Support Technicians" 350 "Licensed Practical and Licensed Vocational Nurses" 351 "Medical Records and Health Information Technicians" 352 "Opticians, Dispensing" 353 "Health Technologists and Technicians, nec" 354 "Healthcare Practitioners and Technical Occupations, nec" 360 "Nursing, Psychiatric, and Home Health Aides" 361 "Occupational Therapy Assistants and Aides" 362 "Physical Therapist Assistants and Aides" 363 "Massage Therapists" 364 "Dental Assistants" 365 "Medical Assistants and Other Healthcare Support Occupations, nec" 370 "First-Line Supervisors of Correctional Officers" 371 "First-Line Supervisors of Police and Detectives" 372 "First-Line Supervisors of Fire Fighting and Prevention Workers" 373 "Supervisors, Protective Service Workers, All Other" 374 "Firefighters" 375 "Fire Inspectors" 380 "Sheriffs, Bailiffs, Correctional Officers, and Jailers" 382 "Police Officers and Detectives" 390 "Animal Control" 391 "Private Detectives and Investigators" 393 "Security Guards and Gaming Surveillance Officers" 394 "Crossing Guards" 395 "Law enforcement workers, nec" 400 "Chefs and Cooks" 401 "First-Line Supervisors of Food Preparation and Serving Workers" 403 "Food Preparation Workers" 404 "Bartenders" 405 "Combined Food Preparation and Serving Workers, Including Fast Food" 406 "Counter Attendant, Cafeteria, Food Concession, and Coffee Shop" 411 "Waiters and Waitresses" 412 "Food Servers, Nonrestaurant" 413 "Food preparation and serving related workers, nec" 414 "Dishwashers" 415 "Host and Hostesses, Restaurant, Lounge, and Coffee Shop" 420 "First-Line Supervisors of Housekeeping and Janitorial Workers" 421 "First-Line Supervisors of Landscaping, Lawn Service, and Groundskeeping Workers" 422 "Janitors and Building Cleaners" 423 "Maids and Housekeeping Cleaners" 424 "Pest Control Workers" 425 "Grounds Maintenance Workers" 430 "First-Line Supervisors of Gaming Workers" 432 "First-Line Supervisors of Personal Service Workers" 434 "Animal Trainers" 435 "Nonfarm Animal Caretakers" 440 "Gaming Services Workers" 442 "Ushers, Lobby Attendants, and Ticket Takers" 443 "Entertainment Attendants and Related Workers, nec" 446 "Funeral Service Workers and Embalmers" 450 "Barbers" 451 "Hairdressers, Hairstylists, and Cosmetologists" 452 "Personal Appearance Workers, nec" 453 "Baggage Porters, Bellhops, and Concierges" 454 "Tour and Travel Guides" 460 "Childcare Workers" 461 "Personal Care Aides" 462 "Recreation and Fitness Workers" 464 "Residential Advisors" 465 "Personal Care and Service Workers, All Other" 470 "First-Line Supervisors of Sales Workers" 472 "Cashiers" 474 "Counter and Rental Clerks" 475 "Parts Salespersons" 476 "Retail Salespersons" 480 "Advertising Sales Agents" 481 "Insurance Sales Agents" 482 "Securities, Commodities, and Financial Services Sales Agents" 483 "Travel Agents" 484 "Sales Representatives, Services, All Other" 485 "Sales Representatives, Wholesale and Manufacturing" 490 "Models, Demonstrators, and Product Promoters" 492 "Real Estate Brokers and Sales Agents" 493 "Sales Engineers" 494 "Telemarketers" 495 "Sales and Related Workers" 500 "First-Line Supervisors of Office and Administrative Support Workers" 501 "Switchboard Operators, Including Answering Service" 502 "Telephone Operators" 503 "Communications Equipment Operators, All Other" 510 "Bill and Account Collectors" 511 "Billing and Posting Clerks" 512 "Bookkeeping, Accounting, and Auditing Clerks" 513 "Gaming Cage Workers" 514 "Payroll and Timekeeping Clerks" 515 "Procurement Clerks" 516 "Bank Tellers, Financial Clerks" 520 "Brokerage Clerks" 522 "Court, Municipal, and License Clerks" 523 "Credit Authorizers, Checkers, and Clerks" 524 "Customer Service Representatives" 525 "Eligibility Interviewers, Government Programs" 526 "File Clerks" 530 "Hotel, Motel, and Resort Desk Clerks" 531 "Interviewers, Except Eligibility and Loan" 532 "Library Assistants, Clerical" 533 "Loan Interviewers and Clerks" 534 "New Account Clerks" 535 "Correspondent clerks and order clerks" 536 "Human Resources Assistants, Except Payroll and Timekeeping" 540 "Receptionists and Information Clerks" 541 "Reservation and Transportation Ticket Agents and Travel Clerks" 542 "Information and Record Clerks, All Other" 550 "Cargo and Freight Agents" 551 "Couriers and Messengers" 552 "Dispatchers" 553 "Meter Readers, Utilities" 554 "Postal Service Clerks" 555 "Postal Service Mail Carriers" 556 "Postal Service Mail Sorters, Processors, and Processing Machine Operators" 560 "Production, Planning, and Expediting Clerks" 561 "Shipping, Receiving, and Traffic Clerks" 562 "Stock Clerks and Order Fillers" 563 "Weighers, Measurers, Checkers, and Samplers, Recordkeeping" 570 "Secretaries and Administrative Assistants" 580 "Computer Operators" 581 "Data Entry Keyers" 582 "Word Processors and Typists" 584 "Insurance Claims and Policy Processing Clerks" 585 "Mail Clerks and Mail Machine Operators, Except Postal Service" 586 "Office Clerks, General" 590 "Office Machine Operators, Except Computer" 591 "Proofreaders and Copy Markers" 592 "Statistical Assistants" 594 "Office and administrative support workers, nec" 600 "First-Line Supervisors of Farming, Fishing, and Forestry Workers" 601 "Agricultural Inspectors" 604 "Graders and Sorters, Agricultural Products" 605 "Agricultural workers, nec" 610 "Fishing and hunting workers" 612 "Forest and Conservation Workers" 613 "Logging Workers" 620 "First-Line Supervisors of Construction Trades and Extraction Workers" 621 "Boilermakers" 622 "Brickmasons, Blockmasons, and Stonemasons" 623 "Carpenters" 624 "Carpet, Floor, and Tile Installers and Finishers" 625 "Cement Masons, Concrete Finishers, and Terrazzo Workers" 626 "Construction Laborers" 630 "Paving, Surfacing, and Tamping Equipment Operators" 632 "Construction equipment operators except paving, surfacing, and tamping equipment operators" 633 "Drywall Installers, Ceiling Tile Installers, and Tapers" 635 "Electricians" 636 "Glaziers" 640 "Insulation Workers" 642 "Painters, Construction and Maintenance" 643 "Paperhangers" 644 "Pipelayers, Plumbers, Pipefitters, and Steamfitters" 646 "Plasterers and Stucco Masons" 650 "Reinforcing Iron and Rebar Workers" 651 "Roofers" 652 "Sheet Metal Workers, metal-working" 653 "Structural Iron and Steel Workers" 660 "Helpers, Construction Trades" 666 "Construction and Building Inspectors" 670 "Elevator Installers and Repairers" 671 "Fence Erectors" 672 "Hazardous Materials Removal Workers" 673 "Highway Maintenance Workers" 674 "Rail-Track Laying and Maintenance Equipment Operators" 676 "Construction workers, nec" 680 "Derrick, rotary drill, and service unit operators, and roustabouts, oil, gas, and mining" 682 "Earth Drillers, Except Oil and Gas" 683 "Explosives Workers, Ordnance Handling Experts, and Blasters" 684 "Mining Machine Operators" 694 "Extraction workers, nec" 700 "First-Line Supervisors of Mechanics, Installers, and Repairers" 701 "Computer, Automated Teller, and Office Machine Repairers" 702 "Radio and Telecommunications Equipment Installers and Repairers" 703 "Avionics Technicians" 704 "Electric Motor, Power Tool, and Related Repairers" 710 "Electrical and electronics repairers, transportation equipment, and industrial and utility" 711 "Electronic Equipment Installers and Repairers, Motor Vehicles" 712 "Electronic Home Entertainment Equipment Installers and Repairers" 713 "Security and Fire Alarm Systems Installers" 714 "Aircraft Mechanics and Service Technicians" 715 "Automotive Body and Related Repairers" 716 "Automotive Glass Installers and Repairers" 720 "Automotive Service Technicians and Mechanics" 721 "Bus and Truck Mechanics and Diesel Engine Specialists" 722 "Heavy Vehicle and Mobile Equipment Service Technicians and Mechanics" 724 "Small Engine Mechanics" 726 "Vehicle and Mobile Equipment Mechanics, Installers, and Repairers, nec" 730 "Control and Valve Installers and Repairers" 731 "Heating, Air Conditioning, and Refrigeration Mechanics and Installers" 732 "Home Appliance Repairers" 733 "Industrial and Refractory Machinery Mechanics" 734 "Maintenance and Repair Workers, General" 735 "Maintenance Workers, Machinery" 736 "Millwrights" 741 "Electrical Power-Line Installers and Repairers" 742 "Telecommunications Line Installers and Repairers" 743 "Precision Instrument and Equipment Repairers" 751 "Coin, Vending, and Amusement Machine Servicers and Repairers" 754 "Locksmiths and Safe Repairers" 755 "Manufactured Building and Mobile Home Installers" 756 "Riggers" 761 "Helpers--Installation, Maintenance, and Repair Workers" 763 "Other Installation, Maintenance, and Repair Workers Including Wind Turbine Service Technicians, and Commercial Divers, and Signal and Track Switch Repairers" 770 "First-Line Supervisors of Production and Operating Workers" 771 "Aircraft Structure, Surfaces, Rigging, and Systems Assemblers" 772 "Electrical, Electronics, and Electromechanical Assemblers" 773 "Engine and Other Machine Assemblers" 774 "Structural Metal Fabricators and Fitters" 775 "Assemblers and Fabricators, nec" 780 "Bakers" 781 "Butchers and Other Meat, Poultry, and Fish Processing Workers" 783 "Food and Tobacco Roasting, Baking, and Drying Machine Operators and Tenders" 784 "Food Batchmakers" 785 "Food Cooking and Processing Machine Operators and Tenders" 790 "Computer Control Programmers and Operators" 792 "Extruding and Drawing Machine Setters, Operators, and Tenders, Metal and Plastic" 793 "Forging Machine Setters, Operators, and Tenders, Metal and Plastic" 794 "Rolling Machine Setters, Operators, and Tenders, metal and Plastic" 795 "Cutting, Punching, and Press Machine Setters, Operators, and Tenders, Metal and Plastic" 796 "Drilling and Boring Machine Tool Setters, Operators, and Tenders, Metal and Plastic" 800 "Grinding, Lapping, Polishing, and Buffing Machine Tool Setters, Operators, and Tenders, Metal and Plastic" 801 "Lathe and Turning Machine Tool Setters, Operators, and Tenders, Metal and Plastic" 803 "Machinists" 804 "Metal Furnace Operators, Tenders, Pourers, and Casters" 806 "Model Makers and Patternmakers, Metal and Plastic" 810 "Molders and Molding Machine Setters, Operators, and Tenders, Metal and Plastic" 813 "Tool and Die Makers" 814 "Welding, Soldering, and Brazing Workers" 815 "Heat Treating Equipment Setters, Operators, and Tenders, Metal and Plastic" 820 "Plating and Coating Machine Setters, Operators, and Tenders, Metal and Plastic" 821 "Tool Grinders, Filers, and Sharpeners" 822 "Metal workers and plastic workers, nec" 823 "Bookbinders, Printing Machine Operators, and Job Printers" 825 "Prepress Technicians and Workers" 830 "Laundry and Dry-Cleaning Workers" 831 "Pressers, Textile, Garment, and Related Materials" 832 "Sewing Machine Operators" 833 "Shoe and Leather Workers and Repairers" 834 "Shoe Machine Operators and Tenders" 835 "Tailors, Dressmakers, and Sewers" 840 "Textile bleaching and dyeing, and cutting machine setters, operators, and tenders" 841 "Textile Knitting and Weaving Machine Setters, Operators, and Tenders" 842 "Textile Winding, Twisting, and Drawing Out Machine Setters, Operators, and Tenders" 845 "Upholsterers" 846 "Textile, Apparel, and Furnishings workers, nec" 850 "Cabinetmakers and Bench Carpenters" 851 "Furniture Finishers" 853 "Sawing Machine Setters, Operators, and Tenders, Wood" 854 "Woodworking Machine Setters, Operators, and Tenders, Except Sawing" 855 "Woodworkers including model makers and patternmakers, nec" 860 "Power Plant Operators, Distributors, and Dispatchers" 861 "Stationary Engineers and Boiler Operators" 862 "Water Wastewater Treatment Plant and System Operators" 863 "Plant and System Operators, nec" 864 "Chemical Processing Machine Setters, Operators, and Tenders" 865 "Crushing, Grinding, Polishing, Mixing, and Blending Workers" 871 "Cutting Workers" 872 "Extruding, Forming, Pressing, and Compacting Machine Setters, Operators, and Tenders" 873 "Furnace, Kiln, Oven, Drier, and Kettle Operators and Tenders" 874 "Inspectors, Testers, Sorters, Samplers, and Weighers" 875 "Jewelers and Precious Stone and Metal Workers" 876 "Medical, Dental, and Ophthalmic Laboratory Technicians" 880 "Packaging and Filling Machine Operators and Tenders" 881 "Painting Workers and Dyers" 883 "Photographic Process Workers and Processing Machine Operators" 885 "Adhesive Bonding Machine Operators and Tenders" 886 "Cleaning, Washing, and Metal Pickling Equipment Operators and Tenders" 891 "Etchers, Engravers, and Lithographers" 892 "Molders, Shapers, and Casters, Except Metal and Plastic" 893 "Paper Goods Machine Setters, Operators, and Tenders" 894 "Tire Builders" 895 "Helpers--Production Workers" 896 "Other production workers including semiconductor processors and cooling and freezing equipment operators" 900 "Supervisors of Transportation and Material Moving Workers" 903 "Aircraft Pilots and Flight Engineers" 904 "Air Traffic Controllers and Airfield Operations Specialists" 905 "Flight Attendants and Transportation Workers and Attendants" 910 "Bus and Ambulance Drivers and Attendants" 913 "Driver/Sales Workers and Truck Drivers" 914 "Taxi Drivers and Chauffeurs" 915 "Motor Vehicle Operators, All Other" 920 "Locomotive Engineers and Operators" 923 "Railroad Brake, Signal, and Switch Operators" 924 "Railroad Conductors and Yardmasters" 926 "Subway, Streetcar, and Other Rail Transportation Workers" 930 "Sailors and marine oilers, and ship engineers" 931 "Ship and Boat Captains and Operators" 935 "Parking Lot Attendants" 936 "Automotive and Watercraft Service Attendants" 941 "Transportation Inspectors" 942 "Transportation workers, nec" 951 "Crane and Tower Operators" 952 "Dredge, Excavating, and Loading Machine Operators" 956 "Conveyor operators and tenders, and hoist and winch operators" 960 "Industrial Truck and Tractor Operators" 961 "Cleaners of Vehicles and Equipment" 962 "Laborers and Freight, Stock, and Material Movers, Hand" 963 "Machine Feeders and Offbearers" 964 "Packers and Packagers, Hand" 965 "Pumping Station Operators" 972 "Refuse and Recyclable Material Collectors" 975 "Material moving workers, nec" 980 "Military Officer Special and Tactical Operations Leaders" 981 "First-Line Enlisted Military Supervisors" 982 "Military Enlisted Tactical Operations and Air/Weapons Specialists and Crew Members" 983 "Military, Rank Not Specified" 992 "Unemployed, with No Work Experience in the Last 5 Years or Earlier or Never Worked" 999 "Unknown"

drop if sex==2 | !inrange(age,18,64)

tab month year
tab year

gen college=1 if educ99>=15 & educ99<=18
replace college=0 if educ99>=1 & educ99<=14

gen occ2010_3digit= occ2010/10
gen occ2010_3digit_2= floor(occ2010/10)
drop occ2010_3digit
rename occ2010_3digit_2 occ2010_3d
label values occ2010_3d occ2010_3d_lbl

gen occ2010_2d = floor(occ2010/100)

preserve
    tempfile threedigit
    collapse (sum) wtsupp (mean) college (count) nobs=wtsupp if age>=18 & sex==1 & age<65 & occ2010_3d<990 [aw=wtsupp], by(occ2010_3d)
    gen lt100obs = nobs<100
    keep occ2010_3d lt100obs
    save `threedigit', replace
restore

merge m:1 occ2010_3d using `threedigit', nogen

preserve
    tempfile twodigit
    collapse (sum) wtsupp (mean) college (count) nobs=wtsupp if age>=18 & sex==1 & age<65 & occ2010_3d<990 [aw=wtsupp], by(occ2010_2d)
    ren college college_2d
    ren nobs nobs_2d
    keep occ2010_2d college_2d nobs_2d
    save `twodigit', replace
restore

merge m:1 occ2010_2d using `twodigit', nogen

egen frac_2d_lt100 = mean(lt100obs), by(occ2010_2d)
tab occ2010_3d if occ2010_2d==3, sum(lt100obs )
tab occ2010_3d if occ2010_2d==3, sum(college )
tab occ2010_3d if occ2010_2d==3, sum(college_2d)

* 18-65
preserve
    collapse (sum) wtsupp (mean) college (count) nobs=wtsupp if age>=18 & sex==1 & age<65 & occ2010_3d<990 [aw=wtsupp], by(occ2010_3d)
    gen occ2010_2d = floor(occ2010_3d/10)
    merge m:1 occ2010_2d using `twodigit'
    replace college = college_2d if nobs<100
    replace nobs = nobs_2d if nobs<100
    gen white_collar = college>.5
    sum white_collar
    l occ2010_3d college nobs white_collar, sep(0) str(40)
    l if inrange(college,.45,.55), sep(0) str(14)
    l if inrange(college,0,.1) | inrange(college,.9,1), sep(0) str(14)
    twoway histogram college, start(0) vertical graphregion(color(white)) ytitle("Proportion") xtitle("Share college") color(navy)
    // graph export occHist18_65.eps, replace
    rename _merge _merge_old
    save "${clnpath}cps_occ_class18_65", replace
restore

merge m:1 occ2010_3d  using "${clnpath}cps_occ_class18_65", keepusing(white_collar nobs)
gen blue_collar=1-white_collar

sum white_collar if college==1 & age>=18 & age<=32 & sex==1 & occ2010_3d<990 [aw=wtsupp]
sum white_collar if college==0 & age>=18 & age<=32 & sex==1 & occ2010_3d<990 [aw=wtsupp]

sum blue_collar if college==1 & age>=18 & age<=32 & sex==1 & occ2010_3d<990 [aw=wtsupp]
sum blue_collar if college==0 & age>=18 & age<=32 & sex==1 & occ2010_3d<990 [aw=wtsupp]

sum college if white_collar & age>=18 & age<=32 & sex==1 & occ2010_3d<990 [aw=wtsupp]
sum college if blue_collar  & age>=18 & age<=32 & sex==1 & occ2010_3d<990 [aw=wtsupp]


* 23-65
preserve
    collapse (sum) wtsupp (mean) college (count) nobs=wtsupp if age>=23 & sex==1 & age<65 & occ2010_3d<990 [aw=wtsupp], by(occ2010_3d)
    gen occ2010_2d = floor(occ2010_3d/10)
    merge m:1 occ2010_2d using `twodigit'
    replace college = college_2d if nobs<100
    replace nobs = nobs_2d if nobs<100
    gen white_collar = college>.5
    sum white_collar
    l occ2010_3d college nobs white_collar, sep(0) str(40)
    l if inrange(college,.45,.55), sep(0) str(14)
    l if inrange(college,0,.1) | inrange(college,.9,1), sep(0) str(14)
    twoway histogram college, start(0) vertical graphregion(color(white)) ytitle("Proportion") xtitle("Share college") color(navy)
    // graph export occHist23_65.eps, replace
    rename _merge _merge_old
    save "${clnpath}cps_occ_class23_65", replace
restore

log close
