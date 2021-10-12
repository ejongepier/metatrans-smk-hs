rule trinity_assemble:
	input:
		left = expand("results/{samples.run}/trimmomatic/{samples.sample}.R1.paired.fastq.gz", samples=smpls.itertuples()),
		right = expand("results/{samples.run}/trimmomatic/{samples.sample}.R2.paired.fastq.gz", samples=smpls.itertuples())
	output:
		out_dir = directory("results/{run}/trinity_output/trinity_assemble"),
		out_fasta = "results/{run}/trinity_output/trinity_assemble/Trinity.fasta",
		out_stats = "results/{run}/trinity_output/trinity_assemble/Trinity_stats.txt"
	threads:
		config["trinity"]["threads"]
	conda:
		config["mtrans-smk-hs"]["environment"]
	shell:
		"""
		Trinity \
  		  --normalize_reads \
  		  --seqType fq \
  		  --max_memory 16G \
  		  --left {input.left} \
  		  --right {input.right} \
  		  --output {output.out_dir} \
  		  --min_kmer_cov 1

		TrinityStats.pl \
  		  {output.out_fasta} \
  		  > {output.out_stats}
		"""