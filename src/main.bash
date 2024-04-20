#-------------------------------------------------------------------------------
# Configure Stata - run this file once at the start of replication
#     This file downloads and installs custom Stata commands used in the
#     data production, data cleaning, and descriptive analysis
#-------------------------------------------------------------------------------
stata-se -b do config_stata.do

#-------------------------------------------------------------------------------
# Configure Julia - run this file once at the start of replication
#     This file installs Julia packages used in the analysis
#-------------------------------------------------------------------------------
julia config_julia.jl

#-------------------------------------------------------------------------------
# Downloading the Data
#     below are steps to obtain raw data from the CPS, SIPP, and NSLY97
#     CPS and NLSY97 require manual downloading; SIPP is fully automated
#-------------------------------------------------------------------------------
# CPS:
# download the CPS data from https://cps.ipums.org
# <this needs to be done manually>
# select the March CPS (ASEC) for years 2007-2014
# select the following variables:
#    - age
#    - sex
#    - race
#    - educ
#    - educ99
#    - occ2010
#    - ind
#
# the variables (year, serial, month, cpsid, asecflag, hflag, asecwth, pernum, 
# cpsidp, asecwt) all come pre-selected
# place the downloaded file ("cps_XXXXX.dat.gz") in the folder `data/cps/raw`
#
# NPSAS:
# follow these steps to replicate the analyses based on NPSAS
# 1. visit https://nces.ed.gov/datalab/ and create an account
# 2. select "NPSAS:UG" and year 2008
# 3. create various regression models following the on-screen steps
#    - we estimate the following regressions:
#      * for grants, separately by 2- and 4-year enrollees:
#        - logit of 1[grants>0] on EFC decile dummies, family income decile dummies, and (for 4-year only) SAT verbal and SAT math decile dummies
#        - linear regression of grant amount on the same set of regressors as immediately above
#      * for loans, separately by 2- and 4-year enrollees:
#        - same regressions as for grants, with the following exceptions:
#          * restrict to 18 year olds who are dependents
#          * use the loans variable that includes PLUS loans
# 4. compute average tuition separately by 4- and 2-year college
#    - we obtained estimates of $6,394.20 and $1,380.10, respectively
#
# NLSY97:
# download the NLSY97 data from https://www.nlsinfo.org/investigator/pages/login
# by uploading each of the *.NLSY97 files in the `data/nlsy97/raw/` folder
# <this needs to be done manually>
# place the downloaded files (*.dct) in the `data/nlsy97/raw/` folder.
# there is an option to download other files; these files may be placed in this
# same folder, but they will not be used
#
# download the "AFQT Matching" data and programs from Fabian Lange's website
# (http://www.fabianlange.ca/data.html)
# This file provides raw data on AFQT scores from both the NLSY79 and NLSY97.
# We extend this approach to six components of the ASVAB, as well as 
# math and verbal components. These additional data and programs are already
# contained in the other "AFQT_MATCHING*" folders in `data/nlsy97/raw/` and
# are not publicly available anywhere else.
#
# SIPP:
# download the SIPP data by executing the following shell script, which auto-
# matically downloads the raw data files from NBER into the `data/sipp/raw/`
# folder
cd ../data/sipp
./downloader.sh
cd ../../src

#-------------------------------------------------------------------------------
# Data Cleaning (approximately 2 hours)
#-------------------------------------------------------------------------------
# CPS
cd data-cleaning/cps
stata-se -b do IPUMS_CPS.do

# SIPP
cd ../sipp
stata-se -b do create_sipp.do

# NLSY
cd ../nlsy97
stata-se -b do y97_import_all.do
stata-se -b do y97_create_master.do
stata-se -b do y97_create_trim_tscrGPA.do
stata-se -b do y97_create_matlab_data_tscrGPA.do
matlab -singleCompThread -nojvm -nodisplay -r "data_import_20220401_tscrGPA;quit"

#-------------------------------------------------------------------------------
# Descriptive Analysis (NLSY) (takes a couple of minutes)
#-------------------------------------------------------------------------------
cd ../../descriptives
stata-se -b do descriptives.do



#-------------------------------------------------------------------------------
# Structural Estimation
#-------------------------------------------------------------------------------

#:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
# Stage 1: Flexible estimation of unobs types (approximately 3 hours with 100 parallel tasks)
#:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
# cd based on what pwd is
CURR_DIR=$(pwd)
LAST_WORD=$(basename "${CURR_DIR}")
if [ "${LAST_WORD}" = "nlsy97" ]; then
	cd ../../estimation-stage1
elif [ "${LAST_WORD}" = "src" ]; then
	cd estimation-stage1
else
	cd ../estimation-stage1
fi

# run the script
bash matbatch32core runmodel_all_stage1_interact_type.m



#:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
# Stage 2: Learning Parameters
# (approximately 4 hours)
#:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
# cd based on what pwd is
CURR_DIR=$(pwd)
LAST_WORD=$(basename "${CURR_DIR}")
if [ "${LAST_WORD}" = "nlsy97" ]; then
	cd ../../estimation-stage2-learning
elif [ "${LAST_WORD}" = "src" ]; then
	cd estimation-stage2-learning
else
	cd ../estimation-stage2-learning
fi

# run the script
bash matbatch32core runmodel_learning_only.m



#:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
# Stages 3-5: Structural Utility Estimation (grid search over CRRA parameter)
# (approximately 16 hours with 40 parallel tasks)
#:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
# cd based on what pwd is
CURR_DIR=$(pwd)
LAST_WORD=$(basename "${CURR_DIR}")
if [ "${LAST_WORD}" = "nlsy97" ]; then
	cd ../../estimation-stage3-gridsearch
elif [ "${LAST_WORD}" = "src" ]; then
	cd estimation-stage3-gridsearch
else
	cd ../estimation-stage3-gridsearch
fi
# run static choice estimation
bash matbatch_t40 runmodel_consump_jointsearchfrictions_WCabsorb.m
# extract SLURM job number (excluding the job that's running the current script)
sleep 100
jobno=$(squeue --user=${USER} --states=RUNNING | sort -k6,6 -t '|' -r | grep -v "shellbat" | head -2 | tail -1 | awk '{print $1}')
# pause execution until after all 40 tasks have completed
compflag=0
while [ ${compflag} -eq 0 ]
do
	sleep 1
	if [ $(squeue -u ${USER} | grep ${jobno%%_*} | wc -l) -eq 0 ]
	then
		# Set compflag to 1 to exit the loop
		compflag=1
	fi
done

# find global max across all grid values
echo " " > ../output/utility-grid-search/runs.txt
crra_array=(0 0-05 0-1 0-15 0-2 0-25 0-3 0-35 0-4 0-45 0-5 0-55 0-6 0-65 0-7 0-75 0-8 0-85 0-9 0-95 1-05 1-1 1-15 1-2 1-25 1-3 1-35 1-4 1-45 1-5 1-55 1-6 1-65 1-7 1-75 1-8 1-85 1-9 1-95 2)
for j in {0..39}
do
	file=../output/utility-grid-search/CRRA-${crra_array[j]}/Searchconsump_utility_results_het_no_int_beta0.csv
	line=$(tail -n 2 $file | head -n 1)
	result=${line%%,*}
	echo "${result},${crra_array[j]}" >> ../output/utility-grid-search/runs.txt
done
echo "global max likelihood value (and grid value): "
cat ../output/utility-grid-search/runs.txt | sed '/^-,/d' | sed '/^,/d' | sed '/^ $/d' | sort | head -10



#:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
# Stages 3-5: Structural Utility Estimation (CRRA parameter = 0.4)
# (approximately 16 hours with 20 parallel tasks)
#:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
# cd based on what pwd is
CURR_DIR=$(pwd)
LAST_WORD=$(basename "${CURR_DIR}")
if [ "${LAST_WORD}" = "nlsy97" ]; then
	cd ../../estimation-stage3-5-structural
elif [ "${LAST_WORD}" = "src" ]; then
	cd estimation-stage3-5-structural
else
	cd ../estimation-stage3-5-structural
fi
# run static choice estimation
matlab -singleCompThread -nojvm -nodisplay -r "runmodel_consump_jointsearchfrictions_WCabsorb;quit"
# run future value computation
bash matbatch_t20 computeFVfastParallel.m
# extract SLURM job number (excluding the job that's running the current script)
sleep 100
jobno=$(squeue --user=${USER} --states=RUNNING | sort -k6,6 -t '|' -r | grep -v "shellbat" | head -2 | tail -1 | awk '{print $1}')
# pause execution until after all 20 tasks have completed
compflag=0
while [ ${compflag} -eq 0 ]
do
	sleep 1
	if [ $(squeue -u ${USER} | grep ${jobno%%_*} | wc -l) -eq 0 ]
	then
		# Set compflag to 1 to exit the loop
		compflag=1
	fi
done
# run dynamic structural model estimation
matlab -singleCompThread -nojvm -nodisplay -r "runmodel_consump_structural_FVfast;quit"
# run robustness check regarding GPA as an independent determinant of college graduation
matlab -singleCompThread -nojvm -nodisplay -r "robustness_check_gradlogit;quit"


#-------------------------------------------------------------------------------
# Forward Simulation used for assessing model fit (takes about 16 hours)
#-------------------------------------------------------------------------------
# cd based on what pwd is
CURR_DIR=$(pwd)
LAST_WORD=$(basename "${CURR_DIR}")
if [ "${LAST_WORD}" = "nlsy97" ]; then
	cd ../../simulations-forward-fit
elif [ "${LAST_WORD}" = "src" ]; then
	cd simulations-forward-fit
else
	cd ../simulations-forward-fit
fi
matlab -singleCompThread -nojvm -nodisplay -r "simulatorMCintEstData10D;quit"
matlab -singleCompThread -nojvm -nodisplay -r "simulatorMCintEstDataRFCCP10D;quit"


#-------------------------------------------------------------------------------
# Backwards Counterfactuals (takes up to 16 days with about 300 parallel tasks)
#-------------------------------------------------------------------------------
# cd based on what pwd is
CURR_DIR=$(pwd)
LAST_WORD=$(basename "${CURR_DIR}")
if [ "${LAST_WORD}" = "nlsy97" ]; then
	cd ../../simulations-counterfactual/baseline
elif [ "${LAST_WORD}" = "src" ]; then
	cd simulations-counterfactual/baseline
else
	cd ../simulations-counterfactual/baseline
fi
# run the baseline backward counterfactual simulation
bash juliabatch_t2300 shellsimbatch.jl
# extract SLURM job number (excluding the job that's running the current script)
sleep 100
jobno=$(squeue --user=${USER} --states=RUNNING | sort -k6,6 -t '|' -r | grep -v "shellbat" | head -2 | tail -1 | awk '{print $1}')
# pause execution until after all tasks have completed
compflag=0
while [ ${compflag} -eq 0 ]
do
	sleep 1
	if [ $(squeue -u ${USER} | grep ${jobno%%_*} | wc -l) -eq 0 ]
	then
		# Set compflag to 1 to exit the loop
		compflag=1
	fi
done
# aggregated simulated data
stata-se -b do postsim.do


# cd based on what pwd is
CURR_DIR=$(pwd)
LAST_WORD=$(basename "${CURR_DIR}")
if [ "${LAST_WORD}" = "nlsy97" ]; then
	cd ../../simulations-counterfactual/no-frictions
elif [ "${LAST_WORD}" = "src" ]; then
	cd simulations-counterfactual/no-frictions
elif [ "${LAST_WORD}" = "baseline" ]; then
	cd ../no-frictions
else
	cd ../simulations-counterfactual/no-frictions
fi
# run the no-search-frictions backward counterfactual simulation
bash juliabatch_t2300 shellsimbatch.jl
# extract SLURM job number (excluding the job that's running the current script)
sleep 100
jobno=$(squeue --user=${USER} --states=RUNNING | sort -k6,6 -t '|' -r | grep -v "shellbat" | head -2 | tail -1 | awk '{print $1}')
# pause execution until after all tasks have completed
compflag=0
while [ ${compflag} -eq 0 ]
do
	sleep 1
	if [ $(squeue -u ${USER} | grep ${jobno%%_*} | wc -l) -eq 0 ]
	then
		# Set compflag to 1 to exit the loop
		compflag=1
	fi
done
stata-se -b do postsim.do


# cd based on what pwd is
CURR_DIR=$(pwd)
LAST_WORD=$(basename "${CURR_DIR}")
if [ "${LAST_WORD}" = "nlsy97" ]; then
	cd ../../simulations-counterfactual/no-cred-cons
elif [ "${LAST_WORD}" = "src" ]; then
	cd simulations-counterfactual/no-cred-cons
elif [ "${LAST_WORD}" = "baseline" ]; then
	cd ../no-cred-cons
else
	cd ../simulations-counterfactual/no-cred-cons
fi
# run the no-cred-cons backward counterfactual simulation
bash juliabatch_t2300 shellsimbatch.jl
# extract SLURM job number (excluding the job that's running the current script)
sleep 100
jobno=$(squeue --user=${USER} --states=RUNNING | sort -k6,6 -t '|' -r | grep -v "shellbat" | head -2 | tail -1 | awk '{print $1}')
# pause execution until after all tasks have completed
compflag=0
while [ ${compflag} -eq 0 ]
do
	sleep 1
	if [ $(squeue -u ${USER} | grep ${jobno%%_*} | wc -l) -eq 0 ]
	then
		# Set compflag to 1 to exit the loop
		compflag=1
	fi
done
stata-se -b do postsim.do


#-------------------------------------------------------------------------------
# Analysis of simulated data (takes about 5 minutes)
#-------------------------------------------------------------------------------
# cd based on what pwd is
CURR_DIR=$(pwd)
LAST_WORD=$(basename "${CURR_DIR}")
if [ "${LAST_WORD}" = "nlsy97" ]; then
	cd ../../sim-results
elif [ "${LAST_WORD}" = "src" ]; then
	cd sim-results
elif [ "${LAST_WORD}" = "baseline" ]; then
	cd ../../sim-results
elif [ "${LAST_WORD}" = "no-frictions" ]; then
	cd ../../sim-results
elif [ "${LAST_WORD}" = "no-cred-cons" ]; then
	cd ../../sim-results
else
	cd ../sim-results
fi
stata-se -b do model-fit.do
stata-se -b do cfl.do


#-------------------------------------------------------------------------------
# Parametric Bootstrap (takes about 2½ days with 151 parallel tasks)
#-------------------------------------------------------------------------------
# cd based on what pwd is
CURR_DIR=$(pwd)
LAST_WORD=$(basename "${CURR_DIR}")
if [ "${LAST_WORD}" = "nlsy97" ]; then
	cd ../../parametric-bootstrap
elif [ "${LAST_WORD}" = "src" ]; then
	cd parametric-bootstrap
else
	cd ../parametric-bootstrap
fi

# run parboot.m in Matlab in parallel using SLURM with a 151-task array
bash matbatch_t151 parboot.m

# extract SLURM job number (excluding the job that's running the current script)
sleep 100
jobno=$(squeue --user=${USER} --states=RUNNING | sort -k6,6 -t '|' -r | grep -v "shellbat" | head -2 | tail -1 | awk '{print $1}')

# pause execution of this master script until after all 151 tasks have completed
compflag=0
while [ ${compflag} -eq 0 ]
do
	sleep 1
	if [ $(squeue -u ${USER} | grep ${jobno%%_*} | wc -l) -eq 0 ]
	then
		# Set compflag to 1 to exit the loop
		compflag=1
	fi
done

# bring all the bootstrap estimates together and compute SEs
matlab -singleCompThread -nojvm -nodisplay -r "computeSEs.m;quit"

# output all estimation results and standard errors
matlab -singleCompThread -nodisplay -r "estimates_tables.m;quit"

