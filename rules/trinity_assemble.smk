rule trinity_assemble:
	input:
		"/home/chezley/metatrans-smk-hs"
	output:
		"/home/chezley/metatrans-smk-hs/test/trinity-assemble/trinity-output/"
	shell:
		"bash /home/chezley/metatrans-smk-hs/test/trinity-assemble/run-trinity-assembly.sh {input} {output}"