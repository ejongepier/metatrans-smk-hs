#!/usr/bin/env bash

#if [ "$1" == "-h" ]; then
#  echo "Usage: bash `basename $0` 2>&1 | tee run-trinity-de.log"
#  exit 0
#fi

start=`date +%s`

#source ~/miniconda3/etc/profile.d/conda.sh
#conda activate mtrans-smk-hs

PARENT_DIR=$3
READ_DIR=${PARENT_DIR}"/results/$2/trimmomatic"
OUT_DIR=${PARENT_DIR}"/results/$2/trinity_output/trinity_de"

echo "Using the following directories:"
echo "  assembly directory: "$ASSEMBLY_DIR
echo "  read directory: "$READ_DIR
echo "  output directory: "$OUT_DIR

############################################

#for fwdpath in ${READ_DIR}/*.R1.paired.fastq.gz; do
#
#  fwd=$(basename $fwdpath)
#  rev=${fwd/.R1.paired.fastq.gz/.R2.paired.fastq.gz}
#  prefix=${fwd/.R1.paired.fastq.gz/}
#
#  echo date" Starting alignment and abundance estimates of "$prefix
#
#  align_and_estimate_abundance.pl \
#    --transcripts $1 \
#    --seqType fq \
#    --left $READ_DIR/$fwd \
#    --right $READ_DIR/$rev \
#    --prep_reference \
#    --est_method RSEM \
#    --aln_method bowtie2 \
#    --trinity_mode \
#    --output_dir $OUT_DIR/$prefix
#
#  echo date"  Finished alignment and abundance estimates of "$prefix

#done

############################################

echo date" Starting conversion of abundance estimates to matrix"

mkdir -p $OUT_DIR/edgeR-output
cd $OUT_DIR/edgeR-output/

ls $OUT_DIR/*/RSEM.isoforms.results > $OUT_DIR/isoform-file-paths.txt
ls $OUT_DIR/*/RSEM.genes.results > $OUT_DIR/genes-file-paths.txt

abundance_estimates_to_matrix.pl \
  --est_method RSEM \
  --out_prefix trinity-de \
  --gene_trans_map none \
  --name_sample_by_basedir \
  --quant_files $OUT_DIR/isoform-file-paths.txt

#cat $PARENT_DIR/results/demo/trinity_output/trinity_assemble/Trinity.fasta.gene_trans_map

abundance_estimates_to_matrix.pl \
  --est_method RSEM \
  --out_prefix trinity-de \
  --gene_trans_map $PARENT_DIR/results/demo/trinity_output/trinity_assemble/Trinity.fasta.gene_trans_map \
  --name_sample_by_basedir \
  --quant_files $OUT_DIR/genes-file-paths.txt

echo date" Finished conversion of abundance estimates to matrix"

############################################

echo date" Starting differential expression analysis"

#ls $READ_DIR/ | \
#  awk -F "_" -v OFS='_' '{print $1"\t"$1, $2, $3, $4}' | \
#  sort | uniq | egrep -r "R[1-2].paired.fastq.gz" > $OUT_DIR/edgeR-output/sample-file.txt
#cat $PARENT_DIR/samples.csv | awk -F "," '{print substr($2, 1, length($2)-4)"\t"$2}' | awk 'NR!=1 {print}' | sort | uniq > $OUT_DIR/edgeR-output/sample-file.txt

cat $PARENT_DIR/samples.csv | awk -F "," '{print $2"\t"$3}' | awk 'NR!=1 {print}' | sort | uniq > $OUT_DIR/edgeR-output/sample-file.txt

run_DE_analysis.pl \
  --matrix $OUT_DIR/edgeR-output/trinity-de.isoform.counts.matrix \
  --method edgeR \
  --samples_file $OUT_DIR/edgeR-output/sample-file.txt \
  --output $OUT_DIR/edgeR-output/edgeR-isoform

run_DE_analysis.pl \
  --matrix $OUT_DIR/edgeR-output/trinity-de.genes.counts.matrix \
  --method edgeR \
  --samples_file $OUT_DIR/edgeR-output/sample-file.txt \
  --output $OUT_DIR/edgeR-output/edgeR-genes

echo date" Finished differential expression analysis"

############################################

echo date" Starting plots"


cd $OUT_DIR/edgeR-output/edgeR-isoform
#Heatmap isoforms
analyze_diff_expr.pl \
  --matrix $OUT_DIR/edgeR-output/trinity-de.isoform.TMM.EXPR.matrix \
  -P 0.01 -C 1 \
  --samples $OUT_DIR/edgeR-output/sample-file.txt

#PCA isoforms
PtR \
  --matrix $OUT_DIR/edgeR-output/trinity-de.isoform.TMM.EXPR.matrix \
  --samples $OUT_DIR/edgeR-output/sample-file.txt \
  --log2 --prin_comp 3

cd $OUT_DIR/edgeR-output/edgeR-genes
#Heatmap genes
analyze_diff_expr.pl \
  --matrix $OUT_DIR/edgeR-output/trinity-de.genes.TMM.EXPR.matrix \
  -P 0.01 -C 1 \
  --samples $OUT_DIR/edgeR-output/sample-file.txt

#PCA genes
PtR \
  --matrix $OUT_DIR/edgeR-output/trinity-de.genes.TMM.EXPR.matrix \
  --samples $OUT_DIR/edgeR-output/sample-file.txt \
  --log2 --prin_comp 3

echo date" Finished plots"

############################################

echo "Done"
end=`date +%s`
runtime=$((end-start))
echo "Runtime: "$runtime" seconds"

