#!/bin/bash
#SBATCH -n 1
#SBATCH --cpus-per-task 16 
#SBATCH --mem=15GB
#SBATCH --job-name=trimmomatic
#SBATCH --output=../slurm_logs/%x/%x_%u_%A_%a.out
#SBATCH --error=../slurm_logs/%x/%x_%u_%A_%a.error

#Define runtime measurement 
start=`date +%s`

source ~/.bashrc
conda activate sponge2 

INPUT_DIR=/zfs/omics/projects/spongeomics/data/input/Halisarca
OUTPUT_DIR=/zfs/omics/projects/spongeomics/data/trimmomatic_results/Halisarca
ADAPTER_DIR=/zfs/omics/projects/spongeomics/git/sara-campana/fa
echo "using the following directories:"
echo "input: $INPUT_DIR"
echo "output: $OUTPUT_DIR"
echo "adapter: $ADAPTER_DIR"

for fwd in $INPUT_DIR/*_R1_*; do 
fwdb=$(basename $fwd) 
rev=${fwdb/_R1_001.fastq.gz/_R2_001.fastq.gz}
prefix=${fwdb/_R1_001.fastq.gz/}
echo $fwdb
echo $rev
echo $prefix 

srun trimmomatic PE -threads $SLURM_CPUS_PER_TASK -phred33 $INPUT_DIR/${fwdb} $INPUT_DIR/${rev} $OUTPUT_DIR/${prefix}_R1_paired.fq $OUTPUT_DIR/${prefix}_R1_unpaired.fq $OUTPUT_DIR/${prefix}_R2_paired.fq $OUTPUT_DIR/${prefix}_R2_unpaired.fq ILLUMINACLIP:$ADAPTER_DIR/ALL_adapters.fa:2:30:10 LEADING:3 TRAILING:3 SLIDINGWINDOW:4:28 MINLEN:36

done

echo "Done"
end=`date +%s`
runtime=$((end-start))
echo "Runtime: '$runtime'"
