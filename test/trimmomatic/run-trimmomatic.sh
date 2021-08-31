#!/usr/bin/env bash

if [ "$1" == "-h" ]; then
  echo "Usage: bash `basename $0` 2>&1 | tee run-trimmomatic.log"
  exit 0
fi

start=`date +%s`

source ~/miniconda3/etc/profile.d/conda.sh
conda activate mtrans-smk-hs

PARENT_DIR="/project/202108-metatranscriptomics-ibedall/github/metatrans-smk-hs"
INPUT_DIR=${PARENT_DIR}"/sample-data/subset-trimmed-libs"
OUTPUT_DIR=${PARENT_DIR}"/test/trimmomatic"
ADAPTER_DIR=${PARENT_DIR}"/db/adapters"
THREADS=8

echo "Running "`basename "$0"`" using the following directories:"
echo "input: "${INPUT_DIR}
echo "output: "${OUTPUT_DIR}
echo "adapter: "${ADAPTER_DIR}

for fwdpath in ${INPUT_DIR}/*_R1_*; do
  fwd=$(basename ${fwdpath})
  rev=${fwd/_R1_paired-subset.fq.gz/_R1_paired-subset.fq.gz}
  prefix=${fwd/_R1_paired-subset.fq.gz/}

  echo "Forward reads: "${fwd}
  echo "Reverse reads: "${rev}
  echo "Library prefix: "${prefix}

  trimmomatic PE \
    -threads ${THREADS} \
    -phred33 \
    ${INPUT_DIR}/${fwd} ${INPUT_DIR}/${rev} \
    ${OUTPUT_DIR}/${prefix}_R1_paired.fq ${OUTPUT_DIR}/${prefix}_R1_unpaired.fq \
    ${OUTPUT_DIR}/${prefix}_R2_paired.fq ${OUTPUT_DIR}/${prefix}_R2_unpaired.fq \
    ILLUMINACLIP:${ADAPTER_DIR}/adapters.fa:2:30:10 LEADING:3 TRAILING:3 SLIDINGWINDOW:4:28 MINLEN:36

  gzip ${OUTPUT_DIR}/${prefix}_R1_paired.fq
  gzip ${OUTPUT_DIR}/${prefix}_R1_unpaired.fq
  gzip ${OUTPUT_DIR}/${prefix}_R2_paired.fq
  gzip ${OUTPUT_DIR}/${prefix}_R2_unpaired.fq

done

echo "Done"
end=`date +%s`
runtime=$((end-start))
echo "Runtime: '$runtime' seconds"

