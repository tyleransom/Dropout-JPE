infile using ${rawloc}y97_college_transcript.dct, clear

drop B0005300 B0005400 B0005500 B0005600 B0005700 B0005800 B0005900 B0006000 B0006100 B0006200 B0006300 B0006400 B0006500 B0006600 B0006700 B0006800 B0006900 B0007000 B0007100 B0007200 B0007300 B0007400 B0007500 B0007600 B0007700 B0007800 B0007900 B0008000 B0008100 B0008200 B0008300 B0008400 B0008500 B0008600 B0008700 B0008800

****************
* Rename
****************

ren R0000100 ID
ren B0000300 tscriptDisposition
ren B0000800 tscriptWaiverStatus
ren B0000900 institution1id
ren B0001000 institution2id
ren B0001100 institution3id
ren B0001200 institution4id
ren B0001300 institution5id
ren B0001400 institution6id
ren B0001500 institution7id
ren B0001600 institution8id
ren B0003900 tscriptOverallCredits1
ren B0004000 tscriptOverallCredits2
ren B0004100 tscriptOverallCredits3
ren B0004200 tscriptOverallCredits4
ren B0004300 tscriptOverallCredits5
ren B0004400 tscriptOverallCredits6
ren B0004500 tscriptOverallCredits7
ren B0004600 tscriptOverallGPA1
ren B0004700 tscriptOverallGPA2
ren B0004800 tscriptOverallGPA3
ren B0004900 tscriptOverallGPA4
ren B0005000 tscriptOverallGPA5
ren B0005100 tscriptOverallGPA6
ren B0005200 tscriptOverallGPA7
ren B0008900 tscriptMajor1Inst1deg1
ren B0009000 tscriptMajor2Inst1deg1
ren B0009100 tscriptMajor1Inst1deg2
ren B0009200 tscriptMajor1Inst1deg3
ren B0009300 tscriptMajor1Inst1deg4
ren B0009400 tscriptMajor1Inst1deg5
ren B0009500 tscriptMajor1Inst2deg1
ren B0009600 tscriptMajor2Inst2deg1
ren B0009700 tscriptMajor1Inst2deg2
ren B0009800 tscriptMajor1Inst2deg3
ren B0009900 tscriptMajor1Inst2deg4
ren B0010000 tscriptMajor1Inst3deg1
ren B0010100 tscriptMajor2Inst3deg1
ren B0010200 tscriptMajor1Inst3deg2
ren B0010300 tscriptMajor1Inst3deg3
ren B0010400 tscriptMajor1Inst4deg1
ren B0010500 tscriptMajor2Inst4deg1
ren B0010600 tscriptMajor1Inst4deg2
ren B0010700 tscriptMajor1Inst4deg3
ren B0010800 tscriptMajor1Inst5deg1
ren B0010900 tscriptMajor1Inst6deg1
ren B0011000 tscriptMajor1Inst7deg1
ren B0011100 tscriptMajor1Inst7deg2
ren B0011200 tscriptMajor1SrcInst1deg1
ren B0011300 tscriptMajor2SrcInst1deg1
ren B0011400 tscriptMajor1SrcInst1deg2
ren B0011500 tscriptMajor1SrcInst1deg3
ren B0011600 tscriptMajor1SrcInst1deg4
ren B0011700 tscriptMajor1SrcInst1deg5
ren B0011800 tscriptMajor1SrcInst2deg1
ren B0011900 tscriptMajor2SrcInst2deg1
ren B0012000 tscriptMajor1SrcInst2deg2
ren B0012100 tscriptMajor1SrcInst2deg3
ren B0012200 tscriptMajor1SrcInst2deg4
ren B0012300 tscriptMajor1SrcInst3deg1
ren B0012400 tscriptMajor2SrcInst3deg1
ren B0012500 tscriptMajor1SrcInst3deg2
ren B0012600 tscriptMajor1SrcInst3deg3
ren B0012700 tscriptMajor1SrcInst4deg1
ren B0012800 tscriptMajor2SrcInst4deg1
ren B0012900 tscriptMajor1SrcInst4deg2
ren B0013000 tscriptMajor1SrcInst4deg3
ren B0013100 tscriptMajor1SrcInst5deg1
ren B0013200 tscriptMajor1SrcInst6deg1
ren B0013300 tscriptMajor1SrcInst7deg1
ren B0013400 tscriptMajor1SrcInst7deg2
ren B0013500 tscriptGradYinst1deg1
ren B0013600 tscriptGradYinst1deg2
ren B0013700 tscriptGradYinst1deg3
ren B0013800 tscriptGradYinst1deg4
ren B0013900 tscriptGradYinst1deg5
ren B0014000 tscriptGradYinst2deg1
ren B0014100 tscriptGradYinst2deg2
ren B0014200 tscriptGradYinst2deg3
ren B0014300 tscriptGradYinst2deg4
ren B0014400 tscriptGradYinst3deg1
ren B0014500 tscriptGradYinst3deg2
ren B0014600 tscriptGradYinst3deg3
ren B0014700 tscriptGradYinst4deg1
ren B0014800 tscriptGradYinst4deg2
ren B0014900 tscriptGradYinst4deg3
ren B0015000 tscriptGradYinst5deg1
ren B0015100 tscriptGradYinst6deg1
ren B0015200 tscriptGradYinst7deg1
ren B0015300 tscriptGradYinst7deg2
ren B0015400 tscriptGradMinst1deg1
ren B0015500 tscriptGradMinst1deg2
ren B0015600 tscriptGradMinst1deg3
ren B0015700 tscriptGradMinst1deg4
ren B0015800 tscriptGradMinst1deg5
ren B0015900 tscriptGradMinst2deg1
ren B0016000 tscriptGradMinst2deg2
ren B0016100 tscriptGradMinst2deg3
ren B0016200 tscriptGradMinst2deg4
ren B0016300 tscriptGradMinst3deg1
ren B0016400 tscriptGradMinst3deg2
ren B0016500 tscriptGradMinst3deg3
ren B0016600 tscriptGradMinst4deg1
ren B0016700 tscriptGradMinst4deg2
ren B0016800 tscriptGradMinst4deg3
ren B0016900 tscriptGradMinst5deg1
ren B0017000 tscriptGradMinst6deg1
ren B0017100 tscriptGradMinst7deg1
ren B0017200 tscriptGradMinst7deg2
ren B0017300 tscriptInst1deg1type
ren B0017400 tscriptInst1deg2type
ren B0017500 tscriptInst1deg3type
ren B0017600 tscriptInst1deg4type
ren B0017700 tscriptInst1deg5type
ren B0017800 tscriptInst2deg1type
ren B0017900 tscriptInst2deg2type
ren B0018000 tscriptInst2deg3type
ren B0018100 tscriptInst2deg4type
ren B0018200 tscriptInst2deg5type
ren B0018300 tscriptInst3deg1type
ren B0018400 tscriptInst3deg2type
ren B0018500 tscriptInst3deg3type
ren B0018600 tscriptInst4deg1type
ren B0018700 tscriptInst4deg2type
ren B0018800 tscriptInst4deg3type
ren B0018900 tscriptInst5deg1type
ren B0019000 tscriptInst6deg1type
ren B0019100 tscriptInst7deg1type
ren B0019200 tscriptInst7deg2type
ren B0019300 institution1calendarType
ren B0019400 institution2calendarType
ren B0019500 institution3calendarType
ren B0019600 institution4calendarType
ren B0019700 institution5calendarType
ren B0019800 institution6calendarType
ren B0019900 institution7calendarType
ren B0020000 institution8calendarType
ren B0020100 institution1level
ren B0020200 institution2level
ren B0020300 institution3level
ren B0020400 institution4level
ren B0020500 institution5level
ren B0020600 institution6level
ren B0020700 institution7level
ren B0020800 institution8level
ren B0023000 institution1numAPcredits
ren B0023100 institution2numAPcredits
ren B0023200 institution3numAPcredits
ren B0023900 term1schoolID
ren B0024000 term2schoolID
ren B0024100 term3schoolID
ren B0024200 term4schoolID
ren B0024300 term5schoolID
ren B0024400 term6schoolID
ren B0024500 term7schoolID
ren B0024600 term8schoolID
ren B0024700 term9schoolID
ren B0024800 term10schoolID
ren B0024900 term11schoolID
ren B0025000 term12schoolID
ren B0025100 term13schoolID
ren B0025200 term14schoolID
ren B0025300 term15schoolID
ren B0025400 term16schoolID
ren B0025500 term17schoolID
ren B0025600 term18schoolID
ren B0025700 term19schoolID
ren B0025800 term20schoolID
ren B0025900 term21schoolID
ren B0026000 term22schoolID
ren B0026100 term23schoolID
ren B0026200 term24schoolID
ren B0026300 term25schoolID
ren B0026400 term26schoolID
ren B0026500 term27schoolID
ren B0026600 term28schoolID
ren B0026700 term29schoolID
ren B0026800 term30schoolID
ren B0026900 term31schoolID
ren B0027000 term32schoolID
ren B0027100 term33schoolID
ren B0027200 term34schoolID
ren B0027300 term35schoolID
ren B0027400 term36schoolID
ren B0027500 term37schoolID
ren B0027600 term38schoolID
ren B0027700 term39schoolID
ren B0027800 term40schoolID
ren B0027900 term1termID
ren B0028000 term2termID
ren B0028100 term3termID
ren B0028200 term4termID
ren B0028300 term5termID
ren B0028400 term6termID
ren B0028500 term7termID
ren B0028600 term8termID
ren B0028700 term9termID
ren B0028800 term10termID
ren B0028900 term11termID
ren B0029000 term12termID
ren B0029100 term13termID
ren B0029200 term14termID
ren B0029300 term15termID
ren B0029400 term16termID
ren B0029500 term17termID
ren B0029600 term18termID
ren B0029700 term19termID
ren B0029800 term20termID
ren B0029900 term21termID
ren B0030000 term22termID
ren B0030100 term23termID
ren B0030200 term24termID
ren B0030300 term25termID
ren B0030400 term26termID
ren B0030500 term27termID
ren B0030600 term28termID
ren B0030700 term29termID
ren B0030800 term30termID
ren B0030900 term31termID
ren B0031000 term32termID
ren B0031100 term33termID
ren B0031200 term34termID
ren B0031300 term35termID
ren B0031400 term36termID
ren B0031500 term37termID
ren B0031600 term38termID
ren B0031700 term39termID
ren B0031800 term40termID
ren B0031900 term1startMo
ren B0032000 term2startMo
ren B0032100 term3startMo
ren B0032200 term4startMo
ren B0032300 term5startMo
ren B0032400 term6startMo
ren B0032500 term7startMo
ren B0032600 term8startMo
ren B0032700 term9startMo
ren B0032800 term10startMo
ren B0032900 term11startMo
ren B0033000 term12startMo
ren B0033100 term13startMo
ren B0033200 term14startMo
ren B0033300 term15startMo
ren B0033400 term16startMo
ren B0033500 term17startMo
ren B0033600 term18startMo
ren B0033700 term19startMo
ren B0033800 term20startMo
ren B0033900 term21startMo
ren B0034000 term22startMo
ren B0034100 term23startMo
ren B0034200 term24startMo
ren B0034300 term25startMo
ren B0034400 term26startMo
ren B0034500 term27startMo
ren B0034600 term28startMo
ren B0034700 term29startMo
ren B0034800 term30startMo
ren B0034900 term31startMo
ren B0035000 term32startMo
ren B0035100 term33startMo
ren B0035200 term34startMo
ren B0035300 term35startMo
ren B0035400 term36startMo
ren B0035500 term37startMo
ren B0035600 term38startMo
ren B0035700 term39startMo
ren B0035800 term40startMo
ren B0035900 term1startYr
ren B0036000 term2startYr
ren B0036100 term3startYr
ren B0036200 term4startYr
ren B0036300 term5startYr
ren B0036400 term6startYr
ren B0036500 term7startYr
ren B0036600 term8startYr
ren B0036700 term9startYr
ren B0036800 term10startYr
ren B0036900 term11startYr
ren B0037000 term12startYr
ren B0037100 term13startYr
ren B0037200 term14startYr
ren B0037300 term15startYr
ren B0037400 term16startYr
ren B0037500 term17startYr
ren B0037600 term18startYr
ren B0037700 term19startYr
ren B0037800 term20startYr
ren B0037900 term21startYr
ren B0038000 term22startYr
ren B0038100 term23startYr
ren B0038200 term24startYr
ren B0038300 term25startYr
ren B0038400 term26startYr
ren B0038500 term27startYr
ren B0038600 term28startYr
ren B0038700 term29startYr
ren B0038800 term30startYr
ren B0038900 term31startYr
ren B0039000 term32startYr
ren B0039100 term33startYr
ren B0039200 term34startYr
ren B0039300 term35startYr
ren B0039400 term36startYr
ren B0039500 term37startYr
ren B0039600 term38startYr
ren B0039700 term39startYr
ren B0039800 term40startYr
ren B0039900 term1endMo
ren B0040000 term2endMo
ren B0040100 term3endMo
ren B0040200 term4endMo
ren B0040300 term5endMo
ren B0040400 term6endMo
ren B0040500 term7endMo
ren B0040600 term8endMo
ren B0040700 term9endMo
ren B0040800 term10endMo
ren B0040900 term11endMo
ren B0041000 term12endMo
ren B0041100 term13endMo
ren B0041200 term14endMo
ren B0041300 term15endMo
ren B0041400 term16endMo
ren B0041500 term17endMo
ren B0041600 term18endMo
ren B0041700 term19endMo
ren B0041800 term20endMo
ren B0041900 term21endMo
ren B0042000 term22endMo
ren B0042100 term23endMo
ren B0042200 term24endMo
ren B0042300 term25endMo
ren B0042400 term26endMo
ren B0042500 term27endMo
ren B0042600 term28endMo
ren B0042700 term29endMo
ren B0042800 term30endMo
ren B0042900 term31endMo
ren B0043000 term32endMo
ren B0043100 term33endMo
ren B0043200 term34endMo
ren B0043300 term35endMo
ren B0043400 term36endMo
ren B0043500 term37endMo
ren B0043600 term38endMo
ren B0043700 term39endMo
ren B0043800 term40endMo
ren B0043900 term1endYr
ren B0044000 term2endYr
ren B0044100 term3endYr
ren B0044200 term4endYr
ren B0044300 term5endYr
ren B0044400 term6endYr
ren B0044500 term7endYr
ren B0044600 term8endYr
ren B0044700 term9endYr
ren B0044800 term10endYr
ren B0044900 term11endYr
ren B0045000 term12endYr
ren B0045100 term13endYr
ren B0045200 term14endYr
ren B0045300 term15endYr
ren B0045400 term16endYr
ren B0045500 term17endYr
ren B0045600 term18endYr
ren B0045700 term19endYr
ren B0045800 term20endYr
ren B0045900 term21endYr
ren B0046000 term22endYr
ren B0046100 term23endYr
ren B0046200 term24endYr
ren B0046300 term25endYr
ren B0046400 term26endYr
ren B0046500 term27endYr
ren B0046600 term28endYr
ren B0046700 term29endYr
ren B0046800 term30endYr
ren B0046900 term31endYr
ren B0047000 term32endYr
ren B0047100 term33endYr
ren B0047200 term34endYr
ren B0047300 term35endYr
ren B0047400 term36endYr
ren B0047500 term37endYr
ren B0047600 term38endYr
ren B0047700 term39endYr
ren B0047800 term40endYr
ren B0047900 term1GPA
ren B0048000 term2GPA
ren B0048100 term3GPA
ren B0048200 term4GPA
ren B0048300 term5GPA
ren B0048400 term6GPA
ren B0048500 term7GPA
ren B0048600 term8GPA
ren B0048700 term9GPA
ren B0048800 term10GPA
ren B0048900 term11GPA
ren B0049000 term12GPA
ren B0049100 term13GPA
ren B0049200 term14GPA
ren B0049300 term15GPA
ren B0049400 term16GPA
ren B0049500 term17GPA
ren B0049600 term18GPA
ren B0049700 term19GPA
ren B0049800 term20GPA
ren B0049900 term21GPA
ren B0050000 term22GPA
ren B0050100 term23GPA
ren B0050200 term24GPA
ren B0050300 term25GPA
ren B0050400 term26GPA
ren B0050500 term27GPA
ren B0050600 term28GPA
ren B0050700 term29GPA
ren B0050800 term30GPA
ren B0050900 term31GPA
ren B0051000 term32GPA
ren B0051100 term33GPA
ren B0051200 term34GPA
ren B0051300 term35GPA
ren B0051400 term36GPA
ren B0051500 term37GPA
ren B0051600 term38GPA
ren B0051700 term39GPA
ren B0051800 term40GPA
ren B0051900 term1credits
ren B0052000 term2credits
ren B0052100 term3credits
ren B0052200 term4credits
ren B0052300 term5credits
ren B0052400 term6credits
ren B0052500 term7credits
ren B0052600 term8credits
ren B0052700 term9credits
ren B0052800 term10credits
ren B0052900 term11credits
ren B0053000 term12credits
ren B0053100 term13credits
ren B0053200 term14credits
ren B0053300 term15credits
ren B0053400 term16credits
ren B0053500 term17credits
ren B0053600 term18credits
ren B0053700 term19credits
ren B0053800 term20credits
ren B0053900 term21credits
ren B0054000 term22credits
ren B0054100 term23credits
ren B0054200 term24credits
ren B0054300 term25credits
ren B0054400 term26credits
ren B0054500 term27credits
ren B0054600 term28credits
ren B0054700 term29credits
ren B0054800 term30credits
ren B0054900 term31credits
ren B0055000 term32credits
ren B0055100 term33credits
ren B0055200 term34credits
ren B0055300 term35credits
ren B0055400 term36credits
ren B0055500 term37credits
ren B0055600 term38credits
ren B0055700 term39credits
ren B0055800 term40credits

recode _all (-1 = .r) (-2 = .d) (-3 = .i) (-4 = .v) (-5 = .n)

capture label drop vl_transcr_status
lab def vl_transcr_status 1 "Never Postsec, No waiver" 2 "Never Postsec, Waiver" 3 "Postsec, No Waiver" 4 "Postsec, Waiver, transcr" 5 "Postsec, Waiver, no Transcr" 6 "Postsec in survey, No enr in transcr" 7 "Postsec in survey, Waiver, no enr, indet. transcr."
lab val tscriptDisposition vl_transcr_status

capture label drop vldegtype
lab def vldegtype 1 "Tech Prog" 2 "Associate's" 3 "Bachelor's" 4 "Post-BA Certif" 5 "Graduate"
foreach tt of varlist tscriptInst?deg?type {
    lab val `tt' vldegtype
    replace `tt' = .v if `tt'==999999
}


***************************************************
* Grab data from October term
***************************************************
forv yy = 1991/2016 {
    gen tscriptEnr`yy' = .
    gen tscriptSID`yy' = .
    gen tscriptGPA`yy' = .
    gen tscriptCredits`yy' = .
    gen tscriptGradAA`yy' = 0
    gen tscriptGradBA`yy' = 0
}

/* List of CCM codes and majors; * indicates STEM by our definition
1  *Agriculture, Agriculture Operations, And Related Services
3  *Natural Resources and Conservation
4   Architecture and Related Services
5   Area, Ethnic, Cultural, Gender, and Group Studies
9   Communication, Journalism, and Related Programs
10  Communications Technologies/Technicians and Support Services
11 *Computer and Information Sciences and Support Services
12  Personal and Culinary Services
13  Education
14 *Engineering
15 *Engineering Technologies and Engineering-Related Fields
16  Foreign Languages, Literatures, and Linguistics
19  Family and Consumer Sciences/Human Sciences
22  Legal Professions and Studies
23  English Language and Literature/Letters
24  Liberal Arts and Sciences, General Studies and Humanities
25  Library Science
26 *Biological and Biomedical Sciences
27 *Mathematics and Statistics
28  Military Science, Leadership and Operational Art.
29  Military Technologies and Applied Sciences
30  Multi/Interdisciplinary Studies
31  Parks, Recreation and Leisure Studies
32  Basic Skills and Developmental/Remedial Education
33  Citizenship Activities
34  Health-Related Knowledge and Skills
35  Interpersonal and Social Skills
36  Leisure and Recreational Activities
37  Personal Awareness and Self-Improvement
38  Philosophy and Religious Studies
39  Theology and Religious Vocations
40 *Physical Sciences
41 *Science and Technologies/Technicians
42  Psychology
43  Homeland Security, Law Enforcement, Firefighting and Related Protective Services
44  Public Administration and Social Service Professions
45  Social Sciences
46  Construction Trades
47  Mechanic and Repair Technologies/Technicians
48  Precision Production
49  Transportation and Materials Moving
50  Visual and Performing Arts
51  Health Professions and Related Programs
52  Business, Management, Marketing, and Related Support Services
53  High School/Secondary Diplomas and Certificates
54  History
60  Residency Programs
90  Other Courses
*/


* Majors
generat tscriptBASciMaj = 0
replace tscriptBASciMaj = .n if institution1id==.n
replace tscriptBASciMaj = 1 if (inlist(tscriptMajor1Inst1deg1,101,103,111,114,115,126,127,140,141) & inlist(tscriptMajor1SrcInst1deg1,1,2,5,6,7,8) & tscriptInst1deg1type==3)
replace tscriptBASciMaj = 1 if (inlist(tscriptMajor2Inst1deg1,101,103,111,114,115,126,127,140,141) & inlist(tscriptMajor2SrcInst1deg1,1,2,5,6,7,8) & tscriptInst1deg1type==3)
replace tscriptBASciMaj = 1 if (inlist(tscriptMajor1Inst1deg2,101,103,111,114,115,126,127,140,141) & inlist(tscriptMajor1SrcInst1deg2,1,2,5,6,7,8) & tscriptInst1deg2type==3)
replace tscriptBASciMaj = 1 if (inlist(tscriptMajor1Inst1deg3,101,103,111,114,115,126,127,140,141) & inlist(tscriptMajor1SrcInst1deg3,1,2,5,6,7,8) & tscriptInst1deg3type==3)
replace tscriptBASciMaj = 1 if (inlist(tscriptMajor1Inst1deg4,101,103,111,114,115,126,127,140,141) & inlist(tscriptMajor1SrcInst1deg4,1,2,5,6,7,8) & tscriptInst1deg4type==3)
replace tscriptBASciMaj = 1 if (inlist(tscriptMajor1Inst1deg5,101,103,111,114,115,126,127,140,141) & inlist(tscriptMajor1SrcInst1deg5,1,2,5,6,7,8) & tscriptInst1deg5type==3)
replace tscriptBASciMaj = 1 if (inlist(tscriptMajor1Inst2deg1,101,103,111,114,115,126,127,140,141) & inlist(tscriptMajor1SrcInst2deg1,1,2,5,6,7,8) & tscriptInst2deg1type==3)
replace tscriptBASciMaj = 1 if (inlist(tscriptMajor2Inst2deg1,101,103,111,114,115,126,127,140,141) & inlist(tscriptMajor2SrcInst2deg1,1,2,5,6,7,8) & tscriptInst2deg1type==3)
replace tscriptBASciMaj = 1 if (inlist(tscriptMajor1Inst2deg2,101,103,111,114,115,126,127,140,141) & inlist(tscriptMajor1SrcInst2deg2,1,2,5,6,7,8) & tscriptInst2deg2type==3)
replace tscriptBASciMaj = 1 if (inlist(tscriptMajor1Inst2deg3,101,103,111,114,115,126,127,140,141) & inlist(tscriptMajor1SrcInst2deg3,1,2,5,6,7,8) & tscriptInst2deg3type==3)
replace tscriptBASciMaj = 1 if (inlist(tscriptMajor1Inst2deg4,101,103,111,114,115,126,127,140,141) & inlist(tscriptMajor1SrcInst2deg4,1,2,5,6,7,8) & tscriptInst2deg4type==3)
replace tscriptBASciMaj = 1 if (inlist(tscriptMajor1Inst3deg1,101,103,111,114,115,126,127,140,141) & inlist(tscriptMajor1SrcInst3deg1,1,2,5,6,7,8) & tscriptInst3deg1type==3)
replace tscriptBASciMaj = 1 if (inlist(tscriptMajor2Inst3deg1,101,103,111,114,115,126,127,140,141) & inlist(tscriptMajor2SrcInst3deg1,1,2,5,6,7,8) & tscriptInst3deg1type==3)
replace tscriptBASciMaj = 1 if (inlist(tscriptMajor1Inst3deg2,101,103,111,114,115,126,127,140,141) & inlist(tscriptMajor1SrcInst3deg2,1,2,5,6,7,8) & tscriptInst3deg2type==3)
replace tscriptBASciMaj = 1 if (inlist(tscriptMajor1Inst3deg3,101,103,111,114,115,126,127,140,141) & inlist(tscriptMajor1SrcInst3deg3,1,2,5,6,7,8) & tscriptInst3deg3type==3)
replace tscriptBASciMaj = 1 if (inlist(tscriptMajor1Inst4deg1,101,103,111,114,115,126,127,140,141) & inlist(tscriptMajor1SrcInst4deg1,1,2,5,6,7,8) & tscriptInst4deg1type==3)
replace tscriptBASciMaj = 1 if (inlist(tscriptMajor2Inst4deg1,101,103,111,114,115,126,127,140,141) & inlist(tscriptMajor2SrcInst4deg1,1,2,5,6,7,8) & tscriptInst4deg1type==3)
replace tscriptBASciMaj = 1 if (inlist(tscriptMajor1Inst4deg2,101,103,111,114,115,126,127,140,141) & inlist(tscriptMajor1SrcInst4deg2,1,2,5,6,7,8) & tscriptInst4deg2type==3)
replace tscriptBASciMaj = 1 if (inlist(tscriptMajor1Inst4deg3,101,103,111,114,115,126,127,140,141) & inlist(tscriptMajor1SrcInst4deg3,1,2,5,6,7,8) & tscriptInst4deg3type==3)
replace tscriptBASciMaj = 1 if (inlist(tscriptMajor1Inst5deg1,101,103,111,114,115,126,127,140,141) & inlist(tscriptMajor1SrcInst5deg1,1,2,5,6,7,8) & tscriptInst5deg1type==3)
replace tscriptBASciMaj = 1 if (inlist(tscriptMajor1Inst6deg1,101,103,111,114,115,126,127,140,141) & inlist(tscriptMajor1SrcInst6deg1,1,2,5,6,7,8) & tscriptInst6deg1type==3)
replace tscriptBASciMaj = 1 if (inlist(tscriptMajor1Inst7deg1,101,103,111,114,115,126,127,140,141) & inlist(tscriptMajor1SrcInst7deg1,1,2,5,6,7,8) & tscriptInst7deg1type==3)
replace tscriptBASciMaj = 1 if (inlist(tscriptMajor1Inst7deg2,101,103,111,114,115,126,127,140,141) & inlist(tscriptMajor1SrcInst7deg2,1,2,5,6,7,8) & tscriptInst7deg2type==3)

generat tscriptBAHumMaj = 0
replace tscriptBAHumMaj = .n if institution1id==.n
replace tscriptBAHumMaj = 1 if (!inlist(tscriptMajor1Inst1deg1,101,103,111,114,115,126,127,140,141) & !mi(tscriptMajor1Inst1deg1) & inlist(tscriptMajor1SrcInst1deg1,1,2,5,6,7,8) & tscriptInst1deg1type==3)
replace tscriptBAHumMaj = 1 if (!inlist(tscriptMajor2Inst1deg1,101,103,111,114,115,126,127,140,141) & !mi(tscriptMajor2Inst1deg1) & inlist(tscriptMajor2SrcInst1deg1,1,2,5,6,7,8) & tscriptInst1deg1type==3)
replace tscriptBAHumMaj = 1 if (!inlist(tscriptMajor1Inst1deg2,101,103,111,114,115,126,127,140,141) & !mi(tscriptMajor1Inst1deg2) & inlist(tscriptMajor1SrcInst1deg2,1,2,5,6,7,8) & tscriptInst1deg2type==3)
replace tscriptBAHumMaj = 1 if (!inlist(tscriptMajor1Inst1deg3,101,103,111,114,115,126,127,140,141) & !mi(tscriptMajor1Inst1deg3) & inlist(tscriptMajor1SrcInst1deg3,1,2,5,6,7,8) & tscriptInst1deg3type==3)
replace tscriptBAHumMaj = 1 if (!inlist(tscriptMajor1Inst1deg4,101,103,111,114,115,126,127,140,141) & !mi(tscriptMajor1Inst1deg4) & inlist(tscriptMajor1SrcInst1deg4,1,2,5,6,7,8) & tscriptInst1deg4type==3)
replace tscriptBAHumMaj = 1 if (!inlist(tscriptMajor1Inst1deg5,101,103,111,114,115,126,127,140,141) & !mi(tscriptMajor1Inst1deg5) & inlist(tscriptMajor1SrcInst1deg5,1,2,5,6,7,8) & tscriptInst1deg5type==3)
replace tscriptBAHumMaj = 1 if (!inlist(tscriptMajor1Inst2deg1,101,103,111,114,115,126,127,140,141) & !mi(tscriptMajor1Inst2deg1) & inlist(tscriptMajor1SrcInst2deg1,1,2,5,6,7,8) & tscriptInst2deg1type==3)
replace tscriptBAHumMaj = 1 if (!inlist(tscriptMajor2Inst2deg1,101,103,111,114,115,126,127,140,141) & !mi(tscriptMajor2Inst2deg1) & inlist(tscriptMajor2SrcInst2deg1,1,2,5,6,7,8) & tscriptInst2deg1type==3)
replace tscriptBAHumMaj = 1 if (!inlist(tscriptMajor1Inst2deg2,101,103,111,114,115,126,127,140,141) & !mi(tscriptMajor1Inst2deg2) & inlist(tscriptMajor1SrcInst2deg2,1,2,5,6,7,8) & tscriptInst2deg2type==3)
replace tscriptBAHumMaj = 1 if (!inlist(tscriptMajor1Inst2deg3,101,103,111,114,115,126,127,140,141) & !mi(tscriptMajor1Inst2deg3) & inlist(tscriptMajor1SrcInst2deg3,1,2,5,6,7,8) & tscriptInst2deg3type==3)
replace tscriptBAHumMaj = 1 if (!inlist(tscriptMajor1Inst2deg4,101,103,111,114,115,126,127,140,141) & !mi(tscriptMajor1Inst2deg4) & inlist(tscriptMajor1SrcInst2deg4,1,2,5,6,7,8) & tscriptInst2deg4type==3)
replace tscriptBAHumMaj = 1 if (!inlist(tscriptMajor1Inst3deg1,101,103,111,114,115,126,127,140,141) & !mi(tscriptMajor1Inst3deg1) & inlist(tscriptMajor1SrcInst3deg1,1,2,5,6,7,8) & tscriptInst3deg1type==3)
replace tscriptBAHumMaj = 1 if (!inlist(tscriptMajor2Inst3deg1,101,103,111,114,115,126,127,140,141) & !mi(tscriptMajor2Inst3deg1) & inlist(tscriptMajor2SrcInst3deg1,1,2,5,6,7,8) & tscriptInst3deg1type==3)
replace tscriptBAHumMaj = 1 if (!inlist(tscriptMajor1Inst3deg2,101,103,111,114,115,126,127,140,141) & !mi(tscriptMajor1Inst3deg2) & inlist(tscriptMajor1SrcInst3deg2,1,2,5,6,7,8) & tscriptInst3deg2type==3)
replace tscriptBAHumMaj = 1 if (!inlist(tscriptMajor1Inst3deg3,101,103,111,114,115,126,127,140,141) & !mi(tscriptMajor1Inst3deg3) & inlist(tscriptMajor1SrcInst3deg3,1,2,5,6,7,8) & tscriptInst3deg3type==3)
replace tscriptBAHumMaj = 1 if (!inlist(tscriptMajor1Inst4deg1,101,103,111,114,115,126,127,140,141) & !mi(tscriptMajor1Inst4deg1) & inlist(tscriptMajor1SrcInst4deg1,1,2,5,6,7,8) & tscriptInst4deg1type==3)
replace tscriptBAHumMaj = 1 if (!inlist(tscriptMajor2Inst4deg1,101,103,111,114,115,126,127,140,141) & !mi(tscriptMajor2Inst4deg1) & inlist(tscriptMajor2SrcInst4deg1,1,2,5,6,7,8) & tscriptInst4deg1type==3)
replace tscriptBAHumMaj = 1 if (!inlist(tscriptMajor1Inst4deg2,101,103,111,114,115,126,127,140,141) & !mi(tscriptMajor1Inst4deg2) & inlist(tscriptMajor1SrcInst4deg2,1,2,5,6,7,8) & tscriptInst4deg2type==3)
replace tscriptBAHumMaj = 1 if (!inlist(tscriptMajor1Inst4deg3,101,103,111,114,115,126,127,140,141) & !mi(tscriptMajor1Inst4deg3) & inlist(tscriptMajor1SrcInst4deg3,1,2,5,6,7,8) & tscriptInst4deg3type==3)
replace tscriptBAHumMaj = 1 if (!inlist(tscriptMajor1Inst5deg1,101,103,111,114,115,126,127,140,141) & !mi(tscriptMajor1Inst5deg1) & inlist(tscriptMajor1SrcInst5deg1,1,2,5,6,7,8) & tscriptInst5deg1type==3)
replace tscriptBAHumMaj = 1 if (!inlist(tscriptMajor1Inst6deg1,101,103,111,114,115,126,127,140,141) & !mi(tscriptMajor1Inst6deg1) & inlist(tscriptMajor1SrcInst6deg1,1,2,5,6,7,8) & tscriptInst6deg1type==3)
replace tscriptBAHumMaj = 1 if (!inlist(tscriptMajor1Inst7deg1,101,103,111,114,115,126,127,140,141) & !mi(tscriptMajor1Inst7deg1) & inlist(tscriptMajor1SrcInst7deg1,1,2,5,6,7,8) & tscriptInst7deg1type==3)
replace tscriptBAHumMaj = 1 if (!inlist(tscriptMajor1Inst7deg2,101,103,111,114,115,126,127,140,141) & !mi(tscriptMajor1Inst7deg2) & inlist(tscriptMajor1SrcInst7deg2,1,2,5,6,7,8) & tscriptInst7deg2type==3)


l ID institution1id term1schoolID tscriptBA???Maj institution1numAPcredits tscriptMajor1Inst1deg1 if ID<=20, sep(0)

* Institution-level data
forv yy = 1991/2016 {
    qui replace tscriptGradBA`yy' = 1 if (mdy(10,1,`yy')>mdy(tscriptGradMinst1deg1,1,tscriptGradYinst1deg1) & tscriptInst1deg1type==3) | (mdy(10,1,`yy')>mdy(tscriptGradMinst1deg2,1,tscriptGradYinst1deg2) & tscriptInst1deg2type==3) | (mdy(10,1,`yy')>mdy(tscriptGradMinst1deg3,1,tscriptGradYinst1deg3) & tscriptInst1deg3type==3) | (mdy(10,1,`yy')>mdy(tscriptGradMinst1deg4,1,tscriptGradYinst1deg4) & tscriptInst1deg4type==3) | (mdy(10,1,`yy')>mdy(tscriptGradMinst1deg5,1,tscriptGradYinst1deg5) & tscriptInst1deg5type==3) | (mdy(10,1,`yy')>mdy(tscriptGradMinst2deg1,1,tscriptGradYinst2deg1) & tscriptInst2deg1type==3) | (mdy(10,1,`yy')>mdy(tscriptGradMinst2deg2,1,tscriptGradYinst2deg2) & tscriptInst2deg2type==3) | (mdy(10,1,`yy')>mdy(tscriptGradMinst2deg3,1,tscriptGradYinst2deg3) & tscriptInst2deg3type==3) | (mdy(10,1,`yy')>mdy(tscriptGradMinst2deg4,1,tscriptGradYinst2deg4) & tscriptInst2deg4type==3) | (mdy(10,1,`yy')>mdy(tscriptGradMinst3deg1,1,tscriptGradYinst3deg1) & tscriptInst3deg1type==3) | (mdy(10,1,`yy')>mdy(tscriptGradMinst3deg2,1,tscriptGradYinst3deg2) & tscriptInst3deg2type==3) | (mdy(10,1,`yy')>mdy(tscriptGradMinst3deg3,1,tscriptGradYinst3deg3) & tscriptInst3deg3type==3) | (mdy(10,1,`yy')>mdy(tscriptGradMinst4deg1,1,tscriptGradYinst4deg1) & tscriptInst4deg1type==3) | (mdy(10,1,`yy')>mdy(tscriptGradMinst4deg2,1,tscriptGradYinst4deg2) & tscriptInst4deg2type==3) | (mdy(10,1,`yy')>mdy(tscriptGradMinst4deg3,1,tscriptGradYinst4deg3) & tscriptInst4deg3type==3) | (mdy(10,1,`yy')>mdy(tscriptGradMinst5deg1,1,tscriptGradYinst5deg1) & tscriptInst5deg1type==3) | (mdy(10,1,`yy')>mdy(tscriptGradMinst6deg1,1,tscriptGradYinst6deg1) & tscriptInst6deg1type==3) | (mdy(10,1,`yy')>mdy(tscriptGradMinst7deg1,1,tscriptGradYinst7deg1) & tscriptInst7deg1type==3) | (mdy(10,1,`yy')>mdy(tscriptGradMinst7deg2,1,tscriptGradYinst7deg2) & tscriptInst7deg2type==3)
    qui replace tscriptGradAA`yy' = 1 if (mdy(10,1,`yy')>mdy(tscriptGradMinst1deg1,1,tscriptGradYinst1deg1) & tscriptInst1deg1type==2) | (mdy(10,1,`yy')>mdy(tscriptGradMinst1deg2,1,tscriptGradYinst1deg2) & tscriptInst1deg2type==2) | (mdy(10,1,`yy')>mdy(tscriptGradMinst1deg3,1,tscriptGradYinst1deg3) & tscriptInst1deg3type==2) | (mdy(10,1,`yy')>mdy(tscriptGradMinst1deg4,1,tscriptGradYinst1deg4) & tscriptInst1deg4type==2) | (mdy(10,1,`yy')>mdy(tscriptGradMinst1deg5,1,tscriptGradYinst1deg5) & tscriptInst1deg5type==2) | (mdy(10,1,`yy')>mdy(tscriptGradMinst2deg1,1,tscriptGradYinst2deg1) & tscriptInst2deg1type==2) | (mdy(10,1,`yy')>mdy(tscriptGradMinst2deg2,1,tscriptGradYinst2deg2) & tscriptInst2deg2type==2) | (mdy(10,1,`yy')>mdy(tscriptGradMinst2deg3,1,tscriptGradYinst2deg3) & tscriptInst2deg3type==2) | (mdy(10,1,`yy')>mdy(tscriptGradMinst2deg4,1,tscriptGradYinst2deg4) & tscriptInst2deg4type==2) | (mdy(10,1,`yy')>mdy(tscriptGradMinst3deg1,1,tscriptGradYinst3deg1) & tscriptInst3deg1type==2) | (mdy(10,1,`yy')>mdy(tscriptGradMinst3deg2,1,tscriptGradYinst3deg2) & tscriptInst3deg2type==2) | (mdy(10,1,`yy')>mdy(tscriptGradMinst3deg3,1,tscriptGradYinst3deg3) & tscriptInst3deg3type==2) | (mdy(10,1,`yy')>mdy(tscriptGradMinst4deg1,1,tscriptGradYinst4deg1) & tscriptInst4deg1type==2) | (mdy(10,1,`yy')>mdy(tscriptGradMinst4deg2,1,tscriptGradYinst4deg2) & tscriptInst4deg2type==2) | (mdy(10,1,`yy')>mdy(tscriptGradMinst4deg3,1,tscriptGradYinst4deg3) & tscriptInst4deg3type==2) | (mdy(10,1,`yy')>mdy(tscriptGradMinst5deg1,1,tscriptGradYinst5deg1) & tscriptInst5deg1type==2) | (mdy(10,1,`yy')>mdy(tscriptGradMinst6deg1,1,tscriptGradYinst6deg1) & tscriptInst6deg1type==2) | (mdy(10,1,`yy')>mdy(tscriptGradMinst7deg1,1,tscriptGradYinst7deg1) & tscriptInst7deg1type==2) | (mdy(10,1,`yy')>mdy(tscriptGradMinst7deg2,1,tscriptGradYinst7deg2) & tscriptInst7deg2type==2)
}

* Term-level data
l ID term1startYr term1startMo term1endYr term1endMo term1GPA term2startYr term2startMo term2endYr term2endMo term2GPA tscriptGPA2000 if ID==6
forv x = 1/40 {
    * di "term `x'"
    forv yy = 1991/2013 {
        * di "year `yy'"
        qui replace tscriptEnr`yy'     = 1               if inrange(`yy',term`x'startYr,term`x'endYr) & inrange(10,term`x'startMo,term`x'endMo) & !mi(term`x'startYr)
        qui replace tscriptSID`yy'     = term`x'schoolID if inrange(`yy',term`x'startYr,term`x'endYr) & inrange(10,term`x'startMo,term`x'endMo) & !mi(term`x'startYr) & mi(tscriptCredits`yy')
        qui replace tscriptCredits`yy' = term`x'credits  if inrange(`yy',term`x'startYr,term`x'endYr) & inrange(10,term`x'startMo,term`x'endMo) & !mi(term`x'startYr) & mi(tscriptCredits`yy')
        qui replace tscriptGPA`yy'     = term`x'GPA      if inrange(`yy',term`x'startYr,term`x'endYr) & inrange(10,term`x'startMo,term`x'endMo) & !mi(term`x'startYr) & mi(tscriptGPA`yy')
    }
}
l ID term1startYr term1startMo term1endYr term1endMo term1GPA term2startYr term2startMo term2endYr term2endMo term2GPA tscriptGPA2000 if ID==6
l term*startYr term*GPA tscriptGPA2010 tscriptEnr2003-tscriptEnr2013 tscriptGPA* if ID==8982 

forvalues yr=1980/2016 {
    gen temp`yr'=0
}
reshape long temp tscriptEnr tscriptSID tscriptGPA tscriptCredits tscriptGradBA tscriptGradAA, i(ID) j(year)

drop temp

***************************************************
* Data cleaning
***************************************************
replace tscriptGPA = . if tscriptCredits==0 & tscriptEnr==1
replace tscriptGPA = tscriptGPA/100

replace tscriptCredits = tscriptCredits/100

l ID year tscriptEnr tscriptSID tscriptGPA tscriptCredits tscriptGradBA tscriptGradAA if inlist(ID,6,9,15,16) & inrange(year,1997,2015), sepby(ID)
* l ID year in_college CollID_Oct GPA Credits grad_4yr grad_2yr  if inlist(ID,6,9,15,16) & inrange(year,1997,2015), sepby(ID)
