import os

rule trinity_de:
	input: 
		assembly = "results/{run}/trinity_output/trinity_assemble/Trinity.fasta",
		align_estimate_abundance = expand("results/{samples.run}/trinity_output/trinity_de/{samples.sample}/", samples=smpls.itertuples())
	output: 
		#directory("results/{run}/trinity_output/trinity_de")
		touch("results/{run}/trinity_output/trinity_de.done")
	params:
		workdir = os.getcwd()
	threads:
		config["trinity"]["threads"]
	conda:
		config["mtrans-smk-hs"]["environment"]
	log:
		"logs/{run}/trinity_de.log"
	shell:
		"bash scripts/run-trinity-de.sh {input.assembly} {wildcards.run} {params.workdir} > {log}"

rule trinty_align_estimate_abundance:
	input: 
		assembly = "results/{run}/trinity_output/trinity_assemble/Trinity.fasta",
		left = "results/{run}/trimmomatic/{sample}.R1.paired.fastq.gz",
		right = "results/{run}/trimmomatic/{sample}.R2.paired.fastq.gz"
	output: 
		directory("results/{run}/trinity_output/trinity_de/{sample}")
	conda:
		config["mtrans-smk-hs"]["environment"]
	log:
		"logs/{run}/trinity_align_estimate_abundance/{sample}.log"
	shell:
		"""
		align_and_estimate_abundance.pl \
    	  --transcripts {input.assembly} \
    	  --seqType fq \
    	  --left {input.left} \
    	  --right {input.right} \
    	  --prep_reference \
    	  --est_method RSEM \
    	  --aln_method bowtie2 \
    	  --trinity_mode \
    	  --output_dir results/{wildcards.run}/trinity_output/trinity_de/{wildcards.sample} > {log}
		""" 