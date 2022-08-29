Pipeline
==========

The DiFlex pipeline performs metatranscriptomic analysis of raw RNA-seq data by using different tools strung together with snakemake =.

The main function of the pipeline can be categorized in six different substeps.

* Quality control of both raw and processed data.

* The pre-processing of the raw RNA-seq dataset. This includes the trimming of adapters and filtering out of rRNA sequences.

* The creation of a de novo transcriptome assembly.

* Aligning the transcripts to the de novo transcriptome.

* Performing a differential gene expression analysis.

* Functional analysis of the transcripts


The Different tools used by DiFlex
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

FastQC

FastQC is a popular tool to perform quality control on high throughput sequencing data. It gives a simple to use graphical overview of the sample quality.
For more information see: `https://www.bioinformatics.babraham.ac.uk/projects/fastqc/ <https://www.bioinformatics.babraham.ac.uk/projects/fastqc/>`_

Trimmomatic

Trimmomatic is a illumina NGS data read trimming tool used to remove Illumina adapters and low quality bases at the start and end of reads.
For more information see: `http://www.usadellab.org/cms/?page=trimmomatic <http://www.usadellab.org/cms/?page=trimmomatic>`

SortMeRNA

SortMeRNa is a local sequence alignment tool used for RNA filtering, mapping and clustering. DiFlex only uses the filtering feature to differentiate between mRNA and rRNA.
The filtering of RNA uses an RNA reference database. This databse is automatically downloaded, further described in the parameters section.
For more information see: `https://github.com/biocore/sortmerna <https://github.com/biocore/sortmerna>`

Trinity

Trinity is an RNA-seq de novo assembly tool used to create transcriptome and perform differential expression analysis. 
For more information see: `https://github.com/trinityrnaseq/trinityrnaseq/wiki <https://github.com/trinityrnaseq/trinityrnaseq/wiki>`

InterProscan

InterProscan is a functional protein annotation tool that uses the InterPro database to perform different analyses. The Trinity isoforms are translated to 
open reading frames and the longest ORF of every different isoform is chosen for functional annotation.
Interproscan can not be installed using anaconda so a seperate installation is available in the amplicomics group. This is an older version since the newer InterProscan 
version require Java 11, which is not available on the cluster. The older version is unable to perform the following analyses: PANTHER, MOBIDB, PROSITEPATTERNS and PROSITEPROFILES.
The database is already installed with this installation.
For more information see: `https://interproscan-docs.readthedocs.io/en/latest/ <https://interproscan-docs.readthedocs.io/en/latest/>`

TopGO








