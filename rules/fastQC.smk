def get_fastq(wildcards):
	return smpls.loc[(wildcards.run, wildcards.sample), ["fwd","rev"]].dropna()

def get_trimmed_input(wildcards):
	return expand("results/{run}/trimmomatic/{sample}.{direction}.paired.fastq.gz", run=wildcards.run, 
					sample=wildcards.sample, direction=["R1","R2"])


rule fastQCraw:
	input:
		get_fastq
	output:
		directory("results/{run}/fastqc/raw/{sample}/")
	threads:
		config["fastQC"]["threads"]
	conda:
		config["fastQC"]["environment"]
	benchmark:
		"benchmarks/{run}/{sample}-fastQC.txt"
	shell:
		"""
		mkdir -p {output}
		fastqc -o {output} {input}
		"""

rule fastQCtrimmed:
	input:
		get_trimmed_input
	output:
		directory("results/{run}/fastqc/trimmed/{sample}/")
	threads:
		config["fastQC"]["threads"]
	conda:
		config["fastQC"]["environment"]
	benchmark:
		"benchmarks/{run}/{sample}-fastQC.txt"
	shell:
		"""
		mkdir -p {output}
		fastqc -o {output} {input}
		"""

