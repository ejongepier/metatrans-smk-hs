#!/bin/bash

#SBATCH --job-name=DiFlex

#SBATCH --ntasks=1
#SBATCH --cpus-per-task=32
#SBATCH --time=120:00:00
#SBATCH --mem=400000

##SBATCH --mailtype=END,FAIL,TIME_LIMIT
##SBATCH --mail-user

#Start tijd in seconden
START=`date +"%Y%m%dT%H%M%S"`
echo "$SLURM_JOB_NAME started at $START on node $SLURM_NODEID using $SLURM_CPUS_ON_NODE cpus."

OUTDIR=/zfs/omics/personal/$USER/DiFlex/
#Conda init
source ~/personal/miniconda3/etc/profile.d/conda.sh

#Conda activatie
conda_env='/zfs/omics/personal/$USER/miniconda3/envs/snakemake'
init_cmd="conda activate $conda_env"
eval $init_cmd

#Setup scratch folder vars
RUNDIR=/scratch/$USER/$START/
TMPDIR=/scratch/$USER/tmp/$START/

srun mkdir -p $RUNDIR
srun mkdir -p $TMPDIR

#Copy pipeline to scratch
echo "Copying pipeline data"
srun cp -fr '/zfs/omics/personal/$USER/DiFlex/metatrans-smk-hs/' $RUNDIR
echo "Done Copying"

#DiFlex pipeline command
cmd="srun --cores $SLURM_CPUS_ON_NODE snakemake --use-conda --cores $SLURM_CPUS_ON_NODE --nolock --rerun-incomplete --directory $RUNDIR --resources mem_mb=$SLURM_MEM_PER_NODE tmpdir=$TMPDIR"
eval $cmd

#DiFlex generate report
cmd="srun snakemake --report reports/DiFLex_report_`date "+%Y%m%dT%H%M"`.zip"
eval $cmd

#Copy results back to USER
srun cp -fr $RUNDIR $OUTDIR

#Delete the scratch folder
srun rm -fr $TMPDIR
srun rm -fr $RUNDIR

#Eindtijd in seconde en runtime
END= `date +"%Y%m%dT%H%M%S"`
echo "$SLURM_JOB_NAME finished at $END"