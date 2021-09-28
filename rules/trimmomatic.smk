def get_fastq(wildcards):
    return smpls.loc[(wildcards.run, wildcards.sample), ["fwd","rev"]].dropna()


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
        adapters = "db/adapters/adapters.fa"
    conda:
        config["trimmomatic"]["environment"]
    log:
        "logs/{run}/{sample}-trimmomatic.log"
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
