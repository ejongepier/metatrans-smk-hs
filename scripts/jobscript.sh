#!/bin/bash

#SBATCH --job-name=DiFlex

#SBATCH --ntasks=1
#SBATCH --cpus-per-task=32
#SBATCH --time=1000
#SBATCH --mem=128000

##SBATCH --mailtype=END,FAIL,TIME_LIMIT
##SBATCH --mail-user

#Start tijd in seconden
start='date "+%s"'
echo "$SLURM_JOB_NAME started at `date` on node $SLURM_NODEID using $SLURM_CPUS_ON_NODE cpus."

#Conda init
source /zfs/omics/personal/$USER/miniconda3/etc/profile.d/conda.sh
#Conda activatie
conda_env='/zfs/omics/personal/$USER/miniconda3/envs/snakemake'
init_cmd="conda activate $conda_env"
eval $init_cmd


#DiFlex pipeline command
cmd="srun --cores $SLURM_CPUS_ON_NODE snakemake --use-conda --cores $SLURM_CPUS_ON_NODE --nolock --rerun-incomplete --resources mem_mb=$SLURM_MEM_PER_NODE"
eval $cmd


#DiFlex generate report
cmd="srun snakemake --report reports/DiFLex_report_`date "+%Y%m%dT%H%M"`.zip"
eval $cmd


#Eindtijd in seconde en runtime
end='date "+%s"'
runtime=$((end-start))
echo "$SLURM_JOB_NAME finished at `date` in $runtime seconds."