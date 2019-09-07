This repository contains all code to reproduce the analysis in the article "Computational massive identification of somatic variants in exonic splicing enhancers using The Cancer Genome Atlas".

How to run codes
(1)Please designate file and directory path in /ESE_detection/pipeline.sh.
 workdir: path to ESE_detection(downloaded folder)
 genomedir: path to the directory contains reference fasta files divided by chromosomes. Line feed should be removed.

(2)Please make data directories in /ESE_detection. Data directories shold be divided by tissues. Only TCGA tissue name is acceptable for data directory name. (such as "TCGA_brain", "TCGA_colorectal" and so on.) Move to data directory and make a directory named "RNAseq_downloaded_data". Then copy downloaded RNA-seq data from TCGA to that directory. 

(3)Please run pipeline.sh like below.
$ sh ./ESE_detection/pipeline.sh

(4)Identified ESE-disrupting variants are output in "All_validated_ese_Seq_ks.txt" file.
