Parameters
============

The parameters of the different tools in the pipeline can be modified using the 'config.yaml' file.

.. code-block:: console

    snakemake_env_path:         "/zfs/omics/personal/thamer/miniconda3/envs/snakemake"
    snakefile_path:             "/zfs/omics/personal/thamer/DiFlex/metatrans-smk-hs"
    return_all_results:         "false"

    samples:                    "samples.csv"

    general:
        environment:            "../envs/general.yaml"
    read-analyse:
        environment:            "../envs/read_analyse.yaml"
        threads:                4
    trimmomatic:
        environment:            "../envs/trimmomatic.yaml"
        threads:                4
        adapters:               "db/adapters/adapters.fa"
    sortmerna:
        environment:            "../envs/sortmerna.yaml"
        aantal_alignments:      1
        aantal_best:            1
        paired_optie:           "paired_in"
        ref_database:           "fast"
        threads:                4
        max_memory:             6000
    fastQC:
        environment:            "../envs/fastqc.yaml"
        threads:                4
    trinity:
        environment:            "../envs/trinity.yaml"
        threads:                32
    trinity-assemble:
        max_memory:             "200G"
        min_kmer_cov:           1
    trinity-DE:
        P_cutoff:               0.05
        fold_change:            1.0
        pca_components:         3
    interproscan:
        environment:            "../envs/interproscan.yaml"
        dir_path:               "/zfs/omics/projects/amplicomics/bin/interproscan/interproscan-5.36-75.0"
        protein-max-length:     30
        analyses:
            - CDD
            - COILS
            - Gene3D
            - HAMAP
            - Pfam
            - PIRSF
            - PRINTS
            - SFLD
            - SMART

The indentation of the yaml file is important. Only tabs can be used, not spaces.

All parameters in DiFlex
**************************

*snakemake_env_path* [string] (default: "")
    The absolute file path that points to the Anaconda environment with snakemake installed. 
    Usually the 'miniconda3/envs/*environment_name*' folder.

*snakefile_path* [string] (default: "")
    The absolute file path that points to the folder containing the Snakefile. This is the folder that is cloned from the github.

*return_all_results* [boolean] (default: "false")
    Set this option to true in order to return the entire results folder as a tar.gz file. Refer to results section of the 
    documentation for more information.

*samples* [string] (default: samples.csv)
    comma seperated file containing the run, sample group, individual samples and file paths to foward and reverse reads.
    This file should be stored within the same folder as the Snakefile.
    Each sample name should be unique.
    the sample name can only contain letters, numbers and underscores (_).
    the forward and reverse reads must be a fastQ file.

FastQC
^^^^^^^^

FastQC is a tool that performs quality control on raw sequence data and is used to evaluate if the sequenced data 
should be used for analysis. It generates a graphic HTML report for an easy overview. https://www.bioinformatics.babraham.ac.uk/projects/fastqc/

*threads* [integer] (default: 4)
    The number of threads that will be used by a single running job of fastQC. A larger number of threads will 
    speed up analyses but will result in less jobs running in parralel to eachother. Snakemake will automatically
    scale down the amount of cores specified in the ``snakemake --use-conda --cores <ncores>`` option.

*environment* [string] (default: "../envs/fastqc.yaml")
    The recipe for conda to create the fastqc environment including all of it's dependencies. If this environment is 
    not installed then snakemake will install it automatically by the ``snakemake --use-conda`` option. Changes to 
    this recipe are not recommended unless you are an advanced user.

Trimmomatic
^^^^^^^^^^^^^

Trimmomatic is a tool used to trim, clip and remove adapters of Illumina sequenced reads. http://www.usadellab.org/cms/?page=trimmomatic

*threads* [integer] (default: 4)
    The number of threads that will be used by a single running job of trimmomatic. A larger number of threads will 
    speed up analyses but will result in less jobs running in parralel to eachother. Snakemake will automatically
    scale down the amount of cores specified in the ``snakemake --use-conda --cores <ncores>`` option.

*environment* [string] (default: "../envs/trimmomatic.yaml")
    The recipe for conda to create the trimmomatic environment including all of it's dependencies. If this environment is 
    not installed then snakemake will install it automatically by the ``snakemake --use-conda`` option. Changes to 
    this recipe are not recommended unless you are an advanced user.

*adapters* [string] (default: "db/adapters/adapters.fa")
    A FASTA file containing the Illumina adapter sequences to be trimmed of the reads.

SortMeRNA
^^^^^^^^^^^

SortMeRNA is a tool that filters next generation sequencing metatranscriptomics data to seperate rRNA and non-rRNA 
reads from eachother. https://github.com/biocore/sortmerna

*threads* [integer] (default: 4)
    The number of threads that will be used by a single running job of SortMeRNA. A larger number of threads will 
    speed up analyses but will result in less jobs running in parralel to eachother. Snakemake will automatically
    scale down the amount of cores specified in the ``snakemake --use-conda --cores <ncores>`` option.

*environment* [string] (default: "../envs/sortmerna.yaml")
    The recipe for conda to create the SortMeRNA environment including all of it's dependencies. If this environment is 
    not installed then snakemake will install it automatically by the ``snakemake --use-conda`` option. Changes to 
    this recipe are not recommended unless you are an advanced user.

*max_memory* [integer] (default: 6000)
    The maximum amount of memory a single SortMeRNA job will use. Snakemake will automatically limit the number of parralel jobs 
    running so as not to exceed the amount of memory specified in the ``snakemake --use-conda --resources mem_mb=<amount_memory>`` option. 

*aantal_best* [integer] (default: 1)
    The amount of reference sequences that will be searched for alignments. A higher number means more alignments will be made but only 
    the best one will be output. A value of zero means that all high-candidate reference sequences will be searched for alignments. The 
    more reference sequenced that have to be searched the longer the process will take.

*aantal_alignments* [integer] (default: 1)
    The amount of outputed alignments that reach the E-value threshold. A value of zero means all alignments that reach the E-value threshold 
    will be outputted. The more alignments that need to be outputed, the longer the process will take


*paired_optie* [string] (default: paired_in)
    This option controls which type of RNA ends up in which file. There are two options: ``paired_in`` and ``paired_out``. 
    The paired_in option makes it so that all reads in the other.fasta file will be non-rRNA. There are small chances that 
    some non-rRNA reads ends up in the aligned.fasta file.
    The paired_out option makes it so that all reads in the aligned.fasta will be rRNA. There are small chances that 
    some rRNA reads ends up in the other.fasta file.
    Since the DiFlex pipeline performs differential expression analysis only non-rRNA reads are of interest. There 
    should not be any reason to change this parameter.


*ref_database* [string] (default: fast)
    The type of database used for the filtering of rRNA. the options are: ``fast``, ``default`` and ``sensitive``.
    The difference between these databases is the identity percentage for the clustering of sequences for each kingdom. 
    
    fast -> unknown
    default -> bac-16S 90%, 5S & 5.8S seeds, rest 95% identity.
    sensitive -> all 97% identity.

Trinity
^^^^^^^^^

Trinity is a RNA-seq de novo transcriptome assembly tool. Trinity can also perform downstream analysis on the constructed transcriptome, 
such as a differential expression analysis. https://github.com/trinityrnaseq/trinityrnaseq/wiki

*threads* [integer] (default: 32)
    The number of threads that will be used by Trinity. Since the assemble of a transcriptome is a single snakemake job it is recommended 
    to set this value equal to the amoutn of cores on your system. Snakemake will make sure all cores
    specified in the ``snakemake --use-conda --cores <ncores>`` option are available to use.

*environment* [string] (default: "../envs/trinity.yaml")
    The recipe for conda to create the Trinity environment including all of it's dependencies. If this environment is 
    not installed then snakemake will install it automatically by the ``snakemake --use-conda`` option. Changes to 
    this recipe are not recommended unless you are an advanced user.

*max_memory* [string] (default: 120G)
    The maximum amount of memory that trinity will use during the assembly. It is a string containing the amount of 
    Gigabytes of memory that is to be used. This value cannot be changed by Snakemake itself so it must be correctly specified beforehand.

*min_kmer_cov* [integer] (default: 1)
    A higher value than 1 is useful to reduce the memory requirement for larger datasets. A value of 1 should still be used for small datasets 
    to retain maximum sensitivity

*P_cutoff* [float] (default: 0.05)
    The P value cutoff used in the differential expression analysis to determine significantly differentially expressed transcripts.

*fold_change* [float] (default: 1.0)

*pca_components* [integer] (default: 3)
    The amount of PCA components used in the Principal analysis component plot.


InterProscan
^^^^^^^^^^^^^^
*dir_path* [string] (default: "/zfs/omics/projects/amplicomics/bin/interproscan/interproscan-5.36-75.0")
    The directory path that contains the interproscan.sh script installed on the cluster server.

*protein-min-length* [integer] (default: 30)
    The minimum length of the open reading frames that are used by InterProscan. DiFlex only uses a single longest ORF for every Trinity isoform.

*analyses* [list] 
    A list with all the analyses that are to be performed by InterProscan. Not all analyses can be used due to the cluster using an older version of InterProscan.
    These analyses are: PANTHER, MOBIDB, PROSITEPATTERNS and PROSITEPROFILES.
