#!/bin/bash
#SBATCH -n 1
#SBATCH --cpus-per-task 16 
#SBATCH --mem=20GB
#SBATCH --job-name=trinity_deg_samples
#SBATCH --output=../slurm_logs/%x/%x_%u_%A_%a.out
#SBATCH --error=../slurm_logs/%x/%x_%u_%A_%a.error

source ~/.bashrc 
conda activate sponge2

INPUT_DIR_TRANSCRIPTS=/zfs/omics/projects/spongeomics/data/trinity_results/assembly_results/trinity_combined_results
INPUT_DIR_SAMPLES=/zfs/omics/projects/spongeomics/data/trimmomatic_results/Haliclona
OUTPUT_DIR=/zfs/omics/projects/spongeomics/data/trinity_results/differential_expression_results/trinity_deg_Haliclona

echo "using the following directories:"
echo "input transcripts: $INPUT_DIR_TRANSCRIPTS"
echo "input samples: $INPUT_DIR_SAMPLES"
echo "output: $OUTPUT_DIR"

srun /zfs/omics/projects/spongeomics/git/sara-campana/inst/trinityrnaseq-v2.9.0/util/align_and_estimate_abundance.pl --transcripts $INPUT_DIR_TRANSCRIPTS/trinity_Haliclona.Trinity.fasta --seqType fq --left $INPUT_DIR_SAMPLES/CO6_4_I26438_R1_paired.fq.gz --right $INPUT_DIR_SAMPLES/CO6_4_I26438_R2_paired.fq.gz --prep_reference --est_method RSEM --aln_method bowtie2 --trinity_mode --output_dir $OUTPUT_DIR/CO6_4

#srun /zfs/omics/projects/spongeomics/git/sara-campana/inst/trinityrnaseq-v2.9.0/util/align_and_estimate_abundance.pl --transcripts $INPUT_DIR_TRANSCRIPTS/trinity_Haliclona.Trinity.fasta --seqType fq --left $INPUT_DIR_SAMPLES/CO6_6_I26433_R1_paired.fq.gz --right $INPUT_DIR_SAMPLES/CO6_6_I26433_R2_paired.fq.gz --prep_reference --est_method RSEM --aln_method bowtie2 --trinity_mode --output_dir $OUTPUT_DIR/CO6_6

#srun /zfs/omics/projects/spongeomics/git/sara-campana/inst/trinityrnaseq-v2.9.0/util/align_and_estimate_abundance.pl --transcripts $INPUT_DIR_TRANSCRIPTS/trinity_Haliclona.Trinity.fasta --seqType fq --left $INPUT_DIR_SAMPLES/CO6_8_I26429_R1_paired.fq.gz --right $INPUT_DIR_SAMPLES/CO6_8_I26429_R2_paired.fq.gz --prep_reference --est_method RSEM --aln_method bowtie2 --trinity_mode --output_dir $OUTPUT_DIR/CO6_8

#srun /zfs/omics/projects/spongeomics/git/sara-campana/inst/trinityrnaseq-v2.9.0/util/align_and_estimate_abundance.pl --transcripts $INPUT_DIR_TRANSCRIPTS/trinity_Haliclona.Trinity.fasta --seqType fq --left $INPUT_DIR_SAMPLES/DI3_10_I26428_R1_paired.fq.gz --right $INPUT_DIR_SAMPLES/DI3_10_I26428_R2_paired.fq.gz --prep_reference --est_method RSEM --aln_method bowtie2 --trinity_mode --output_dir $OUTPUT_DIR/DI3_10

#srun /zfs/omics/projects/spongeomics/git/sara-campana/inst/trinityrnaseq-v2.9.0/util/align_and_estimate_abundance.pl --transcripts $INPUT_DIR_TRANSCRIPTS/trinity_Haliclona.Trinity.fasta --seqType fq --left $INPUT_DIR_SAMPLES/DI3_11_I26441_R1_paired.fq.gz --right $INPUT_DIR_SAMPLES/DI3_11_I26441_R2_paired.fq.gz --prep_reference --est_method RSEM --aln_method bowtie2 --trinity_mode --output_dir $OUTPUT_DIR/DI3_11

#srun /zfs/omics/projects/spongeomics/git/sara-campana/inst/trinityrnaseq-v2.9.0/util/align_and_estimate_abundance.pl --transcripts $INPUT_DIR_TRANSCRIPTS/trinity_Haliclona.Trinity.fasta --seqType fq --left $INPUT_DIR_SAMPLES/DI3_12_I26436_R1_paired.fq.gz --right $INPUT_DIR_SAMPLES/DI3_12_I26436_R2_paired.fq.gz --prep_reference --est_method RSEM --aln_method bowtie2 --trinity_mode --output_dir $OUTPUT_DIR/DI3_12

#srun /zfs/omics/projects/spongeomics/git/sara-campana/inst/trinityrnaseq-v2.9.0/util/align_and_estimate_abundance.pl --transcripts $INPUT_DIR_TRANSCRIPTS/trinity_Haliclona.Trinity.fasta --seqType fq --left $INPUT_DIR_SAMPLES/MA6_1_I26442_R1_paired.fq.gz --right $INPUT_DIR_SAMPLES/MA6_1_I26442_R2_paired.fq.gz --prep_reference --est_method RSEM --aln_method bowtie2 --trinity_mode --output_dir $OUTPUT_DIR/MA6_1

#srun /zfs/omics/projects/spongeomics/git/sara-campana/inst/trinityrnaseq-v2.9.0/util/align_and_estimate_abundance.pl --transcripts $INPUT_DIR_TRANSCRIPTS/trinity_Haliclona.Trinity.fasta --seqType fq --left $INPUT_DIR_SAMPLES/MA6_2_I26426_R1_paired.fq.gz --right $INPUT_DIR_SAMPLES/MA6_2_I26426_R2_paired.fq.gz --prep_reference --est_method RSEM --aln_method bowtie2 --trinity_mode --output_dir $OUTPUT_DIR/MA6_2

#srun /zfs/omics/projects/spongeomics/git/sara-campana/inst/trinityrnaseq-v2.9.0/util/align_and_estimate_abundance.pl --transcripts $INPUT_DIR_TRANSCRIPTS/trinity_Haliclona.Trinity.fasta --seqType fq --left $INPUT_DIR_SAMPLES/MA6_3_I26432_R1_paired.fq.gz --right $INPUT_DIR_SAMPLES/MA6_3_I26432_R2_paired.fq.gz --prep_reference --est_method RSEM --aln_method bowtie2 --trinity_mode --output_dir $OUTPUT_DIR/MA6_3


