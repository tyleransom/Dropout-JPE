* Import, rename, reshape, recode and label the demographic variables

infile using ${rawloc}y97_demographics.dct, clear

****************
* Rename
****************

ren R0000100 ID
ren R1235800 Sample_type
ren R1482600 race_ethnicity
ren R0536300 sex
ren R0536401 birth_month
ren R0536402 birth_year
ren U0000600 version_number

ren R1236101 weight_cc1997
ren R2600301 weight_cc1998
ren R3923701 weight_cc1999
ren R5510600 weight_cc2000
ren R7274200 weight_cc2001
ren S1598100 weight_cc2002
ren S2067000 weight_cc2003
ren S3861600 weight_cc2004
ren S5444200 weight_cc2005
ren S7545500 weight_cc2006
ren T0042100 weight_cc2007
ren T2022500 weight_cc2008
ren T3613300 weight_cc2009
ren T5213200 weight_cc2010
ren T6665000 weight_cc2011
ren T8135900 weight_cc2013
ren U0017100 weight_cc2015
ren R1236201 weight_panel1997
ren R2600401 weight_panel1998
ren R3958501 weight_panel1999
ren R5510700 weight_panel2000
ren R7274300 weight_panel2001
ren S1598200 weight_panel2002
ren S2067100 weight_panel2003
ren S3861700 weight_panel2004
ren S5444300 weight_panel2005
ren S7545600 weight_panel2006
ren T0042200 weight_panel2007
ren T2022600 weight_panel2008
ren T3613400 weight_panel2009
ren T5213300 weight_panel2010
ren T6665100 weight_panel2011
ren T8136000 weight_panel2013
ren U0017200 weight_panel2015

ren R1209300 Int_month1997
ren R2568200 Int_month1998
ren R3890100 Int_month1999
ren R5472200 Int_month2000
ren R7236000 Int_month2001
ren S1550800 Int_month2002
ren S2020700 Int_month2003
ren S3821900 Int_month2004
ren S5421900 Int_month2005
ren S7524000 Int_month2006
ren T0024400 Int_month2007
ren T2019300 Int_month2008
ren T3609900 Int_month2009
ren T5210300 Int_month2010
ren T6661300 Int_month2011
ren T8132800 Int_month2013
ren U0013100 Int_month2015
ren R1209401 InterviewM1997
ren R1209402 InterviewY1997
ren R2568301 InterviewM1998
ren R2568302 InterviewY1998
ren R3890301 InterviewM1999
ren R3890302 InterviewY1999
ren R5472301 InterviewM2000
ren R5472302 InterviewY2000
ren R7236101 InterviewM2001
ren R7236102 InterviewY2001
ren S1550901 InterviewM2002
ren S1550902 InterviewY2002
ren S2020801 InterviewM2003
ren S2020802 InterviewY2003
ren S3822001 InterviewM2004
ren S3822002 InterviewY2004
ren S5422001 InterviewM2005
ren S5422002 InterviewY2005
ren S7524101 InterviewM2006
ren S7524102 InterviewY2006
ren T0024501 InterviewM2007
ren T0024502 InterviewY2007
ren T2019401 InterviewM2008
ren T2019402 InterviewY2008
ren T3610001 InterviewM2009
ren T3610002 InterviewY2009
ren T5210401 InterviewM2010
ren T5210402 InterviewY2010
ren T6661401 InterviewM2011
ren T6661402 InterviewY2011
ren T8132901 InterviewM2013
ren T8132902 InterviewY2013
ren U0013201 InterviewM2015
ren U0013202 InterviewY2015

ren R1205000 Relationship_to_Par_age12_
ren R1205100 Relationship_to_Par_age2_
ren R1205200 Relationship_to_Par_age6_
ren R1205300 Relationship_HH_head1997
ren R2563600 Relationship_HH_head1998
ren R3885200 Relationship_HH_head1999
ren R5464400 Relationship_HH_head2000
ren R7228100 Relationship_HH_head2001
ren S1542000 Relationship_HH_head2002
ren S2011800 Relationship_HH_head2003

ren R1205400 HH_size
ren R1205500 HH_size_under_18
ren R1200200 age_mom_born
ren R0567300 marriedSp1
ren R0567400 marriedSp2
ren R0567500 marriedSp3
ren R1204800 Student_net_worth1996
ren Z9048900 Student_net_worthAge20
ren Z9049000 Student_net_worthAge25

ren R5821400 Born_in_US2001
ren S0191300 Born_in_US2002
ren S2175900 Born_in_US2003
ren S3952000 Born_in_US2004
ren S7642200 Born_in_US2006
ren T0135800 Born_in_US2007
ren T2110700 Born_in_US2008
ren T3721700 Born_in_US2009
ren T5313500 Born_in_US2010
ren T6758500 Born_in_US2011
ren T8232600 Born_in_US2013
ren U0128300 Born_in_US2015

ren R9829600 ASVAB
ren R1210800 PIAT_math1997
ren R2569700 PIAT_math1998
ren R3891700 PIAT_math1999
ren R5473700 PIAT_math2000
ren R7237400 PIAT_math2001
ren S1552700 PIAT_math2002
ren Z9033700 surveySATmath
ren Z9033900 surveySATverb
ren Z9034100 surveyACTmax
ren R0041000 surveyACTenglish1997
ren R0041100 surveyACTmath1997
ren R0041200 surveyACTreading1997
ren R0041300 surveyACTscience1997
ren R0041400 surveyACT1997
ren R0058500 surveyACTenglish1998 // This was actually asked twice in 1997 (to different subsets of people, so this 1998 is more of a placeholder)
ren R0058600 surveyACTmath1998
ren R0058700 surveyACTreading1998
ren R0058800 surveyACTscience1998
ren R0058900 surveyACT1998

ren R0041600 tookAPart1997
ren R0041601 tookAPbio1997
ren R0041602 tookAPchem1997
ren R0041603 tookAPcompSci1997
ren R0041604 tookAPecon1997
ren R0041605 tookAPeng1997
ren R0041606 tookAPfrench1997
ren R0041607 tookAPgerman1997
ren R0041608 tookAPgov1997
ren R0041609 tookAPhistory1997
ren R0041610 tookAPlatin1997
ren R0041611 tookAPmath1997
ren R0041612 tookAPmusic1997
ren R0041613 tookAPphysics1997
ren R0041614 tookAPpsychology1997
ren R0041615 tookAPspanish1997
ren R0041616 tookAPnone1997
ren R0059100 DLItookAPart1997
ren R0059101 DLItookAPbio1997
ren R0059102 DLItookAPchem1997
ren R0059103 DLItookAPcompSci1997
ren R0059104 DLItookAPecon1997
ren R0059105 DLItookAPeng1997
ren R0059106 DLItookAPfrench1997
ren R0059107 DLItookAPgerman1997
ren R0059108 DLItookAPgov1997
ren R0059109 DLItookAPhistory1997
ren R0059110 DLItookAPlatin1997
ren R0059111 DLItookAPmath1997
ren R0059112 DLItookAPmusic1997
ren R0059113 DLItookAPphysics1997
ren R0059114 DLItookAPpsychology1997
ren R0059115 DLItookAPspanish1997
ren R0059116 DLItookAPnone1997
ren R1704000 tookAPart1998
ren R1704001 tookAPbio1998
ren R1704002 tookAPchem1998
ren R1704003 tookAPcompSci1998
ren R1704004 tookAPecon1998
ren R1704005 tookAPeng1998
ren R1704006 tookAPfrench1998
ren R1704007 tookAPgerman1998
ren R1704008 tookAPgov1998
ren R1704009 tookAPhistory1998
ren R1704010 tookAPlatin1998
ren R1704011 tookAPmath1998
ren R1704012 tookAPmusic1998
ren R1704013 tookAPphysics1998
ren R1704014 tookAPpsychology1998
ren R1704015 tookAPspanish1998
ren R1704016 tookAPnone1998
ren R2996500 tookAPart1999
ren R2996501 tookAPbio1999
ren R2996502 tookAPchem1999
ren R2996503 tookAPcompSci1999
ren R2996504 tookAPecon1999
ren R2996505 tookAPeng1999
ren R2996506 tookAPfrench1999
ren R2996507 tookAPgerman1999
ren R2996508 tookAPgov1999
ren R2996509 tookAPhistory1999
ren R2996510 tookAPlatin1999
ren R2996511 tookAPmath1999
ren R2996512 tookAPmusic1999
ren R2996513 tookAPphysics1999
ren R2996514 tookAPpsychology1999
ren R2996515 tookAPspanish1999
ren R2996516 tookAPnone1999
ren R2996700 DLItookAPart1999
ren R2996701 DLItookAPbio1999
ren R2996702 DLItookAPchem1999
ren R2996703 DLItookAPcompSci1999
ren R2996704 DLItookAPecon1999
ren R2996705 DLItookAPeng1999
ren R2996706 DLItookAPfrench1999
ren R2996707 DLItookAPgerman1999
ren R2996708 DLItookAPgov1999
ren R2996709 DLItookAPhistory1999
ren R2996710 DLItookAPlatin1999
ren R2996711 DLItookAPmath1999
ren R2996712 DLItookAPmusic1999
ren R2996713 DLItookAPphysics1999
ren R2996714 DLItookAPpsychology1999
ren R2996715 DLItookAPspanish1999
ren R2996716 DLItookAPnone1999
ren R4262100 tookAPart2000
ren R4262101 tookAPbio2000
ren R4262102 tookAPchem2000
ren R4262103 tookAPcompSci2000
ren R4262104 tookAPecon2000
ren R4262105 tookAPeng2000
ren R4262106 tookAPfrench2000
ren R4262107 tookAPgerman2000
ren R4262108 tookAPgov2000
ren R4262109 tookAPhistory2000
ren R4262110 tookAPlatin2000
ren R4262111 tookAPmath2000
ren R4262112 tookAPmusic2000
ren R4262113 tookAPphysics2000
ren R4262114 tookAPpsychology2000
ren R4262115 tookAPspanish2000
ren R4262116 tookAPnone2000
ren R4262300 DLItookAPart2000
ren R4262301 DLItookAPbio2000
ren R4262302 DLItookAPchem2000
ren R4262303 DLItookAPcompSci2000
ren R4262304 DLItookAPecon2000
ren R4262305 DLItookAPeng2000
ren R4262306 DLItookAPfrench2000
ren R4262307 DLItookAPgerman2000
ren R4262308 DLItookAPgov2000
ren R4262309 DLItookAPhistory2000
ren R4262310 DLItookAPlatin2000
ren R4262311 DLItookAPmath2000
ren R4262312 DLItookAPmusic2000
ren R4262313 DLItookAPphysics2000
ren R4262314 DLItookAPpsychology2000
ren R4262315 DLItookAPspanish2000
ren R4262316 DLItookAPnone2000
ren R5919800 tookAPart2001
ren R5919801 tookAPbio2001
ren R5919802 tookAPchem2001
ren R5919803 tookAPcompSci2001
ren R5919804 tookAPecon2001
ren R5919805 tookAPeng2001
ren R5919806 tookAPfrench2001
ren R5919807 tookAPgerman2001
ren R5919808 tookAPgov2001
ren R5919809 tookAPhistory2001
ren R5919810 tookAPlatin2001
ren R5919811 tookAPmath2001
ren R5919812 tookAPmusic2001
ren R5919813 tookAPphysics2001
ren R5919814 tookAPpsychology2001
ren R5919815 tookAPspanish2001
ren R5919816 tookAPnone2001
ren R5920000 DLItookAPart2001
ren R5920001 DLItookAPbio2001
ren R5920002 DLItookAPchem2001
ren R5920003 DLItookAPcompSci2001
ren R5920004 DLItookAPecon2001
ren R5920005 DLItookAPeng2001
ren R5920006 DLItookAPfrench2001
ren R5920007 DLItookAPgerman2001
ren R5920008 DLItookAPgov2001
ren R5920009 DLItookAPhistory2001
ren R5920010 DLItookAPlatin2001
ren R5920011 DLItookAPmath2001
ren R5920012 DLItookAPmusic2001
ren R5920013 DLItookAPphysics2001
ren R5920014 DLItookAPpsychology2001
ren R5920015 DLItookAPspanish2001
ren R5920016 DLItookAPnone2001
ren S0294100 tookAPart2002
ren S0294101 tookAPbio2002
ren S0294102 tookAPchem2002
ren S0294103 tookAPcompSci2002
ren S0294104 tookAPecon2002
ren S0294105 tookAPeng2002
ren S0294106 tookAPfrench2002
ren S0294107 tookAPgerman2002
ren S0294108 tookAPgov2002
ren S0294109 tookAPhistory2002
ren S0294110 tookAPlatin2002
ren S0294111 tookAPmath2002
ren S0294112 tookAPmusic2002
ren S0294113 tookAPphysics2002
ren S0294114 tookAPpsychology2002
ren S0294115 tookAPspanish2002
ren S0294116 tookAPnone2002
ren S0294300 DLItookAPart2002
ren S0294301 DLItookAPbio2002
ren S0294302 DLItookAPchem2002
ren S0294303 DLItookAPcompSci2002
ren S0294304 DLItookAPecon2002
ren S0294305 DLItookAPeng2002
ren S0294306 DLItookAPfrench2002
ren S0294307 DLItookAPgerman2002
ren S0294308 DLItookAPgov2002
ren S0294309 DLItookAPhistory2002
ren S0294310 DLItookAPlatin2002
ren S0294311 DLItookAPmath2002
ren S0294312 DLItookAPmusic2002
ren S0294313 DLItookAPphysics2002
ren S0294314 DLItookAPpsychology2002
ren S0294315 DLItookAPspanish2002
ren S0294316 DLItookAPnone2002
ren S2332900 tookAPart2003
ren S2332901 tookAPbio2003
ren S2332902 tookAPchem2003
ren S2332903 tookAPcompSci2003
ren S2332904 tookAPecon2003
ren S2332905 tookAPeng2003
ren S2332906 tookAPfrench2003
ren S2332907 tookAPgerman2003
ren S2332908 tookAPgov2003
ren S2332909 tookAPhistory2003
ren S2332910 tookAPlatin2003
ren S2332911 tookAPmath2003
ren S2332912 tookAPmusic2003
ren S2332913 tookAPphysics2003
ren S2332914 tookAPpsychology2003
ren S2332915 tookAPspanish2003
ren S2332916 tookAPnone2003
ren S2333100 DLItookAPart2003
ren S2333101 DLItookAPbio2003
ren S2333102 DLItookAPchem2003
ren S2333103 DLItookAPcompSci2003
ren S2333104 DLItookAPecon2003
ren S2333105 DLItookAPeng2003
ren S2333106 DLItookAPfrench2003
ren S2333107 DLItookAPgerman2003
ren S2333108 DLItookAPgov2003
ren S2333109 DLItookAPhistory2003
ren S2333110 DLItookAPlatin2003
ren S2333111 DLItookAPmath2003
ren S2333112 DLItookAPmusic2003
ren S2333113 DLItookAPphysics2003
ren S2333114 DLItookAPpsychology2003
ren S2333115 DLItookAPspanish2003
ren S2333116 DLItookAPnone2003
ren S4104600 tookAPart2004
ren S4104601 tookAPbio2004
ren S4104602 tookAPchem2004
ren S4104603 tookAPcompSci2004
ren S4104604 tookAPecon2004
ren S4104605 tookAPeng2004
ren S4104606 tookAPfrench2004
ren S4104607 tookAPgerman2004
ren S4104608 tookAPgov2004
ren S4104609 tookAPhistory2004
ren S4104610 tookAPlatin2004
ren S4104611 tookAPmath2004
ren S4104612 tookAPmusic2004
ren S4104613 tookAPphysics2004
ren S4104614 tookAPpsychology2004
ren S4104615 tookAPspanish2004
ren S4104616 tookAPnone2004
ren S4104800 DLItookAPart2004
ren S4104801 DLItookAPbio2004
ren S4104802 DLItookAPchem2004
ren S4104803 DLItookAPcompSci2004
ren S4104804 DLItookAPecon2004
ren S4104805 DLItookAPeng2004
ren S4104806 DLItookAPfrench2004
ren S4104807 DLItookAPgerman2004
ren S4104808 DLItookAPgov2004
ren S4104809 DLItookAPhistory2004
ren S4104810 DLItookAPlatin2004
ren S4104811 DLItookAPmath2004
ren S4104812 DLItookAPmusic2004
ren S4104813 DLItookAPphysics2004
ren S4104814 DLItookAPpsychology2004
ren S4104815 DLItookAPspanish2004
ren S4104816 DLItookAPnone2004
ren S5664700 tookAPart2005
ren S5664701 tookAPbio2005
ren S5664702 tookAPchem2005
ren S5664703 tookAPcompSci2005
ren S5664704 tookAPecon2005
ren S5664705 tookAPeng2005
ren S5664706 tookAPfrench2005
ren S5664707 tookAPgerman2005
ren S5664708 tookAPgov2005
ren S5664709 tookAPhistory2005
ren S5664710 tookAPlatin2005
ren S5664711 tookAPmath2005
ren S5664712 tookAPmusic2005
ren S5664713 tookAPphysics2005
ren S5664714 tookAPpsychology2005
ren S5664715 tookAPspanish2005
ren S5664716 tookAPnone2005
ren S5664900 DLItookAPart2005
ren S5664901 DLItookAPbio2005
ren S5664902 DLItookAPchem2005
ren S5664903 DLItookAPcompSci2005
ren S5664904 DLItookAPecon2005
ren S5664905 DLItookAPeng2005
ren S5664906 DLItookAPfrench2005
ren S5664907 DLItookAPgerman2005
ren S5664908 DLItookAPgov2005
ren S5664909 DLItookAPhistory2005
ren S5664910 DLItookAPlatin2005
ren S5664911 DLItookAPmath2005
ren S5664912 DLItookAPmusic2005
ren S5664913 DLItookAPphysics2005
ren S5664914 DLItookAPpsychology2005
ren S5664915 DLItookAPspanish2005
ren S5664916 DLItookAPnone2005
ren S7740700 tookAPart2006
ren S7740701 tookAPbio2006
ren S7740702 tookAPchem2006
ren S7740703 tookAPcompSci2006
ren S7740704 tookAPecon2006
ren S7740705 tookAPeng2006
ren S7740706 tookAPfrench2006
ren S7740707 tookAPgerman2006
ren S7740708 tookAPgov2006
ren S7740709 tookAPhistory2006
ren S7740710 tookAPlatin2006
ren S7740711 tookAPmath2006
ren S7740712 tookAPmusic2006
ren S7740713 tookAPphysics2006
ren S7740714 tookAPpsychology2006
ren S7740715 tookAPspanish2006
ren S7740716 tookAPnone2006
ren S7740900 DLItookAPart2006
ren S7740901 DLItookAPbio2006
ren S7740902 DLItookAPchem2006
ren S7740903 DLItookAPcompSci2006
ren S7740904 DLItookAPecon2006
ren S7740905 DLItookAPeng2006
ren S7740906 DLItookAPfrench2006
ren S7740907 DLItookAPgerman2006
ren S7740908 DLItookAPgov2006
ren S7740909 DLItookAPhistory2006
ren S7740910 DLItookAPlatin2006
ren S7740911 DLItookAPmath2006
ren S7740912 DLItookAPmusic2006
ren S7740913 DLItookAPphysics2006
ren S7740914 DLItookAPpsychology2006
ren S7740915 DLItookAPspanish2006
ren S7740916 DLItookAPnone2006
ren T0197400 tookAPart2007
ren T0197401 tookAPbio2007
ren T0197402 tookAPchem2007
ren T0197403 tookAPcompSci2007
ren T0197404 tookAPecon2007
ren T0197405 tookAPeng2007
ren T0197406 tookAPfrench2007
ren T0197407 tookAPgerman2007
ren T0197408 tookAPgov2007
ren T0197409 tookAPhistory2007
ren T0197410 tookAPlatin2007
ren T0197411 tookAPmath2007
ren T0197412 tookAPmusic2007
ren T0197413 tookAPphysics2007
ren T0197414 tookAPpsychology2007
ren T0197415 tookAPspanish2007
ren T0197416 tookAPnone2007
ren T0197600 DLItookAPart2007
ren T0197601 DLItookAPbio2007
ren T0197602 DLItookAPchem2007
ren T0197603 DLItookAPcompSci2007
ren T0197604 DLItookAPecon2007
ren T0197605 DLItookAPeng2007
ren T0197606 DLItookAPfrench2007
ren T0197607 DLItookAPgerman2007
ren T0197608 DLItookAPgov2007
ren T0197609 DLItookAPhistory2007
ren T0197610 DLItookAPlatin2007
ren T0197611 DLItookAPmath2007
ren T0197612 DLItookAPmusic2007
ren T0197613 DLItookAPphysics2007
ren T0197614 DLItookAPpsychology2007
ren T0197615 DLItookAPspanish2007
ren T0197616 DLItookAPnone2007
ren R0062300 scoreAPart1997
ren R0062400 scoreAPbio1997
ren R0062500 scoreAPchem1997
ren R0062600 scoreAPcompSci1997
ren R0062700 scoreAPecon1997
ren R0062800 scoreAPeng1997
ren R0062900 scoreAPfrench1997
ren R0063000 scoreAPgov1997
ren R0063100 scoreAPhistory1997
ren R0063200 scoreAPlatin1997
ren R0063300 scoreAPmath1997
ren R0063400 scoreAPmusic1997
ren R0063500 scoreAPphysics1997
ren R0063600 scoreAPpsychology1997
ren R0063700 scoreAPspanish1997
ren R0043600 scoreAPbio1996
ren R0043700 scoreAPeng1996
ren R0043800 scoreAPmusic1996
gen scoreAPart2007        = .
gen scoreAPbio2007        = .
gen scoreAPchem2007       = .
gen scoreAPcompSci2007    = .
gen scoreAPecon2007       = .
gen scoreAPeng2007        = .
gen scoreAPfrench2007     = .
gen scoreAPgerman2007     = .
gen scoreAPgov2007        = .
gen scoreAPhistory2007    = .
gen scoreAPlatin2007      = .
gen scoreAPmath2007       = .
gen scoreAPmusic2007      = .
gen scoreAPphysics2007    = .
gen scoreAPpsychology2007 = .
gen scoreAPspanish2007    = .

ren R1204700 Family_net_worth1996

ren R1204500 Family_income1996
ren R2563300 Family_income1997
ren R3884900 Family_income1998
ren R5464100 Family_income1999
ren R7227800 Family_income2000
ren S1541700 Family_income2001
ren S2011500 Family_income2002
ren S3812400 Family_income2003
ren S5412800 Family_income2004
ren S7513700 Family_income2005
ren T0014100 Family_income2006
ren T2016200 Family_income2007
ren T3606500 Family_income2008
ren T5206900 Family_income2009
ren T6656700 Family_income2010
ren T8129100 Family_income2012
ren U0008900 Family_income2014

ren R0490200 IncomePvs1997
ren R2341200 IncomePvs1998
ren R3650200 IncomePvs1999
ren R5098900 IncomePvs2000
ren R6827500 IncomePvs2001
ren S1055800 IncomePvs2002
ren S3134600 IncomePvs2003
ren S4799600 IncomePvs2004
ren S6501000 IncomePvs2005
ren S8496500 IncomePvs2006
ren T0889800 IncomePvs2007
ren T3003000 IncomePvs2008
ren T4406000 IncomePvs2009
ren T6055500 IncomePvs2010
ren T7545600 IncomePvs2011
ren T8976700 IncomePvs2013
ren U0956900 IncomePvs2015

ren R2399400 parIncome1997
ren R3707300 parIncome1998
ren R5164800 parIncome1999
ren R6893100 parIncome2000
ren R2399600 parSpIncome1997
ren R3707500 parSpIncome1998
ren R5165000 parSpIncome1999
ren R6893300 parSpIncome2000
ren R2399800 parSpOthIncome1997
ren R3707700 parSpOthIncome1998
ren R5165200 parSpOthIncome1999
ren R6893500 parSpOthIncome2000

ren R1302400 Bio_father_highest_educ
ren R1302500 Bio_mother_highest_educ

ren R2510200 reason_noninterview1998
ren R3827700 reason_noninterview1999
ren R5341500 reason_noninterview2000
ren R7085400 reason_noninterview2001
ren S1524700 reason_noninterview2002
ren S3590300 reason_noninterview2003
ren S4966600 reason_noninterview2004
ren S6706700 reason_noninterview2005
ren S8679600 reason_noninterview2006
ren T1099500 reason_noninterview2007
ren T3176800 reason_noninterview2008
ren T4587900 reason_noninterview2009
ren T6221000 reason_noninterview2010
ren T7718200 reason_noninterview2011
ren T9118900 reason_noninterview2013
ren U1110400 reason_noninterview2015

ren R0496500 allowance1997
ren R2346300 allowance1998
ren R3655400 allowance1999
ren R5104100 allowance2000
ren R6832700 allowance2001
ren S1061400 allowance2002
ren S3140200 allowance2003

ren R0493200 totParGave1997
ren R0493300 estParGave1997
ren R0494200 totMomGave1997
ren R0494300 estMomGave1997
ren R0495200 totDadGave1997
ren R0495300 estDadGave1997
ren R2344700 totParGave1998
ren R2344800 estParGave1998
ren R2345100 totMomGave1998
ren R2345200 estMomGave1998
ren R2345500 totDadGave1998
ren R2345600 estDadGave1998
ren R3653800 totParGave1999
ren R3653900 estParGave1999
ren R3654200 totMomGave1999
ren R3654300 estMomGave1999
ren R3654600 totDadGave1999
ren R3654700 estDadGave1999
ren R5102500 totParGave2000
ren R5102600 estParGave2000
ren R5102900 totMomGave2000
ren R5103000 estMomGave2000
ren R5103300 totDadGave2000
ren R5103400 estDadGave2000
ren R6831100 totParGave2001
ren R6831200 estParGave2001
ren R6831500 totMomGave2001
ren R6831600 estMomGave2001
ren R6831900 totDadGave2001
ren R6832000 estDadGave2001
ren S1059800 totParGave2002
ren S1059900 estParGave2002
ren S1060200 totMomGave2002
ren S1060300 estMomGave2002
ren S1060600 totDadGave2002
ren S1060700 estDadGave2002
ren S3138600 totParGave2003
ren S3138700 estParGave2003
ren S3139000 totMomGave2003
ren S3139100 estMomGave2003
ren S3139400 totDadGave2003
ren S3139500 estDadGave2003

ren S4803500 estFamTrans2003
ren S6505000 estFamTrans2004
ren S8500900 estFamTrans2005
ren T0894000 estFamTrans2006
ren T3007300 estFamTrans2007
ren T4410200 estFamTrans2008
ren T6059700 estFamTrans2009
ren T7549800 estFamTrans2010

ren R2416300 HH1rel1998
ren R2416400 HH2rel1998
ren R2416500 HH3rel1998
ren R2416600 HH4rel1998
ren R2416700 HH5rel1998
ren R2416800 HH6rel1998
ren R2416900 HH7rel1998
ren R2417000 HH8rel1998
ren R2417100 HH9rel1998
ren R2417200 HH10rel1998
ren R2417300 HH11rel1998
ren R2417400 HH12rel1998
ren R2417500 HH13rel1998
ren R2417600 HH14rel1998
ren R3726900 HH1rel1999
ren R3727000 HH2rel1999
ren R3727100 HH3rel1999
ren R3727200 HH4rel1999
ren R3727300 HH5rel1999
ren R3727400 HH6rel1999
ren R3727500 HH7rel1999
ren R3727600 HH8rel1999
ren R3727700 HH9rel1999
ren R3727800 HH10rel1999
ren R3727900 HH11rel1999
ren R3728000 HH12rel1999
ren R3728100 HH13rel1999
ren R3728200 HH14rel1999
ren R5191800 HH1rel2000
ren R5191900 HH2rel2000
ren R5192000 HH3rel2000
ren R5192100 HH4rel2000
ren R5192200 HH5rel2000
ren R5192300 HH6rel2000
ren R5192400 HH7rel2000
ren R5192500 HH8rel2000
ren R5192600 HH9rel2000
ren R5192700 HH10rel2000
ren R5192800 HH11rel2000
ren R5192900 HH12rel2000
ren R5193000 HH13rel2000
ren R5193100 HH14rel2000
ren R6919700 HH1rel2001
ren R6919800 HH2rel2001
ren R6919900 HH3rel2001
ren R6920000 HH4rel2001
ren R6920100 HH5rel2001
ren R6920200 HH6rel2001
ren R6920300 HH7rel2001
ren R6920400 HH8rel2001
ren R6920500 HH9rel2001
ren R6920600 HH10rel2001
ren R6920700 HH11rel2001
ren R6920800 HH12rel2001
ren R6920900 HH13rel2001
ren R6921000 HH14rel2001
ren R6921100 HH15rel2001
ren R6921200 HH16rel2001
ren S1353900 HH1rel2002
ren S1354000 HH2rel2002
ren S1354100 HH3rel2002
ren S1354200 HH4rel2002
ren S1354300 HH5rel2002
ren S1354400 HH6rel2002
ren S1354500 HH7rel2002
ren S1354600 HH8rel2002
ren S1354700 HH9rel2002
ren S1354800 HH10rel2002
ren S1354900 HH11rel2002
ren S1355000 HH12rel2002
ren S1355100 HH13rel2002
ren S3417000 HH1rel2003
ren S3417100 HH2rel2003
ren S3417200 HH3rel2003
ren S3417300 HH4rel2003
ren S3417400 HH5rel2003
ren S3417500 HH6rel2003
ren S3417600 HH7rel2003
ren S3417700 HH8rel2003
ren S3417800 HH9rel2003
ren S3417900 HH10rel2003
ren S3418000 HH11rel2003
ren S3418100 HH12rel2003
ren S3418200 HH13rel2003
ren S5171600 HH1rel2004
ren S5171700 HH2rel2004
ren S5171800 HH3rel2004
ren S5171900 HH4rel2004
ren S5172000 HH5rel2004
ren S5172100 HH6rel2004
ren S5172200 HH7rel2004
ren S5172300 HH8rel2004
ren S5172400 HH9rel2004
ren S5172500 HH10rel2004
ren S5172600 HH11rel2004
ren S5172700 HH12rel2004
ren S6946900 HH1rel2005
ren S6947000 HH2rel2005
ren S6947100 HH3rel2005
ren S6947200 HH4rel2005
ren S6947300 HH5rel2005
ren S6947400 HH6rel2005
ren S6947500 HH7rel2005
ren S6947600 HH8rel2005
ren S6947700 HH9rel2005
ren S6947800 HH10rel2005
ren S6947900 HH11rel2005
ren S6948000 HH12rel2005
ren S6948100 HH13rel2005
ren S8922600 HH1rel2006
ren S8922700 HH2rel2006
ren S8922800 HH3rel2006
ren S8922900 HH4rel2006
ren S8923000 HH5rel2006
ren S8923100 HH6rel2006
ren S8923200 HH7rel2006
ren S8923300 HH8rel2006
ren S8923400 HH9rel2006
ren S8923500 HH10rel2006
ren S8923600 HH11rel2006
ren S8923700 HH12rel2006
ren S8923800 HH13rel2006
ren S8923900 HH14rel2006
ren T1333500 HH1rel2007
ren T1333600 HH2rel2007
ren T1333700 HH3rel2007
ren T1333800 HH4rel2007
ren T1333900 HH5rel2007
ren T1334000 HH6rel2007
ren T1334100 HH7rel2007
ren T1334200 HH8rel2007
ren T1334300 HH9rel2007
ren T1334400 HH10rel2007
ren T1334500 HH11rel2007
ren T3424400 HH1rel2008
ren T3424500 HH2rel2008
ren T3424600 HH3rel2008
ren T3424700 HH4rel2008
ren T3424800 HH5rel2008
ren T3424900 HH6rel2008
ren T3425000 HH7rel2008
ren T3425100 HH8rel2008
ren T3425200 HH9rel2008
ren T3425300 HH10rel2008
ren T3425400 HH11rel2008
ren T3425500 HH12rel2008
ren T3425600 HH13rel2008
ren T4845300 HH1rel2009
ren T4845400 HH2rel2009
ren T4845500 HH3rel2009
ren T4845600 HH4rel2009
ren T4845700 HH5rel2009
ren T4845800 HH6rel2009
ren T4845900 HH7rel2009
ren T4846000 HH8rel2009
ren T4846100 HH9rel2009
ren T4846200 HH10rel2009
ren T4846300 HH11rel2009
ren T4846400 HH12rel2009
ren T4846500 HH13rel2009
ren T4846600 HH14rel2009
ren T4846700 HH15rel2009
ren T4846800 HH16rel2009
ren T4846900 HH17rel2009
ren T4847000 HH18rel2009
ren T6491500 HH1rel2010
ren T6491600 HH2rel2010
ren T6491700 HH3rel2010
ren T6491800 HH4rel2010
ren T6491900 HH5rel2010
ren T6492000 HH6rel2010
ren T6492100 HH7rel2010
ren T6492200 HH8rel2010
ren T6492300 HH9rel2010
ren T6492400 HH10rel2010
ren T6492500 HH11rel2010
ren T6492600 HH12rel2010
ren T6492700 HH13rel2010
ren T6492800 HH14rel2010
ren T6492900 HH15rel2010
ren T7994600 HH1rel2011
ren T7994700 HH2rel2011
ren T7994800 HH3rel2011
ren T7994900 HH4rel2011
ren T7995000 HH5rel2011
ren T7995100 HH6rel2011
ren T7995200 HH7rel2011
ren T7995300 HH8rel2011
ren T7995400 HH9rel2011
ren T7995500 HH10rel2011
ren T7995600 HH11rel2011
ren T7995700 HH12rel2011
ren T7995800 HH13rel2011
ren T7995900 HH14rel2011
ren T9253700 HH1rel2013
ren T9253800 HH2rel2013
ren T9253900 HH3rel2013
ren T9254000 HH4rel2013
ren T9254100 HH5rel2013
ren T9254200 HH6rel2013
ren T9254300 HH7rel2013
ren T9254400 HH8rel2013
ren T9254500 HH9rel2013
ren T9254600 HH10rel2013
ren T9254700 HH11rel2013
ren T9254800 HH12rel2013
ren U1261700 HH1rel2015
ren U1261800 HH2rel2015
ren U1261900 HH3rel2015
ren U1262000 HH4rel2015
ren U1262100 HH5rel2015
ren U1262200 HH6rel2015
ren U1262300 HH7rel2015
ren U1262400 HH8rel2015
ren U1262500 HH9rel2015
ren U1262600 HH10rel2015
ren U1262700 HH11rel2015
ren U1262800 HH12rel2015
ren U1262900 HH13rel2015
ren U1263000 HH14rel2015
ren U1263100 HH15rel2015
ren U1263200 HH16rel2015
ren U1263300 HH17rel2015

ren R0071600 TimeWakeUp1997
ren R0071700 R1IsThereARegPlace
ren R0071900 R1TimeLeaveForPlace1
ren R0072000 R1TimeLeaveForPlace2
ren R0072100 R1TimeLeaveForPlace3
ren R0072200 R1TimeLeaveForPlace4
ren R0072300 R1TimeArriveFromPlace1
ren R0072400 R1TimeArriveFromPlace2
ren R0072500 R1TimeArriveFromPlace3
ren R0072600 R1TimeArriveFromPlace4
ren R2163200 TimeWakeUp1998
ren R2163300 TimeLeaveHome1998
ren R2163400 TimeArriveHome1998
ren R2163500 TimeGoToSleep1998
ren R2163700 HrsSpendPlace1_1998
ren R2163800 HrsSpendPlace2_1998
ren R2163900 HrsSpendPlace3_1998
ren R3481000 TimeWakeUp1999
ren R3481100 TimeLeaveHome1999
ren R3481200 TimeArriveHome1999
ren R3481300 TimeGoToSleep1999
ren R3481500 HrsSpendPlace1_1999
ren R3481600 HrsSpendPlace2_1999
ren R3481700 HrsSpendPlace3_1999
ren R0072900 R1Homework
ren R0073000 R1WeekdaysHomework
ren R0073100 R1hoursWeekdayHomework
ren R0073200 R1minsWeekdayHomework
ren R0073300 R1hoursWeekendHomework
ren R0073400 R1minsWeekendHomework
ren R0073500 R1ExtraClass
ren R0073600 R1WeekdaysExtraClass
ren R0073700 R1hoursWeekdayExtraClass
ren R0073800 R1minsWeekdayExtraClass
ren R0073900 R1hoursWeekendExtraClass
ren R0074000 R1minsWeekendExtraClass
ren R0074100 R1WatchTV
ren R0074200 R1WeekdaysWatchTV
ren R0074300 R1hoursWeekdayWatchTV
ren R0074400 R1minsWeekdayWatchTV
ren R0074500 R1hoursWeekendWatchTV
ren R0074600 R1minsWeekendWatchTV
ren R0074700 R1ReadPleasure
ren R0074800 R1WeekdaysReadPleasure
ren R0074900 R1hoursWeekdayReadPleasure
ren R0075000 R1minsWeekdayReadPleasure
ren R0075100 R1hoursWeekendReadPleasure
ren R0075200 R1minsWeekendReadPleasure
ren S8645900 samplingGroupR10TimeUse
ren S8646000 TimeUseR10opinionPaidJob
ren S8646100 TimeUseR10opinionHousework
ren S8646200 TimeUseR10opinionFamily
ren S8646300 TimeUseR10opinionFriends
ren S8646400 TimeUseR10opinionLeisure
ren S8646500 TimeUseR10opinionRelaxing
ren S8646600 TimeUseR10opinionAmntTime
ren S8646700 TimeUseR10opinionExtraTime
ren S1225400 HrsWeekUseComputer2002
ren S1225500 HrsWeekWatchTV2002
ren S1225600 HrsNightSleep2002
ren T1049900 HrsWeekUseComputer2007
ren T1050000 HrsWeekWatchTV2007
ren T1050100 HrsNightSleep2007
ren T3145100 HrsWeekUseComputer2008
ren T3145200 HrsWeekWatchTV2008
ren T3145300 HrsNightSleep2008
ren T4565400 HrsWeekUseComputer2009
ren T4565500 HrsWeekWatchTV2009
ren T4565600 HrsNightSleep2009
ren T6209600 HrsWeekUseComputer2010
ren T6209700 HrsWeekWatchTV2010
ren T6209800 HrsNightSleep2010
ren T7707000 HrsWeekUseComputer2011
ren T7707100 HrsWeekWatchTV2011
ren T7707200 HrsNightSleep2011
ren U1099700 HrsWeekUseComputer2015
ren U1099800 HrsWeekWatchTV2015
ren U1099900 HrsNightSleep2015


ren R0675400 tookClassDuringBreak
ren R0675500 yrTookClassDuringBreak1         // PC8-154.01 YEAR R TOOK CLASSES DURING BREAK? PRD 01 1997
ren R0675600 yrTookClassDuringBreak2         // PC8-154.02 YEAR R TOOK CLASSES DURING BREAK? PRD 02 1997
ren R0675700 yrTookClassDuringBreak3         // PC8-154.03 YEAR R TOOK CLASSES DURING BREAK? PRD 03 1997
ren R0675800 yrTookClassDuringBreak4         // PC8-154.04 YEAR R TOOK CLASSES DURING BREAK? PRD 04 1997
ren R0675900 yrTookClassDuringBreak5         // PC8-154.05 YEAR R TOOK CLASSES DURING BREAK? PRD 05 1997
ren R0676000 yrTookClassDuringBreak6         // PC8-154.06 YEAR R TOOK CLASSES DURING BREAK? PRD 06 1997
ren R0676100 yrTookClassDuringBreak7         // PC8-154.07 YEAR R TOOK CLASSES DURING BREAK? PRD 07 1997
ren R0676200 yrTookClassDuringBreak8         // PC8-154.08 YEAR R TOOK CLASSES DURING BREAK? PRD 08 1997
ren R0676300 yrTookClassDuringBreak9         // PC8-154.09 YEAR R TOOK CLASSES DURING BREAK? PRD 09 1997
ren R0676400 yrTookClassDuringBreak10        // PC8-154.10 YEAR R TOOK CLASSES DURING BREAK? PRD 10 1997
ren R0676500 yrTookClassDuringBreak11        // PC8-154.11 YEAR R TOOK CLASSES DURING BREAK? PRD 11 1997
ren R0676600 yrTookClassDuringBreak12        // PC8-154.12 YEAR R TOOK CLASSES DURING BREAK? PRD 12 1997
ren R0676700 reasonTookClassDuringBreak1     // PC8-155.01 REASON R ATTENDED CLASS DURING BREAK? PRD 01 1997
ren R0676800 reasonTookClassDuringBreak2     // PC8-155.02 REASON R ATTENDED CLASS DURING BREAK? PRD 02 1997
ren R0676900 reasonTookClassDuringBreak3     // PC8-155.03 REASON R ATTENDED CLASS DURING BREAK? PRD 03 1997
ren R0677000 reasonTookClassDuringBreak4     // PC8-155.04 REASON R ATTENDED CLASS DURING BREAK? PRD 04 1997
ren R0677100 reasonTookClassDuringBreak5     // PC8-155.05 REASON R ATTENDED CLASS DURING BREAK? PRD 05 1997
ren R0677200 reasonTookClassDuringBreak6     // PC8-155.06 REASON R ATTENDED CLASS DURING BREAK? PRD 06 1997
ren R0677300 reasonTookClassDuringBreak7     // PC8-155.07 REASON R ATTENDED CLASS DURING BREAK? PRD 07 1997
ren R0677400 reasonTookClassDuringBreak8     // PC8-155.08 REASON R ATTENDED CLASS DURING BREAK? PRD 08 1997
ren R0677500 reasonTookClassDuringBreak9     // PC8-155.09 REASON R ATTENDED CLASS DURING BREAK? PRD 09 1997
ren R0677600 reasonTookClassDuringBreak10    // PC8-155.10 REASON R ATTENDED CLASS DURING BREAK? PRD 10 1997
ren R0677700 reasonTookClassDuringBreak11    // PC8-155.11 REASON R ATTENDED CLASS DURING BREAK? PRD 11 1997
ren R0677800 reasonTookClassDuringBreak12    // PC8-155.12 REASON R ATTENDED CLASS DURING BREAK? PRD 12 1997
ren R0677900 anotherYrTookClassDuringBreak1  // PC8-156.01 ANOTHER YEAR R TOOK CLASS DURING BREAK? PRD 01 1997
ren R0678000 anotherYrTookClassDuringBreak2  // PC8-156.02 ANOTHER YEAR R TOOK CLASS DURING BREAK? PRD 02 1997
ren R0678100 anotherYrTookClassDuringBreak3  // PC8-156.03 ANOTHER YEAR R TOOK CLASS DURING BREAK? PRD 03 1997
ren R0678200 anotherYrTookClassDuringBreak4  // PC8-156.04 ANOTHER YEAR R TOOK CLASS DURING BREAK? PRD 04 1997
ren R0678300 anotherYrTookClassDuringBreak5  // PC8-156.05 ANOTHER YEAR R TOOK CLASS DURING BREAK? PRD 05 1997
ren R0678400 anotherYrTookClassDuringBreak6  // PC8-156.06 ANOTHER YEAR R TOOK CLASS DURING BREAK? PRD 06 1997
ren R0678500 anotherYrTookClassDuringBreak7  // PC8-156.07 ANOTHER YEAR R TOOK CLASS DURING BREAK? PRD 07 1997
ren R0678600 anotherYrTookClassDuringBreak8  // PC8-156.08 ANOTHER YEAR R TOOK CLASS DURING BREAK? PRD 08 1997
ren R0678700 anotherYrTookClassDuringBreak9  // PC8-156.09 ANOTHER YEAR R TOOK CLASS DURING BREAK? PRD 09 1997
ren R0678800 anotherYrTookClassDuringBreak10 // PC8-156.10 ANOTHER YEAR R TOOK CLASS DURING BREAK? PRD 10 1997
ren R0678900 anotherYrTookClassDuringBreak11 // PC8-156.11 ANOTHER YEAR R TOOK CLASS DURING BREAK? PRD 11 1997
ren R0679000 anotherYrTookClassDuringBreak12 // PC8-156.12 ANOTHER YEAR R TOOK CLASS DURING BREAK? PRD 12 1997
ren R0679100 everTakeRemedialEnglish         // PC8-158_000001 R EVER TAKE REMEDIAL/SPECIAL ED CLASS? 1997
ren R0679101 everTakeRemedialMath            // PC8-158_000002 R EVER TAKE REMEDIAL/SPECIAL ED CLASS? 1997
ren R0679102 everTakeLangImmersion           // PC8-158_000003 R EVER TAKE REMEDIAL/SPECIAL ED CLASS? 1997
ren R0679103 everTakeESL                     // PC8-158_000004 R EVER TAKE REMEDIAL/SPECIAL ED CLASS? 1997
ren R0679104 everTakeMentalSpecialEd         // PC8-158_000005 R EVER TAKE REMEDIAL/SPECIAL ED CLASS? 1997
ren R0679105 everTakePhysicalSpecialEd       // PC8-158_000006 R EVER TAKE REMEDIAL/SPECIAL ED CLASS? 1997
ren R0679106 everTakeGiftedTalented          // PC8-158_000007 R EVER TAKE REMEDIAL/SPECIAL ED CLASS? 1997
ren R0679107 everTakeMagnetProgram           // PC8-158_000008 R EVER TAKE REMEDIAL/SPECIAL ED CLASS? 1997
ren R0679108 neverTookExtremalEdProg         // PC8-158_000000 R EVER TAKE REMEDIAL/SPECIAL ED CLASS? 1997

ren R0513700 pctChanceSchNextYr1997
ren R0514700 pctChanceHSdiplomaBy20
ren R0515100 pctChanceBAby30_1997
ren R0688500 parPctChanceSchNextYr
ren R0688700 parPctChanceHSdiplomaBy20
ren R0689000 parPctChanceBAby30
ren R0515200 pctChanceWork20Hrs30
ren R0689100 parPctChanceWork20Hrs30
ren R5155100 pctChanceSchNextYr2000
ren R5156200 pctChanceSch5yrs2000
ren R5513400 validationPctChanceSchNextYr2000
ren R5513700 validationPctChanceSch5yrs2000
ren R6884300 pctChanceSch5yrs2001
ren R6884400 pctChanceBAby30_2001
drop R6532700

ren R0069200 lateForSchoolNoExcuse // "In the Fall term of the current school year, how many times did any of the following things happen to you?"
ren T3162701 breakRulesRegularly2008
ren T6216501 breakRulesRegularly2010
ren T3162602 highStandardsWork2008
ren T3162603 doMoreThanExpected2008
ren T6216402 highStandardsWork2010
ren T6216403 doMoreThanExpected2010


* List variables that didn't get renamed
capture d ????????

***************************************************
* Reshape and recode certain variables.
***************************************************

* exclued from reshape: ID (i) Sample_type race_ethnicity sex birth_month birth_year Bio_father_highest_educ Bio_mother_highest_educ Relationship_to_Par_age12_ Relationship_to_Par_age2_ Relationship_to_Par_age6_ HH_size ASVAB HH_size_under_18 age_mom_born marriedSp1 marriedSp2 marriedSp3 Family_net_worth1996 Student_net_worth1996 Student_net_worthAge20 Student_net_worthAge25
forvalues yr=1980/2016 {
    gen temp`yr'=0
}
reshape long temp weight_cc weight_panel Int_month InterviewM InterviewY Relationship_HH_head Born_in_US PIAT_math Family_income parIncome parSpIncome parSpOthIncome IncomePvs reason_noninterview totParGave estParGave totMomGave estMomGave totDadGave estDadGave estFamTrans HH1rel HH2rel HH3rel HH4rel HH5rel HH6rel HH7rel HH8rel HH9rel HH10rel HH11rel HH12rel HH13rel HH14rel HH15rel HH16rel HH17rel HH18rel allowance TimeWakeUp TimeLeaveHome TimeArriveHome TimeGoToSleep HrsSpendPlace1_ HrsSpendPlace2_ HrsSpendPlace3_ HrsWeekUseComputer HrsWeekWatchTV HrsNightSleep surveyACTenglish surveyACTmath surveyACTreading surveyACTscience surveyACT tookAPart tookAPbio tookAPchem tookAPcompSci tookAPecon tookAPeng tookAPfrench tookAPgerman tookAPgov tookAPhistory tookAPlatin tookAPmath tookAPmusic tookAPphysics tookAPpsychology tookAPspanish tookAPnone DLItookAPart DLItookAPbio DLItookAPchem DLItookAPcompSci DLItookAPecon DLItookAPeng DLItookAPfrench DLItookAPgerman DLItookAPgov DLItookAPhistory DLItookAPlatin DLItookAPmath DLItookAPmusic DLItookAPphysics DLItookAPpsychology DLItookAPspanish DLItookAPnone scoreAPart scoreAPbio scoreAPchem scoreAPcompSci scoreAPecon scoreAPeng scoreAPfrench scoreAPgerman scoreAPgov scoreAPhistory scoreAPlatin scoreAPmath scoreAPmusic scoreAPphysics scoreAPpsychology scoreAPspanish pctChanceSchNextYr pctChanceSch5yrs, i(ID) j(year)

drop temp
drop if mi(ID)

recode _all (-1 = .r) (-2 = .d) (-3 = .i) (-4 = .v) (-5 = .n)

***************************************************
* Label variables and values
***************************************************

label var ID                          "ID"
label var year                        "YEAR"
label var sex                         "SEX"
label var birth_month                 "BIRTH MONTH"
label var birth_year                  "BIRTH YEAR"
label var Relationship_to_Par_age12_  "RELATIONSHIP TO PARENTS AT AGE 12"
label var Relationship_to_Par_age2_   "RELATIONSHIP TO PARENTS AT AGE 2"
label var Relationship_to_Par_age6_   "RELATIONSHIP TO PARENTS AT AGE 6"
label var HH_size                     "HOUSEHOLD SIZE"
label var Sample_type                 "SAMPLE TYPE (CROSS-SECTIONAL OR OVERSAMPLE)"
label var Bio_father_highest_educ     "FATHER'S EDUCATION"
label var Bio_mother_highest_educ     "MOTHER'S EDUCATION"
label var race_ethnicity              "RACE/ETHNICITY"
label var ASVAB                       "ASVAB MATH/VERBAL SCORE PERCENTILE"
label var weight_cc                   "CUMULATIVE-CASES WEIGHTS"
label var weight_panel                "PANEL WEIGHTS"
label var Int_month                   "INTERVIEW MONTH (CONTINUOUS MONTH FORMAT)"
label var InterviewM                  "INTERVIEW MONTH (CALENDAR FORMAT)"
label var InterviewY                  "INTERVIEW YEAR (CALENDAR FORMAT)"
label var Relationship_HH_head        "RELATIONSHIP TO HOUSEHOLD HEAD"
label var Born_in_US                  "BORN IN THE US"
label var PIAT_math                   "PIAT MATH SCORE"
label var surveySATmath               "HIGHEST SAT MATH SCORE"
label var surveySATverb               "HIGHEST SAT VERBAL SCORE"
label var surveyACT                   "HIGHEST ACT SCORE"
label var Family_income               "FAMILY INCOME"
label var parIncome                   "PARENTAL INCOME (YEARS 1997-2000 ONLY)"
label var parSpIncome                 "PARENTAL/SPOUSE PARTNER INCOME (YEARS 1997-2000 ONLY)"
label var parSpOthIncome              "PARENTAL/SPOUSE PARTNER OTHER INCOME (YEARS 1997-2000 ONLY)"
label var Family_net_worth            "FAMILY NET WORTH (AT FIRST INTERVIEW, ACCORDING TO PARENT)"
label var reason_noninterview         "REASON FOR NON-INTERVIEW"
label var HH_size_under_18            "NUMBER OF MEMBERS OF HH UNDER AGE 18 IN 1997"
label var Student_net_worth1996       "STUDENT NET WORTH IN 1996"
label var Student_net_worthAge20      "STUDENT NET WORTH AT AGE 20"
label var Student_net_worthAge25      "STUDENT NET WORTH AT AGE 25"
label var age_mom_born                "MOTHER'S AGE WHEN R WAS BORN"
label var marriedSp1                  "R CONTINUOUSLY MARRIED TO SPOUSE? SPOUSE 01"
label var marriedSp2                  "R CONTINUOUSLY MARRIED TO SPOUSE? SPOUSE 02"
label var marriedSp3                  "R CONTINUOUSLY MARRIED TO SPOUSE? SPOUSE 03"

label define vl_race   1 "Black"  2 "Hispanic"  3 "Mixed Race (Non-Hispanic)"  4 "Non-Black / Non-Hispanic"
label values race_ethnicity vl_race

label define vl_sex   1 "Male"  2 "Female"  0 "No Information"
label values sex vl_sex

label define vl_relPar 1 "Both biological parents"  2 "Biological mother, other parent present"  3 "Biological father, other parent present"  4 "Biological mother, marital status unknown"  5 "Biological dad, marital status unknown"  6 "Adoptive parent(s)"  7 "Foster parent(s)"  8 "Other adults, biologial parent status unknown, not group quarters"  9 "Group quarters"  10 "Anything else"
label define vl_relHH  1 "Both biological parents"  2 "Two parents, biological mother"  3 "Two parents, biological father"  4 "Biological mother only"  5 "Biological father only"  6 "Adoptive parent(s)"  7 "Foster parent(s)"  8 "No parents, grandparents"  9 "No parents, other relatives"  10 "Anything else"
label values Relationship_to_Par_age12_ vl_relPar
label values Relationship_to_Par_age2_  vl_relPar
label values Relationship_to_Par_age6_  vl_relPar
label values Relationship_HH_head       vl_relHH

label define vl_sample  1 "Cross-sectional"  0 "Oversample"
label values Sample_type vl_sample

label define vl_int  60 "Completed in person"  61 "Completed by phone"  62 "Comp in person/conv"  63 "Comp by phone/conv"  64 "Compy by proxy parent/R disabled"  65 "Comp by proxy nonparent/R disabled"  66 "Comp in person/incarcerated"  67 "Comp by phone/incarcerated"  80 "Prior deceased blocked"  89 "NIR blocked"  90 "Final unlocatable"  91 "Very hostile refusal"  92 "Gatekeeper Refusal"  93 "R - inaccessible"  94 "Respondent too ill/handicapped"  95 "Respondent unavailable entire field period"  96 "Refusal"  97 "Hostile refusal"  98 "Deceased (current round)"  99 "Other" 113 "Refusal - Prison"
label values reason_noninterview vl_int

label define vl_origin 1 "YES"  0 "NO"
label values Born_in_US vl_origin

label define vl_HHrel  0 "Identity"  1 "Wife"  2 "Husband"  3 "Mother"  4 "Father"  5 "Adoptive mother"  6 "Adoptive father"  7 "Step-mother"  8 "Step-father"  9 "Foster mother" 10 "Foster father" 11 "Mother-in-law" 12 "Father-in-law" 13 "Sister (FULL)" 14 "Brother (FULL)" 15 "Sister (HALF - Same mother)" 16 "Sister (HALF - Same father)" 17 "Sister (HALF - don't know)" 18 "Brother (HALF - Same mother)" 19 "Brother (HALF - Same father)" 20 "Brother (HALF - don't know)" 21 "Sister (STEP)" 22 "Brother (STEP)" 23 "Sister (ADOPTIVE)" 24 "Brother (ADOPTIVE)" 25 "Sister (FOSTER)" 26 "Brother (FOSTER)" 27 "Brother-in-law" 28 "Sister-in-law" 29 "Maternal Grandmother" 30 "Paternal Grandmother" 31 "Social Grandmother" 32 "Grandmother (don't know or refused)" 33 "Maternal Grandfather" 34 "Paternal Grandfather" 35 "Social Grandfather" 36 "Grandfather (don't know or refused)" 37 "Maternal Great-Grandmother" 38 "Paternal Great-Grandmother" 39 "Social Great-Grandmother" 40 "Great-Grandmother (don't know or refused)" 41 "Maternal Great-Grandfather" 42 "Paternal Great-Grandfather" 43 "Social Great-Grandfather" 44 "Great-Grandfather (don't know or refused)" 45 "Great Great Grandmother" 46 "Great Great Grandfather" 47 "Granddaughter (Biological or social)" 48 "Grandson (Biological or social)" 49 "Daughter (Biological)" 50 "Son (Biological)" 51 "Step-daughter" 52 "Step-son" 53 "Adoptive daughter" 54 "Adoptive son" 55 "Foster daughter" 56 "Foster son" 57 "Daughter of lover/partner" 58 "Son of lover/partner" 59 "Daughter-in-law" 60 "Son-in-law" 61 "Grandmother-in-law" 62 "Grandfather-in-law" 63 "Aunt-in-law" 64 "Uncle-in-law" 65 "Cousin-in-law" 66 "Great-Grandmother-in-law" 67 "Great-Grandfather-in-law" 68 "Roommate" 69 "Lover/partner" 70 "Aunt (biological or social)" 71 "Great Aunt" 72 "Uncle (biological or social)" 73 "Great Uncle" 74 "Niece (biological or social)" 75 "Step Niece (biological or social)" 76 "Foster Niece (biological or social)" 77 "Adoptive Niece (biological or social)" 78 "Nephew (biological or social)" 79 "Step Nephew (biological or social)" 80 "Foster Nephew (biological or social)" 81 "Adoptive Nephew (biological or social)" 82 "Female cousin (biological or social)" 83 "Male cousin (biological or social)" 84 "Other relative" 85 "Other non-relative" 86 "Great Grandson" 87 "Great Granddaughter" 88 "Mother's Boyfriend/Partner" 89 "Father's Girlfriend/Partner" 90 "Parent of R's child"
foreach var in HH1rel HH2rel HH3rel HH4rel HH5rel HH6rel HH7rel HH8rel HH9rel HH10rel HH11rel HH12rel HH13rel HH14rel HH15rel HH16rel HH17rel HH18rel {
    label values `var' vl_HHrel
}

foreach var in surveyACTenglish surveyACTmath surveyACTreading surveyACTscience surveyACT {
    recode `var' (0 = .v)
}

order ID year birth* race_ethnicity sex
