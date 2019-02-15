#!/bin/bash
# renaming quality filtered fasta seqeunces for downstream analysis

# Enter directory for quality filtered output
QF="4.quality_filtered"
# Enter directory for labeled data
labeled_data="5.labeled_data"

##########################################################################################

echo %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
echo Renameing sequences with ">barcodelabel=sample_id;sequence_id"
echo %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

# For this script to run correctly input fasta label must be formatted >sequence_id and filename must be sample_id.fasta.
# Result will be ">barcodelabel=sample_id;sequenceid"

mkdir ${labeled_data}
mkdir working2

#*****************************************************************************************
# Part 1: Remove ">" from start of sequence_ID

for file5 in ${QF}/*.fasta
	do
		sed -e 's/>/>barcodelabel=;/g' ${file5} > working2/$(basename "$file5" .fasta).txt
done

#*****************************************************************************************
# Part 2: Add sample_ID (should be filename) to produce ">barcodelabel=sample_ID;sequence_ID"

for file6 in working2/*.txt
	do
		sample_id=$(basename ${file6} .txt)
		echo ${sample_id}

	sed -e "s/;/${sample_id};/g" ${file6} > "${labeled_data}/$(basename "$file6" .txt).fasta"
done

#*****************************************************************************************
# Remove working directories

rm -r working2

##########################################################################################
