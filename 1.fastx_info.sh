#!/bin/bash
# USEARCH v11 fastq info script

raw_data="raw_data"
read_summary="1.read_summary"

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
