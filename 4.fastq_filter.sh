#!/bin/bash
# USEARCH v11 quality filtering of fastq reads to give fasta output

# Enter directory for sequences that are matched to primers
primer_matched="3a.primer_matches"
# Enter directory for quality filtered output
QF="4.quality_filtered"
# Enter max error rate. Natural choice is 1, however may want to decrease to 0.5 or 0.25 for more stringent filtering.
max_ee="1"
# Enter min length of sequence for trimming in bp (eg. to keep all seqs above 200 bp enter "200")
minlen="150"

##########################################################################################

echo %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
echo Quality control and removing dimer seqs
echo %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

mkdir ${QF}

for file4 in ${primer_matched}/*.fastq
	do
		echo ""
		echo ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		echo Quality control and removing dimer seqs
		echo input is:
		echo ${file4}

    usearch11 -fastq_filter ${file4} -fastaout "${QF}/$(basename "$file4" .fastq).fasta" -fastq_maxee ${max_ee} -fastq_minlen ${minlen}
done

##########################################################################################
