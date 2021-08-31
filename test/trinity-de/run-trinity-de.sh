#!/usr/bin/env bash

if [ "$1" == "-h" ]; then
  echo "Usage: bash `basename $0` 2>&1 | tee run-trinity-de.log"
  exit 0
fi

start=`date +%s`

source ~/miniconda3/etc/profile.d/conda.sh
conda activate mtrans-smk-hs

PARENT_DIR="/project/202108-metatranscriptomics-ibedall/github/metatrans-smk-hs"
ASSEMBLY_DIR=${PARENT_DIR}"/test/trinity-assemble/trinity-output"
READ_DIR=${PARENT_DIR}"/sample-data/subset-trimmed-libs"
OUT_DIR=${PARENT_DIR}"/test/trinity-de/trinity-output"

echo "Using the following directories:"
echo "  assembly directory: "$ASSEMBLY_DIR
echo "  read directory: "$READ_DIR
echo "  output directory: "$OUT_DIR

############################################

for fwdpath in ${READ_DIR}/*_R1_*; do

  fwd=$(basename $fwdpath)
  rev=${fwd/_R1_paired-subset.fq.gz/_R2_paired-subset.fq.gz}
  prefix=${fwd/_R1_paired-subset.fq.gz/}

  echo date" Starting alignment and abundance estimates of "$prefix

  align_and_estimate_abundance.pl \
    --transcripts $ASSEMBLY_DIR/Trinity.fasta \
    --seqType fq \
    --left $READ_DIR/$fwd \
    --right $READ_DIR/$rev \
    --prep_reference \
    --est_method RSEM \
    --aln_method bowtie2 \
    --trinity_mode \
    --output_dir $OUT_DIR/$prefix

  echo date"  Finished alignment and abundance estimates of "$prefix

done

############################################

echo date" Starting conversion of abundance estimates to matrix"

mkdir -p $OUT_DIR/edgeR-output
cd $OUT_DIR/edgeR-output/

ls $OUT_DIR/*/RSEM.isoforms.results > $OUT_DIR/file-paths.txt

abundance_estimates_to_matrix.pl \
  --est_method RSEM \
  --out_prefix trinity-de \
  --gene_trans_map none \
  --name_sample_by_basedir \
  --quant_files $OUT_DIR/file-paths.txt

echo date" Finished conversion of abundance estimates to matrix"

############################################

echo date" Starting differential expression analysis"

ls $READ_DIR/ | \
  awk -F "_" -v OFS='_' '{print $1"\t"$1, $2, $3, $4}' | \
  sort | uniq > $OUT_DIR/edgeR-output/sample-file.txt

for level in isoform; do
  run_DE_analysis.pl \
    --matrix $OUT_DIR/edgeR-output/trinity-de.$level.counts.matrix \
    --method edgeR \
    --samples_file $OUT_DIR/edgeR-output/sample-file.txt \
    --output $OUT_DIR/edgeR-output/edgeR-$level
done

echo date" Finished differential expression analysis"

############################################

echo date" Starting plots"

for level in isoform; do
  cd $OUT_DIR/edgeR-output/edgeR-$level

  #Heatmap isoforms
  analyze_diff_expr.pl \
    --matrix $OUT_DIR/edgeR-output/trinity-de.$level.TMM.EXPR.matrix \
    -P 0.01 -C 1 \
    --samples $OUT_DIR/edgeR-output/sample-file.txt

  #PCA isoforms
  PtR \
    --matrix $OUT_DIR/edgeR-output/trinity-de.$level.TMM.EXPR.matrix \
    --samples $OUT_DIR/edgeR-output/sample-file.txt \
    --log2 --prin_comp 3

done

echo date" Finished plots"

############################################

echo "Done"
end=`date +%s`
runtime=$((end-start))
echo "Runtime: "$runtime" seconds"

