rule fastQCraw:
	input:
		get_raw_input
	output:
		directory("results/{run}/fastqc/raw/{sample}/")
	priority: 10
	threads:
		config["fastQC"]["threads"]
	conda:
		config["fastQC"]["environment"]
	log:
		"logs/{run}/fastqc/raw/{sample}.log"
	benchmark:
		"benchmarks/{run}/fastqc_raw/{sample}-fastQC.txt"
	shell:
		"""
		mkdir -p {output} 
		fastqc -o {output} {input} --threads {threads}
		"""

rule fastQCtrimmed:
	input:
		get_filter_input
	output:
		directory("results/{run}/fastqc/trimmed_filtered/{sample}/")
	priority: 10
	threads:
		config["fastQC"]["threads"]
	conda:
		config["fastQC"]["environment"]
	log:
		"logs/{run}/fastqc/trimmed/{sample}.log"
	benchmark:
		"benchmarks/{run}/fastqc_trimmed/{sample}-fastQC.txt"
	shell:
		"""
		mkdir -p {output}
		fastqc -o {output} {input} --threads {threads}
		"""
