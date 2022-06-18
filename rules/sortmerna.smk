#wget commando voor database downloaden 'wget https://github.com/biocore/sortmerna/releases/download/v4.3.3/database.tar.gz'
rule reference_database:
    input:
        fol = "db/sortmerna/"
    output: 
        database = "db/sortmerna/smr_v4.3_{database_type}_db.fasta"
    params:
        db = "smr_v4.3_"+config["sortmerna"]["ref_database"]+"_db.fasta"
    shell: 
        """
        mkdir -p 'db/sortmerna/download'
        wget -nc -P 'db/sortmerna/download/' 'https://github.com/biocore/sortmerna/releases/download/v4.3.3/database.tar.gz'
        tar -xzvf db/sortmerna/download/database.tar.gz -C db/sortmerna/download
        mv 'db/sortmerna/download/{params.db}' '{input.fol}' 
        rm -r 'db/sortmerna/download'
        """

rule sortmerna:
    input: 
        fow = "results/{run}/trimmomatic/{sample}.R1.paired.fastq.gz",
        rev = "results/{run}/trimmomatic/{sample}.R2.paired.fastq.gz",
        ref = "db/sortmerna/smr_v4.3_"+config["sortmerna"]["ref_database"]+"_db.fasta"
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
    threads:
        4
    resources:
        mem_mb = 2000
    log:
        "logs/{run}/sortmerna/{sample}_sortmerna.log"
    shell: 
        """
        sortmerna \
        --reads {input.fow} \
        --reads {input.rev} \
        --ref {input.ref} \
        --workdir {output.work} \
        --num_alignments {params.num_alignments} \
        --threads {threads} \
        -m {resources.mem_mb} \
        -{params.paired_optie} -v -fastx -other > {log}
        """

rule ungzip:
    input: 
        "{path}.fq.gz"
    output: 
        "{path}.fq"
    conda:
        config["general"]["environment"]
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