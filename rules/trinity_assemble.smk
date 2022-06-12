rule assemble_samples:
	input: 
		left = expand("results/{samples.run}/sortmerna/{samples.sample}/paired_left.fq", samples=smpls.itertuples()),
		right = expand("results/{samples.run}/sortmerna/{samples.sample}/paired_right.fq", samples=smpls.itertuples()),
		samples = config["samples"]
	output: 
		assemble_samples = "results/{run}/trinity_output/assemble_samples.txt"
	run: 
		samples_list = []
		i = 0
		with open(input.samples, "r") as in_sample:
			in_sample.readline()
			samples_list = in_sample.readlines()
		
		with open(output.assemble_samples, "w") as out:
			for line_str in samples_list:
				line = line_str.split(",")
				out.write(f"{line[1]}\t{line[2]}\t{input.left[i]}\t{input.right[i]}\n")
				i += 1

rule trinity_assemble:
	input:
		left = expand("results/{samples.run}/sortmerna/{samples.sample}/paired_left.fq", samples=smpls.itertuples()),
		right = expand("results/{samples.run}/sortmerna/{samples.sample}/paired_right.fq", samples=smpls.itertuples()),
		samples = "results/{run}/trinity_output/assemble_samples.txt"
	output:
		out_dir = directory("results/{run}/trinity_output/trinity_assemble"),
		out_fasta = "results/{run}/trinity_output/trinity_assemble.Trinity.fasta",
		out_stats = "results/{run}/trinity_output/trinity_assemble/Trinity_stats.txt",
		out_gene_map="results/{run}/trinity_output/trinity_assemble.Trinity.fasta.gene_trans_map"
	params:
		max_memory = config["trinity-assemble"]["max_memory"],
		min_kmer_cov = config["trinity-assemble"]["min_kmer_cov"]
	threads:
		config["trinity"]["threads"]
	conda:
		config["trinity"]["environment"]
	log:
		"logs/{run}/trinity_assemble.log"
	benchmark:
		"benchmarks/{run}/trinity_assemble.txt"
	shell:
		"""
		Trinity \
  		  --normalize_reads \
		  --seqType fq \
		  --max_memory {params.max_memory} \
		  --samples_file results/{wildcards.run}/trinity_output/assemble_samples.txt \
		  --output {output.out_dir} \
		  --min_kmer_cov {params.min_kmer_cov} > {log}

		TrinityStats.pl \
		  {output.out_fasta} \
		  > {output.out_stats}
		"""