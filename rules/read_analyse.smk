rule krijg_read_info:
    input: 
        raw = get_all_raw_input,
        trim = expand("results/{samples.run}/trimmomatic/{samples.sample}.R{direction}.paired.fastq.gz",
            samples=smpls.itertuples(), direction=["1","2"]),
        filt = expand("results/{samples.run}/sortmerna/{samples.sample}/paired_{direction}.fq.gz",
            samples=smpls.itertuples(), direction=["left", "right"]),
        trinity = "results/{run}/trinity_output/trinity_assemble.Trinity.fasta"
    output:
        out="results/{run}/reads_results_r.tsv"
    conda:
        config["read-analyse"]["environment"]
    threads:
        config["read-analyse"]["threads"]
    log:
        "logs/{run}/read_analyse.log"
    shell:
        """
        echo "{input.raw} {input.trim} {input.filt} {input.trinity}" | tr " " "\n" > results/{wildcards.run}/reads_files.tmp
        seqkit stats \
            --infile-list results/{wildcards.run}/reads_files.tmp \
            --out-file {output.out} \
            -T > {log}
        rm results/{wildcards.run}/reads_files.tmp
        """

rule reads_plot:
    input: 
        reads_results = "results/{run}/reads_results_r.tsv"
    output: 
        plot="results/{run}/processed_reads.pdf"
    conda:
        config["read-analyse"]["environment"]
    log:
        "logs/{run}/read_analyse_plot.log"
    shell: 
        """Rscript scripts/plot_reads.r {input.reads_results} {output.plot} > {log}"""