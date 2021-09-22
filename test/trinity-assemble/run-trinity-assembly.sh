#!/usr/bin/env bash

## note with few reads it may fail often, just remove output dir and restart

if [ "$1" == "-h" ]; then
  echo "Usage: bash `basename $0` 2>&1 | tee run-trinity-assembly.log"
  exit 0
fi

start=`date +%s`

source ~/miniconda3/etc/profile.d/conda.sh
conda activate mtrans-smk-hs

PARENT_DIR="/home/s1119647/Bpexa/metatrans-smk-hs"
IN_DIR=${PARENT_DIR}"/sample-data/subset-trimmed-libs"
OUT_DIR=${PARENT_DIR}"/test/trinity-assemble/trinity-output"
THREADS=8

echo "using the following directories:"
echo "input: $IN_DIR"
echo "output: $OUT_DIR"

#ls $IN_DIR/*_R1_paired-subset.fq.gz | tr '\n' ','
#ls $IN_DIR/*_R2_paired-subset.fq.gz | tr '\n' ','

Trinity \
  --normalize_reads \
  --seqType fq \
  --max_memory 16G \
  --left /home/s1119647/Bpexa/metatrans-smk-hs/sample-data/subset-trimmed-libs/C_PT1_0_J36463_R1_paired-subset.fq.gz,/home/s1119647/Bpexa/metatrans-smk-hs/sample-data/subset-trimmed-libs/C_PT1_1_J36443_R1_paired-subset.fq.gz,/home/s1119647/Bpexa/metatrans-smk-hs/sample-data/subset-trimmed-libs/C_PT1_2_J36451_R1_paired-subset.fq.gz,/home/s1119647/Bpexa/metatrans-smk-hs/sample-data/subset-trimmed-libs/C_PT1_3_J36458_R1_paired-subset.fq.gz,/home/s1119647/Bpexa/metatrans-smk-hs/sample-data/subset-trimmed-libs/C_PT2_0_J36461_R1_paired-subset.fq.gz,/home/s1119647/Bpexa/metatrans-smk-hs/sample-data/subset-trimmed-libs/C_PT2_1_J36457_R1_paired-subset.fq.gz,/home/s1119647/Bpexa/metatrans-smk-hs/sample-data/subset-trimmed-libs/C_PT2_2_J36489_R1_paired-subset.fq.gz,/home/s1119647/Bpexa/metatrans-smk-hs/sample-data/subset-trimmed-libs/C_PT2_3_J36467_R1_paired-subset.fq.gz,/home/s1119647/Bpexa/metatrans-smk-hs/sample-data/subset-trimmed-libs/MA_PT1_0_J36462_R1_paired-subset.fq.gz,/home/s1119647/Bpexa/metatrans-smk-hs/sample-data/subset-trimmed-libs/MA_PT1_1_J36455_R1_paired-subset.fq.gz,/home/s1119647/Bpexa/metatrans-smk-hs/sample-data/subset-trimmed-libs/MA_PT1_2_J36479_R1_paired-subset.fq.gz,/home/s1119647/Bpexa/metatrans-smk-hs/sample-data/subset-trimmed-libs/MA_PT1_3_J36484_R1_paired-subset.fq.gz,/home/s1119647/Bpexa/metatrans-smk-hs/sample-data/subset-trimmed-libs/MA_PT2_0_J36468_R1_paired-subset.fq.gz,/home/s1119647/Bpexa/metatrans-smk-hs/sample-data/subset-trimmed-libs/MA_PT2_1_J36471_R1_paired-subset.fq.gz,/home/s1119647/Bpexa/metatrans-smk-hs/sample-data/subset-trimmed-libs/MA_PT2_2_J36480_R1_paired-subset.fq.gz,/home/s1119647/Bpexa/metatrans-smk-hs/sample-data/subset-trimmed-libs/MA_PT2_3_J36478_R1_paired-subset.fq.gz \
  --right /home/s1119647/Bpexa/metatrans-smk-hs/sample-data/subset-trimmed-libs/C_PT1_0_J36463_R2_paired-subset.fq.gz,/home/s1119647/Bpexa/metatrans-smk-hs/sample-data/subset-trimmed-libs/C_PT1_1_J36443_R2_paired-subset.fq.gz,/home/s1119647/Bpexa/metatrans-smk-hs/sample-data/subset-trimmed-libs/C_PT1_2_J36451_R2_paired-subset.fq.gz,/home/s1119647/Bpexa/metatrans-smk-hs/sample-data/subset-trimmed-libs/C_PT1_3_J36458_R2_paired-subset.fq.gz,/home/s1119647/Bpexa/metatrans-smk-hs/sample-data/subset-trimmed-libs/C_PT2_0_J36461_R2_paired-subset.fq.gz,/home/s1119647/Bpexa/metatrans-smk-hs/sample-data/subset-trimmed-libs/C_PT2_1_J36457_R2_paired-subset.fq.gz,/home/s1119647/Bpexa/metatrans-smk-hs/sample-data/subset-trimmed-libs/C_PT2_2_J36489_R2_paired-subset.fq.gz,/home/s1119647/Bpexa/metatrans-smk-hs/sample-data/subset-trimmed-libs/C_PT2_3_J36467_R2_paired-subset.fq.gz,/home/s1119647/Bpexa/metatrans-smk-hs/sample-data/subset-trimmed-libs/MA_PT1_0_J36462_R2_paired-subset.fq.gz,/home/s1119647/Bpexa/metatrans-smk-hs/sample-data/subset-trimmed-libs/MA_PT1_1_J36455_R2_paired-subset.fq.gz,/home/s1119647/Bpexa/metatrans-smk-hs/sample-data/subset-trimmed-libs/MA_PT1_2_J36479_R2_paired-subset.fq.gz,/home/s1119647/Bpexa/metatrans-smk-hs/sample-data/subset-trimmed-libs/MA_PT1_3_J36484_R2_paired-subset.fq.gz,/home/s1119647/Bpexa/metatrans-smk-hs/sample-data/subset-trimmed-libs/MA_PT2_0_J36468_R2_paired-subset.fq.gz,/home/s1119647/Bpexa/metatrans-smk-hs/sample-data/subset-trimmed-libs/MA_PT2_1_J36471_R2_paired-subset.fq.gz,/home/s1119647/Bpexa/metatrans-smk-hs/sample-data/subset-trimmed-libs/MA_PT2_2_J36480_R2_paired-subset.fq.gz,/home/s1119647/Bpexa/metatrans-smk-hs/sample-data/subset-trimmed-libs/MA_PT2_3_J36478_R2_paired-subset.fq.gz \
  --output $OUT_DIR \
  --min_kmer_cov 1
#  --CPU $THREADS \
#  --full_cleanup \
#  --inchworm_cpu $THREADS \
#  --bflyHeapSpaceMax 15G \
#  --bflyCalculateCPU \
#  --min_kmer_cov 2

TrinityStats.pl \
  trinity-output/Trinity.fasta \
  > trinity-output/Trinity_stats.txt


echo "Done"
end=`date +%s`
runtime=$((end-start))
echo "Runtime: '$runtime'"

