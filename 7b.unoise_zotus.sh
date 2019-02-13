#!/bin/bash
# clustering sequences in ZOTUs with UNOISE3

# Enter directory for singlteton filter data
SF="7.singleton_filtered"
# Enter directory for sequence clustering
cluster="9.cluster"
# Enter sub-directory for unoise_zotu clustering
unoise_zotus="9b.zotus"

##########################################################################################

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

##########################################################################################
