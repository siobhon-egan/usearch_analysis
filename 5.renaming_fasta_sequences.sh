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

		mkdir ${labeled_data}
		mkdir working2

#*****************************************************************************************
# Step 1: Remove ">" from start of sequence_ID

for file5 in ${QF}/*.fasta
	do

		sed -e 's/>/>barcodelabel=;/g' ${file5} > working2/$(basename "$file5" .fasta).txt
done

#*****************************************************************************************
# Step 2: Add sample_ID (should be filename) to produce ">barcodelabel=sample_ID;sequence_ID"

for file6 in working2/*.txt
	do

		sample_id=$(basename ${file6} .txt)
		echo ${sample_id}

	sed -e "s/;/${sample_id};/g" ${file6} > "${labeled_data}/$(basename "$file6" .txt).fasta"
done

##########################################################################################
