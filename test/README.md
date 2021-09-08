# README tests

This folder contains the test of the trimmomatic, sortmerna and trinity-assemble and differential expression analysis.
Q&D scripts are in respective subdirectories. Only trinity results were retained because trinity-assemble somtimes failed when restarting dur to low data volume.
Solution is just to remove output dir and try again.

Based on trimmed data in sample-data/subset-trimmed-libs because raw data was not yet available at time of testing.
Based on env mtrans-smk-hs, see also ../env subdir.

The scripts in this test dir serve as starting point to integrate in the smk pipeline.

### TODO

Test diamond blast and megan for taxonomic classification to include as extentions to the basic assembly and DE pipeline.
