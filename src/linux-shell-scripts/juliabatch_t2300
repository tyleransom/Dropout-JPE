#!/bin/bash

#
# Juliabatch will prepare and submit a Julia job to the SLURM queue on the DCSR cluster by SLURM script

# PATH=$PATH:/usr/local/gauss:/usr/local/stata

# Test usage; if incorrect, output correct usage
if [ "$#" -gt 2  -o  "$#" -eq 0 ]; then
	echo "********************************************************************"
	echo "*                        Juliabatch version 0.1                      *"
	echo "********************************************************************"
	echo "The 'Juliabatch' script submits Julia batch jobs to the DCC cluster using SLURM."
	echo ""
	echo "Usage is:"
	echo "         juliabatch-small <input_file.jl> [<output_file.jlog>]"
	echo ""
	echo "If only input_file.jl is provided, then input_file.jlog will be created."
	echo ""
	echo "Spaces in the filename or directory name may cause failure."
	echo ""
else
	# Stem and extension of file
	filestem=`echo $1 | cut -f1 -d.`
	extension=`echo $1 | cut -f2 -d.`
	
	# Test if file exist
	if [ ! -r $1 ]; then
		echo ""
		echo "File does not exist"
		echo ""
	elif [ $extension != jl ]; then
		echo ""
		echo "Invalid input file, must be a jl-file"
		echo ""
	else
		# Direct output, conditional on number of arguments
		if [ "$#" -eq 1 ]; then
			output=$filestem.jlog
		else
			output=$2
		fi
		
		# Use user-defined 'TMPDIR' if possible; else, use /work/tmr17
		if [[ -n $TMPDIR ]]; then
			pathy=$TMPDIR
		else
			pathy=/work/tmr17
		fi
		
		# Tempfile for the script
		shell=`mktemp $pathy/shell.XXXXXX` || exit 1
		chmod 700 $shell
		
		# Create script
		echo "#!/bin/tcsh"                        >> $shell
		
		# workaround for "GLIBC_2.0 not being defined" error on 2.4 kernels
		checkkernelversion=`uname -r | cut -f1-2 -d.`
		if [ "$checkkernelversion" == "2.4" ];
		then
			echo 'export LD_ASSUME_KERNEL=2.4.1'  >> $shell
		fi
		
		# SLURM metacommands
		echo "#SBATCH --job-name=juliabatch"             >> $shell
		echo "#SBATCH -o master_%A_%a.jlog"              >> $shell
		echo "#SBATCH -e master_%A_%a.jerr"              >> $shell
		echo "#SBATCH --mail-type=END"                   >> $shell
		echo "#SBATCH --mail-user=email@address.com"     >> $shell
		echo "#SBATCH --array=1-2300%174"                >> $shell # add %[number] to limit concurrent tasks to [number], eg. 0-15%4 limits number of concurrent tasks to 4
		echo "#SBATCH --requeue"                         >> $shell
		echo "#SBATCH --mem=14G"                         >> $shell
        echo "#SBATCH --partition=econ,scavenger,common" >> $shell
        #echo "#SBATCH --exclude=dcc-ultrasound-06,dcc-ultrasound-07" >> $shell
		echo "uname -a"                                  >> $shell
		echo "pwd"                                       >> $shell
		echo "date"                                      >> $shell
		echo "julia -p 1 $filestem.jl"                   >> $shell
		sbatch $shell
	fi
fi

