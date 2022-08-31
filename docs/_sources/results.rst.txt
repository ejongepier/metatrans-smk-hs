Results
=========

The results that are useful for the end user are compiled together in a HTML report. This report shows how each rule has been executed and
which rules depend on the output of other rules.

The following results are contained in the report.

* The fastQC quality control analysis seperated by sample. The quality control is performed on both the raw and processed data.

* Plots visualizing the size of the samples and amount of reads lost between methods.

* The different results from the differential gene expression analysis, such as
    - An MA plot
    - A Volcano plot
    - A Samples correlation heatmap
    - A Differentially expressed genes vs samples heatmap
    - A Principal component analysis plot

These DGE results are generated for both the isoform and gene level transcripts.

Besides the results included in the report there are:

* The assembled transcripts contained in the *results/run/trinity_output/trinity_assemble.Trinity.fasta* file. 

* The differential expression result tables contained within the *results/run/trinity_output/trinity_assemble/edgeR-output/* folder. These DE results are made for both the isoform and gene level expression.

Not all results generated during a DiFlex run are returned by default. This is because the complete results can be over 180 GB large due to the file space needed for the Trinity assembly.
Most of these files are not of importance to the end user. The complete results can be returned by changing the *return_all_results* setting in the config file to *true*.
