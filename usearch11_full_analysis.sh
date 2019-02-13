#!/bin/bash
#
#	Requirements: usearch11 must be installed on the PATH as "usearch11".
# Remeber if you have a large dataset you will need the 64 bit version.
#	This script will work in unix and linux environments.
#
#	This script taked raw MiSeq demultiplexed .fastq files for input and performs the following tasks:
#
#	1) Inspecting raw fastq sequences
# 2) Merging of illumina paired reads
#	2) Trimming of primer sequences and distal bases and removal of sequences without correct primer sequences
#	3) Quality filtering of `.fastq` sequence data and removal of short dimer seqs to generate `.fasta` sequence files
#	4) Renaming files with USEARCH labels "barcodelabel=sample_id;sequence_id"
#	5) Removing low abundant sequences & singletons
#	6) Clustering sequences with
# 	6a) UPARSE otus (using 97% similarity threshold)
#		6b) UNOISE3 zotus
##########################################################################################
#	Input raw unmerged filenames must be named "sample_id_SXXX_L001_R1_001.fastq" (read 1)
#	and "sample_id_SXXX_L001_R2_001.fastq" (read 2) and all deposited in a directory specified
#	by the "$raw_data" variable. "SXXX" is the sample number given by the MiSeq
#	in the order you entered them in the Sample Sheet.
#
#	Before use: $chmod 775 this_script.sh
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
# Enter directory for sequences that are matched to primers
primer_matched="3a.primer_matches"
# Enter directory for sequences that do not match primers
primer_not_matched="3b.primer_not_matched"
# Enter forward sequences (5'-3'). Wildcard letters indicating degenerate positions in the primer are supported. See IUPAC(https://drive5.com/usearch/manual/IUPAC_codes.html) codes for details.
fwd_primer="CCAGCAGCCGCGGTAATTC"
rev_primer="CTTTCGCAGTAGTTYGTCTTTAACAAATCT"
# Enter directory for quality filtered output
QF="4.quality_filtered"
# Enter max error rate. Natural choice is 1, however may want to decrease to 0.5 or 0.25 for more stringent filtering.
max_ee="1"
# Enter min length of sequence for trimming in bp (eg. to keep all seqs above 200 bp enter "200")
minlen="150"
# Enter directory for labeled data
labeled_data="5.labeled_data"
# Enter directory for dereplicated sequences
derep_dir="6.derep_data"
# Enter directory for singlteton filter data
SF="7.singleton_filtered"
# Enter directory for singlteton sequences
low_abund_seqs="8.singleton_sequences"
maxsize="1"
cluster="9.cluster"
uparse_otus="9a.otus"
unoise_zotus="9b.zotus"


##########################################################################################
# DO NOT EDIT BELOW THIS LINE
##########################################################################################

##########################################################################################

echo %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
echo Read summary of raw `.fastq` sequences
echo %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

mkdir $read_summary

 for fq in $raw_data/*R1*.fastq
 do
  usearch11 -fastx_info $fq -output $read_summary/1a_fwd_fastq_info.txt
 done

 for fq in $raw_data/*R2*.fastq
 do
  usearch11 -fastx_info $fq -output $read_summary/1b_rev_fastq_info.txt
 done

##########################################################################################

echo %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
echo Merging paried illumina `.fastq` sequences
echo %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


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

echo %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
echo Triming primers and distal bases
echo %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
echo ""

# At the moment this usearch command can only take .fasta as input so can only be done
# after QF

# Creating working directories

mkdir ${primer_matched}
mkdir ${primer_not_matched}

#*****************************************************************************************
# Step 1: Finding seqs with FWD primer

for file3 in ${merged_data}/*.fastq
	do

		echo ""
		echo ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		echo Trimming primers step 1: finding seqs with FWD primer
		echo input is:
		echo ${file3}

	usearch11 -search_pcr2 ${file3} -fwdprimer ${fwd_primer} \
	-revprimer ${rev_primer} \
	-strand both -fastqout "${primer_matched}/$(basename ${file3})" -notmatchedfq "${primer_not_matched}/$(basename ${file3})" -tabbedout pcr2_output.txt
done

##########################################################################################
echo %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
echo Quality control and removing dimer seqs
echo %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
echo ""

		mkdir ${QF}

#*****************************************************************************************
for file4 in ${primer_matched}/*.fastq
	do
		echo ""
		echo ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		echo Quality control and removing dimer seqs
		echo input is:
		echo ${file4}

	usearch11 -fastq_filter ${file4} -fastaout "${QF}/$(basename "$file4" .fastq).fasta" -fastq_maxee ${max_ee} -fastq_minlen ${minlen}
done

# For this script to run correctly input fasta label must be formatted >sequence_id and filename must be sample_id.fasta.
# Result will be ">barcodelabel=sample_id;sequenceid"

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


#*****************************************************************************************
# Remove working directories

		rm -r working2

################################################################################################
################################################################################################
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


#*****************************************************************************************
################################################################################################
################################################################################################
echo %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
echo CLUSTERING
echo %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

echo ----------------------------------------------------------------------------
echo Part a - Generating UPARSE OTUs
echo ----------------------------------------------------------------------------

mkdir ${cluster}

	cat ${SF}/*.fasta > ${cluster}/all_SF.fasta

cd ${cluster}

	usearch11 -fastx_uniques all_SF.fasta -fastaout all_SF_DR.fasta -sizeout

	mkdir ${uparse_otus}
	cd ${uparse_otus}

		usearch11 -cluster_otus ../all_SF_DR.fasta -otus uparse_otus.fasta -relabel OTU

		usearch11 -usearch_global ../all_SF.fasta -db uparse_otus.fasta -strand both -id 0.97 -otutabout uparse_otu_tab.txt -biomout uparse_otu_biom.biom

		usearch11 -cluster_agg uparse_otus.fasta -treeout uparse_otus.tree -clusterout clusters.txt

	cd ..

echo ----------------------------------------------------------------------------
echo Part b - Generating UNOISE ZOTUs
echo ----------------------------------------------------------------------------


	mkdir ${unoise_zotus}
	cd ${unoise_zotus}

		usearch11 -unoise3 ../all_SF_DR.fasta -zotus unoise_zotus.fasta -tabbedout unoise_tab.txt

		usearch11 -fastx_relabel unoise_zotus.fasta -prefix Otu -fastaout unoise_zotus_relabeled.fasta -keep_annots

		usearch11 -otutab ../all_SF_DR.fasta -zotus unoise_zotus_relabeled.fasta -otutabout unoise_otu_tab.txt -biomout unoise_otu_biom.biom -mapout unoise_map.txt -notmatched unoise_notmatched.fasta -dbmatched dbmatches.fasta -sizeout

		usearch11 -cluster_agg unoise_zotus_relabeled.fasta -treeout unoise_zotus.tree -clusterout clusters.txt -id 0.80 -linkage min

	cd ..
	cd ..
################################################################################################
echo %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
echo ANALYSIS COMPLETE
echo %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
################################################################################################
