#!/bin/bash

#SBATCH --job-name=DiFlex
#SBATCH --mailtype=END,FAIL,TIME_LIMIT
#SBATCH --mail-user

#SBATCH --ntasks=1
#SBATCH --cpus-per-task=32
#SBATCH --time=1000
#SBATCH --mem=120G

#Start tijd in seconden
start='date "+%s"'
echo "$SLURM_JOB_NAME started at `date` on node $SLURM_NODEID using $SLURM_CPUS_ON_NODE cpus."


#Conda initialize
__conda_setup="$('/home/$USER/personal/miniconda3/bin/conda' 'shell.bash' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "/home/$USER/personal/miniconda3/etc/profile.d/conda.sh" ]; then
        . "/home/$USER/personal/miniconda3/etc/profile.d/conda.sh"
    else
        export PATH="/home/$USER/personal/miniconda3/bin:$PATH"
    fi
fi
unset __conda_setup


#Conda activatie
conda_env='/zfs/omics/projects/amplicomics/miniconda3/envs/snakemake-ampl'
init_cmd="conda activate $conda_env"
eval $init_cmd


#DiFlex pipeline command
cmd="srun --cores $SLURM_CPUS_ON_NODE snakemake --use-conda --cores $SLURM_CPUS_ON_NODE --nolock --rereun-incomplete"
eval $cmd


#DiFlex generate report
cmd="srun snakemake --report reports/DiFLex_report_`date "+%Y%m%dT%H%M"`.zip"
eval $cmd


#Eindtijd in seconde en runtime
end='date "+%s"'
runtime=$((end-start))
echo "$SLURM_JOB_NAME finished at `date` in $runtime seconds."