# INSTALL mtrans-smk-hs environment

## Setup the conda environment

``` bash
conda create -y -n mtrans-smk-hs
conda activate mtrans-smk-hs
```

## Install packages

```bash
conda install -c bioconda -y trinity
conda install -c bioconda -y sortmerna
conda install -c bioconda -y rsem
```

## Fix dependencey clashes

Rsem installs R v 3.2.2 which cause problems with readline.
Solution: Upgrade R and install r packages

``` bash
conda update -y r-base
conda install -y -c bioconda bioconductor-edger
conda install -y libopenblas==0.3.7
conda install -y -c bioconda bioconductor-biobase
conda install -y -c bioconda bioconductor-qvalue
conda install -y -c conda-forge r-fastcluster
conda install -y -c r r-cluster
```

Note: See mtrans-smk-hs.yaml and mtrans-smk-hs-from-history.yaml for program versions etc.
Note ``conda create -f mtrans-smk-hs`` does not work - hangs at solving environment.
Instead use walkthorugh in this INSTALL.md. 
