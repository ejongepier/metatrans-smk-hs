#!/bin/bash
#SBATCH -n 1
#SBATCH --cpus-per-task 16 
#SBATCH --mem=20GB
#SBATCH --job-name=trinity_deg_edgeR
#SBATCH --output=../slurm_logs/%x/%x_%u_%A_%a.out
#SBATCH --error=../slurm_logs/%x/%x_%u_%A_%a.error

source ~/.bashrc 
conda activate sponge2

INPUT_DIR_TRANSCRIPTS=/zfs/omics/projects/spongeomics/data/trinity_results/assembly_results/trinity_combined_results
INPUT_DIR_SAMPLES=/zfs/omics/projects/spongeomics/data/trinity_results/differential_expression_results/trinity_deg_Haliclona
OUTPUT_DIR=/zfs/omics/projects/spongeomics/data/trinity_results/differential_expression_results/trinity_deg_Haliclona/edgeR

echo "using the following directories:"
echo "input transcripts: $INPUT_DIR_TRANSCRIPTS"
echo "input samples: $INPUT_DIR_SAMPLES"
echo "output: $OUTPUT_DIR"

cd $OUTPUT_DIR

srun /zfs/omics/projects/spongeomics/git/sara-campana/inst/trinityrnaseq-v2.9.0/util/abundance_estimates_to_matrix.pl --est_method RSEM --out_prefix Hvansoes_final --gene_trans_map $INPUT_DIR_TRANSCRIPTS/trinity_Haliclona.Trinity.fasta.gene_trans_map  --name_sample_by_basedir $INPUT_DIR_SAMPLES/MA6_1/RSEM.isoforms.results $INPUT_DIR_SAMPLES/MA6_2/RSEM.isoforms.results $INPUT_DIR_SAMPLES/MA6_3/RSEM.isoforms.results $INPUT_DIR_SAMPLES/CO6_4/RSEM.isoforms.results $INPUT_DIR_SAMPLES/CO6_6/RSEM.isoforms.results $INPUT_DIR_SAMPLES/CO6_8/RSEM.isoforms.results $INPUT_DIR_SAMPLES/DI3_10/RSEM.isoforms.results $INPUT_DIR_SAMPLES/DI3_11/RSEM.isoforms.results $INPUT_DIR_SAMPLES/DI3_12/RSEM.isoforms.results

#Matrix Isoforms
srun /zfs/omics/projects/spongeomics/git/sara-campana/inst/trinityrnaseq-v2.9.0/Analysis/DifferentialExpression/run_DE_analysis.pl --matrix Hvansoes_final.isoform.counts.matrix --method edgeR --samples_file /zfs/omics/projects/spongeomics/git/sara-campana/fa/Hvan_sample_file.txt --output edgeR_isoforms

#Matrix Genes
srun /zfs/omics/projects/spongeomics/git/sara-campana/inst/trinityrnaseq-v2.9.0/Analysis/DifferentialExpression/run_DE_analysis.pl --matrix Hvansoes_final.gene.counts.matrix --method edgeR --samples_file /zfs/omics/projects/spongeomics/git/sara-campana/fa/Hvan_sample_file.txt --output edgeR_genes


##Move to edgeR directories (one for the genes and one for the isoforms) and run the following in the appropriate folder

cd /zfs/omics/projects/spongeomics/data/trinity_results/differential_expression_results/trinity_deg_Haliclona/edgeR/edgeR_isoforms

#Heatmap isoforms
/zfs/omics/projects/spongeomics/git/sara-campana/inst/trinityrnaseq-v2.9.0/Analysis/DifferentialExpression/analyze_diff_expr.pl --matrix /zfs/omics/projects/spongeomics/data/trinity_results/differential_expression_results/trinity_deg_Haliclona/edgeR/Hvansoes_final.isoform.TMM.EXPR.matrix -P 1e-3 -C 2 --samples /zfs/omics/projects/spongeomics/git/sara-campana/fa/Hvan_sample_file.txt

#PCA isoforms
/zfs/omics/projects/spongeomics/git/sara-campana/inst/trinityrnaseq-v2.9.0/Analysis/DifferentialExpression/PtR --matrix /zfs/omics/projects/spongeomics/data/trinity_results/differential_expression_results/trinity_deg_Haliclona/edgeR/Hvansoes_final.isoform.TMM.EXPR.matrix --samples /zfs/omics/projects/spongeomics/git/sara-campana/fa/Hvan_sample_file.txt --log2 --prin_comp 3

cd /zfs/omics/projects/spongeomics/data/trinity_results/differential_expression_results/trinity_deg_Haliclona/edgeR/edgeR_genes

#Heatmap genes
/zfs/omics/projects/spongeomics/git/sara-campana/inst/trinityrnaseq-v2.9.0/Analysis/DifferentialExpression/analyze_diff_expr.pl --matrix /zfs/omics/projects/spongeomics/data/trinity_results/differential_expression_results/trinity_deg_Haliclona/edgeR/Hvansoes_final.gene.TMM.EXPR.matrix -P 1e-3 -C 2 --samples /zfs/omics/projects/spongeomics/git/sara-campana/fa/Hvan_sample_file.txt

#PCA genes
/zfs/omics/projects/spongeomics/git/sara-campana/inst/trinityrnaseq-v2.9.0/Analysis/DifferentialExpression/PtR --matrix /zfs/omics/projects/spongeomics/data/trinity_results/differential_expression_results/trinity_deg_Haliclona/edgeR/Hvansoes_final.gene.TMM.EXPR.matrix --samples /zfs/omics/projects/spongeomics/git/sara-campana/fa/Hvan_sample_file.txt --log2 --prin_comp 3

