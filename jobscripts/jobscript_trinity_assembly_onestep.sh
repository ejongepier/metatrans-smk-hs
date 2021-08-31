#!/bin/bash
#SBATCH -n 1
#SBATCH --cpus-per-task 16
#SBATCH --mem=250GB
#SBATCH --job-name=trinity_assembly_onestep
#SBATCH --output=../slurm_logs/%x/%x_%u_%A_%a.out
#SBATCH --error=../slurm_logs/%x/%x_%u_%A_%a.error

source ~/.bashrc #because we cannot activate conda
conda activate /zfs/omics/projects/spongeomics/miniconda3/envs/sponge

INPUT_DIR=/zfs/omics/projects/spongeomics/data/trimmomatic_results/Haliclona
OUTPUT_DIR=/zfs/omics/projects/spongeomics/data/trinity_results/assembly_results/trinity_combined_results

echo "using the following directories:"
echo "input: $INPUT_DIR"
echo "output: $OUTPUT_DIR"

srun Trinity --normalize_reads --seqType fq --max_memory 250G --left $INPUT_DIR/CO6_4_I26438_R1_paired.fq.gz,$INPUT_DIR/CO6_6_I26433_R1_paired.fq.gz,$INPUT_DIR/CO6_8_I26429_R1_paired.fq.gz,$INPUT_DIR/DI3_10_I26428_R1_paired.fq.gz,$INPUT_DIR/DI3_11_I26441_R1_paired.fq.gz,$INPUT_DIR/DI3_12_I26436_R1_paired.fq.gz,$INPUT_DIR/MA6_1_I26442_R1_paired.fq.gz,$INPUT_DIR/MA6_2_I26426_R1_paired.fq.gz,$INPUT_DIR/MA6_3_I26432_R1_paired.fq.gz --right $INPUT_DIR/CO6_4_I26438_R2_paired.fq.gz,$INPUT_DIR/CO6_6_I26433_R2_paired.fq.gz,$INPUT_DIR/CO6_8_I26429_R2_paired.fq.gz,$INPUT_DIR/DI3_10_I26428_R2_paired.fq.gz,$INPUT_DIR/DI3_11_I26441_R2_paired.fq.gz,$INPUT_DIR/DI3_12_I26436_R2_paired.fq.gz,$INPUT_DIR/MA6_1_I26442_R2_paired.fq.gz,$INPUT_DIR/MA6_2_I26426_R2_paired.fq.gz,$INPUT_DIR/MA6_3_I26432_R2_paired.fq.gz --output $OUTPUT_DIR/trinity_Haliclona --CPU $SLURM_CPUS_PER_TASK --full_cleanup --inchworm_cpu $SLURM_CPUS_PER_TASK --bflyHeapSpaceMax 15G --bflyCalculateCPU --min_kmer_cov 2


