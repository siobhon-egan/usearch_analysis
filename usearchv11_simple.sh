#!/bin/bash
# Siobhon L Egan, Jan 2021
##########################################################################################
##########################################################################################
############################# USEARCH v11 simple pipeline ##############################
##########################################################################################
##########################################################################################
#	Requirements: usearch11 must be installed on the PATH as "usearch11".
# Remeber if you have a large dataset you will need the 64 bit version.
#	This script will work in unix and linux environments.
#
# This is a simplified pipeline that does not search for any primers/distal sequences and does not differentiate sequences based on expected length
# Recommend this script if working with unknown amplicon illumina NGS data i.e. you are not sure what primers were used and/or the target length of amplicons
#
#	This script taked raw MiSeq demultiplexed .fastq files for input and performs the following tasks:
#
# 1) Merging of illumina paired reads
#	2) Quality filtering of `.fastq` sequence data and removal of short dimer seqs to generate `.fasta` sequence files
#	3) Renaming files with USEARCH labels "barcodelabel=sample_id;sequence_id"
#	4) Removing low abundant sequences & singletons
#	5) Clustering sequences with
# 	5a) UPARSE otus (using 97% similarity threshold)
#		5b) UNOISE3 zotus
##########################################################################################
#	Input raw unmerged filenames must be named "sample_id_SXXX_L001_R1.fastq" (read 1)
#	and "sample_id_SXXX_L001_R2.fastq" (read 2) and all deposited in a directory.
#	by the "$raw_data" variable. "SXXX" is the sample number given by the MiSeq
#	in the order you entered them in the Sample Sheet.
#
#	Before use: $chmod +x this_script.sh
#	To run: $./this_script.sh
#	This script will read any input directory specified by the "raw_data" variable, but will deposit all
#	output into the current working diretory.
##########################################################################################

# Enter raw data directorry
raw_data="raw_data"
# Enter raw read information on raw sequences
read_summary="1.read_sumary"
# Enter directory for merged output
merged_data="2.merged_data"
# Enter max diff for merging - default 5 but should increase for paired end
maxdiffs="15"
# Enter minimum merge overlap - default is 16 bp
overlap="50"
# Enter directory for quality filtered output
QF="3.quality_filtered"
# Enter max error rate. Natural choice is 1, however may want to decrease to 0.5 or 0.25 for more stringent filtering.
max_ee="1"
# Enter directory for labeled data
labeled_data="4.labeled_data"
# Enter directory for dereplicated sequences
derep_dir="5.derep_data"
# Enter directory for singlteton filter data
SF="6.singleton_filtered"
# Enter directory for singlteton sequences
low_abund_seqs="7.singleton_sequences"
# Enter max size to discard i.e. to discard singletons = 1, duplicates = 2
maxsize="1"
# Enter directory for sequence clustering
cluster="8.cluster"
# Enter sub-directory for uparse_otu clustering
uparse_otus="8a.otus"
# Enter sub-directory for unoise_zotu clustering
unoise_zotus="8b.zotus"


##########################################################################################
# DO NOT EDIT BELOW THIS LINE
##########################################################################################

##########################################################################################


##########################################################################################

echo %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
echo Merging paried illumina .fastq sequences
echo %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

# Merge paired-end reads using `-fastq_mergepairs` command, and rename sequences. This would be done before primers are trimmed.

mkdir ${merged_data}
mkdir working1

#*****************************************************************************************
# Part 1: merge reads

for file1 in ${raw_data}/*R1.fastq
  do
    echo ""
		echo ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		echo Merging paired reads
		echo forward reads are:
		echo $(basename ${file1})
		echo reverse reads are:
		echo $(basename ${file1} R1.fastq)R2.fastq

    usearch11 -fastq_mergepairs ${file1} -reverse "${raw_data}/$(basename -s R1.fastq ${file1})R2.fastq" -fastqout "working1/$(basename "$file1")" -fastq_maxdiffs ${maxdiffs} -fastq_minovlen ${overlap} -report ${merged_data}/2a_merging_seqs_report.txt -tabbedout ${merged_data}/2b_tabbedout.txt
done

#*****************************************************************************************
# Part 2: Remove "_L001_R1_001" from filenames

for file2 in working1/*.fastq
	do
		rename="$(basename ${file2} _L001_R1.fastq).fastq"
	mv ${file2} ${merged_data}/${rename}
done

#*****************************************************************************************
# Removing working directory

rm -r working1


##########################################################################################

echo %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
echo Quality control and removing dimer seqs
echo %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

# Quality filtering of fastq files using the `-fastq_filter` command, output gives fasta files.

mkdir ${QF}

for file3 in ${merged_data}/*.fastq
	do
		echo ""
		echo ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		echo Quality control and removing dimer seqs
		echo input is:
		echo ${file3}

    usearch11 -fastq_filter ${file3} -fastaout "${QF}/$(basename "$file3" .fastq).fasta" -fastq_maxee ${max_ee}
done

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

for file4 in ${QF}/*.fasta
	do
		sed -e 's/>/>barcodelabel=;/g' ${file4} > working2/$(basename "$file4" .fasta).txt
done

#*****************************************************************************************
# Part 2: Add sample_ID (should be filename) to produce ">barcodelabel=sample_ID;sequence_ID"

for file5 in working2/*.txt
	do
		sample_id=$(basename ${file5} .txt)
		echo ${sample_id}

	sed -e "s/;/${sample_id};/g" ${file5} > "${labeled_data}/$(basename "$file5" .txt).fasta"
done

#*****************************************************************************************
# Remove working directories

rm -r working2

################################################################################################

echo %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
echo Removing low abundant seqs singletons per sample
echo %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

# Remove low abundant sequences (e.g. singletons) in samples using the `-fastx_uniques` command

mkdir ${derep_dir}
mkdir ${SF}
mkdir ${low_abund_seqs}

#*****************************************************************************************
# Part 1: Dereplicating

for file6 in ${labeled_data}/*.fasta
	do
		echo ""
		echo ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		echo Removing singletons step 1: derep_fulllength
		echo input is:
		echo ${file6}

		usearch11 -fastx_uniques ${file6} -fastaout "${derep_dir}/$(basename "$file6" .fasta).fasta" -sizeout
done

#*****************************************************************************************
# Part 2: Filtering low abundant seqs {maxsize}

for file7 in ${derep_dir}/*.fasta
	do
		echo ""
		echo ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		echo Removing singletons step 2: sorting uniques
		echo input is:
		echo ${file7}

		usearch11 -sortbysize ${file7} -fastaout "${low_abund_seqs}/$(basename "$file7" .fasta).fasta" -maxsize ${maxsize}
done

#*****************************************************************************************
# Step 3: Mapping reads

for file8 in ${labeled_data}/*.fasta
	do
	  echo ""
	  echo ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	  echo Removing singletons step 3: mapping reads to low abundant uniques
	  echo input is:
	  echo ${file8}

	  usearch11 -search_exact ${file8} -db "${low_abund_seqs}/$(basename "$file8" .fasta).fasta" -strand plus -notmatched "${SF}/$(basename "$file8" .fasta).fasta"
done

################################################################################################
################################################################################################

echo %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
echo CLUSTERING
echo %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

# Concatenate all singleton filter sequences into a single fasta file
# Find the set of unique sequences in an input file, also called dereplication using `-fastx_uniques` command

mkdir ${cluster}

cat ${SF}/*.fasta > ${cluster}/all_SF.fasta

cd ${cluster}

usearch11 -fastx_uniques all_SF.fasta -fastaout all_SF_DR.fasta -sizeout

#*****************************************************************************************

echo ----------------------------------------------------------------------------
echo Part a - Generating UPARSE OTUs
echo ----------------------------------------------------------------------------

# Cluster sequences in 97% operational taxonomic units (OTUs) using UPARSE algorithm `-cluster_otus` command and generate an OTU table

mkdir ${uparse_otus}
cd ${uparse_otus}

	usearch11 -cluster_otus ../all_SF_DR.fasta -otus uparse_otus.fasta -relabel OTU

  usearch11 -usearch_global ../all_SF.fasta -db uparse_otus.fasta -strand both -id 0.97 -otutabout uparse_otu_tab.txt -biomout uparse_otu_biom.biom

  # The next two lines produce a distance matrix file and then a tree (newick format)
  # Current parameters are a guide only and you will need to optimse them for your data
  # Large datasets can take a long time, so you can skip this part for now to speed up analysis

#  usearch11 -calc_distmx uparse_otus.fasta -tabbedout uparse_otus_distmx.txt -maxdist 0.2 -termdist 0.3

#	usearch11 -cluster_aggd uparse_otus_distmx.txt -treeout uparse_otus_clusters.tree -clusterout uparse_otus_clusters.txt \
#	  -id 0.80 -linkage min
cd ..

#*****************************************************************************************

echo ----------------------------------------------------------------------------
echo Part b - Generating UNOISE ZOTUs
echo ----------------------------------------------------------------------------

# Cluster sequences in zero-radius operational taxonomic units (ZOTUs) using `-unoise3` command and generate a ZOTU table

mkdir ${unoise_zotus}
cd ${unoise_zotus}

  usearch11 -unoise3 ../all_SF_DR.fasta -zotus unoise_zotus.fasta -tabbedout unoise_tab.txt

	usearch11 -fastx_relabel unoise_zotus.fasta -prefix Otu -fastaout unoise_zotus_relabeled.fasta -keep_annots

	usearch11 -otutab ../all_SF.fasta -zotus unoise_zotus_relabeled.fasta -otutabout unoise_otu_tab.txt -biomout unoise_otu_biom.biom -mapout unoise_map.txt -notmatched unoise_notmatched.fasta -dbmatched dbmatches.fasta -sizeout

  # The next two lines produce a distance matrix file and then a tree (newick format)
  # Current parameters are a guide only and you will need to optimse them for your data
  # Large datasets can take a long time, so you can skip this part for now to speed up analysis

#  usearch11 -calc_distmx unoise_zotus.fasta -tabbedout unoise_zotus_distmx.txt -maxdist 0.2 -termdist 0.3

#  usearch11 -cluster_aggd unoise_zotus_distmx.txt -treeout unoise_zotus_clusters.tree -clusterout unoise_zotus_clusters.txt \
#    -id 0.80 -linkage min
cd ..
cd ..

################################################################################################
echo %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
echo ANALYSIS COMPLETE
echo %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
################################################################################################
