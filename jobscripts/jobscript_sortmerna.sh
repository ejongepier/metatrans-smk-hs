#!/bin/bash
#SBATCH -n 1
#SBATCH --cpus-per-task 16
#SBATCH --mem=20GB
#SBATCH --job-name=sortmerna #remeber to create this folder in the slurm_logs directory beforehand
#SBATCH --output=../slurm_logs/%x/%x_%u_%A_%a.out
#SBATCH --error=../slurm_logs/%x/%x_%u_%A_%a.error

source ~/.bashrc 
conda activate /zfs/omics/projects/spongeomics/miniconda3/envs/sponge

DB_DIR=/zfs/omics/projects/spongeomics/download/sortmerna-master/data/rRNA_databases
IN_DIR=/zfs/omics/projects/spongeomics/data/trimmomatic_results/Haliclona
OUT_DIR=/zfs/omics/projects/spongeomics/data/sortmerna_results

echo "using the following directories:"
echo "input: $INPUT_DIR"
echo "output: $OUTPUT_DIR"

srun sortmerna --ref $DB_DIR/silva-bac-16s-id90.fasta --ref $DB_DIR/silva-bac-23s-id98.fasta --ref $DB_DIR/silva-arc-16s-id95.fasta --ref $DB_DIR/silva-arc-23s-id98.fasta --ref $DB_DIR/silva-euk-18s-id95.fasta --ref $DB_DIR/silva-euk-28s-id98.fasta --ref $DB_DIR/rfam-5s-database-id98.fasta --ref $DB_DIR/rfam-5.8s-database-id98.fasta --reads $IN_DIR/CO6_4_I26438_R1_paired.fq.gz  --num_alignments 1 --fastx --blast 0 --aligned $OUT_DIR/CO6_4_R1_ribo2 --other $OUT_DIR/CO6_4_R1_mess2 -v --workdir /zfs/omics/projects/spongeomics/sortmernawork/

srun sortmerna --ref $DB_DIR/silva-bac-16s-id90.fasta --ref $DB_DIR/silva-bac-23s-id98.fasta --ref $DB_DIR/silva-arc-16s-id95.fasta --ref $DB_DIR/silva-arc-23s-id98.fasta --ref $DB_DIR/silva-euk-18s-id95.fasta --ref $DB_DIR/silva-euk-28s-id98.fasta --ref $DB_DIR/rfam-5s-database-id98.fasta --ref $DB_DIR/rfam-5.8s-database-id98.fasta --reads $IN_DIR/DI3_10_I26428_R1_paired.fq.gz  --num_alignments 1 --fastx --blast 0 --aligned $OUT_DIR/DI3_10_R1_ribo2 --other $OUT_DIR/DI3_10_R1_mess2 -v --workdir /zfs/omics/projects/spongeomics/sortmernawork/

srun sortmerna --ref $DB_DIR/silva-bac-16s-id90.fasta --ref $DB_DIR/silva-bac-23s-id98.fasta --ref $DB_DIR/silva-arc-16s-id95.fasta --ref $DB_DIR/silva-arc-23s-id98.fasta --ref $DB_DIR/silva-euk-18s-id95.fasta --ref $DB_DIR/silva-euk-28s-id98.fasta --ref $DB_DIR/rfam-5s-database-id98.fasta --ref $DB_DIR/rfam-5.8s-database-id98.fasta --reads $IN_DIR/MA6_1_I26442_R1_paired.fq.gz  --num_alignments 1 --fastx --blast 0 --aligned $OUT_DIR/MA6_1_R1_ribo2 --other $OUT_DIR/MA6_1_R1_mess2 -v --workdir /zfs/omics/projects/spongeomics/sortmernawork/

