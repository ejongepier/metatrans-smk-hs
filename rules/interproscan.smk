rule translate_transcripts:
    input: 
        "results/{run}/trinity_output/trinity_assemble.Trinity.fasta"
    output: 
        directory("results/{run}/interproscan/trinity_proteins"),
        "results/{run}/interproscan/trinity_proteins/longest_orfs.pep"
    params:
        pep_max_len=config["interproscan"]["protein-max-length"]
    conda:
        config["interproscan"]["environment"]
    shell:
        """
        TransDecoder.LongOrfs -t {input} -m {params.pep_max_len} -O {output[0]}
        """ 

rule temp_pep_file:
    input: 
        "results/{run}/interproscan/trinity_proteins/longest_orfs.pep"
    output: 
        temp("results/{run}/interproscan/longest_orfs.pep.tmp")
    shell: 
        """cat {input[0]} | tr -d '\n' | sed "s_>_\n>_g" | tail -n +2 > {output}""".encode('unicode_escape').decode('utf-8')

rule select_proteins:
    input: 
        "results/{run}/interproscan/longest_orfs.pep.tmp"
    output: 
        "results/{run}/interproscan/trinity_proteins_fil.fasta"
    run: 
        with open(input[0], "r") as inf, open(output[0], "w") as outf:
            current_best = ["", 0, ""]
            for line in inf:
                sline = line.split(" ")
                if sline[0].split(".")[0] != current_best[0] and current_best[0]:
                    outf.write(f"{current_best[0]} len:{current_best[1]}\n")
                    outf.write(f"{current_best[2]}")
                    current_best = ["", -1, ""]
                if not current_best[0]:
                    current_best[0] = sline[0].split(".")[0]
                    current_best[1] = sline[2].split(":")[1]
                    current_best[2] = line.split(")")[1].replace("*","X")
                elif sline[0].split(".")[0] == current_best[0]:
                    if sline[2].split(":")[1] > current_best[1]:
                        current_best[0] = sline[0].split(".")[0]
                        current_best[1] = sline[2].split(":")[1]
                        current_best[2] = line.split(")")[1].replace("*","X")



rule interproscan:
    input: 
        "results/{run}/interproscan/trinity_proteins_fil.fasta"
    output: 
        "results/{run}/interproscan/interproscan_output/output.tsv"
    params:
        applications=config["interproscan"]["analyses"],
        interproscandir=config["interproscan"]["dir_path"],
	output_base_name="results/{run}/interproscan/interproscan_output/output"
    log:
        "logs/{run}/interproscan.log"
    shell: 
        """
        {params.interproscandir}/interproscan.sh --applications {params.applications} \
            --output-file-base {params.output_base_name} \
            --tempdir {resources.tmpdir} \
            --input {input[0]} > {log}
        """


# rule interproscan:
#     input: 
#         "results/{run}/interproscan/split_proteins/{part}.pep"
#     output: 
#         directory("results/{run}/interproscan/output_{part}")
#     params:
#         applications=config["interproscan"]["analyses"]
#     conda:
#         config["interproscan"]["environment"]
#     log:
#         "logs/{run}/output_{part}_interproscan.log"
#     shell: 
#         """
#         ./interproscan.sh --applications {params.applications} \
#             --output-dir {output} \
#             --tempdir {resources.tmpdir} \
#             --seqtype p \
#             --input {input} > {log}
#         """
