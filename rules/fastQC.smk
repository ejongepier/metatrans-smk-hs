def get_fastq(wildcards):
	return smpls.loc[(wildcards.run, wildcards.sample), ["fwd","rev"]].dropna()


rule fastQC:
	input:
		get_fastq
	output:
		directory("results/{run}/fastqc/{sample}/")
	shell:
		"""
		mkdir -p {output}
		fastqc -o {output} {input}
		"""
