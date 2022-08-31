.. DiFlex documentation master file, created by
   sphinx-quickstart on Sat Jun 25 11:22:04 2022.
   You can adapt this file completely to your liking, but it should at least
   contain the root `toctree` directive.

DiFlex
========

DiFlex is a meta-transcriptomics pipeline for Illumina sequenced data. A single command is used to install the required programs, 
run all processes, manage the created files and distributes the computational resources between processes.

The pipeline consists of the following steps. Filtering of RNA to include only mRNA. Assembly of a metatranscriptome and the alignment of the reads to it. 
A differential expression analysis and functional annotation and enrichment of proteins.

Quick start
----------------------------------
Clone the DiFlex repository using the following command.

.. code-block:: console

   git clone https://github.com/ejongepier/metatrans-smk-hs

Or download and extract the zip archive from https://github.com/ejongepier/metatrans-smk-hs

The DiFlex immediately pipeline is ready for use on both local computers and cluster servers

Enter your input samples into the samples.csv file. This file definies the relation between your samples, condition and input reads.
The group defines the species of your samples. The sample name must be unique per sample. The fow and rev contain the path to 
the fastQ files of both the forward and reverse reads. The run can be used to seperate the results of different analysis.

The pipeline can be run by using this command.

.. code-block:: console

   snakemake --use-conda --cores <ncores> --resources mem_mb=<amount_memory>

Where ncores is the amount of CPU cores to be dedicated to running the pipeline and amount_memory is how 
much RAM can be used in the pipeline, defined in Megabytes (Mb).

To generate a report describing the process executed by the pipeline and containing the generated results, the following command is used.

.. code-block:: console

   snakemake --report reports/DiFlex_report.zip 


Documentation
==================================
.. toctree::
   :maxdepth: 2
   :caption: Contents:

   objective
   getting_started
   parameters
   pipeline
   results


Indices and tables
==================

* :ref:`genindex`
* :ref:`modindex`
* :ref:`search`
