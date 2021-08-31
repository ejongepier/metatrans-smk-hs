#!/bin/bash
#SBATCH -n 1
#SBATCH --cpus-per-task 16
#SBATCH --mem=100GB
#SBATCH --job-name=trinity_assembly
#SBATCH --output=../slurm_logs/%x/%x_%u_%A_%a.out
#SBATCH --error=../slurm_logs/%x/%x_%u_%A_%a.error

source ~/.bashrc
conda activate /zfs/omics/projects/spongeomics/miniconda3/envs/sponge

INPUT_DIR=/zfs/omics/projects/spongeomics/data/trinity_results/assembly_results/trinity_step_1_results
OUTPUT_DIR=/zfs/omics/projects/spongeomics/data/trinity_results/assembly_results/trinity_step_2_results

echo "using the following directories:"
echo "input: $INPUT_DIR"
echo "output: $OUTPUT_DIR"

srun Trinity --seqType fq --no_normalize_reads --max_memory 100G --left $INPUT_DIR/CO6_4_I26438_R1_paired.fq.gz_ext_all_reads.normalized_K25_maxC50_minC0_maxCV10000.fq --right $INPUT_DIR/CO6_4_I26438_R2_paired.fq.gz_ext_all_reads.normalized_K25_maxC50_minC0_maxCV10000.fq --output $OUTPUT_DIR/trinity_Haliclona --CPU $SLURM_CPUS_PER_TASK --full_cleanup --inchworm_cpu $SLURM_CPUS_PER_TASK --bflyHeapSpaceMax 15G --bflyCalculateCPU --min_kmer_cov 2


