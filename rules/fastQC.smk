def get_fastq(wildcards):
	return smpls.loc[(wildcards.run, wildcards.sample), ["fwd","rev"]].dropna()


rule fastQC:
	input:
		get_fastq
	output:
		html_out = "results/{run}/fastqc/{sample}_fastqc.html",
       		zip_out = "results/{run}/fastqc/{sample}_fastqc.zip"
	shell:
		"fastqc -o 'results/{wildcards.run}/fastqc' {input}"
