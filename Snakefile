rule all:
    input:
        expand("fastqc_output.txt"), expand("run-trimomatic.log")

rule fastQC:
	input:
		"sample.csv"
	output:
		"fastqc_output.txt"
	shell:
		"fastqc {input}"

rule trimmomatic:
	input:
		"/sample-data/subset-raw-libs"
	output:
		"run-trimmomatic.log"
	shell:
		"bash run-trimmomatic.sh {input} {output}"

