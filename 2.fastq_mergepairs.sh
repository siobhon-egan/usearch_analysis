#!/bin/bash
# USEARCH v11 fastq merge pairs script

raw_data="raw_data"
merged_data="2.merged_data"
# Enter max diff for merging - default 5 but should increase for paired end
maxdiffs="15"
# Enter minimum merge overlap - default is 16 bp
overlap="50"

##########################################################################################

echo %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
echo Merging paried illumina `.fastq` sequences
echo %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

# Merge paired-end reads using `-fastq_mergepairs` command, and rename sequences. This would be done before primers are trimmed.

mkdir ${merged_data}
mkdir working1

#*****************************************************************************************
# Step1: merge data with usearch9 -fastq-filter

for file1 in ${raw_data}/*R1_001.fastq
  do
    echo ""
		echo ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		echo Merging paired reads
		echo forward reads are:
		echo $(basename ${file1})
		echo reverse reads are:
		echo $(basename ${file1} R1_001.fastq)R2_001.fastq

    usearch11 -fastq_mergepairs ${file1} -reverse "${raw_data}/$(basename -s R1_001.fastq ${file1})R2_001.fastq" -fastqout "working1/$(basename "$file1")" -fastq_maxdiffs ${maxdiffs} -fastq_minovlen ${overlap} -report ${merged_data}/2a_merging_seqs_report.txt -tabbedout ${merged_data}/2b_tabbedout.txt
done

#*****************************************************************************************
# Step 2: Remove "_L001_R1_001" from filenames

for file2 in working1/*.fastq
	do
		rename="$(basename ${file2} _L001_R1_001.fastq).fastq"
	mv ${file2} ${merged_data}/${rename}
done

#*****************************************************************************************
# Removing working directory

		rm -r working1

##########################################################################################
