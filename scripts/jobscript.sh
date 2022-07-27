 #!/bin/bash

#SBATCH --job-name=DiFlex

#SBATCH --ntasks=1
#SBATCH --cpus-per-task=32
#SBATCH --time=120:00:00
#SBATCH --mem=230000
#SBATCH --nodes=1

##SBATCH --mailtype=END,FAIL,TIME_LIMIT
##SBATCH --mail-user

#Start tijd in seconden
START=`date +"%Y%m%dT%H%M%S"`
echo "$SLURM_JOB_NAME started at $START on node $SLURM_NODEID using $SLURM_CPUS_ON_NODE cpus."


startdir=$(pwd)
cd "${0%/*}"
head -n 2 ../config.yaml | sed '/^[[:space:]]*$/d' | sed 's/:\s*/=/' > ../config.tmp
source ../config.tmp
cd $startdir

echo $condaenv_path
echo $snakefile_path

#Conda init
source ~/personal/miniconda3/etc/profile.d/conda.sh

#Conda activatie
#conda_env="/zfs/omics/personal/$USER/miniconda3/envs/snakemake"
init_cmd="conda activate $condaenv_path"
eval $init_cmd

#Setup scratch folder vars
RUNDIR="/scratch/$USER/snakemake/"
export TMPDIR="/scratch/$USER/tmp/"

srun mkdir -p $RUNDIR
srun mkdir -p $TMPDIR

#Copy pipeline to scratch
echo "Copying pipeline data"
srun cp -fr $snakefile_path/* $RUNDIR
#srun cp -fr "/zfs/omics/personal/$USER/DiFlex/metatrans-smk-hs/*" $RUNDIR
echo "Done copying pipeline data"

#Copy input data to folder
#echo "copying input data"
#srun cp -fr "/zfs/omics/personal/$USER/workflow-input-data/*" $INDIR
#echo "Done copying input data"

#DiFlex pipeline command
cmd="srun snakemake -useconda --snakefile $RUNDIR/Snakefile --cores $SLURM_CPUS_ON_NODE --directory $RUNDIR --nolock --ri -n --resources mem_mb=$SLURM_MEM_PER_NODE"
echo "running: $cmd"
eval $cmd

#if [ $? -eq 0 ]; then
#    #DiFlex generate report
#    cmd="srun snakemake --snakefile $RUNDIR/Snakefile --directory $RUNDIR --report reports/DiFLex_report.zip"
#    echo "running: $cmd"
#    eval $cmd
#else
#    echo "An error has occured. The report will not be generated."
#fi

if [ $? -eq 0 ]; then
    #Copy results back to USER
    echo "Copying back result data"
    srun cp -f $RUNDIR/reports/DiFlex_report.zip $snakefile_path/reports/
    for run in $RUNDIR/results/*; do
        srun cp -fr $RUNDIR/results/$run/fastqc $snakefile_path/results/$run/
        srun cp -fr $RUNDIR/results/$run/trimmomatic/*.R1.paired.fastq.gz $snakefile_path/results/$run/trimmomatic/
        srun cp -fr $RUNDIR/results/$run/trimmomatic/*.R2.paired.fastq.gz $snakefile_path/results/$run/trimmomatic/
        for sample in $RUNDIR/results/sortmerna/*; do
            srun cp -f $RUNDIR/results/$run/sortmerna/$sample/paired_*.fq.gz $snakefile_path/results/$run/sortmerna/$sample/
            srun cp -fr $RUNDIR/results/$run/sortmerna/$sample/out $snakefile_path/results/$run/sortmerna/$sample/
        done
        srun cp -fr $RUNDIR/results/$run/trinity_output/trinity_de/ $snakefile_path/results/$run/trinity_output/
        srun cp -f $RUNDIR/results/$run/trinity_output/trinity_assemble.Trinity.fasta $snakefile_path/results/$run/trinity_output/
        srun cp -f $RUNDIR/results/$run/trinity_output/trinity_assemble.Trinity.fasta.gene_trans_map $snakefile_path/results/$run/trinity_output/
        srun cp -fr $RUNDIR/results/$run/plots/ $snakefile_path/results/$run/
    done
    echo "Copying complete"

    #Delete the scratch folder
    echo "Deleting scratch folders"
    srun rm -fr $TMPDIR
    srun rm -fr $RUNDIR
    echo "Scratch folders deleted"
else
    echo "An error has occured running the pipeline. Scratch data has not been deleted so that the pipeline can be restarted. Use the node ID: $SLURM_JOB_NODELIST when rerunning the pipeline."
fi

#Eindtijd in seconde en runtime
echo "$SLURM_JOB_NAME finished"
