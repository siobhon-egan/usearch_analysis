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

	##########################################################################################
