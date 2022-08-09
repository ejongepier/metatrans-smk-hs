rule interprodb:
    output: 
        touch("interprodb.done")
    shadow:
        "full"
    params:
        major=config["interproscan"]["major_version"],
        minor=config["interproscan"]["minor_version"]
    shell: 
        """
            mkdir -p '{resources.tmpdir}/interprodb'
            wget -nv -P '{resources.tmpdir}/interprodb/' 'http://ftp.ebi.ac.uk/pub/software/unix/iprscan/5/{params.major}-{params.minor}/interproscan-{params.major}-{params.minor}-64-bit.tar.gz.md5'
            wget -nv -P '{resources.tmpdir}/interprodb/' 'http://ftp.ebi.ac.uk/pub/software/unix/iprscan/5/{params.major}-{params.minor}/interproscan-{params.major}-{params.minor}-64-bit.tar.gz'
            md5sum -c '{resources.tmpdir}/interprodb/interproscan-{params.major}-{params.minor}-64-bit.tar.gz.md5'
            tar -xvzf '{resources.tmpdir}/interprodb/interproscan-{params.major}-{params.minor}-64-bit.tar.gz'
            rm -fr .snakemake/conda/*/share/InterProScan/data/
            mv -r {resources.tmpdir}/interprodb/interproscan-{params.major}-{params.minor}/data .snakemake/conda/*/share/InterProScan/
        """

rule translate_transcripts:
    input: 
        "results/{run}/trinity_output/trinity_assemble.Trinity.fasta"
    output: 
        temp("results/{run}/interproscan/trinity_proteins.fasta"),
        "results/{run}/interproscan/trinity_proteins_fil.fasta"
    params:
        pep_max_len=config["interproscan"]["protein-max-length"]
    conda:
        config["interproscan"]["environment"]
    shell:
        """
        TransDecoder.LongOrfs -t {input} -m {params.pep_max_len} -O {output[0]}
        cat {output[0]} | egrep -A1 complete | sed '/^--/d' > {output[1]}
        """ 

rule split_transcripts:
    input: 
        "results/{run}/interproscan/trinity_proteins.fasta"
    output:
        directory("results/{run}/interproscan/split_proteins")
    conda:
        config["read-analyse"]["environment"]
    shell: 
        """seqkit split -i -s 40 --out-dir {output} {input}"""

# rule longest_orf:
#     input: 
#     output: 
#     run:
#         #Loop door file en bewaar de trinity isoform ID
#         #sla entry op met de lengte
#         #als lengte van volgende met dezelfde trinity ID langer is sla deze dan op.
#         #herhaal voor elk trinity ID


rule interproscan:
    input: 
        "results/{run}/interproscan/split_proteins/{part}.pep"
    output: 
        directory("results/{run}/interproscan/output_{part}")
    params:
        applications=config["interproscan"]["analyses"]
    conda:
        config["interproscan"]["environment"]
    log:
        "logs/{run}/output_{part}_interproscan.log"
    shell: 
        """
        ./interproscan.sh --applications {params.applications} \
            --output-dir {output} \
            --tempdir {resources.tmpdir} \
            --seqtype p \
            --input {input} > {log}
        """