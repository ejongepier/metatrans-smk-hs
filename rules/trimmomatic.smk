def get_fastq(wildcards):
    return smpls.loc[(wildcards.run, wildcards.sample), ["fwd","rev"]].dropna()

rule help_trimmomatic:
    shell: 
        """
        echo "This is the help for the trimmomatic rule"
        echo "The trimmomatic rules retrieves the raw sample reads based on the file locations specified in the samples.csv file."
        echo ""
        echo "To run the entire trimmomatic rule on it's own use the following command"
        echo "'snakemake -c<n> --use-conda trim_trimmomatic'"
        echo ""
        echo "These files are created by the trimmomatic"
        echo "'{{sample}}.R1.paired.fastq.gz' These are the forward paired trimmed reads of the given sample"
        echo "'{{sample}}.R2.paired.fastq.gz' These are the reverse paired trimmed reads of the given sample"
        echo "'{{sample}}.R1.unpaired.fastq.gz' These are the forward unpaired trimmed reads of the given sample"
        echo "'{{sample}}.R2.unpaired.fastq.gz' These are the reverse unpaired trimmed reads of the given sample"
        """

rule trim_trimmomatic:
    input:
        get_fastq
    output:
        fwd_p = "results/{run}/trimmomatic/{sample}.R1.paired.fastq.gz",
        rev_p = "results/{run}/trimmomatic/{sample}.R2.paired.fastq.gz",
        fwd_u = "results/{run}/trimmomatic/{sample}.R1.unpaired.fastq.gz",
        rev_u = "results/{run}/trimmomatic/{sample}.R2.unpaired.fastq.gz"
    threads:
        config["trimmomatic"]["threads"]
    params:
        adapters = config["trimmomatic"]["adapters"]
    conda:
        config["trimmomatic"]["environment"]
    log:
        "logs/{run}/trimmomatic/{sample}-trimmomatic.log"
    benchmark:
        "benchmarks/{run}/{sample}-trimmomatic.txt"
    shell:
        """
        trimmomatic PE \
          -threads {threads} \
          -phred33 \
          {input} \
          {output.fwd_p} {output.fwd_u} \
          {output.rev_p} {output.rev_u} \
          ILLUMINACLIP:{params.adapters}:2:30:10 \
          LEADING:3 TRAILING:3 \
          SLIDINGWINDOW:4:28 MINLEN:36 2> {log}
        """