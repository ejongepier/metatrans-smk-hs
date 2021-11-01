rule trinity_assemble:
	input:
		left = expand("results/{samples.run}/trimmomatic/{samples.sample}.R1.paired.fastq.gz", samples=smpls.itertuples()),
		right = expand("results/{samples.run}/trimmomatic/{samples.sample}.R2.paired.fastq.gz", samples=smpls.itertuples())
	output:
		out_dir = directory("results/{run}/trinity_output/trinity_assemble"),
		out_fasta = "results/{run}/trinity_output/trinity_assemble/Trinity.fasta",
		out_stats = "results/{run}/trinity_output/trinity_assemble/Trinity_stats.txt",
		out_gene_map="results/{run}/trinity_output/trinity_assemble/Trinity.fasta.gene_trans_map"
	params:
		max_memory = config["trinity-assemble"]["max_memory"],
		min_kmer_cov = config["trinity-assemble"]["min_kmer_cov"]
	threads:
		config["trinity"]["threads"]
	conda:
		config["mtrans-smk-hs"]["environment"]
	log:
		"logs/{run}/trinity_assemble.log"
	shell:
		"""
		cat samples.csv | awk -F "," '{{print $1"\t"$3"\t"$4"\t"$5}}' | awk 'NR!=1 {{print}}' > results/demo/trinity_output/assemble_samples.txt
		Trinity \
  		  --normalize_reads \
  		  --seqType fq \
  		  --max_memory {params.max_memory} \
  		  --samples_file results/demo/trinity_output/assemble_samples.txt \
  		  --output {output.out_dir} \
  		  --min_kmer_cov {params.min_kmer_cov} > {log}

		TrinityStats.pl \
  		  {output.out_fasta} \
  		  > {output.out_stats}
		"""