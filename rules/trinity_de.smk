import os

rule trinity_de:
	input: 
		assembly = "results/{run}/trinity_output/trinity_assemble/Trinity.fasta",
		align_estimate_abundance = expand("results/{samples.run}/trinity_output/trinity_de/{samples.sample}/", samples=smpls.itertuples())
	output: 
		touch("results/{run}/trinity_output/trinity_script_test.done")
	params:
		workdir = os.getcwd()
	threads:
		config["trinity"]["threads"]
	conda:
		config["mtrans-smk-hs"]["environment"]
	log:
		"logs/{run}/trinity_de.log"
	shell:
		"bash scripts/run-trinity-de.sh {input.assembly} {wildcards.run} {params.workdir} > {log}"

rule trinty_align_estimate_abundance:
	input: 
		assembly = "results/{run}/trinity_output/trinity_assemble/Trinity.fasta",
		gene_trans_map="results/{run}/trinity_output/trinity_assemble/Trinity.fasta.gene_trans_map",
		left = "results/{run}/trimmomatic/{sample}.R1.paired.fastq.gz",
		right = "results/{run}/trimmomatic/{sample}.R2.paired.fastq.gz"
	output: 
		directory("results/{run}/trinity_output/trinity_de/{sample}")
	conda:
		config["mtrans-smk-hs"]["environment"]
	log:
		"logs/{run}/trinity_align_estimate_abundance/{sample}.log"
	shell:
		"""
		align_and_estimate_abundance.pl \
    	  --transcripts {input.assembly} \
    	  --seqType fq \
    	  --left {input.left} \
    	  --right {input.right} \
    	  --prep_reference \
    	  --est_method RSEM \
    	  --aln_method bowtie2 \
    	  --gene_trans_map {input.gene_trans_map} \
    	  --output_dir results/{wildcards.run}/trinity_output/trinity_de/{wildcards.sample} > {log}
		"""


rule isoform_matrix:
	input:
		align_estimate_abundance = expand("results/{samples.run}/trinity_output/trinity_de/{samples.sample}/", samples=smpls.itertuples())
	output: 
		"results/{run}/trinity_output/trinity_de/edgeR-output/trinity-de.isoform.counts.matrix"
	conda:
		config["mtrans-smk-hs"]["environment"]
	shell: 
		"""
		mkdir -p results/{wildcards.run}/trinity_output/trinity_de/edgeR-output
		ls results/{wildcards.run}/trinity_output/trinity_de/*/RSEM.isoforms.results > results/{wildcards.run}/trinity_output/trinity_de/isoform-file-paths.txt
		abundance_estimates_to_matrix.pl \
  			--est_method RSEM \
  			--out_prefix results/{wildcards.run}/trinity_output/trinity_de/edgeR-output/trinity-de \
  			--gene_trans_map none \
  			--name_sample_by_basedir \
  			--quant_files results/{wildcards.run}/trinity_output/trinity_de/isoform-file-paths.txt
		"""

rule gene_matrix:
	input:
		align_estimate_abundance = expand("results/{samples.run}/trinity_output/trinity_de/{samples.sample}/", samples=smpls.itertuples()),
		gene_trans_map="results/{run}/trinity_output/trinity_assemble/Trinity.fasta.gene_trans_map"
	output: 
		"results/{run}/trinity_output/trinity_de/edgeR-output/trinity-de.genes.counts.matrix"
	conda:
		config["mtrans-smk-hs"]["environment"]
	shell: 
		"""
		mkdir -p results/{wildcards.run}/trinity_output/trinity_de/edgeR-output
		ls results/{wildcards.run}/trinity_output/trinity_de/*/RSEM.genes.results > results/{wildcards.run}/trinity_output/trinity_de/genes-file-paths.txt
		abundance_estimates_to_matrix.pl \
  			--est_method RSEM \
  			--out_prefix trinity-de \
  			--gene_trans_map {input.gene_trans_map} \
  			--name_sample_by_basedir \
  			--quant_files results/{wildcards.run}/trinity_output/trinity_de/genes-file-paths.txt
		"""

rule sample_file:
	input: 
		samples="samples.csv"
	output: 
		sample_file="results/{run}/trinity_output/trinity_de/edgeR-output/sample-file.txt"
	conda:
		config["mtrans-smk-hs"]["environment"]
	shell: 
		"""
		cat {input.samples} | awk -F "," '{{print $2"\t"$3}}' | awk 'NR!=1 {{print}}' | sort | uniq > {output.sample_file}
		"""

rule DE_analysis_isoform:
	input: 
		matrix="results/{run}/trinity_output/trinity_de/edgeR-output/trinity-de.isoform.counts.matrix",
		sample_file="results/{run}/trinity_output/trinity_de/edgeR-output/sample-file.txt"
	output: 
		directory("results/{run}/trinity_output/trinity_de/edgeR-output/edgeR-isoform"),
		"results/{run}/trinity_output/trinity_de/edgeR-output/trinity-de.isoform.TMM.EXPR.matrix"
	conda:
		config["mtrans-smk-hs"]["environment"]
	shell: 
		"""
		run_DE_analysis.pl \
    		--matrix {input.matrix} \
    		--method edgeR \
    		--samples_file {input.sample_file} \
    		--output results/{wildcards.run}/trinity_output/trinity_de/edgeR-output/edgeR-isoform
		"""

rule DE_analysis_genes:
	input: 
		matrix="results/{run}/trinity_output/trinity_de/edgeR-output/trinity-de.genes.counts.matrix",
		sample_file="results/{run}/trinity_output/trinity_de/edgeR-output/sample-file.txt"
	output: 
		directory("results/{run}/trinity_output/trinity_de/edgeR-output/edgeR-genes"),
		"results/{run}/trinity_output/trinity_de/edgeR-output/trinity-de.genes.TMM.EXPR.matrix"
	conda:
		config["mtrans-smk-hs"]["environment"]
	shell: 
		"""
		run_DE_analysis.pl \
    		--matrix {input.matrix} \
    		--method edgeR \
    		--samples_file {input.sample_file} \
    		--output results/{wildcards.run}/trinity_output/trinity_de/edgeR-output/edgeR-genes
		"""

rule isoform_analysis:
	input: 
		matrix="results/{run}/trinity_output/trinity_de/edgeR-output/trinity-de.isoform.TMM.EXPR.matrix",
		sample_file="results/{run}/trinity_output/trinity_de/edgeR-output/sample-file.txt",
		direc="results/{run}/trinity_output/trinity_de/edgeR-output/edgeR-isoform"
	output: 
		touch("results/{run}/trinity_output/trinity_de/isoform.done")
	conda:
		config["mtrans-smk-hs"]["environment"]
	shell:
		"""
		analyze_diff_expr.pl \
    		--matrix {input.matrix} \
    		-P 0.01 -C 1 \
    		--samples {input.sample_file}

		PtR \
   			--matrix {input.matrix} \
    		--samples {input.sample_file} \
    		--log2 --prin_comp 3
		"""

rule genes_analysis:
	input: 
		matrix="results/{run}/trinity_output/trinity_de/edgeR-output/trinity-de.genes.TMM.EXPR.matrix",
		sample_file="results/{run}/trinity_output/trinity_de/edgeR-output/sample-file.txt",
		direc="results/{run}/trinity_output/trinity_de/edgeR-output/edgeR-genes"
	output: 
		touch("results/{run}/trinity_output/trinity_de/genes.done")
	conda:
		config["mtrans-smk-hs"]["environment"]
	shell:
		"""
		analyze_diff_expr.pl \
    		--matrix {input.matrix} \
    		-P 0.01 -C 1 \
    		--samples {input.sample_file}

		PtR \
   			--matrix {input.matrix} \
    		--samples {input.sample_file} \
    		--log2 --prin_comp 3
		"""