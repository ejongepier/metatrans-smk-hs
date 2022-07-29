rule krijg_read_info:
    input: 
        raw = get_all_raw_input,
        trim = expand("results/{samples.run}/trimmomatic/{samples.sample}.R{direction}.paired.fastq.gz",
            samples=smpls.itertuples(), direction=["1","2"]),
        filt = expand("results/{samples.run}/sortmerna/{samples.sample}/paired_{direction}.fq.gz",
            samples=smpls.itertuples(), direction=["left", "right"])
    output:
        temp("results/{run}/plots/seqkit_results.tsv")
    conda:
        config["read-analyse"]["environment"]
    threads:
        config["read-analyse"]["threads"]
    log:
        "logs/{run}/read_analyse.log"
    shell:
        """
        echo "{input.raw} {input.trim} {input.filt}" | tr " " "\n" > results/{wildcards.run}/reads_files.tmp
        seqkit stats \
            --infile-list results/{wildcards.run}/reads_files.tmp \
            --out-file {output} \
            -T > {log}
        rm -f results/{wildcards.run}/reads_files.tmp
        """

rule krijg_bam_info:
    input: 
        align_done="results/{run}/trinity_output/align_estimate.done"
    output: 
        outfile = "results/{run}/trinity_output/trinity_de/{sample}/flagstats.tsv"
    params:
        bam = "results/{run}/trinity_output/trinity_de/{sample}/bowtie2.bam"
    conda:
        config["trinity"]["environment"]
    threads:
        4
    shell: 
        """samtools flagstats -@ {threads} -O tsv {input} > {output}"""

rule combine_bam_info:
    input: 
        expand("results/{samples.run}/trinity_output/trinity_de/{samples.sample}/flagstats.tsv",
            samples=smpls.itertuples())
    output: 
        temp("results/{run}/plots/bam_results.tsv")
    run: 
        bam_list = []
        for bam in input:
            run = bam.split("/")[1]
            sample = bam.split("/")[4]
            with open(bam, "r") as f:
                res = f.readlines()[13].split("\t")[0]
                bam_list.append(f"{run}\t{sample}\ttrinity\t{res}")
        with open(output[0], "w") as outf:
            for x in bam_list:
                outf.write(f"{x}\n")

rule reformat_seqkit:
    input: 
        "results/{run}/plots/seqkit_results.tsv"
    output: 
        temp("results/{run}/plots/seqkit_for_r.tsv")
    run: 
        read_list = []
        with open(input[0], "r") as f:
            for line in f:
                sline = line.split("\t")
                if "results/" in line:
                    if "trimmomatic" in line:
                        read_list.append(f"{wildcards.run}\t{sline[0].split('/')[3]}\t{sline[0].split('/')[2]}\t{sline[3]}")
                    else:
                        read_list.append(f"{wildcards.run}\t{sline[0].split('/')[3]}.{sline[0].split('/')[4]}\t{sline[0].split('/')[2]}\t{sline[3]}")
                else:
                    read_list.append(f"{wildcards.run}\t{sline[0].split('/')[-1]}\traw\t{sline[3]}")
        with open(output[0], "w") as outf:
            for x in read_list[1:]:
                outf.write(f"{x}\n")

rule final_read_info:
    input: 
        seqkit = "results/{run}/plots/seqkit_for_r.tsv",
        bam = "results/{run}/plots/bam_results.tsv"
    output: 
        read_info = "results/{run}/plots/reads_results.tsv"
    shell: 
        """cat {input.seqkit} {input.bam} > {output.read_info}"""


rule reads_plot:
    input: 
        reads_results = "results/{run}/plots/reads_results.tsv"
    output: 
        plot="results/{run}/plots/processed_reads.pdf"
    conda:
        config["read-analyse"]["environment"]
    log:
        "logs/{run}/read_analyse_plot.log"
    shell: 
        """Rscript scripts/plot_reads.r {input.reads_results} {output.plot} > {log}"""