#!/bin/bash
# USEARCH v11 search merged fastq sequences for primers and extract amplicon sequence

merged_data="2.merged_data"
# Enter directory for sequences that are matched to primers
primer_matched="3a.primer_matches"
# Enter directory for sequences that do not match primers
primer_not_matched="3b.primer_not_matched"
# Enter forward sequences (5'-3'). Wildcard letters indicating degenerate positions in the primer are supported. See IUPAC(https://drive5.com/usearch/manual/IUPAC_codes.html) codes for details.
fwd_primer="AGAGTTTGATCCTGGCTYAG" #16S v1-2 primer, ref Gofton et al. Parasites & Vectors (2015) 8:345
rev_primer="TGCTGCCTCCCGTAGGAGT" #16S v1-2 primer, ref Turner et al. J Eukaryot Microbiol (1999) 46(4):32

##########################################################################################

echo %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
echo Triming primers and distal bases
echo %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
echo ""

# The `-search_pcr2` command searches for matches to a primer pair and outputs the sequence in between (i.e. amplicon with primers removed) into `primer_matched` file

mkdir ${primer_matched}
mkdir ${primer_not_matched}

for file3 in ${merged_data}/*.fastq
	do

	usearch11 -search_pcr2 ${file3} -fwdprimer ${fwd_primer} \
	-revprimer ${rev_primer} \
	-strand both -fastqout "${primer_matched}/$(basename ${file3})" -notmatchedfq "${primer_not_matched}/$(basename ${file3})" -tabbedout ${primer_matched}/pcr2_output.txt
done

##########################################################################################
