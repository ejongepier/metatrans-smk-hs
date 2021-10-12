import os
rule trinity_de:
	input: 
		assembly = "results/{run}/trinity_output/trinity_assemble/Trinity.fasta"
	output: 
		directory("results/{run}/trinity_output/trinity_de")
	params:
		workdir = os.getcwd()
	threads:
		config["trinity"]["threads"]
	conda:
		config["mtrans-smk-hs"]["environment"]
	shell:
		"bash scripts/run-trinity-de.sh {input.assembly} {wildcards.run} {params.workdir}"