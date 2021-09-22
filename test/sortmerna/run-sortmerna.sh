#!/usr/bin/env bash

if [ "$1" == "-h" ]; then
  echo "Usage: bash `basename $0` 2>&1 | tee run-sortmerna.log"
  exit 0
fi

start=`date +%s`

#source ~/home/s1117684/miniconda3/etc/profile.d/conda.sh
source ~/miniconda3/etc/profile.d/conda.sh
conda activate mtrans-smk-hs

<<<<<<< HEAD
PARENT_DIR="/metatrans-smk-hs"
=======
PARENT_DIR="/project/202108-metatranscriptomics-ibedall"
>>>>>>> 97351e8641dc84c7a50c6a0cce764d942c020099
IN_DIR=${PARENT_DIR}"/sample-data/subset-trimmed-libs"
OUT_DIR=${PARENT_DIR}"/test/sortmerna"
DB_DIR=${PARENT_DIR}"/db/sortmerna"
THREADS=8

echo "using the following directories:"
echo "input: $IN_DIR"
echo "output: $OUT_DIR"
echo "db: $DB_DIR"

for fwdpath in ${IN_DIR}/*_R1_*; do
  fwd=$(basename $fwdpath)
  rev=${fwd/_R1_paired-subset.fq.gz/_R2_paired-subset.fq.gz}
  prefix=${fwd/_R1_paired-subset.fq.gz/}

  echo $fwd
  echo $rev
  echo $prefix

  sortmerna \
    --ref ${DB_DIR}/set5-database.fasta \
    --reads ${IN_DIR}/$fwd \
    --reads ${IN_DIR}/$rev \
    --aligned ${OUT_DIR}/${prefix}-rRNA \
    --other ${OUT_DIR}/${prefix}-clean \
    --num_alignments 1 \
    --fastx \
    --blast 1 \
    --paired_out \
    -v \
    --threads $THREADS \
    --workdir ${OUT_DIR}/tmp

  ## one file is misnamed in sortmerna output
  mv MA_PT2_J36468-clean_0.fq.gz MA_PT2_0_J36468-clean.fq.gz
  mv C_PT1_J36463-clean_0.fq.gz C_PT1_0_J36463-clean.fq.gz

  ## deinterleve
  zcat ${OUT_DIR}/${prefix}-clean.fq.gz | paste - - - - - - - - | tee | cut -f 1-4 | tr "\t" "\n" | egrep -v '^$' | gzip -c > ${OUT_DIR}/${prefix}-R1-clean.fq.gz
  zcat ${OUT_DIR}/${prefix}-clean.fq.gz | paste - - - - - - - - | tee | cut -f 5-8 | tr "\t" "\n" | egrep -v '^$' | gzip -c > ${OUT_DIR}/${prefix}-R2-clean.fq.gz

  rm -r ${OUT_DIR}/tmp

done

echo "Done"
end=`date +%s`
runtime=$((end-start))
echo "Runtime: '$runtime'"
