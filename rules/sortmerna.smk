rule sortmerna:
    input: 
        fow = "results/{run}/trimmomatic/{sample}.R1.paired.fastq.gz",
        rev = "results/{run}/trimmomatic/{sample}.R1.paired.fastq.gz",
        ref1 = "db/sortmerna/set1-database.fasta",
        ref2 = "db/sortmerna/set2-database.fasta",
        ref3 = "db/sortmerna/set3-database.fasta",
        ref4 = "db/sortmerna/set4-database.fasta"
    output: 
        work = directory("results/{run}/sortmerna/{sample}")
        #aligned = "results/{run}/sortmerna/{sample}/aligned.fasta"
    params:
        num_alignments = config["sortmerna"]["aantal_alignments"],
        best = config["sortmerna"]["aantal_best"],
        paired_optie = config["sortmerna"]["paired_optie"]
    conda:
        config["sortmerna"]["environment"]
    log:
        "logs/{run}/sortmerna/{sample}_sortmerna.log"
    shell: 
        """
        sortmerna \
        --reads {input.fow} \
        --reads {input.rev} \
        --ref {input.ref1} \
        --ref {input.ref2} \
        --ref {input.ref3} \
        --ref {input.ref4} \
        --workdir {output.work} \
        --num_alignments {params.num_alignments} \
        -fastx -other -{params.paired_optie} > {log}
        """