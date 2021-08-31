#!/bin/bash
#SBATCH -n 1
#SBATCH --cpus-per-task 16
#SBATCH --mem=20GB
#SBATCH --job-name=diamond_blast
#SBATCH --output=../slurm_logs/%x/%x_%u_%A_%a.out
#SBATCH --error=../slurm_logs/%x/%x_%u_%A_%a.error

source ~/.bashrc 
conda activate /zfs/omics/projects/spongeomics/miniconda3/envs/sponge

INPUT_DIR=/zfs/omics/projects/spongeomics/data/trinity_results/assembly_results/trinity_combined_results
OUTPUT_DIR=/zfs/omics/projects/spongeomics/data/diamond_results/Haliclona
DB_DIR=/zfs/omics/projects/spongeomics/download/uniprot-db

echo "using the following directories:"
echo "input: $INPUT_DIR"
echo "output: $OUTPUT_DIR"
echo "db: $DB_DIR"

#.daa Output
srun diamond blastx --query $INPUT_DIR/trinity_Haliclona.Trinity.fasta --db $DB_DIR/uniprot_sprot.dmnd --evalue 0.001 --out $OUTPUT_DIR/Trinity_Haliclona_sprot.daa --threads $SLURM_CPUS_PER_TASK --top 10 --outfmt 100 --more-sensitive --salltitles --sallseqid --unal 1
#.txt Output
srun diamond blastx --query $INPUT_DIR/trinity_Haliclona.Trinity.fasta --db $DB_DIR/uniprot_sprot.dmnd --evalue 0.001 --out $OUTPUT_DIR/Trinity_Haliclona_sprot.txt --outfmt 6 --threads $SLURM_CPUS_PER_TASK --top 10 --more-sensitive --salltitles --sallseqid --unal 1
#.xml Output
srun diamond blastx --query $INPUT_DIR/trinity_Haliclona.Trinity.fasta --db $DB_DIR/uniprot_sprot.dmnd --evalue 0.001 --out $OUTPUT_DIR/Trinity_Haliclona_sprot.xml --outfmt 5 --threads $SLURM_CPUS_PER_TASK --top 10 --more-sensitive --salltitles --sallseqid --unal 1
#Swissprot prokaryota
srun diamond blastx --query $INPUT_DIR/trinity_Haliclona.Trinity.fasta --db $DB_DIR/uniprot_sprot-prokaryota.dmnd --evalue 0.001 --out $OUTPUT_DIR/Trinity_Haliclona_sw_prokaryota.xml --outfmt 5 --threads $SLURM_CPUS_PER_TASK --top 10 --more-sensitive --salltitles --sallseqid --unal 1
#Swissprot metazoan
srun diamond blastx --query $INPUT_DIR/trinity_Haliclona.Trinity.fasta --db $DB_DIR/uniprot_sprot-metazoa.dmnd --evalue 0.001 --out $OUTPUT_DIR/Trinity_Haliclona_sw_metazoa.xml --outfmt 5 --threads $SLURM_CPUS_PER_TASK --top 10 --more-sensitive --salltitles --sallseqid --unal 1

