***********************************************
* Create fed min wage and cpi
* http://www.dol.gov/whd/minwage/chart.htm
* http://lmi2.detma.org/lmi/pdf/MinimumWage.pdf
* and
* http://www.bls.gov/cpi/
***********************************************

generat fedMinWage=0.25 if year==1938
replace fedMinWage=0.30 if year==1939
replace fedMinWage=0.30 if year==1940
replace fedMinWage=0.30 if year==1941
replace fedMinWage=0.30 if year==1942
replace fedMinWage=0.30 if year==1943
replace fedMinWage=0.30 if year==1944
replace fedMinWage=0.40 if year==1945
replace fedMinWage=0.40 if year==1946
replace fedMinWage=0.40 if year==1947
replace fedMinWage=0.40 if year==1948
replace fedMinWage=0.40 if year==1949
replace fedMinWage=0.75 if year==1950
replace fedMinWage=0.75 if year==1951
replace fedMinWage=0.75 if year==1952
replace fedMinWage=0.75 if year==1953
replace fedMinWage=0.75 if year==1954
replace fedMinWage=0.75 if year==1955
replace fedMinWage=1.00 if year==1956
replace fedMinWage=1.00 if year==1957
replace fedMinWage=1.00 if year==1958
replace fedMinWage=1.00 if year==1959
replace fedMinWage=1.00 if year==1960
replace fedMinWage=1.15 if year==1961
replace fedMinWage=1.15 if year==1962
replace fedMinWage=1.25 if year==1963
replace fedMinWage=1.25 if year==1964
replace fedMinWage=1.25 if year==1965
replace fedMinWage=1.25 if year==1966
replace fedMinWage=1.40 if year==1967
replace fedMinWage=1.60 if year==1968
replace fedMinWage=1.60 if year==1969
replace fedMinWage=1.60 if year==1970
replace fedMinWage=1.60 if year==1971
replace fedMinWage=1.60 if year==1972
replace fedMinWage=1.60 if year==1973
replace fedMinWage=2.00 if year==1974
replace fedMinWage=2.10 if year==1975
replace fedMinWage=2.30 if year==1976
replace fedMinWage=2.30 if year==1977
replace fedMinWage=2.65 if year==1978
replace fedMinWage=2.90 if year==1979
replace fedMinWage=3.10 if year==1980
replace fedMinWage=3.35 if year==1981
replace fedMinWage=3.35 if year==1982
replace fedMinWage=3.35 if year==1983
replace fedMinWage=3.35 if year==1984
replace fedMinWage=3.35 if year==1985
replace fedMinWage=3.35 if year==1986
replace fedMinWage=3.35 if year==1987
replace fedMinWage=3.35 if year==1988
replace fedMinWage=3.35 if year==1989
replace fedMinWage=3.80 if year==1990
replace fedMinWage=4.25 if year==1991
replace fedMinWage=4.25 if year==1992
replace fedMinWage=4.25 if year==1993
replace fedMinWage=4.25 if year==1994
replace fedMinWage=4.25 if year==1995
replace fedMinWage=4.75 if year==1996
replace fedMinWage=5.15 if year==1997
replace fedMinWage=5.15 if year==1998
replace fedMinWage=5.15 if year==1999
replace fedMinWage=5.15 if year==2000
replace fedMinWage=5.15 if year==2001
replace fedMinWage=5.15 if year==2002
replace fedMinWage=5.15 if year==2003
replace fedMinWage=5.15 if year==2004
replace fedMinWage=5.15 if year==2005
replace fedMinWage=5.15 if year==2006
replace fedMinWage=5.85 if year==2007
replace fedMinWage=6.55 if year==2008
replace fedMinWage=7.25 if year==2009
replace fedMinWage=7.25 if year==2010
replace fedMinWage=7.25 if year==2011
replace fedMinWage=7.25 if year==2012
replace fedMinWage=7.25 if year==2013
replace fedMinWage=7.25 if year==2014
replace fedMinWage=7.25 if year==2015
replace fedMinWage=7.25 if year==2016
replace fedMinWage=7.25 if year==2017

generat cpi =   8.986615 if year==1938
replace cpi =   8.859145 if year==1939
replace cpi =   8.922880 if year==1940
replace cpi =   9.369024 if year==1941
replace cpi =  10.388782 if year==1942
replace cpi =  11.026131 if year==1943
replace cpi =  11.217335 if year==1944
replace cpi =  11.472275 if year==1945
replace cpi =  12.428298 if year==1946
replace cpi =  14.212874 if year==1947
replace cpi =  15.360101 if year==1948
replace cpi =  15.168897 if year==1949
replace cpi =  15.360101 if year==1950
replace cpi =  16.571064 if year==1951
replace cpi =  16.889738 if year==1952
replace cpi =  17.017208 if year==1953
replace cpi =  17.144678 if year==1954
replace cpi =  17.080943 if year==1955
replace cpi =  17.335882 if year==1956
replace cpi =  17.909496 if year==1957
replace cpi =  18.419375 if year==1958
replace cpi =  18.546845 if year==1959
replace cpi =  18.865519 if year==1960
replace cpi =  19.056724 if year==1961
replace cpi =  19.247928 if year==1962
replace cpi =  19.502868 if year==1963
replace cpi =  19.757807 if year==1964
replace cpi =  20.076481 if year==1965
replace cpi =  20.650095 if year==1966
replace cpi =  21.287444 if year==1967
replace cpi =  22.179732 if year==1968
replace cpi =  23.390694 if year==1969
replace cpi =  24.729126 if year==1970
replace cpi =  25.812619 if year==1971
replace cpi =  26.641172 if year==1972
replace cpi =  28.298279 if year==1973
replace cpi =  31.421287 if year==1974
replace cpi =  34.289356 if year==1975
replace cpi =  36.265137 if year==1976
replace cpi =  38.623326 if year==1977
replace cpi =  41.555130 if year==1978
replace cpi =  46.271510 if year==1979
replace cpi =  52.517527 if year==1980
replace cpi =  57.934990 if year==1981
replace cpi =  61.504142 if year==1982
replace cpi =  63.479923 if year==1983
replace cpi =  66.220522 if year==1984
replace cpi =  68.578712 if year==1985
replace cpi =  69.853409 if year==1986
replace cpi =  72.402804 if year==1987
replace cpi =  75.398342 if year==1988
replace cpi =  79.031230 if year==1989
replace cpi =  83.301465 if year==1990
replace cpi =  86.806883 if year==1991
replace cpi =  89.420012 if year==1992
replace cpi =  92.096876 if year==1993
replace cpi =  94.455066 if year==1994
replace cpi =  97.131931 if year==1995
replace cpi = 100.000000 if year==1996
replace cpi = 102.294455 if year==1997
replace cpi = 103.887826 if year==1998
replace cpi = 106.182281 if year==1999
replace cpi = 109.751434 if year==2000
replace cpi = 112.874442 if year==2001
replace cpi = 114.659018 if year==2002
replace cpi = 117.272147 if year==2003
replace cpi = 120.395156 if year==2004
replace cpi = 124.474187 if year==2005
replace cpi = 128.489483 if year==2006
replace cpi = 132.149139 if year==2007
replace cpi = 137.223072 if year==2008
replace cpi = 136.734863 if year==2009
replace cpi = 138.977692 if year==2010
replace cpi = 143.364563 if year==2011
replace cpi = 146.331421 if year==2012
replace cpi = 148.474825 if year==2013
replace cpi = 151.50     if year==2014
replace cpi = 151.36     if year==2015
replace cpi = 153.44     if year==2016
replace cpi = 157.28     if year==2017

replace fedMinWage = fedMinWage*100
replace cpi=cpi/100

lab var fedMinWage "Federal Minimum Wage (undeflated)"
lab var cpi "CPI-Urban/100 (1996)"
