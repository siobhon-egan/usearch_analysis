# Amplicon next generation sequence analysis

Set of pipelines and scripts for analysis of sequence data using [USEARCH](https://drive5.com/usearch/), a program developed by Robert Edgar.

**Download USEARCH**
Available [here](https://www.drive5.com/usearch/download.html).
Remeber if you have a large dataset you will need the 64 bit version.

## Documentation and tutorials

I maintain a webpage on NGS sequence analysis (currently focused on amplicon illumia MiSeq data) that contains a variety of pipelines, code, examples and lots of links.
- [Home page](https://cryptick-lab.github.io/NGS-Analysis/_site/index.html)
- [Getting started in usearch](https://cryptick-lab.github.io/NGS-Analysis/_site/usearch-getting-started.html)
- [USEARCH v11 Amplicon pipeline](https://cryptick-lab.github.io/NGS-Analysis/_site/usearch-v11.html)

***

## Notes on using these scripts

It is import that your sequence files are unzipped (i.e. in `*.fastq` format).
If your sequences are zipped (i.e. in `*.fastq.gz` format) you will need to unzip them, you can do so using unix command
```
gunzip *.fastq.gz
```

Each script in the repo here is numbered 1-7 and written so that it can be run as a 'stand alone' piece however will require you have installed appropriate version USEARCH and adjust directories and file names as needed.

If you are new or starting out this step by step process will be easier to follow and importantly you will be able to decide which parts work for your data and which parameters might need optimising.

Once you are happy with the script you can run the complete pipeline in full by using (usearchv11_analysis.sh](https://github.com/siobhon-egan/usearch_analysis/blob/master/usearch11_analysis.sh).

To use the `usearchv11_analysis.sh` script make edits in the first part of the script by opening in a text editor.

You can rename directories as you like. The most important one is the `raw_data` directory, this MUST match the name of the folder where you raw data is.
It assumes your raw data is in the following format
- `sample_id_SXXX_L001_R1_001.fastq` (read 1, forward)
- `sample_id_SXXX_L001_R2_001.fastq` (read 2, reverse)

Before use:
```
$chmod 775 this_script.sh
```

To run:
```
$./usearch_analysis.sh
```


**Important variables to edit**

*Enter max diff for merging - default 5 but should increase for paired end*
- `maxdiffs="15"`

*Enter minimum merge overlap - default is 16 bp*
- `overlap="50"`

*Enter forward sequences (5'-3'). Wildcard letters indicating degenerate positions in the primer are supported. See [IUPAC](https://drive5.com/usearch/manual/IUPAC_codes.html) codes for details*
- `fwd_primer="AGAGTTTGATCCTGGCTYAG" #primer name and reference`
- `rev_primer="TGCTGCCTCCCGTAGGAGT" #primer name and reference`

*Enter max error rate. Natural choice is 1, however may want to decrease to 0.5 or 0.25 for more stringent filtering*
- `max_ee="1"`

*Enter min length of sequence for trimming in bp (eg. to keep all seqs above 200 bp enter "200")*
- `minlen="150"`

*Enter max size to discard i.e. to discard singletons = 1, duplicates = 2*
- `maxsize="1"`

## Alternative simple script

I have created a simplified version of the usearch11 script [here](https://github.com/siobhon-egan/usearch_analysis/blob/master/usearchv11_simple.sh)

This simplified pipeline does not search for any primers/distal sequences and does not differentiate sequences based on expected length.
I Recommend this script if working with unknown amplicon illumina NGS data i.e. you are not sure what primers were used and/or the target length of amplicons.
