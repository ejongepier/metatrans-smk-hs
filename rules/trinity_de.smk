rule trinity_de:
	input: 
		"/home/chezley/metatrans-smk-hs"
	output: 
		"/home/chezley/metatrans-smk-hs/test/trinity-de/trinity-output/"
	shell:
		"bash /home/chezley/metatrans-smk-hs/test/trinity-de/run-trinity-de.sh"