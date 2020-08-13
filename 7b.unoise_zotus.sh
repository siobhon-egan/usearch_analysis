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

# Cluster sequences in zero-radius operational taxonomic units (ZOTUs) using `-unoise3` command and generate a ZOTU table

mkdir ${unoise_zotus}
cd ${unoise_zotus}

		usearch11 -unoise3 ../all_SF_DR.fasta -zotus unoise_zotus.fasta -tabbedout unoise_tab.txt

		usearch11 -fastx_relabel unoise_zotus.fasta -prefix Otu -fastaout unoise_zotus_relabeled.fasta -keep_annots

		usearch11 -otutab ../all_SF.fasta -zotus unoise_zotus_relabeled.fasta -otutabout unoise_otu_tab.txt -biomout unoise_otu_biom.biom -mapout unoise_map.txt -notmatched unoise_notmatched.fasta -dbmatched dbmatches.fasta -sizeout

		# The next two lines produce a distance matrix file and then a tree (newick format)
		# Current parameters are a guide only and you will need to optimse them for your data
		# Large datasets can take a long time, so you can skip this part for now to speed up analysis

		usearch11 -calc_distmx unoise_zotus.fasta -tabbedout unoise_zotus_distmx.txt -maxdist 0.2 -termdist 0.3

		usearch11 -cluster_aggd unoise_zotus_distmx.txt -treeout unoise_zotus_clusters.tree -clusterout unoise_zotus_clusters.txt \
		  -id 0.80 -linkage min

cd ..
cd ..

##########################################################################################
