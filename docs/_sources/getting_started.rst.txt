Getting started
=================

DiFlex can be run on a normal desktop for analysing smaller datasets, while 
large datasets can be analyzed using a cluster server with much more processing power.

The requirements for running the DiFlex pipeline are the conda package manager and snakemake 
itself, installed using conda.

Installing Conda
------------------
The full installation of Anaconda is large and unnecessary for our purpose so we will use miniconda instead. 
Miniconda contains everything needed to create enviroments and install packages. Detailed installation instructions can be found `here <https://conda.io/projects/conda/en/latest/user-guide/install/index.html>`.
You can download and install it using the following command

.. code-block:: console

    cd && wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh
    bash Miniconda3-latest-linux-x86_64.sh && rm Miniconda3-latest-Linux-x86_64

Follow the instructions given during installation and when you're finished you should run the following command to initialize conda.

.. code-block:: console

    source ~/.bashrc

Update your conda installation using:

.. code-block:: console

    conda update -y conda

Installing Snakemake
----------------------
Snakemake will be installed using conda. Since the default conda solver is slow we will install and use Mamba. 
Install mamba and create a snakemake enviroment using the following commands:

.. code-block:: console

    conda install -c conda-forge Mamba
    mamba create -c conda-forge -c bioconda -n snakemake snakemake=7.8.1

To activate this enviroment use this command:

.. code-block:: console

    conda activate snakemake

Installing DiFlex
-------------------
To install DiFlex, clone the repository using:

.. code-block:: console

    git clone https://github.com/ejongepier/metatrans-smk-hs

or download and extract the zip archive from https://github.com/ejongepier/metatrans-smk-hs

DiFlex can be run immediately using the snakemake enviroment.
