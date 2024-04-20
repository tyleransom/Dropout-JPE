* Formula for backing out college term: CollegeTerm_Feb2012 = CollegeTypeTerm_Feb2012-round(CollegeTypeTerm_Feb2012,1000)
* First two digits are college type (public, private, religious, other)
* Second two digits are term number


* Code for applying college number/term grades to month enrolled:
* foreach c in 1/`=maxcoll' {
    * foreach t in 1/`=maxterm' {
        * replace GPA_new = College`c'_GPA_Term`t'_ if CollegeID_Oct==Newschool_ID`c'_ & CollegeTypeTerm_Oct-round(CollegeTypeTerm_Oct,1000)==`t'
        * replace Major1_new = College`c'_GPA_Term`t'_ if CollegeID_Oct==Newschool_ID`c'_ & CollegeTypeTerm_Oct-round(CollegeTypeTerm_Oct,1000)==`t'
        * replace Major2_new = College`c'_GPA_Term`t'_ if CollegeID_Oct==Newschool_ID`c'_ & CollegeTypeTerm_Oct-round(CollegeTypeTerm_Oct,1000)==`t'
    * }
* }

*------------------------------------------------------------------
* Make sure school info is truly missing with .n before backfilling
*------------------------------------------------------------------
forvalues x = 1/8 {
    if inlist(`x',1) {
        local maxy = 26
    }
    else if inlist(`x',2) {
        local maxy = 18
    }
    else if inlist(`x',3) {
        local maxy = 17
    }
    else if inlist(`x',4) {
        local maxy = 7
    }
    else if inlist(`x',5) {
        local maxy = 8
    }
    else if inlist(`x',6,7,8) {
        local maxy = 3
    }
    forvalues y = 1/`maxy' {
        disp "College `x', Term `y'"
        l ID year miss_interview Coll`x'_GPA_Term`y'_ Major1_Coll`x'_Term`y'_ Major2_Coll`x'_Term`y'_ EnrM_Coll`x'_Term`y'_ EnrY_Coll`x'_Term`y'_  if (~mi(EnrY_Coll`x'_Term`y'_  ) | ~mi(Coll`x'_GPA_Term`y'_) | ~mi(Major1_Coll`x'_Term`y'_) | ~mi(Major2_Coll`x'_Term`y'_) | ~mi(EnrM_Coll`x'_Term`y'_  )) & miss_interview
        qui replace Coll`x'_GPA_Term`y'_            = .n if miss_interview
        qui replace Coll`x'_LetterGPA_Term`y'_      = .n if miss_interview
        qui replace Major1_Coll`x'_Term`y'_         = .n if miss_interview
        qui replace Major2_Coll`x'_Term`y'_         = .n if miss_interview
        qui replace EnrM_Coll`x'_Term`y'_           = .n if miss_interview
        qui replace EnrY_Coll`x'_Term`y'_           = .n if miss_interview
        qui replace Coll`x'_Tuition_Term`y'_        = .n if miss_interview
        qui replace Coll`x'_OOP_Term`y'_            = .n if miss_interview
        qui replace Coll`x'_RecFromPar_Term`y'_     = .n if miss_interview
        qui replace Coll`x'_RecFromFath_Term`y'_    = .n if miss_interview
        qui replace Coll`x'_RecFromGpar_Term`y'_    = .n if miss_interview
        qui replace Coll`x'_RecFromMoth_Term`y'_    = .n if miss_interview
        qui replace Coll`x'_RecFromNone_Term`y'_    = .n if miss_interview
        qui replace Coll`x'_RecFromORel_Term`y'_    = .n if miss_interview
        qui replace Coll`x'_TotGiftFrFam1_Term`y'_  = .n if miss_interview
        qui replace Coll`x'_TotGiftFrFam2_Term`y'_  = .n if miss_interview
        qui replace Coll`x'_TotGiftFrFam3_Term`y'_  = .n if miss_interview
        qui replace Coll`x'_TotGiftFrFam4_Term`y'_  = .n if miss_interview
        qui replace Coll`x'_TotGiftFrFam5_Term`y'_  = .n if miss_interview
        qui replace Coll`x'_TotLoanFrFam1_Term`y'_  = .n if miss_interview
        qui replace Coll`x'_TotLoanFrFam2_Term`y'_  = .n if miss_interview
        qui replace Coll`x'_TotLoanFrFam3_Term`y'_  = .n if miss_interview
        qui replace Coll`x'_TotLoanFrFam4_Term`y'_  = .n if miss_interview
        qui replace Coll`x'_TotLoanFrFam5_Term`y'_  = .n if miss_interview
        qui replace Coll`x'_RecFamily_Term`y'_      = .n if miss_interview
        qui replace Coll`x'_HrsInClass_Term`y'_     = .n if miss_interview
        qui replace Coll`x'_FTorPT_Term`y'_         = .n if miss_interview
        qui replace Coll`x'_CredsTaken_Term`y'_     = .n if miss_interview
        qui replace Coll`x'_EntCredEarn_Term`y'_    = .n if miss_interview
        qui replace Coll`x'_CredsEarned_Term`y'_    = .n if miss_interview
    }
}

*----------------------------
* Backfill School Information
*----------------------------
** CHECK THIS LOOP FOR ID 734, 826, 1179 FOR YEARS 2000-2007
** IT LOOKS LIKE THE .N MISSING VALUES MIGHT NOT BE CARRIED THROUGH IN THE RAW DATA
l ID year miss_interview College_enrollment_Oct if ID==734 & inrange(year,2000,2006)
l ID year miss_interview Coll4_GPA_Term1_ Coll4_GPA_Term2_ Coll4_GPA_Term3_ Coll4_GPA_Term4_ Coll4_GPA_Term5_ Coll4_GPA_Term6_ Coll4_GPA_Term7_ if ID==734 & inrange(year,2000,2006)
l ID year miss_interview EnrY_Coll4_Term1_ EnrY_Coll4_Term2_ EnrY_Coll4_Term3_ EnrY_Coll4_Term4_ EnrY_Coll4_Term5_ EnrY_Coll4_Term6_ EnrY_Coll4_Term7_ if ID==734 & inrange(year,2000,2006)
l ID year miss_interview Major1_Coll4_Term1_ Major1_Coll4_Term2_ Major1_Coll4_Term3_ Major1_Coll4_Term4_ Major1_Coll4_Term5_ Major1_Coll4_Term6_ Major1_Coll4_Term7_ if ID==734 & inrange(year,2000,2006), nol
l ID year miss_interview Grade_scale_Coll4_ Grade_scale_new_Coll4_ if ID==734 & inrange(year,2000,2006)

qui gen Grade_scale_Coll5_ = .
qui gen Grade_scale_Coll6_ = .
qui gen Grade_scale_Coll7_ = .
qui gen Grade_scale_Coll8_ = .

forvalues x = 1/8 {
    by ID: replace Newschool_ID`x'_         = Newschool_ID`x'_[_n+1]         if inlist(year,2012,2014)
    by ID: replace Newschool_Code`x'_       = Newschool_Code`x'_[_n+1]       if inlist(year,2012,2014)
    by ID: replace Grade_scale_Coll`x'_     = Grade_scale_Coll`x'_[_n+1]     if inlist(year,2012,2014)
    by ID: replace Grade_scale_new_Coll`x'_ = Grade_scale_new_Coll`x'_[_n+1] if inlist(year,2012,2014)
}

forvalues x = 1/7 {
    by ID: replace Reason_Left_School_`x'_ = Reason_Left_School_`x'_[_n+1]   if  inlist(year,2012,2014)
}

forvalues x = 1/8 {
    if inlist(`x',1) {
        local maxy = 26
    }
    else if inlist(`x',2) {
        local maxy = 18
    }
    else if inlist(`x',3) {
        local maxy = 17
    }
    else if inlist(`x',4) {
        local maxy = 7
    }
    else if inlist(`x',5) {
        local maxy = 8
    }
    else if inlist(`x',6,7,8) {
        local maxy = 3
    }
    forvalues y = 1/`maxy' {
        bys ID (year): replace Coll`x'_GPA_Term`y'_           = Coll`x'_GPA_Term`y'_[_n+1]           if inlist(year,2012,2014)
        bys ID (year): replace Coll`x'_LetterGPA_Term`y'_     = Coll`x'_LetterGPA_Term`y'_[_n+1]     if inlist(year,2012,2014)
        bys ID (year): replace Major1_Coll`x'_Term`y'_        = Major1_Coll`x'_Term`y'_[_n+1]        if inlist(year,2012,2014)
        bys ID (year): replace Major2_Coll`x'_Term`y'_        = Major2_Coll`x'_Term`y'_[_n+1]        if inlist(year,2012,2014)
        bys ID (year): replace EnrM_Coll`x'_Term`y'_          = EnrM_Coll`x'_Term`y'_[_n+1]          if inlist(year,2012,2014)
        bys ID (year): replace EnrY_Coll`x'_Term`y'_          = EnrY_Coll`x'_Term`y'_[_n+1]          if inlist(year,2012,2014)
        bys ID (year): replace Coll`x'_Tuition_Term`y'_       = Coll`x'_Tuition_Term`y'_[_n+1]       if inlist(year,2012,2014)
        bys ID (year): replace Coll`x'_OOP_Term`y'_           = Coll`x'_OOP_Term`y'_[_n+1]           if inlist(year,2012,2014)
        bys ID (year): replace Coll`x'_RecFromPar_Term`y'_    = Coll`x'_RecFromPar_Term`y'_[_n+1]    if inlist(year,2012,2014)
        bys ID (year): replace Coll`x'_RecFromFath_Term`y'_   = Coll`x'_RecFromFath_Term`y'_[_n+1]   if inlist(year,2012,2014)
        bys ID (year): replace Coll`x'_RecFromGpar_Term`y'_   = Coll`x'_RecFromGpar_Term`y'_[_n+1]   if inlist(year,2012,2014)
        bys ID (year): replace Coll`x'_RecFromMoth_Term`y'_   = Coll`x'_RecFromMoth_Term`y'_[_n+1]   if inlist(year,2012,2014)
        bys ID (year): replace Coll`x'_RecFromNone_Term`y'_   = Coll`x'_RecFromNone_Term`y'_[_n+1]   if inlist(year,2012,2014)
        bys ID (year): replace Coll`x'_RecFromORel_Term`y'_   = Coll`x'_RecFromORel_Term`y'_[_n+1]   if inlist(year,2012,2014)
        bys ID (year): replace Coll`x'_TotGiftFrFam1_Term`y'_ = Coll`x'_TotGiftFrFam1_Term`y'_[_n+1] if inlist(year,2012,2014)
        bys ID (year): replace Coll`x'_TotGiftFrFam2_Term`y'_ = Coll`x'_TotGiftFrFam2_Term`y'_[_n+1] if inlist(year,2012,2014)
        bys ID (year): replace Coll`x'_TotGiftFrFam3_Term`y'_ = Coll`x'_TotGiftFrFam3_Term`y'_[_n+1] if inlist(year,2012,2014)
        bys ID (year): replace Coll`x'_TotGiftFrFam4_Term`y'_ = Coll`x'_TotGiftFrFam4_Term`y'_[_n+1] if inlist(year,2012,2014)
        bys ID (year): replace Coll`x'_TotGiftFrFam5_Term`y'_ = Coll`x'_TotGiftFrFam5_Term`y'_[_n+1] if inlist(year,2012,2014)
        bys ID (year): replace Coll`x'_TotLoanFrFam1_Term`y'_ = Coll`x'_TotLoanFrFam1_Term`y'_[_n+1] if inlist(year,2012,2014)
        bys ID (year): replace Coll`x'_TotLoanFrFam2_Term`y'_ = Coll`x'_TotLoanFrFam2_Term`y'_[_n+1] if inlist(year,2012,2014)
        bys ID (year): replace Coll`x'_TotLoanFrFam3_Term`y'_ = Coll`x'_TotLoanFrFam3_Term`y'_[_n+1] if inlist(year,2012,2014)
        bys ID (year): replace Coll`x'_TotLoanFrFam4_Term`y'_ = Coll`x'_TotLoanFrFam4_Term`y'_[_n+1] if inlist(year,2012,2014)
        bys ID (year): replace Coll`x'_TotLoanFrFam5_Term`y'_ = Coll`x'_TotLoanFrFam5_Term`y'_[_n+1] if inlist(year,2012,2014)
        bys ID (year): replace Coll`x'_RecFamily_Term`y'_     = Coll`x'_RecFamily_Term`y'_[_n+1]     if inlist(year,2012,2014)
        bys ID (year): replace Coll`x'_HrsInClass_Term`y'_    = Coll`x'_HrsInClass_Term`y'_[_n+1]    if inlist(year,2012,2014)
        bys ID (year): replace Coll`x'_FTorPT_Term`y'_        = Coll`x'_FTorPT_Term`y'_[_n+1]        if inlist(year,2012,2014)
        bys ID (year): replace Coll`x'_CredsTaken_Term`y'_    = Coll`x'_CredsTaken_Term`y'_[_n+1]    if inlist(year,2012,2014)
        bys ID (year): replace Coll`x'_EntCredEarn_Term`y'_   = Coll`x'_EntCredEarn_Term`y'_[_n+1]   if inlist(year,2012,2014)
        bys ID (year): replace Coll`x'_CredsEarned_Term`y'_   = Coll`x'_CredsEarned_Term`y'_[_n+1]   if inlist(year,2012,2014)
    }
}

gsort ID -year
forvalues x = 1/8 {
    by ID: replace Newschool_ID`x'_         = Newschool_ID`x'_[_n-1]         if ~mi(Newschool_ID`x'_[_n-1]        ) & Newschool_ID`x'_[_n]==.n
    by ID: replace Newschool_ID`x'_         = Newschool_ID`x'_[_n-1]         if ~mi(Newschool_ID`x'_[_n-1]        ) & inrange(year,1993,1996)
    by ID: replace Newschool_Code`x'_       = Newschool_Code`x'_[_n-1]       if ~mi(Newschool_Code`x'_[_n-1]      ) & Newschool_Code`x'_[_n]==.n
    by ID: replace Newschool_Code`x'_       = Newschool_Code`x'_[_n-1]       if ~mi(Newschool_Code`x'_[_n-1]      ) & inrange(year,1993,1996)
    by ID: replace Grade_scale_Coll`x'_     = Grade_scale_Coll`x'_[_n-1]     if ~mi(Grade_scale_Coll`x'_[_n-1]    ) & Grade_scale_Coll`x'_==.n
    by ID: replace Grade_scale_Coll`x'_     = Grade_scale_Coll`x'_[_n-1]     if ~mi(Grade_scale_Coll`x'_[_n-1]    ) & inrange(year,1993,1996)
    by ID: replace Grade_scale_new_Coll`x'_ = Grade_scale_new_Coll`x'_[_n-1] if ~mi(Grade_scale_new_Coll`x'_[_n-1]) & Grade_scale_new_Coll`x'_==.n
    by ID: replace Grade_scale_new_Coll`x'_ = Grade_scale_new_Coll`x'_[_n-1] if ~mi(Grade_scale_new_Coll`x'_[_n-1]) & inrange(year,1993,1996)
}

forvalues x = 1/7 {
    by ID: replace Reason_Left_School_`x'_ = Reason_Left_School_`x'_[_n-1]   if  ~mi(Reason_Left_School_`x'_[_n-1]) & Reason_Left_School_`x'_[_n]==.n
}

forvalues x = 1/8 {
    if inlist(`x',1) {
        local maxy = 26
    }
    else if inlist(`x',2) {
        local maxy = 18
    }
    else if inlist(`x',3) {
        local maxy = 17
    }
    else if inlist(`x',4) {
        local maxy = 7
    }
    else if inlist(`x',5) {
        local maxy = 8
    }
    else if inlist(`x',6,7,8) {
        local maxy = 3
    }
    forvalues y = 1/`maxy' {
        by ID: replace Coll`x'_GPA_Term`y'_           = Coll`x'_GPA_Term`y'_[_n-1]           if !mi(Coll`x'_GPA_Term`y'_[_n-1]          ) & Coll`x'_GPA_Term`y'_[_n]           == .n
        by ID: replace Coll`x'_LetterGPA_Term`y'_     = Coll`x'_LetterGPA_Term`y'_[_n-1]     if !mi(Coll`x'_LetterGPA_Term`y'_[_n-1]    ) & Coll`x'_LetterGPA_Term`y'_[_n]     == .n
        by ID: replace Major1_Coll`x'_Term`y'_        = Major1_Coll`x'_Term`y'_[_n-1]        if !mi(Major1_Coll`x'_Term`y'_[_n-1]       ) & Major1_Coll`x'_Term`y'_[_n]        == .n
        by ID: replace Major2_Coll`x'_Term`y'_        = Major2_Coll`x'_Term`y'_[_n-1]        if !mi(Major2_Coll`x'_Term`y'_[_n-1]       ) & Major2_Coll`x'_Term`y'_[_n]        == .n
        by ID: replace EnrM_Coll`x'_Term`y'_          = EnrM_Coll`x'_Term`y'_[_n-1]          if !mi(EnrM_Coll`x'_Term`y'_[_n-1]         ) & EnrM_Coll`x'_Term`y'_[_n]          == .n
        by ID: replace EnrY_Coll`x'_Term`y'_          = EnrY_Coll`x'_Term`y'_[_n-1]          if !mi(EnrY_Coll`x'_Term`y'_[_n-1]         ) & EnrY_Coll`x'_Term`y'_[_n]          == .n
        by ID: replace Coll`x'_Tuition_Term`y'_       = Coll`x'_Tuition_Term`y'_[_n-1]       if !mi(Coll`x'_Tuition_Term`y'_[_n-1]      ) & Coll`x'_Tuition_Term`y'_[_n]       == .n
        by ID: replace Coll`x'_OOP_Term`y'_           = Coll`x'_OOP_Term`y'_[_n-1]           if !mi(Coll`x'_OOP_Term`y'_[_n-1]          ) & Coll`x'_OOP_Term`y'_[_n]           == .n
        by ID: replace Coll`x'_RecFromPar_Term`y'_    = Coll`x'_RecFromPar_Term`y'_[_n-1]    if !mi(Coll`x'_RecFromPar_Term`y'_[_n-1]   ) & Coll`x'_RecFromPar_Term`y'_[_n]    == .n
        by ID: replace Coll`x'_RecFromFath_Term`y'_   = Coll`x'_RecFromFath_Term`y'_[_n-1]   if !mi(Coll`x'_RecFromFath_Term`y'_[_n-1]  ) & Coll`x'_RecFromFath_Term`y'_[_n]   == .n
        by ID: replace Coll`x'_RecFromGpar_Term`y'_   = Coll`x'_RecFromGpar_Term`y'_[_n-1]   if !mi(Coll`x'_RecFromGpar_Term`y'_[_n-1]  ) & Coll`x'_RecFromGpar_Term`y'_[_n]   == .n
        by ID: replace Coll`x'_RecFromMoth_Term`y'_   = Coll`x'_RecFromMoth_Term`y'_[_n-1]   if !mi(Coll`x'_RecFromMoth_Term`y'_[_n-1]  ) & Coll`x'_RecFromMoth_Term`y'_[_n]   == .n
        by ID: replace Coll`x'_RecFromNone_Term`y'_   = Coll`x'_RecFromNone_Term`y'_[_n-1]   if !mi(Coll`x'_RecFromNone_Term`y'_[_n-1]  ) & Coll`x'_RecFromNone_Term`y'_[_n]   == .n
        by ID: replace Coll`x'_RecFromORel_Term`y'_   = Coll`x'_RecFromORel_Term`y'_[_n-1]   if !mi(Coll`x'_RecFromORel_Term`y'_[_n-1]  ) & Coll`x'_RecFromORel_Term`y'_[_n]   == .n
        by ID: replace Coll`x'_TotGiftFrFam1_Term`y'_ = Coll`x'_TotGiftFrFam1_Term`y'_[_n-1] if !mi(Coll`x'_TotGiftFrFam1_Term`y'_[_n-1]) & Coll`x'_TotGiftFrFam1_Term`y'_[_n] == .n
        by ID: replace Coll`x'_TotGiftFrFam2_Term`y'_ = Coll`x'_TotGiftFrFam2_Term`y'_[_n-1] if !mi(Coll`x'_TotGiftFrFam2_Term`y'_[_n-1]) & Coll`x'_TotGiftFrFam2_Term`y'_[_n] == .n
        by ID: replace Coll`x'_TotGiftFrFam3_Term`y'_ = Coll`x'_TotGiftFrFam3_Term`y'_[_n-1] if !mi(Coll`x'_TotGiftFrFam3_Term`y'_[_n-1]) & Coll`x'_TotGiftFrFam3_Term`y'_[_n] == .n
        by ID: replace Coll`x'_TotGiftFrFam4_Term`y'_ = Coll`x'_TotGiftFrFam4_Term`y'_[_n-1] if !mi(Coll`x'_TotGiftFrFam4_Term`y'_[_n-1]) & Coll`x'_TotGiftFrFam4_Term`y'_[_n] == .n
        by ID: replace Coll`x'_TotGiftFrFam5_Term`y'_ = Coll`x'_TotGiftFrFam5_Term`y'_[_n-1] if !mi(Coll`x'_TotGiftFrFam5_Term`y'_[_n-1]) & Coll`x'_TotGiftFrFam5_Term`y'_[_n] == .n
        by ID: replace Coll`x'_TotLoanFrFam1_Term`y'_ = Coll`x'_TotLoanFrFam1_Term`y'_[_n-1] if !mi(Coll`x'_TotLoanFrFam1_Term`y'_[_n-1]) & Coll`x'_TotLoanFrFam1_Term`y'_[_n] == .n
        by ID: replace Coll`x'_TotLoanFrFam2_Term`y'_ = Coll`x'_TotLoanFrFam2_Term`y'_[_n-1] if !mi(Coll`x'_TotLoanFrFam2_Term`y'_[_n-1]) & Coll`x'_TotLoanFrFam2_Term`y'_[_n] == .n
        by ID: replace Coll`x'_TotLoanFrFam3_Term`y'_ = Coll`x'_TotLoanFrFam3_Term`y'_[_n-1] if !mi(Coll`x'_TotLoanFrFam3_Term`y'_[_n-1]) & Coll`x'_TotLoanFrFam3_Term`y'_[_n] == .n
        by ID: replace Coll`x'_TotLoanFrFam4_Term`y'_ = Coll`x'_TotLoanFrFam4_Term`y'_[_n-1] if !mi(Coll`x'_TotLoanFrFam4_Term`y'_[_n-1]) & Coll`x'_TotLoanFrFam4_Term`y'_[_n] == .n
        by ID: replace Coll`x'_TotLoanFrFam5_Term`y'_ = Coll`x'_TotLoanFrFam5_Term`y'_[_n-1] if !mi(Coll`x'_TotLoanFrFam5_Term`y'_[_n-1]) & Coll`x'_TotLoanFrFam5_Term`y'_[_n] == .n
        by ID: replace Coll`x'_RecFamily_Term`y'_     = Coll`x'_RecFamily_Term`y'_[_n-1]     if !mi(Coll`x'_RecFamily_Term`y'_[_n-1]    ) & Coll`x'_RecFamily_Term`y'_[_n]     == .n
        by ID: replace Coll`x'_HrsInClass_Term`y'_    = Coll`x'_HrsInClass_Term`y'_[_n-1]    if !mi(Coll`x'_HrsInClass_Term`y'_[_n-1]   ) & Coll`x'_HrsInClass_Term`y'_[_n]    == .n
        by ID: replace Coll`x'_FTorPT_Term`y'_        = Coll`x'_FTorPT_Term`y'_[_n-1]        if !mi(Coll`x'_FTorPT_Term`y'_[_n-1]       ) & Coll`x'_FTorPT_Term`y'_[_n]        == .n
        by ID: replace Coll`x'_CredsTaken_Term`y'_    = Coll`x'_CredsTaken_Term`y'_[_n-1]    if !mi(Coll`x'_CredsTaken_Term`y'_[_n-1]   ) & Coll`x'_CredsTaken_Term`y'_[_n]    == .n
        by ID: replace Coll`x'_EntCredEarn_Term`y'_   = Coll`x'_EntCredEarn_Term`y'_[_n-1]   if !mi(Coll`x'_EntCredEarn_Term`y'_[_n-1]  ) & Coll`x'_EntCredEarn_Term`y'_[_n]   == .n
        by ID: replace Coll`x'_CredsEarned_Term`y'_   = Coll`x'_CredsEarned_Term`y'_[_n-1]   if !mi(Coll`x'_CredsEarned_Term`y'_[_n-1]  ) & Coll`x'_CredsEarned_Term`y'_[_n]   == .n
    }
}
sort ID year

*--------------------------------------------------------------------------
* Now only use the backfilled information for the actual year it applies to
*--------------------------------------------------------------------------
forvalues x = 1/8 {
    if inlist(`x',1) {
        local maxy = 26
    }
    else if inlist(`x',2) {
        local maxy = 18
    }
    else if inlist(`x',3) {
        local maxy = 17
    }
    else if inlist(`x',4) {
        local maxy = 7
    }
    else if inlist(`x',5) {
        local maxy = 8
    }
    else if inlist(`x',6,7,8) {
        local maxy = 3
    }
    * NOT SURE HOW TO TAKE CARE OF THESE....
    * replace Newschool_ID`x'_         = . if EnrY_Coll`x'_Term`y'_~=year
    * replace Newschool_Code`x'_       = . if EnrY_Coll`x'_Term`y'_~=year
    * replace Grade_scale_Coll`x'_     = . if EnrY_Coll`x'_Term`y'_~=year
    * replace Grade_scale_new_Coll`x'_ = . if EnrY_Coll`x'_Term`y'_~=year
    forvalues y = 1/`maxy' {
        replace Coll`x'_GPA_Term`y'_           = . if EnrY_Coll`x'_Term`y'_~=year
        replace Coll`x'_LetterGPA_Term`y'_     = . if EnrY_Coll`x'_Term`y'_~=year
        replace Major1_Coll`x'_Term`y'_        = . if EnrY_Coll`x'_Term`y'_~=year
        replace Major2_Coll`x'_Term`y'_        = . if EnrY_Coll`x'_Term`y'_~=year
        replace EnrM_Coll`x'_Term`y'_          = . if EnrY_Coll`x'_Term`y'_~=year
        replace EnrY_Coll`x'_Term`y'_          = . if EnrY_Coll`x'_Term`y'_~=year
        replace Coll`x'_Tuition_Term`y'_       = . if EnrY_Coll`x'_Term`y'_~=year
        replace Coll`x'_OOP_Term`y'_           = . if EnrY_Coll`x'_Term`y'_~=year
        replace Coll`x'_RecFromPar_Term`y'_    = . if EnrY_Coll`x'_Term`y'_~=year
        replace Coll`x'_RecFromFath_Term`y'_   = . if EnrY_Coll`x'_Term`y'_~=year
        replace Coll`x'_RecFromGpar_Term`y'_   = . if EnrY_Coll`x'_Term`y'_~=year
        replace Coll`x'_RecFromMoth_Term`y'_   = . if EnrY_Coll`x'_Term`y'_~=year
        replace Coll`x'_RecFromNone_Term`y'_   = . if EnrY_Coll`x'_Term`y'_~=year
        replace Coll`x'_RecFromORel_Term`y'_   = . if EnrY_Coll`x'_Term`y'_~=year
        replace Coll`x'_TotGiftFrFam1_Term`y'_ = . if EnrY_Coll`x'_Term`y'_~=year
        replace Coll`x'_TotGiftFrFam2_Term`y'_ = . if EnrY_Coll`x'_Term`y'_~=year
        replace Coll`x'_TotGiftFrFam3_Term`y'_ = . if EnrY_Coll`x'_Term`y'_~=year
        replace Coll`x'_TotGiftFrFam4_Term`y'_ = . if EnrY_Coll`x'_Term`y'_~=year
        replace Coll`x'_TotGiftFrFam5_Term`y'_ = . if EnrY_Coll`x'_Term`y'_~=year
        replace Coll`x'_TotLoanFrFam1_Term`y'_ = . if EnrY_Coll`x'_Term`y'_~=year
        replace Coll`x'_TotLoanFrFam2_Term`y'_ = . if EnrY_Coll`x'_Term`y'_~=year
        replace Coll`x'_TotLoanFrFam3_Term`y'_ = . if EnrY_Coll`x'_Term`y'_~=year
        replace Coll`x'_TotLoanFrFam4_Term`y'_ = . if EnrY_Coll`x'_Term`y'_~=year
        replace Coll`x'_TotLoanFrFam5_Term`y'_ = . if EnrY_Coll`x'_Term`y'_~=year
        replace Coll`x'_RecFamily_Term`y'_     = . if EnrY_Coll`x'_Term`y'_~=year
        replace Coll`x'_HrsInClass_Term`y'_    = . if EnrY_Coll`x'_Term`y'_~=year
        replace Coll`x'_FTorPT_Term`y'_        = . if EnrY_Coll`x'_Term`y'_~=year
        replace Coll`x'_CredsTaken_Term`y'_    = . if EnrY_Coll`x'_Term`y'_~=year
        replace Coll`x'_EntCredEarn_Term`y'_   = . if EnrY_Coll`x'_Term`y'_~=year
        replace Coll`x'_CredsEarned_Term`y'_   = . if EnrY_Coll`x'_Term`y'_~=year
    }
}

l ID year miss_interview College_enrollment_Oct if ID==734 & inrange(year,2000,2006)
l ID year miss_interview Coll4_GPA_Term1_ Coll4_GPA_Term2_ Coll4_GPA_Term3_ Coll4_GPA_Term4_ Coll4_GPA_Term5_ Coll4_GPA_Term6_ Coll4_GPA_Term7_ if ID==734 & inrange(year,2000,2006)
l ID year miss_interview EnrY_Coll4_Term1_ EnrY_Coll4_Term2_ EnrY_Coll4_Term3_ EnrY_Coll4_Term4_ EnrY_Coll4_Term5_ EnrY_Coll4_Term6_ EnrY_Coll4_Term7_ if ID==734 & inrange(year,2000,2006)
l ID year miss_interview Major1_Coll4_Term1_ Major1_Coll4_Term2_ Major1_Coll4_Term3_ Major1_Coll4_Term4_ Major1_Coll4_Term5_ Major1_Coll4_Term6_ Major1_Coll4_Term7_ if ID==734 & inrange(year,2000,2006), nol
l ID year miss_interview Grade_scale_Coll4_ Grade_scale_new_Coll4_ if ID==734 & inrange(year,2000,2006)

* get number of surveyGPA/Major/Enrollment dates per year (i.e. number of semesters in the year)
egen num_GPA_obs  = rownonmiss(Coll*_GPA_Term*_)
egen num_Maj_obs  = rownonmiss(Major?_Coll*_Term*_)
egen num_EnrD_obs = rownonmiss(EnrY_Coll*_Term*_  )

* see the distribution of number of semesters for years in which enrollment is reported
tab num_GPA_obs  if in_4yr==1 | in_2yr==1
tab num_Maj_obs  if in_4yr==1 | in_2yr==1
tab num_EnrD_obs if in_4yr==1 | in_2yr==1

*---------------------------------------
* Correct surveyGPA for different grade scales
*---------------------------------------
* 1         0 to 4.0
* 2         0 to 5.0
* 3          0 to 10
* 4        0  to 100
* 5  Other (SPECIFY)
* 99       UNCODABLE

* Get perent of surveyGPA observations that are not on a 4-point scale
* local en0 = 0
* local en02= 0
* forvalues x = 1/8 {
    * if inlist(`x',1) {
        * local maxy = 26
    * }
    * else if inlist(`x',2) {
        * local maxy = 18
    * }
    * else if inlist(`x',3) {
        * local maxy = 17
    * }
    * else if inlist(`x',4) {
        * local maxy = 7
    * }
    * else if inlist(`x',5) {
        * local maxy = 8
    * }
    * else if inlist(`x',6,7,8) {
        * local maxy = 3
    * }
    * forvalues y = 1/`maxy' {
        * disp "College `x', Term `y'"
        * qui count if inrange(College`x'_GPA_Term`y'_,0,.)
        * local en1 `r(N)'
        * qui count if inrange(College`x'_GPA_Term`y'_,401,.)
        * local en2 `r(N)'
        * disp "N = " `en1'
        * disp "% not on 4-point scale: " `en2'/`en1'
        * local en0  = `en0' +`en1'
        * local en02 = `en02'+`en2'
    * }
* }
* disp "Overall N = " `en0'
* disp "Overall % not on 4-point scale: " `en02'/`en0'

* Convert letter GPAs to numbers (where applicable)
forvalues x = 1/8 {
    if inlist(`x',1) {
        local maxy = 26
    }
    else if inlist(`x',2) {
        local maxy = 18
    }
    else if inlist(`x',3) {
        local maxy = 17
    }
    else if inlist(`x',4) {
        local maxy = 7
    }
    else if inlist(`x',5) {
        local maxy = 8
    }
    else if inlist(`x',6,7,8) {
        local maxy = 3
    }
    forvalues y = 1/`maxy' {
        qui generat Coll`x'_LetterGrd_Term`y'_ = .
        qui replace Coll`x'_LetterGrd_Term`y'_ = 400 if inlist(Coll`x'_LetterGPA_Term`y'_,1,2)
        qui replace Coll`x'_LetterGrd_Term`y'_ = 370 if inlist(Coll`x'_LetterGPA_Term`y'_,3)
        qui replace Coll`x'_LetterGrd_Term`y'_ = 340 if inlist(Coll`x'_LetterGPA_Term`y'_,4)
        qui replace Coll`x'_LetterGrd_Term`y'_ = 300 if inlist(Coll`x'_LetterGPA_Term`y'_,5)
        qui replace Coll`x'_LetterGrd_Term`y'_ = 270 if inlist(Coll`x'_LetterGPA_Term`y'_,6)
        qui replace Coll`x'_LetterGrd_Term`y'_ = 240 if inlist(Coll`x'_LetterGPA_Term`y'_,7)
        qui replace Coll`x'_LetterGrd_Term`y'_ = 200 if inlist(Coll`x'_LetterGPA_Term`y'_,8)
        qui replace Coll`x'_LetterGrd_Term`y'_ = 170 if inlist(Coll`x'_LetterGPA_Term`y'_,9)
        qui replace Coll`x'_LetterGrd_Term`y'_ = 140 if inlist(Coll`x'_LetterGPA_Term`y'_,10)
        qui replace Coll`x'_LetterGrd_Term`y'_ = 100 if inlist(Coll`x'_LetterGPA_Term`y'_,11)
        qui replace Coll`x'_LetterGrd_Term`y'_ =  70 if inlist(Coll`x'_LetterGPA_Term`y'_,12)
        qui replace Coll`x'_LetterGrd_Term`y'_ =   0 if inlist(Coll`x'_LetterGPA_Term`y'_,13)
        qui replace Coll`x'_GPA_Term`y'_       = Coll`x'_LetterGrd_Term`y'_ if mi(Coll`x'_GPA_Term`y'_) & !mi(Coll`x'_LetterGrd_Term`y'_)
    }
}

* Correct surveyGPA according to reported grade scale
forvalues x = 1/8 {
    if inlist(`x',1) {
        local maxy = 26
    }
    else if inlist(`x',2) {
        local maxy = 18
    }
    else if inlist(`x',3) {
        local maxy = 17
    }
    else if inlist(`x',4) {
        local maxy = 7
    }
    else if inlist(`x',5) {
        local maxy = 8
    }
    else if inlist(`x',6,7,8) {
        local maxy = 3
    }
    forvalues y = 1/`maxy' {
        qui replace Coll`x'_GPA_Term`y'_ = Coll`x'_GPA_Term`y'_*(4/5  ) if Grade_scale_Coll`x'_ == 2
        qui replace Coll`x'_GPA_Term`y'_ = Coll`x'_GPA_Term`y'_*(4/10 ) if Grade_scale_Coll`x'_ == 3
        qui replace Coll`x'_GPA_Term`y'_ = Coll`x'_GPA_Term`y'_*(4/100) if Grade_scale_Coll`x'_ == 4
        qui replace Coll`x'_GPA_Term`y'_ = .                            if inlist(Grade_scale_Coll`x'_,5,99)
        qui replace Coll`x'_GPA_Term`y'_ = Coll`x'_GPA_Term`y'_*(4/5  ) if Grade_scale_new_Coll`x'_ == 2
        qui replace Coll`x'_GPA_Term`y'_ = Coll`x'_GPA_Term`y'_*(4/10 ) if Grade_scale_new_Coll`x'_ == 3
        qui replace Coll`x'_GPA_Term`y'_ = Coll`x'_GPA_Term`y'_*(4/100) if Grade_scale_new_Coll`x'_ == 4
        qui replace Coll`x'_GPA_Term`y'_ = .                            if inlist(Grade_scale_new_Coll`x'_,5,99)
    }
}

* Correct surveyGPA for those who don't report a grade scale
forvalues x = 1/8 {
    if inlist(`x',1) {
        local maxy = 26
    }
    else if inlist(`x',2) {
        local maxy = 18
    }
    else if inlist(`x',3) {
        local maxy = 17
    }
    else if inlist(`x',4) {
        local maxy = 7
    }
    else if inlist(`x',5) {
        local maxy = 8
    }
    else if inlist(`x',6,7,8) {
        local maxy = 3
    }
    forvalues y = 1/`maxy' {
        qui replace Coll`x'_GPA_Term`y'_ = Coll`x'_GPA_Term`y'_*(4/5 )  if inrange(Coll`x'_GPA_Term`y'_,401 ,500  ) & ~inlist(Grade_scale_Coll`x'_,2,3,4) & ~inlist(Grade_scale_Coll`x'_,2,3,4)
        qui replace Coll`x'_GPA_Term`y'_ = Coll`x'_GPA_Term`y'_*(4/10 ) if inrange(Coll`x'_GPA_Term`y'_,501 ,1000 ) & ~inlist(Grade_scale_Coll`x'_,2,3,4) & ~inlist(Grade_scale_Coll`x'_,2,3,4)
        qui replace Coll`x'_GPA_Term`y'_ = Coll`x'_GPA_Term`y'_*(4/100) if inrange(Coll`x'_GPA_Term`y'_,1001,10000) & ~inlist(Grade_scale_Coll`x'_,2,3,4) & ~inlist(Grade_scale_Coll`x'_,2,3,4)
    }
}

* forvalues x = 1/8 {
    * if inlist(`x',1) {
        * local maxy = 26
    * }
    * else if inlist(`x',2) {
        * local maxy = 18
    * }
    * else if inlist(`x',3) {
        * local maxy = 17
    * }
    * else if inlist(`x',4) {
        * local maxy = 7
    * }
    * else if inlist(`x',5) {
        * local maxy = 8
    * }
    * else if inlist(`x',6,7,8) {
        * local maxy = 3
    * }
    * forvalues y = 1/`maxy' {
        * disp "College `x', Term `y'"
        * count if inrange(College`x'_GPA_Term`y'_,401,.)
    * }
* }

* Divide surveyGPA by 100 to convert to 4-point scale (instead of 400-point scale)
forvalues x = 1/8 {
    if inlist(`x',1) {
        local maxy = 26
    }
    else if inlist(`x',2) {
        local maxy = 18
    }
    else if inlist(`x',3) {
        local maxy = 17
    }
    else if inlist(`x',4) {
        local maxy = 7
    }
    else if inlist(`x',5) {
        local maxy = 8
    }
    else if inlist(`x',6,7,8) {
        local maxy = 3
    }
    forvalues y = 1/`maxy' {
        qui replace Coll`x'_GPA_Term`y'_ = Coll`x'_GPA_Term`y'_/100
    }
}

* Hand-code two cases that have an extra zero on their surveyGPA:
replace Coll1_GPA_Term1_ = Coll1_GPA_Term1_/10 if (ID==6911 & year==2008) | (ID==7854 & year==2001)

* Check some IDs that may be problematic
* l ID year Coll1_GPA_Term1_ Grade_scale_new_Coll1_ Grade_scale_Coll1_ if inlist(ID,6911,7854), nol
* Check some IDs that may be problematic
* l ID year Coll1_GPA_Term1_ Grade_scale_new_Coll1_ Grade_scale_Coll1_ if inlist(ID,6911,7854), nol
*-----------------------------------------------------------------------------
* Collapse the College Term specific data into one array, evaluated at October
*-----------------------------------------------------------------------------
egen    OOP               = rowtotal(Coll?_OOP_Term*_), missing
egen    recColParTransfer = rowtotal(Coll?_RecFromPar_Term*_ Coll?_RecFromFath_Term*_ Coll?_RecFromGpar_Term*_ Coll?_RecFromMoth_Term*_ Coll?_RecFromORel_Term*_ ), missing
egen    colParTransfer    = rowtotal(Coll?_TotGiftFrFam?_Term*_ Coll?_TotLoanFrFam?_Term*_), missing
egen    HrsClass          = rowmean (Coll*_HrsInClass_Term*_)
egen    surveyCredits     = rowmean (Coll*_CredsTaken_Term*_)
egen    TuitionReported   = rowmean (Coll*_Tuition_Term*_)
egen    surveyGPA         = rowmean (Coll*_GPA_Term*_)
egen    Major             = rowfirst(Major?_Coll*_Term*_)
replace Major             = . if in_4yr==0
lab val Major    vl_Majors

sum tscriptGPA if in_college
local tranmu = `r(mean)'
local transd = `r(sd)'
sum surveyGPA if in_college
local svysd = `r(sd)'
gen newSurveyGPAa = surveyGPA/(`svysd'/`transd')
sum newSurveyGPAa if in_college
local svymu = `r(mean)'
gen newSurveyGPAb = newSurveyGPAa-(`svymu'-`tranmu')
sum tscriptGPA *urveyGPA* if in_college
gen     GPA               = tscriptGPA
replace GPA               = newSurveyGPAb if  in_college & mi(tscriptGPA)
replace GPA               = .             if !in_college
sum tscriptGPA GPA if in_college
gen     GPAdiffVar        = tscriptGPA
replace GPAdiffVar        = surveyGPA if  in_college & mi(tscriptGPA)
replace GPAdiffVar        = .         if !in_college

corr  surveyGPA tscriptGPA GPA GPAdiffVar if in_college
mdesc surveyGPA tscriptGPA GPA GPAdiffVar if in_college

gen     Credits = tscriptCredits
replace Credits = surveyCredits if  in_college & mi(tscriptCredits)
replace Credits = .             if !in_college

corr  surveyCredits tscriptCredits Credits if in_college
mdesc surveyCredits tscriptCredits Credits if in_college

* Clean up parental transfer variables
replace recColParTransfer = 0 if mi(recColParTransfer) & in_college
replace recColParTransfer = 1 if inrange(recColParTransfer,1,.) & in_college
replace recColParTransfer = 0 if !in_college

replace colParTransfer = 0 if recColParTransfer==0 & in_college
replace colParTransfer = 0 if mi(colParTransfer)   & in_college
replace colParTransfer = 0 if                       !in_college

* Deflate money by CPI
replace OOP             = OOP/cpi
replace colParTransfer  = colParTransfer/cpi
replace TuitionReported = TuitionReported/cpi

sum OOP               if in_college, d
sum recColParTransfer if in_college, d
sum colParTransfer    if in_college, d
sum HrsClass          if in_college, d
sum Credits           if in_college, d
sum surveyCredits     if in_college, d
sum tscriptCredits    if in_college, d
sum TuitionReported   if in_college, d
sum GPA               if in_college, d
sum surveyGPA         if in_college, d
sum tscriptGPA        if in_college, d
tab Major             if in_4yr, mi

generat DKMajor      =  Major==0
generat missingMajor =  mi(Major)
generat scienceMajor =  inlist(Major,1,6,9,13,21,25,36) // narrowest possible definition of STEM
generat otherMajor   = ~inlist(Major,1,6,9,13,21,25,36) & Major~=0 & ~mi(Major)
replace scienceMajor = . if in_4yr==0
replace DKMajor      = . if in_4yr==0
replace missingMajor = . if in_4yr==0
replace otherMajor   = . if in_4yr==0

generat scienceMajorA =  inlist(Major,6,  9   ,13,21   ,25,27,29,30) // take out Business, Econ, and Nursing
generat otherMajorA   = ~inlist(Major,6,  9   ,13,21   ,25,27,29,30) & Major~=0 & ~mi(Major)
replace scienceMajorA = . if in_4yr==0
replace otherMajorA   = . if in_4yr==0

generat scienceMajorB =  inlist(Major,6,  9   ,13,21   ,25,26      ) // take out Business, Econ, Nursing, and Pre-Meds, but add in NDFS
generat otherMajorB   = ~inlist(Major,6,  9   ,13,21   ,25,26      ) & Major~=0 & ~mi(Major)
replace scienceMajorB = . if in_4yr==0
replace otherMajorB   = . if in_4yr==0

*-----------------------------------------------------------------------------
* Create a variable for final major --- last non-missing Major for graduates
*-----------------------------------------------------------------------------
bys ID (year): egen final_majorA = lastnm(Major) if ever_grad_4yr==1
bys ID (year): egen final_major  = mean(final_majorA)
count if year==BA_year
count if final_majorA<.
* 27 and 29 are pre-dental, pre-med. These at one point were in the science major but then the data didn't work so I'm seeing if they were causing the problem
gen finalSciMajor     = (inlist(final_major,1,6,9,13,21,25      ,36) & final_major<.) // widest possible definition of STEM
gen finalSciMajorA    = (inlist(final_major,  6,9,13,21,25,27,29,30) & final_major<.) // take out Business, Econ, and Nursing
gen finalSciMajorB    = (inlist(final_major,  6,9,13,21,25,26      ) & final_major<.) // take out Business, Econ, Nursing, and Pre-Meds, but add in NDFS



*-----------------------------------------------------------------------------
* Create average tuition variable from NCES statistics, based on college type
* and level (e.g. 4-year public, 2-year private, etc.)
* (https://nces.ed.gov/programs/digest/d16/tables/dt16_330.10.asp)
*-----------------------------------------------------------------------------
generat Tuition = .
generat Room = .
generat Board = .

* Public 4-year tuition
replace Tuition = 3110  if year==1997 & inlist(floor(CollTypeTerm_Oct/100),10,40) & in_4yr==1
replace Tuition = 3229  if year==1998 & inlist(floor(CollTypeTerm_Oct/100),10,40) & in_4yr==1
replace Tuition = 3349  if year==1999 & inlist(floor(CollTypeTerm_Oct/100),10,40) & in_4yr==1
replace Tuition = 3501  if year==2000 & inlist(floor(CollTypeTerm_Oct/100),10,40) & in_4yr==1
replace Tuition = 3735  if year==2001 & inlist(floor(CollTypeTerm_Oct/100),10,40) & in_4yr==1
replace Tuition = 4046  if year==2002 & inlist(floor(CollTypeTerm_Oct/100),10,40) & in_4yr==1
replace Tuition = 4587  if year==2003 & inlist(floor(CollTypeTerm_Oct/100),10,40) & in_4yr==1
replace Tuition = 5027  if year==2004 & inlist(floor(CollTypeTerm_Oct/100),10,40) & in_4yr==1
replace Tuition = 5351  if year==2005 & inlist(floor(CollTypeTerm_Oct/100),10,40) & in_4yr==1
replace Tuition = 5666  if year==2006 & inlist(floor(CollTypeTerm_Oct/100),10,40) & in_4yr==1
replace Tuition = 5943  if year==2007 & inlist(floor(CollTypeTerm_Oct/100),10,40) & in_4yr==1
replace Tuition = 6312  if year==2008 & inlist(floor(CollTypeTerm_Oct/100),10,40) & in_4yr==1
replace Tuition = 6717  if year==2009 & inlist(floor(CollTypeTerm_Oct/100),10,40) & in_4yr==1
replace Tuition = 7132  if year==2010 & inlist(floor(CollTypeTerm_Oct/100),10,40) & in_4yr==1
replace Tuition = 7713  if year==2011 & inlist(floor(CollTypeTerm_Oct/100),10,40) & in_4yr==1
replace Tuition = 8070  if year==2012 & inlist(floor(CollTypeTerm_Oct/100),10,40) & in_4yr==1
replace Tuition = 8312  if year==2013 & inlist(floor(CollTypeTerm_Oct/100),10,40) & in_4yr==1
replace Tuition = 8543  if year==2014 & inlist(floor(CollTypeTerm_Oct/100),10,40) & in_4yr==1
replace Tuition = 8778  if year==2015 & inlist(floor(CollTypeTerm_Oct/100),10,40) & in_4yr==1

* Private 4-year tuition
replace Tuition = 13344 if year==1997 & inlist(floor(CollTypeTerm_Oct/100),20) & in_4yr==1
replace Tuition = 13973 if year==1998 & inlist(floor(CollTypeTerm_Oct/100),20) & in_4yr==1
replace Tuition = 14616 if year==1999 & inlist(floor(CollTypeTerm_Oct/100),20) & in_4yr==1
replace Tuition = 15470 if year==2000 & inlist(floor(CollTypeTerm_Oct/100),20) & in_4yr==1
replace Tuition = 16211 if year==2001 & inlist(floor(CollTypeTerm_Oct/100),20) & in_4yr==1
replace Tuition = 16826 if year==2002 & inlist(floor(CollTypeTerm_Oct/100),20) & in_4yr==1
replace Tuition = 17763 if year==2003 & inlist(floor(CollTypeTerm_Oct/100),20) & in_4yr==1
replace Tuition = 18604 if year==2004 & inlist(floor(CollTypeTerm_Oct/100),20) & in_4yr==1
replace Tuition = 19292 if year==2005 & inlist(floor(CollTypeTerm_Oct/100),20) & in_4yr==1
replace Tuition = 20517 if year==2006 & inlist(floor(CollTypeTerm_Oct/100),20) & in_4yr==1
replace Tuition = 21427 if year==2007 & inlist(floor(CollTypeTerm_Oct/100),20) & in_4yr==1
replace Tuition = 22036 if year==2008 & inlist(floor(CollTypeTerm_Oct/100),20) & in_4yr==1
replace Tuition = 22269 if year==2009 & inlist(floor(CollTypeTerm_Oct/100),20) & in_4yr==1
replace Tuition = 22677 if year==2010 & inlist(floor(CollTypeTerm_Oct/100),20) & in_4yr==1
replace Tuition = 23464 if year==2011 & inlist(floor(CollTypeTerm_Oct/100),20) & in_4yr==1
replace Tuition = 24523 if year==2012 & inlist(floor(CollTypeTerm_Oct/100),20) & in_4yr==1
replace Tuition = 25707 if year==2013 & inlist(floor(CollTypeTerm_Oct/100),20) & in_4yr==1
replace Tuition = 26740 if year==2014 & inlist(floor(CollTypeTerm_Oct/100),20) & in_4yr==1
replace Tuition = 27951 if year==2015 & inlist(floor(CollTypeTerm_Oct/100),20) & in_4yr==1

* Public 2-year tuition
replace Tuition = 1314  if year==1997 & inlist(floor(CollTypeTerm_Oct/100),10,40) & in_2yr==1
replace Tuition = 1327  if year==1998 & inlist(floor(CollTypeTerm_Oct/100),10,40) & in_2yr==1
replace Tuition = 1348  if year==1999 & inlist(floor(CollTypeTerm_Oct/100),10,40) & in_2yr==1
replace Tuition = 1333  if year==2000 & inlist(floor(CollTypeTerm_Oct/100),10,40) & in_2yr==1
replace Tuition = 1380  if year==2001 & inlist(floor(CollTypeTerm_Oct/100),10,40) & in_2yr==1
replace Tuition = 1483  if year==2002 & inlist(floor(CollTypeTerm_Oct/100),10,40) & in_2yr==1
replace Tuition = 1702  if year==2003 & inlist(floor(CollTypeTerm_Oct/100),10,40) & in_2yr==1
replace Tuition = 1849  if year==2004 & inlist(floor(CollTypeTerm_Oct/100),10,40) & in_2yr==1
replace Tuition = 1935  if year==2005 & inlist(floor(CollTypeTerm_Oct/100),10,40) & in_2yr==1
replace Tuition = 2018  if year==2006 & inlist(floor(CollTypeTerm_Oct/100),10,40) & in_2yr==1
replace Tuition = 2061  if year==2007 & inlist(floor(CollTypeTerm_Oct/100),10,40) & in_2yr==1
replace Tuition = 2136  if year==2008 & inlist(floor(CollTypeTerm_Oct/100),10,40) & in_2yr==1
replace Tuition = 2283  if year==2009 & inlist(floor(CollTypeTerm_Oct/100),10,40) & in_2yr==1
replace Tuition = 2441  if year==2010 & inlist(floor(CollTypeTerm_Oct/100),10,40) & in_2yr==1
replace Tuition = 2651  if year==2011 & inlist(floor(CollTypeTerm_Oct/100),10,40) & in_2yr==1
replace Tuition = 2792  if year==2012 & inlist(floor(CollTypeTerm_Oct/100),10,40) & in_2yr==1
replace Tuition = 2881  if year==2013 & inlist(floor(CollTypeTerm_Oct/100),10,40) & in_2yr==1
replace Tuition = 2955  if year==2014 & inlist(floor(CollTypeTerm_Oct/100),10,40) & in_2yr==1
replace Tuition = 3038  if year==2015 & inlist(floor(CollTypeTerm_Oct/100),10,40) & in_2yr==1

* Private 2-year tuition
replace Tuition = 7464  if year==1997 & inlist(floor(CollTypeTerm_Oct/100),20) & in_2yr==1
replace Tuition = 7854  if year==1998 & inlist(floor(CollTypeTerm_Oct/100),20) & in_2yr==1
replace Tuition = 8225  if year==1999 & inlist(floor(CollTypeTerm_Oct/100),20) & in_2yr==1
replace Tuition = 9067  if year==2000 & inlist(floor(CollTypeTerm_Oct/100),20) & in_2yr==1
replace Tuition = 10076 if year==2001 & inlist(floor(CollTypeTerm_Oct/100),20) & in_2yr==1
replace Tuition = 10651 if year==2002 & inlist(floor(CollTypeTerm_Oct/100),20) & in_2yr==1
replace Tuition = 11545 if year==2003 & inlist(floor(CollTypeTerm_Oct/100),20) & in_2yr==1
replace Tuition = 12122 if year==2004 & inlist(floor(CollTypeTerm_Oct/100),20) & in_2yr==1
replace Tuition = 12450 if year==2005 & inlist(floor(CollTypeTerm_Oct/100),20) & in_2yr==1
replace Tuition = 12708 if year==2006 & inlist(floor(CollTypeTerm_Oct/100),20) & in_2yr==1
replace Tuition = 13126 if year==2007 & inlist(floor(CollTypeTerm_Oct/100),20) & in_2yr==1
replace Tuition = 13562 if year==2008 & inlist(floor(CollTypeTerm_Oct/100),20) & in_2yr==1
replace Tuition = 14862 if year==2009 & inlist(floor(CollTypeTerm_Oct/100),20) & in_2yr==1
replace Tuition = 13687 if year==2010 & inlist(floor(CollTypeTerm_Oct/100),20) & in_2yr==1
replace Tuition = 13961 if year==2011 & inlist(floor(CollTypeTerm_Oct/100),20) & in_2yr==1
replace Tuition = 14149 if year==2012 & inlist(floor(CollTypeTerm_Oct/100),20) & in_2yr==1
replace Tuition = 14170 if year==2013 & inlist(floor(CollTypeTerm_Oct/100),20) & in_2yr==1
replace Tuition = 14254 if year==2014 & inlist(floor(CollTypeTerm_Oct/100),20) & in_2yr==1
replace Tuition = 14524 if year==2015 & inlist(floor(CollTypeTerm_Oct/100),20) & in_2yr==1

* Public 4-year Room
replace Room = 2301  if year==1997 & inlist(floor(CollTypeTerm_Oct/100),10,40) & in_4yr==1
replace Room = 2409  if year==1998 & inlist(floor(CollTypeTerm_Oct/100),10,40) & in_4yr==1
replace Room = 2519  if year==1999 & inlist(floor(CollTypeTerm_Oct/100),10,40) & in_4yr==1
replace Room = 2654  if year==2000 & inlist(floor(CollTypeTerm_Oct/100),10,40) & in_4yr==1
replace Room = 2816  if year==2001 & inlist(floor(CollTypeTerm_Oct/100),10,40) & in_4yr==1
replace Room = 3029  if year==2002 & inlist(floor(CollTypeTerm_Oct/100),10,40) & in_4yr==1
replace Room = 3212  if year==2003 & inlist(floor(CollTypeTerm_Oct/100),10,40) & in_4yr==1
replace Room = 3418  if year==2004 & inlist(floor(CollTypeTerm_Oct/100),10,40) & in_4yr==1
replace Room = 3664  if year==2005 & inlist(floor(CollTypeTerm_Oct/100),10,40) & in_4yr==1
replace Room = 3878  if year==2006 & inlist(floor(CollTypeTerm_Oct/100),10,40) & in_4yr==1
replace Room = 4082  if year==2007 & inlist(floor(CollTypeTerm_Oct/100),10,40) & in_4yr==1
replace Room = 4331  if year==2008 & inlist(floor(CollTypeTerm_Oct/100),10,40) & in_4yr==1
replace Room = 4564  if year==2009 & inlist(floor(CollTypeTerm_Oct/100),10,40) & in_4yr==1
replace Room = 4832  if year==2010 & inlist(floor(CollTypeTerm_Oct/100),10,40) & in_4yr==1
replace Room = 5031  if year==2011 & inlist(floor(CollTypeTerm_Oct/100),10,40) & in_4yr==1
replace Room = 5241  if year==2012 & inlist(floor(CollTypeTerm_Oct/100),10,40) & in_4yr==1
replace Room = 5479  if year==2013 & inlist(floor(CollTypeTerm_Oct/100),10,40) & in_4yr==1
replace Room = 5677  if year==2014 & inlist(floor(CollTypeTerm_Oct/100),10,40) & in_4yr==1
replace Room = 5850  if year==2015 & inlist(floor(CollTypeTerm_Oct/100),10,40) & in_4yr==1

* Private 4-year Room
replace Room = 2964  if year==1997 & inlist(floor(CollTypeTerm_Oct/100),20) & in_4yr==1
replace Room = 3091  if year==1998 & inlist(floor(CollTypeTerm_Oct/100),20) & in_4yr==1
replace Room = 3242  if year==1999 & inlist(floor(CollTypeTerm_Oct/100),20) & in_4yr==1
replace Room = 3392  if year==2000 & inlist(floor(CollTypeTerm_Oct/100),20) & in_4yr==1
replace Room = 3576  if year==2001 & inlist(floor(CollTypeTerm_Oct/100),20) & in_4yr==1
replace Room = 3764  if year==2002 & inlist(floor(CollTypeTerm_Oct/100),20) & in_4yr==1
replace Room = 3952  if year==2003 & inlist(floor(CollTypeTerm_Oct/100),20) & in_4yr==1
replace Room = 4173  if year==2004 & inlist(floor(CollTypeTerm_Oct/100),20) & in_4yr==1
replace Room = 4404  if year==2005 & inlist(floor(CollTypeTerm_Oct/100),20) & in_4yr==1
replace Room = 4613  if year==2006 & inlist(floor(CollTypeTerm_Oct/100),20) & in_4yr==1
replace Room = 4808  if year==2007 & inlist(floor(CollTypeTerm_Oct/100),20) & in_4yr==1
replace Room = 5032  if year==2008 & inlist(floor(CollTypeTerm_Oct/100),20) & in_4yr==1
replace Room = 5248  if year==2009 & inlist(floor(CollTypeTerm_Oct/100),20) & in_4yr==1
replace Room = 5410  if year==2010 & inlist(floor(CollTypeTerm_Oct/100),20) & in_4yr==1
replace Room = 5627  if year==2011 & inlist(floor(CollTypeTerm_Oct/100),20) & in_4yr==1
replace Room = 5837  if year==2012 & inlist(floor(CollTypeTerm_Oct/100),20) & in_4yr==1
replace Room = 6026  if year==2013 & inlist(floor(CollTypeTerm_Oct/100),20) & in_4yr==1
replace Room = 6229  if year==2014 & inlist(floor(CollTypeTerm_Oct/100),20) & in_4yr==1
replace Room = 6463  if year==2015 & inlist(floor(CollTypeTerm_Oct/100),20) & in_4yr==1

* Public 2-year Room
replace Room = 1401  if year==1997 & inlist(floor(CollTypeTerm_Oct/100),10,40) & in_2yr==1
replace Room = 1450  if year==1998 & inlist(floor(CollTypeTerm_Oct/100),10,40) & in_2yr==1
replace Room = 1549  if year==1999 & inlist(floor(CollTypeTerm_Oct/100),10,40) & in_2yr==1
replace Room = 1600  if year==2000 & inlist(floor(CollTypeTerm_Oct/100),10,40) & in_2yr==1
replace Room = 1722  if year==2001 & inlist(floor(CollTypeTerm_Oct/100),10,40) & in_2yr==1
replace Room = 1954  if year==2002 & inlist(floor(CollTypeTerm_Oct/100),10,40) & in_2yr==1
replace Room = 2089  if year==2003 & inlist(floor(CollTypeTerm_Oct/100),10,40) & in_2yr==1
replace Room = 2174  if year==2004 & inlist(floor(CollTypeTerm_Oct/100),10,40) & in_2yr==1
replace Room = 2251  if year==2005 & inlist(floor(CollTypeTerm_Oct/100),10,40) & in_2yr==1
replace Room = 2407  if year==2006 & inlist(floor(CollTypeTerm_Oct/100),10,40) & in_2yr==1
replace Room = 2506  if year==2007 & inlist(floor(CollTypeTerm_Oct/100),10,40) & in_2yr==1
replace Room = 2664  if year==2008 & inlist(floor(CollTypeTerm_Oct/100),10,40) & in_2yr==1
replace Room = 2854  if year==2009 & inlist(floor(CollTypeTerm_Oct/100),10,40) & in_2yr==1
replace Room = 2955  if year==2010 & inlist(floor(CollTypeTerm_Oct/100),10,40) & in_2yr==1
replace Room = 3100  if year==2011 & inlist(floor(CollTypeTerm_Oct/100),10,40) & in_2yr==1
replace Room = 3247  if year==2012 & inlist(floor(CollTypeTerm_Oct/100),10,40) & in_2yr==1
replace Room = 3448  if year==2013 & inlist(floor(CollTypeTerm_Oct/100),10,40) & in_2yr==1
replace Room = 3559  if year==2014 & inlist(floor(CollTypeTerm_Oct/100),10,40) & in_2yr==1
replace Room = 3772  if year==2015 & inlist(floor(CollTypeTerm_Oct/100),10,40) & in_2yr==1

* Private 2-year Room
replace Room = 2672  if year==1997 & inlist(floor(CollTypeTerm_Oct/100),20) & in_2yr==1
replace Room = 2581  if year==1998 & inlist(floor(CollTypeTerm_Oct/100),20) & in_2yr==1
replace Room = 3067  if year==1999 & inlist(floor(CollTypeTerm_Oct/100),20) & in_2yr==1
replace Room = 3006  if year==2000 & inlist(floor(CollTypeTerm_Oct/100),20) & in_2yr==1
replace Room = 3116  if year==2001 & inlist(floor(CollTypeTerm_Oct/100),20) & in_2yr==1
replace Room = 3232  if year==2002 & inlist(floor(CollTypeTerm_Oct/100),20) & in_2yr==1
replace Room = 3581  if year==2003 & inlist(floor(CollTypeTerm_Oct/100),20) & in_2yr==1
replace Room = 4475  if year==2004 & inlist(floor(CollTypeTerm_Oct/100),20) & in_2yr==1
replace Room = 4173  if year==2005 & inlist(floor(CollTypeTerm_Oct/100),20) & in_2yr==1
replace Room = 4147  if year==2006 & inlist(floor(CollTypeTerm_Oct/100),20) & in_2yr==1
replace Room = 4484  if year==2007 & inlist(floor(CollTypeTerm_Oct/100),20) & in_2yr==1
replace Room = 4537  if year==2008 & inlist(floor(CollTypeTerm_Oct/100),20) & in_2yr==1
replace Room = 5211  if year==2009 & inlist(floor(CollTypeTerm_Oct/100),20) & in_2yr==1
replace Room = 4939  if year==2010 & inlist(floor(CollTypeTerm_Oct/100),20) & in_2yr==1
replace Room = 5169  if year==2011 & inlist(floor(CollTypeTerm_Oct/100),20) & in_2yr==1
replace Room = 5228  if year==2012 & inlist(floor(CollTypeTerm_Oct/100),20) & in_2yr==1
replace Room = 5489  if year==2013 & inlist(floor(CollTypeTerm_Oct/100),20) & in_2yr==1
replace Room = 5504  if year==2014 & inlist(floor(CollTypeTerm_Oct/100),20) & in_2yr==1
replace Room = 5666  if year==2015 & inlist(floor(CollTypeTerm_Oct/100),20) & in_2yr==1

* Public 4-year Board
replace Board = 2263  if year==1997 & inlist(floor(CollTypeTerm_Oct/100),10,40) & in_4yr==1
replace Board = 2389  if year==1998 & inlist(floor(CollTypeTerm_Oct/100),10,40) & in_4yr==1
replace Board = 2406  if year==1999 & inlist(floor(CollTypeTerm_Oct/100),10,40) & in_4yr==1
replace Board = 2499  if year==2000 & inlist(floor(CollTypeTerm_Oct/100),10,40) & in_4yr==1
replace Board = 2645  if year==2001 & inlist(floor(CollTypeTerm_Oct/100),10,40) & in_4yr==1
replace Board = 2712  if year==2002 & inlist(floor(CollTypeTerm_Oct/100),10,40) & in_4yr==1
replace Board = 2876  if year==2003 & inlist(floor(CollTypeTerm_Oct/100),10,40) & in_4yr==1
replace Board = 2981  if year==2004 & inlist(floor(CollTypeTerm_Oct/100),10,40) & in_4yr==1
replace Board = 3093  if year==2005 & inlist(floor(CollTypeTerm_Oct/100),10,40) & in_4yr==1
replace Board = 3253  if year==2006 & inlist(floor(CollTypeTerm_Oct/100),10,40) & in_4yr==1
replace Board = 3404  if year==2007 & inlist(floor(CollTypeTerm_Oct/100),10,40) & in_4yr==1
replace Board = 3619  if year==2008 & inlist(floor(CollTypeTerm_Oct/100),10,40) & in_4yr==1
replace Board = 3755  if year==2009 & inlist(floor(CollTypeTerm_Oct/100),10,40) & in_4yr==1
replace Board = 3956  if year==2010 & inlist(floor(CollTypeTerm_Oct/100),10,40) & in_4yr==1
replace Board = 4042  if year==2011 & inlist(floor(CollTypeTerm_Oct/100),10,40) & in_4yr==1
replace Board = 4163  if year==2012 & inlist(floor(CollTypeTerm_Oct/100),10,40) & in_4yr==1
replace Board = 4308  if year==2013 & inlist(floor(CollTypeTerm_Oct/100),10,40) & in_4yr==1
replace Board = 4412  if year==2014 & inlist(floor(CollTypeTerm_Oct/100),10,40) & in_4yr==1
replace Board = 4561  if year==2015 & inlist(floor(CollTypeTerm_Oct/100),10,40) & in_4yr==1

* Private 4-year Board
replace Board = 2761  if year==1997 & inlist(floor(CollTypeTerm_Oct/100),20) & in_4yr==1
replace Board = 2865  if year==1998 & inlist(floor(CollTypeTerm_Oct/100),20) & in_4yr==1
replace Board = 2879  if year==1999 & inlist(floor(CollTypeTerm_Oct/100),20) & in_4yr==1
replace Board = 2993  if year==2000 & inlist(floor(CollTypeTerm_Oct/100),20) & in_4yr==1
replace Board = 3109  if year==2001 & inlist(floor(CollTypeTerm_Oct/100),20) & in_4yr==1
replace Board = 3197  if year==2002 & inlist(floor(CollTypeTerm_Oct/100),20) & in_4yr==1
replace Board = 3354  if year==2003 & inlist(floor(CollTypeTerm_Oct/100),20) & in_4yr==1
replace Board = 3483  if year==2004 & inlist(floor(CollTypeTerm_Oct/100),20) & in_4yr==1
replace Board = 3637  if year==2005 & inlist(floor(CollTypeTerm_Oct/100),20) & in_4yr==1
replace Board = 3788  if year==2006 & inlist(floor(CollTypeTerm_Oct/100),20) & in_4yr==1
replace Board = 3991  if year==2007 & inlist(floor(CollTypeTerm_Oct/100),20) & in_4yr==1
replace Board = 4206  if year==2008 & inlist(floor(CollTypeTerm_Oct/100),20) & in_4yr==1
replace Board = 4329  if year==2009 & inlist(floor(CollTypeTerm_Oct/100),20) & in_4yr==1
replace Board = 4430  if year==2010 & inlist(floor(CollTypeTerm_Oct/100),20) & in_4yr==1
replace Board = 4586  if year==2011 & inlist(floor(CollTypeTerm_Oct/100),20) & in_4yr==1
replace Board = 4712  if year==2012 & inlist(floor(CollTypeTerm_Oct/100),20) & in_4yr==1
replace Board = 4866  if year==2013 & inlist(floor(CollTypeTerm_Oct/100),20) & in_4yr==1
replace Board = 5021  if year==2014 & inlist(floor(CollTypeTerm_Oct/100),20) & in_4yr==1
replace Board = 5116  if year==2015 & inlist(floor(CollTypeTerm_Oct/100),20) & in_4yr==1

* Public 2-year Board
replace Board = 1795  if year==1997 & inlist(floor(CollTypeTerm_Oct/100),10,40) & in_2yr==1
replace Board = 1828  if year==1998 & inlist(floor(CollTypeTerm_Oct/100),10,40) & in_2yr==1
replace Board = 1834  if year==1999 & inlist(floor(CollTypeTerm_Oct/100),10,40) & in_2yr==1
replace Board = 1906  if year==2000 & inlist(floor(CollTypeTerm_Oct/100),10,40) & in_2yr==1
replace Board = 2036  if year==2001 & inlist(floor(CollTypeTerm_Oct/100),10,40) & in_2yr==1
replace Board = 2164  if year==2002 & inlist(floor(CollTypeTerm_Oct/100),10,40) & in_2yr==1
replace Board = 2221  if year==2003 & inlist(floor(CollTypeTerm_Oct/100),10,40) & in_2yr==1
replace Board = 2353  if year==2004 & inlist(floor(CollTypeTerm_Oct/100),10,40) & in_2yr==1
replace Board = 2306  if year==2005 & inlist(floor(CollTypeTerm_Oct/100),10,40) & in_2yr==1
replace Board = 2390  if year==2006 & inlist(floor(CollTypeTerm_Oct/100),10,40) & in_2yr==1
replace Board = 2409  if year==2007 & inlist(floor(CollTypeTerm_Oct/100),10,40) & in_2yr==1
replace Board = 2769  if year==2008 & inlist(floor(CollTypeTerm_Oct/100),10,40) & in_2yr==1
replace Board = 2571  if year==2009 & inlist(floor(CollTypeTerm_Oct/100),10,40) & in_2yr==1
replace Board = 2683  if year==2010 & inlist(floor(CollTypeTerm_Oct/100),10,40) & in_2yr==1
replace Board = 2866  if year==2011 & inlist(floor(CollTypeTerm_Oct/100),10,40) & in_2yr==1
replace Board = 2888  if year==2012 & inlist(floor(CollTypeTerm_Oct/100),10,40) & in_2yr==1
replace Board = 2955  if year==2013 & inlist(floor(CollTypeTerm_Oct/100),10,40) & in_2yr==1
replace Board = 3072  if year==2014 & inlist(floor(CollTypeTerm_Oct/100),10,40) & in_2yr==1
replace Board = 3128  if year==2015 & inlist(floor(CollTypeTerm_Oct/100),10,40) & in_2yr==1

* Private 2-year Board
replace Board = 2785  if year==1997 & inlist(floor(CollTypeTerm_Oct/100),20) & in_2yr==1
replace Board = 2884  if year==1998 & inlist(floor(CollTypeTerm_Oct/100),20) & in_2yr==1
replace Board = 2753  if year==1999 & inlist(floor(CollTypeTerm_Oct/100),20) & in_2yr==1
replace Board = 2834  if year==2000 & inlist(floor(CollTypeTerm_Oct/100),20) & in_2yr==1
replace Board = 2633  if year==2001 & inlist(floor(CollTypeTerm_Oct/100),20) & in_2yr==1
replace Board = 3870  if year==2002 & inlist(floor(CollTypeTerm_Oct/100),20) & in_2yr==1
replace Board = 4432  if year==2003 & inlist(floor(CollTypeTerm_Oct/100),20) & in_2yr==1
replace Board = 3700  if year==2004 & inlist(floor(CollTypeTerm_Oct/100),20) & in_2yr==1
replace Board = 4781  if year==2005 & inlist(floor(CollTypeTerm_Oct/100),20) & in_2yr==1
replace Board = 3429  if year==2006 & inlist(floor(CollTypeTerm_Oct/100),20) & in_2yr==1
replace Board = 4074  if year==2007 & inlist(floor(CollTypeTerm_Oct/100),20) & in_2yr==1
replace Board = 4627  if year==2008 & inlist(floor(CollTypeTerm_Oct/100),20) & in_2yr==1
replace Board = 4390  if year==2009 & inlist(floor(CollTypeTerm_Oct/100),20) & in_2yr==1
replace Board = 4475  if year==2010 & inlist(floor(CollTypeTerm_Oct/100),20) & in_2yr==1
replace Board = 4475  if year==2011 & inlist(floor(CollTypeTerm_Oct/100),20) & in_2yr==1
replace Board = 3977  if year==2012 & inlist(floor(CollTypeTerm_Oct/100),20) & in_2yr==1
replace Board = 4211  if year==2013 & inlist(floor(CollTypeTerm_Oct/100),20) & in_2yr==1
replace Board = 4560  if year==2014 & inlist(floor(CollTypeTerm_Oct/100),20) & in_2yr==1
replace Board = 4177  if year==2015 & inlist(floor(CollTypeTerm_Oct/100),20) & in_2yr==1

* Deflate by CPI
replace Tuition = Tuition/cpi if !mi(Tuition)
replace    Room =    Room/cpi if !mi(   Room)
replace   Board =   Board/cpi if !mi(  Board)

*----------------------------
* Create CC/SO/DO variable -- use Stata custom command -spell- written by Nick Cox
*----------------------------
* 3 different ways to define this: 1) any college; 2) 2-yr college only; 3) 4-yr college only
* Need to decide how those who never start 4yr college are treated, since 4yr graduation is considered "success"

* any college is considered a spell
sort ID year
spell if ~missIntLastSpell & year<2016, by(ID) cond(in_college==1 & grad_4yr==0) spell(coll_spell) end(coll_end) seq(coll_seq) censor(coll_censor_l coll_censor_r)
egen nspellsAny = max(coll_spell), by(ID)
egen coll_spell_length = max(coll_seq), by(ID coll_spell)

* only 2yr college is considered a spell
sort ID year
spell if ~missIntLastSpell & year<2016, by(ID) cond(in_2yr==1 & grad_4yr==0) spell(coll_2yr_spell) end(coll_2yr_end) seq(coll_2yr_seq) censor(coll_2yr_censor_l coll_2yr_censor_r)
egen nspells2yr = max(coll_2yr_spell), by(ID)
egen coll_2yr_spell_length = max(coll_2yr_seq), by(ID coll_2yr_spell)

* only 4yr college is considered a spell
sort ID year
spell if ~missIntLastSpell & year<2016, by(ID) cond(in_4yr==1 & grad_4yr==0) spell(coll_4yr_spell) end(coll_4yr_end) seq(coll_4yr_seq) censor(coll_4yr_censor_l coll_4yr_censor_r)
egen nspells4yr = max(coll_4yr_spell), by(ID)
egen coll_4yr_spell_length = max(coll_4yr_seq), by(ID coll_4yr_spell)

bys ID (year): egen ever_coll_censor_r = max(coll_censor_r)

* Generate college completion variable here
* people who have missIntLastSpell in their first year of grad_4yr
gen CC          =((nspellsAny==1 & ever_grad_4yr==1 & ever_start_college & ever_coll_censor_r==0) & ~(nspellsAny==1 & ever_start_2yr & ~ever_start_4yr & ever_grad_4yr==0)) | inlist(ID,63,125,207,845,2140,3305,3559,4022,5954,6248,6519,7021,7057,8783,8949)
* people who have missIntLastSpell in their first year of grad_4yr
gen CC_censored =((nspellsAny==1 & ever_grad_4yr==0 & ever_start_college & ever_coll_censor_r==1) & ~(nspellsAny==1 & ever_start_2yr & ~ever_start_4yr & ever_grad_4yr==0))
gen SO_but_grad = (nspellsAny>=2 & ever_grad_4yr==1 & ever_start_college & ever_coll_censor_r==0)
gen SO_then_DO  = (nspellsAny>=2 & ever_grad_4yr==0 & ever_start_college & ever_coll_censor_r==0)
* people who are enrolled in college in the last year of data but who also have missIntLastSpell in the last year of data
gen SO_censored = (nspellsAny>=2 & ever_grad_4yr==0 & ever_start_college & ever_coll_censor_r==1)
* 2yr CCers are re-classified here as dropouts ... however, 5 of them had no 4yr history but reported receiving BA degrees. I'm keeping those guys as CCers
gen DO                    = (nspellsAny==1 & ever_grad_4yr==0 & ever_start_college & ever_coll_censor_r==0) | (nspellsAny==1 & ever_start_2yr & ~ever_start_4yr & ever_grad_4yr==0)
gen DO_2yr                = (nspells2yr==1 & ever_start_4yr==0 & ever_grad_2yr==1 & ever_start_college & ever_coll_censor_r==0)
gen SO_but_grad_2yr_break = (nspells2yr==1 & nspells4yr==1 & nspellsAny>=2 & ever_grad_2yr==1 & ever_grad_4yr==1 & ever_start_college & ever_coll_censor_r==0)
gen SO_then_DO_2yr_break  = (nspells2yr==1 & nspells4yr==1 & nspellsAny>=2 & ever_grad_2yr==1 & ever_grad_4yr==0 & ever_start_college & ever_coll_censor_r==0)

* assert CC+CC_censored+SO_but_grad+SO_then_DO+SO_censored+DO==1 if ever_start_college & ID~=8072
tab ID if (CC+CC_censored+SO_but_grad+SO_then_DO+SO_censored+DO!=1) & ever_start_college

generat CC_DO_SO = .
replace CC_DO_SO = 1 if CC
replace CC_DO_SO = 2 if SO_but_grad
replace CC_DO_SO = 3 if SO_then_DO
replace CC_DO_SO = 4 if DO
replace CC_DO_SO = 5 if CC_censored
replace CC_DO_SO = 6 if SO_censored

mdesc CC CC_censored SO_but_grad SO_then_DO SO_censored DO CC_DO_SO if ever_start_college & ID~=8072
tab ID if mi(CC_DO_SO) & ever_start_college & ID~=8072

label define vlCCDOSO 1 "Continuous completion" 2 "Stopout but graduate" 3 "Stopout but dropout" 4 "Dropout" 5 "CC, but right-censored" 6 "SO, but right-censored"
label values CC_DO_SO vlCCDOSO

generat CC_DO_SO_2yr = .
replace CC_DO_SO_2yr = 1 if CC
replace CC_DO_SO_2yr = 2 if SO_but_grad
replace CC_DO_SO_2yr = 3 if SO_but_grad_2yr_break
replace CC_DO_SO_2yr = 4 if SO_then_DO
replace CC_DO_SO_2yr = 5 if SO_then_DO_2yr_break
replace CC_DO_SO_2yr = 6 if DO
replace CC_DO_SO_2yr = 7 if DO_2yr
replace CC_DO_SO_2yr = 8 if CC_censored
replace CC_DO_SO_2yr = 9 if SO_censored

label define vlCCDOSO2yr 1 "Continuous completion" 2 "Stopout but graduate (all others)" 3 "Stopout but graduate (break between 2yr and 4yr)" 4 "Stopout but dropout (all others)" 5 "Stopout but dropout (break between 2yr and 4yr)" 6 "Dropout (all others)" 7 "Dropout (Grad 2yr, never 4yr)" 8 "CC, but right-censored" 9 "SO, but right-censored"
label values CC_DO_SO_2yr vlCCDOSO2yr


*----------------------------
* Get stopout length
*----------------------------
bys ID (year): gen cum_coll_spell = sum(coll_end)

forvalues x=1/4 {
    sort ID year
    spell if ~missIntLastSpell & cum_coll_spell==`x' & nspellsAny>=`=`x'+1', by(ID) cond(in_college==0) spell(coll_SO`x'_spell) end(coll_SO`x'_end) seq(coll_SO`x'_seq) censor(coll_SO`x'_censor_l coll_SO`x'_censor_r)
}
/*
use Nick Cox's -spell- command!!!

Options
-------
fcond(fcondstr) specifies a true or false condition that defines the
    start of a spell: to be precise, the first observation in a spell.
    A new spell starts whenever this condition is true.

    If varname is specified, and neither fcond( ) nor cond( ) is
    specified, fcond( ) defaults to "varname != varname[_n-1]".

cond(condstr) specifies a true or false condition that defines the
    spell.

pcond(pcondstr) is equivalent to

    cond((pcondstr) > 0 & (pcondstr) < .))

    That is, some expression pcondstr evaluates to a positive number
    (but not missing).  Commonly, the expression is just the name of
    a numeric variable.

Only one of fcond( ), cond( ) and pcond( ) may be specified.

by(byvarlist) specifies one or more variables that subdivide the
    data into groups. For example, the byvarlist could specify
    individual people. A further condition on a spell is then that
    the variable or variables in a byvarlist remain constant.

    With by( ), spell sorts data first by byvarlist and then by the
    order of the data when called. It then identifies spells. See also
    resort below.

censor(censorvarlist) defines two new variables that are 1 if the
    spell is left- or right-censored and 0 otherwise. A left-censored
    spell starts at the first relevant observation (so it might have
    started earlier, except that we have no data to determine that). A
    right-censored spell ends at the last relevant observation (so it
    might have ended later, except that we have no data to determine
    that). censor( ) should specify two new variable names, separated
    by white space (e.g. censor(cl cr)), for indicating left-censored
    and right-censoring. As a special case, censor(.) indicates that
    _cl and _cr should be tried as new variable names.

end(endvar) defines a new variable that is 1 at the end of each
    spell and 0 otherwise. _end is tried as a variable name if this
    option is not specified.

seq(seqvar) defines a new variable that is the number of
    observations so far in the spell. _seq is tried as a variable name
    if this option is not specified.

spell(spellvar) defines a new variable that is the number of spells
    so far. All observations in the first spell are tagged with 1, all
    in the second with 2, and so on. _spell is tried as a variable name
    if this option is not specified. Under by( ), a separate count is
    kept for distinct values of byvarlist.

replace indicates that any variables created by spell may overwrite
    existing variables with the same names.

resort restores the original sort order of the observations after
    identifying spells. (The default if by( ), if or in is invoked
    is to sort the data so that comparable and relevant observations are
    put together.)


Examples
--------
spell party

Spells are distinct jobs (panel data):
spell job, by(id)
Number of spells (panel data):
egen nspells = max(_spell), by(id)

To define spells of consecutive values of time:
spell, f(_n == 1 | (time - time[_n - 1]) > 1) by(id)

Rainfall spells:
spell, p(rain)
For spells in which rainfall was at least 10 mm every day:
spell, c(rain >= 10) e(hrend) s(hrseq)

To get information on spell lengths (# observations):
su hrseq if hrend
tab hrseq if hrend

Length of each spell in a new variable:
spell ..
egen length = max(_seq), by(_spell)

spell .., by(id)
egen length = max(_seq), by(id _spell)

Duration (length in time) of each spell in a new variable:
egen _tmax = max(time), by(_spell)
egen _tmin = min(time), by(_spell)
gen duration = _tmax - _tmin

Cumulative totals of varname:
sort _spell _seq
qui by _spell : gen _tot = sum(varname) if _seq

Sums of varname:
egen total = sum(varname), by(_spell)
*/
