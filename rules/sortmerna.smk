rule sortmerna:
    input: 
        fow = "results/{run}/trimmomatic/{sample}.R1.paired.fastq.gz",
        rev = "results/{run}/trimmomatic/{sample}.R2.paired.fastq.gz",
        ref1 = "db/sortmerna/set1-database.fasta",
        ref2 = "db/sortmerna/set2-database.fasta",
        ref3 = "db/sortmerna/set3-database.fasta",
        ref4 = "db/sortmerna/set4-database.fasta"
    output: 
        work = directory("results/{run}/sortmerna/{sample}"),
        aligned = "results/{run}/sortmerna/{sample}/out/aligned.fq.gz",
        other = "results/{run}/sortmerna/{sample}/out/other.fq.gz"
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

rule ungzip:
    input: 
        "{path}.fq.gz"
    output: 
        "{path}.fq"
    conda:
        config["gunzip"]["environment"]
    shell: 
        "gzip -k -d -c {input} > {output}"

rule split_reads:
    input: 
        other_reads = "results/{run}/sortmerna/{sample}/out/other.fq"
    output: 
        left_reads = "results/{run}/sortmerna/{sample}/paired_left.fq",
        right_reads = "results/{run}/sortmerna/{sample}/paired_right.fq"
    run: 
        counter = 0
        write_left = True
        with open(input.other_reads, "r") as in_reads, open(output.left_reads, "w") as out_left, open(output.right_reads, "w") as out_right:
                for line in in_reads:
                    if counter % 4 == 0 and counter > 0:
                        write_left = not write_left
                        counter = 0
                    if write_left:
                        out_left.write(line)
                    else:
                        out_right.write(line)
                    counter += 1