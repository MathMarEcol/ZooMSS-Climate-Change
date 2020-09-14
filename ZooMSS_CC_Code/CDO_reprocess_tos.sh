#!/bin/bash

# script to regrid tos

# Start with TOS
indir="/Users/jason/Nextcloud/MME1Data/ZooMSS_Climate_Change/raw/tos/"
outdir="/Users/jason/Nextcloud/MME1Data/ZooMSS_Climate_Change/regrid/tos/"

# Declare an array of string with type
declare -a ModelArray=("CESM2" "GFDL-ESM4" "IPSL-CM6A-LR" "MPI-ESM1" "UKESM1-0-LL")
declare -a ExpArray=("historical" "ssp126" "ssp370" "ssp585")

# Iterate the string array using for loop
for m in ${ModelArray[@]}; do
   echo $m

	for e in ${ExpArray[@]}; do
		echo $e
		curr_files=($(ls ${indir}*$m*$e*))
		num_files=${#curr_files[@]}
   		echo $curr_files

		for ((i=0; i<=num_files-1; i++)); do
			curr_file=${curr_files[i]}
			cdo -sinfov $curr_file # Print the current details of the file

			out_name1="tempfile_tos.nc"
			cdo -remapbil,global_1 $curr_file $out_name1 # Remap to 1 degree global on the half-degree

			annual_name=${curr_file/_gn_/_onedeg_} # Replace gn or gr with onedeg in filename
			annual_name=${annual_name/_gr_/_onedeg_}
			annual_name=${annual_name/_Omon_/_Oyr_} # Replace Omon with Oyr to indicate annual average
			annual_name=${annual_name/raw/regrid} # change directory
			cdo yearmean $out_name1 $annual_name
		done
		
		merged_name=${annual_name::${#annual_name}-16} # Remove the dates
		merged_name=${merged_name/_onedeg_/_onedeg_merged.nc} # Add merged tag
		merged_name=${merged_name/regrid/merged} # change directory
		cdo -O -mergetime $outdir*$m*$e* $merged_name

	done
done

#Clean up
rm $out_name1