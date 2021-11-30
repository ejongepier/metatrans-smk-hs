## EJ: This function is also defined in trimmomatic.smk. Better to move such global functions to
## the Snakefile in stead of defining twice.

#def get_fastq(wildcards):
#	return smpls.loc[(wildcards.run, wildcards.sample), ["fwd","rev"]].dropna()

#def get_trimmed_input(wildcards):
#	return expand("results/{run}/trimmomatic/{sample}.{direction}.paired.fastq.gz", run=wildcards.run, 
#					sample=wildcards.sample, direction=["R1","R2"])


## EJ: what is the purpose here of defining priority?
## EJ: add log
## EJ: add threads parameter. Can speed things up a bit when working with real life datasets
rule fastQCraw:
	input:
		get_fastq
	output:
		#report(directory("results/{run}/fastqc/raw/{sample}/"), caption="report/fastQCraw.rst", patterns=["{sample}.txt"])
		directory("results/{run}/fastqc/raw/{sample}")
	priority: 10
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

## EJ: pls mind that the same benchmork file is defined here which will be overwritten
## EJ: add log
## EJ: add threads parameter. Can speed things up a bit when working with real life datasets
rule fastQCtrimmed:
	input:
		get_trimmed_input
	output:
		directory("results/{run}/fastqc/trimmed/{sample}")
	priority: 10
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

