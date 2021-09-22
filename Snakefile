rule all:
	input:
		"/home/s1119647/Bpexa/metatrans-smk-hs/test/trimmomatic/uitslag/", "/home/s1119647/Bpexa/metatrans-smk-hs/test/trinity-assemble/trinity-output/"

#rule fastQC:
#	input:
#		"samples.csv"
#	output:
#		"fastqc_output.txt"
#	shell:
#		"fastqc {input}"

rule trimmomatic:
	input:
		"/home/s1119647/Bpexa/metatrans-smk-hs"
	output:
		"/home/s1119647/Bpexa/metatrans-smk-hs/test/trimmomatic/uitslag/"
	shell:
		"bash /home/s1119647/Bpexa/metatrans-smk-hs/test/trimmomatic/run-trimmomatic.sh {input} {output}"

rule trinity_assemble:
	input:
		"/home/s1119647/Bpexa/metatrans-smk-hs"
	output:
		"/home/s1119647/Bpexa/metatrans-smk-hs/test/trinity-assemble/trinity-output/"
	shell:
		"bash /home/s1119647/Bpexa/metatrans-smk-hs/test/trinity-assemble/run-trinity-assembly.sh {input} {output}"
