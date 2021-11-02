import os

# rule trinity_de:
# 	input: 
# 		assembly = "results/{run}/trinity_output/trinity_assemble/Trinity.fasta",
# 		align_estimate_abundance = expand("results/{samples.run}/trinity_output/trinity_de/{samples.sample}/", samples=smpls.itertuples())
# 	output: 
# 		touch("results/{run}/trinity_output/trinity_script_test.done")
# 	params:
# 		workdir = os.getcwd()
# 	threads:
# 		config["trinity"]["threads"]
# 	conda:
# 		config["mtrans-smk-hs"]["environment"]
# 	log:
# 		"logs/{run}/trinity_de.log"
# 	shell:
# 		"bash scripts/run-trinity-de.sh {input.assembly} {wildcards.run} {params.workdir} > {log}"

rule trinty_align_estimate_abundance:
	input: 
		assembly="results/{run}/trinity_output/trinity_assemble/Trinity.fasta",
		left="results/{run}/trimmomatic/{sample}.R1.paired.fastq.gz",
		right="results/{run}/trimmomatic/{sample}.R2.paired.fastq.gz"
	output: 
		sample_dir=directory("results/{run}/trinity_output/trinity_de/{sample}")
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
    	  --trinity_mode \
    	  --output_dir results/{wildcards.run}/trinity_output/trinity_de/{wildcards.sample} > {log}
		"""

#rule edgeR_dir:
#	output:	
#		edgeR=directory("results/{run}/trinity_output/trinity_de/edgeR-output")
#	shell:	
#		"""
#		mkdir --parents {output.edgeR}
#		"""

rule isoform_matrix:
	input:
		align_estimate_abundance=expand("results/{samples.run}/trinity_output/trinity_de/{samples.sample}/", samples=smpls.itertuples())
	output: 
		isoform_path="results/{run}/trinity_output/trinity_de/isoform-file-paths.txt",
		isoform_matrix="results/{run}/trinity_output/trinity_de/edgeR-output/trinity-de.isoform.counts.matrix"
	params:
		edgeR_dir="results/{run}/trinity_output/trinity_de/edgeR-output"
	conda:
		config["mtrans-smk-hs"]["environment"]
	shell: 
		"""
		ls results/{wildcards.run}/trinity_output/trinity_de/*/RSEM.isoforms.results > {output.isoform_path}
		abundance_estimates_to_matrix.pl \
  			--est_method RSEM \
  			--out_prefix {params.edgeR_dir}/trinity-de \
  			--gene_trans_map none \
  			--name_sample_by_basedir \
  			--quant_files {output.isoform_path}
		"""

rule gene_matrix:
	input:
		align_estimate_abundance=expand("results/{samples.run}/trinity_output/trinity_de/{samples.sample}/", samples=smpls.itertuples()),
		gene_trans_map="results/{run}/trinity_output/trinity_assemble/Trinity.fasta.gene_trans_map"
	output:
		gene_path="results/{run}/trinity_output/trinity_de/gene-file-paths.txt",
		gene_matrix="results/{run}/trinity_output/trinity_de/edgeR-output/trinity-de.gene.counts.matrix"
	params:
		edgeR_dir="results/{run}/trinity_output/trinity_de/edgeR-output"
	conda:
		config["mtrans-smk-hs"]["environment"]
	shell: 
		"""
		ls results/{wildcards.run}/trinity_output/trinity_de/*/RSEM.isoforms.results > {output.gene_path}
		abundance_estimates_to_matrix.pl \
  			--est_method RSEM \
  			--out_prefix {params.edgeR_dir}/trinity-de \
  			--gene_trans_map {input.gene_trans_map} \
  			--name_sample_by_basedir \
  			--quant_files {output.gene_path}
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
		isoform_dir=directory("results/{run}/trinity_output/trinity_de/edgeR-output/edgeR-isoform")
	conda:
		config["mtrans-smk-hs"]["environment"]
	shell: 
		"""
		run_DE_analysis.pl \
    		--matrix {input.matrix} \
    		--method edgeR \
    		--samples_file {input.sample_file} \
    		--output {output.isoform_dir}
		"""

rule DE_analysis_gene:
	input: 
		matrix="results/{run}/trinity_output/trinity_de/edgeR-output/trinity-de.gene.counts.matrix",
		sample_file="results/{run}/trinity_output/trinity_de/edgeR-output/sample-file.txt"
	output: 
		gene_dir=directory("results/{run}/trinity_output/trinity_de/edgeR-output/edgeR-gene")
	conda:
		config["mtrans-smk-hs"]["environment"]
	shell: 
		"""
		run_DE_analysis.pl \
    		--matrix {input.matrix} \
    		--method edgeR \
    		--samples_file {input.sample_file} \
    		--output {output.gene_dir}
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
		cd {input.direc}
		analyze_diff_expr.pl \
			--matrix {input.matrix} \
			-P 0.01 \
			-C 1 \
			--samples {input.sample_file}

		PtR \
			--matrix {input.matrix} \
			--samples {input.sample_file} \
			--log2 \
			--prin_comp 3
		"""

rule gene_analysis:
	input: 
		matrix="results/{run}/trinity_output/trinity_de/edgeR-output/trinity-de.gene.TMM.EXPR.matrix",
		sample_file="results/{run}/trinity_output/trinity_de/edgeR-output/sample-file.txt",
		direc="results/{run}/trinity_output/trinity_de/edgeR-output/edgeR-gene"
	output: 
		touch("results/{run}/trinity_output/trinity_de/gene.done")
	conda:
		config["mtrans-smk-hs"]["environment"]
	shell:
		"""
		cd {input.direc}
		analyze_diff_expr.pl \
			--matrix {input.matrix} \
			-P 0.01 \
			-C 1 \
			--samples {input.sample_file}

		PtR \
			--matrix {input.matrix} \
			--samples {input.sample_file} \
			--log2 \
			--prin_comp 3
		 """