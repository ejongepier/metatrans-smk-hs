rule all:
	input:
		"/home/chezley/metatrans-smk-hs/test/trimmomatic/uitslag/", "/home/chezley/metatrans-smk-hs/test/trinity-assemble/trinity-output/", "/home/chezley/metatrans-smk-hs/test/trinity-de/trinity-output/"

rule fastQC:
	input:
		expand("/home/chezley/metatrans-smk-hs/{samples.run}/trimmomatic/{samples.sample}.R1.paired.fastq.gz",
			samples=smpls.itertuples()
		)
	output:
		"fastqc_output.txt"
	shell:
		"fastqc {input}"

rule trimmomatic:
	input:
		"/home/chezley/metatrans-smk-hs"
	output:
		"/home/chezley/metatrans-smk-hs/test/trimmomatic/uitslag/"
	shell:
		"bash /home/chezley/metatrans-smk-hs/test/trimmomatic/run-trimmomatic.sh {input} {output}"

rule trinity_assemble:
	input:
		"/home/chezley/metatrans-smk-hs"
	output:
		"/home/chezley/metatrans-smk-hs/test/trinity-assemble/trinity-output/"
	shell:
		"bash /home/chezley/metatrans-smk-hs/test/trinity-assemble/run-trinity-assembly.sh {input} {output}"

rule trinity_de:
	input: 
		"/home/chezley/metatrans-smk-hs"
	output: 
		"/home/chezley/metatrans-smk-hs/test/trinity-de/trinity-output/"
	shell:
		"bash /home/chezley/metatrans-smk-hs/test/trinity-de/run-trinity-de.sh"
