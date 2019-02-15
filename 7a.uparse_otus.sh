#!/bin/bash
# clustering sequences into 97% OTUs with UPARSE

# Enter directory for singlteton filter data
SF="7.singleton_filtered"
# Enter directory for sequence clustering
cluster="9.cluster"
# Enter sub-directory for uparse_otu clustering
uparse_otus="9a.otus"

##########################################################################################

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
	
	usearch11 -calc_distmx uparse_otus.fasta -tabbedout uparse_otus_distmx.txt -maxdist 0.2 -termdist 0.3

	usearch11 -cluster_aggd uparse_otus_distmx.txt -treeout uparse_otus_clusters.tree -clusterout uparse_otus_clusters.txt \
	  -id 0.80 -linkage min
cd ..

	##########################################################################################
