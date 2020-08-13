#!/bin/bash
# USEARCH v11 fastq info script

raw_data="raw_data"
read_summary="1.read_summary"

##########################################################################################

echo %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
echo Read summary of raw `.fastq` sequences
echo %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

# Prouduce a short summary report of raw fastq sequences using `-fastx_info` command.
# Expected error should be <2 for both forward and reverse reads. Usually reverse reads have a higher error rate.

mkdir $read_summary

for fastq in $raw_data/*R1*.fastq
  do
    echo ""
    echo ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    echo "fastq_info forward reads"

    usearch11 -fastx_info $fastq -output ${read_summary}/a_fwd_fastq_info.txt
done

for fastq in $raw_data/*R2*.fastq
  do
    echo ""
    echo ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    echo "fastq_info forward reads"

    usearch11 -fastx_info $fastq -output ${read_summary}/b_rev_fastq_info.txt
done

##########################################################################################
