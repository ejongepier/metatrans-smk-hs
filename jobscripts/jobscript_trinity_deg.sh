#!/bin/bash
#SBATCH -n 1
#SBATCH --cpus-per-task 16 
#SBATCH --mem=20GB
#SBATCH --job-name=trinity_deg
#SBATCH --output=../slurm_logs/%x/%x_%u_%A_%a.out
#SBATCH --error=../slurm_logs/%x/%x_%u_%A_%a.error

source ~/.bashrc 
conda activate sponge2


INPUT_DIR=/zfs/omics/projects/spongeomics/data/trinity_results/assembly_results/trinity_combined_results
OUTPUT_DIR=/zfs/omics/projects/spongeomics/data/trinity_results/differential_expression_results/trinity_deg_Haliclona

echo "using the following directories:"
echo "input: $INPUT_DIR"
echo "output: $OUTPUT_DIR"

srun /zfs/omics/projects/spongeomics/git/sara-campana/inst/trinityrnaseq-v2.9.0/util/align_and_estimate_abundance.pl --transcripts $INPUT_DIR/trinity_Haliclona.Trinity.fasta --est_method RSEM --aln_method bowtie2 --trinity_mode --prep_reference --output_dir $OUTPUT_DIR/prep_ref
