#!/bin/bash
# Removing low abundant sequences and singletons from samples

# Enter directory for labeled data
labeled_data="5.labeled_data"
# Enter directory for dereplicated sequences
derep_dir="6.derep_data"
# Enter directory for singlteton filter data
SF="7.singleton_filtered"
# Enter directory for singlteton sequences
low_abund_seqs="8.singleton_sequences"
# max size to discard i.e. to discard singletons = 1, duplicates = 2
maxsize="1"

##########################################################################################

echo %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
echo Removing low abundant seqs singletons per sample
echo %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
echo ""

# Creating directories

mkdir ${derep_dir}
mkdir ${SF}
mkdir ${low_abund_seqs}

#*****************************************************************************************
# Step 1: Dereplicating

for file7 in ${labeled_data}/*.fasta
	do

		echo ""
		echo ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		echo Removing singletons step 1: derep_fulllength
		echo input is:
		echo ${file7}

		usearch11 -fastx_uniques ${file7} -fastaout "${derep_dir}/$(basename "$file7" .fasta).fasta" -sizeout
	done


#*****************************************************************************************
# Step 2: Filtering low abundant seqs {maxsize}

for file8 in ${derep_dir}/*.fasta
	do

		echo ""
		echo ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		echo Removing singletons step 2: sorting uniques
		echo input is:
		echo ${file8}

		usearch11 -sortbysize ${file8} -fastaout "${low_abund_seqs}/$(basename "$file8" .fasta).fasta" -maxsize ${maxsize}
	done


	# Step 3: Mapping reads

for file11 in ${labeled_data}/*.fasta
	do

	  echo ""
	  echo ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	  echo Removing singletons step 3: mapping reads to low abundant uniques
	  echo input is:
	  echo ${file11}

	  usearch11 -search_exact ${file11} -db "${low_abund_seqs}/$(basename "$file11" .fasta).fasta" -strand plus -notmatched "${SF}/$(basename "$file11" .fasta).fasta"
	done

##########################################################################################
