#!/bin/bash
#SBATCH -n 1
#SBATCH --cpus-per-task 16 
#SBATCH --mem=20GB
#SBATCH --job-name=sortmerna
#SBATCH --output=../slurm_logs/%x/%x_%u_%A_%a.out
#SBATCH --error=../slurm_logs/%x/%x_%u_%A_%a.error

#Define runtime measurement 
start=`date +%s`

source ~/.bashrc 
conda activate sponge2

DB_DIR=/zfs/omics/projects/spongeomics/download/sortmerna-master/data/rRNA_databases
IN_DIR=/zfs/omics/projects/spongeomics/data/trimmomatic_results/Plakortis
OUT_DIR=/zfs/omics/projects/spongeomics/data/sortmerna_results/Plakortis

echo "using the following directories:"
echo "input: $IN_DIR"
echo "output: $OUT_DIR"

for read in $IN_DIR/MA_*_paired.fq; do
readb=$(basename $read)
prefix=${readb/_paired.fq/}
echo $readb
echo $prefix

rm -rf /zfs/omics/projects/spongeomics/sortmernawork_Plakortis_MA
srun sortmerna --ref $DB_DIR/silva-bac-16s-id90.fasta --ref $DB_DIR/silva-bac-23s-id98.fasta --ref $DB_DIR/silva-arc-16s-id95.fasta --ref $DB_DIR/silva-arc-23s-id98.fasta --ref $DB_DIR/silva-euk-18s-id95.fasta --ref $DB_DIR/silva-euk-28s-id98.fasta --ref $DB_DIR/rfam-5s-database-id98.fasta --ref $DB_DIR/rfam-5.8s-database-id98.fasta --reads $IN_DIR/${readb}  --num_alignments 1 --fastx --blast 0 --aligned $OUT_DIR/${prefix}_rRNA --other $OUT_DIR/${prefix}_clean -v --threads $SLURM_CPUS_PER_TASK --workdir /zfs/omics/projects/spongeomics/sortmernawork_Plakortis_MA

done

echo "Done"
end=`date +%s`
runtime=$((end-start))
echo "Runtime: '$runtime'"
