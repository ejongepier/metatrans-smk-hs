import os

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
	benchmark:
		"benchmarks/{run}/{sample}-trinity_align_estimate_abundance.txt"
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
    	  --output_dir "results/{wildcards.run}/trinity_output/trinity_de/{wildcards.sample}" > {log}
		"""

rule isoform_matrix:
	input:
		align_estimate_abundance=expand("results/{samples.run}/trinity_output/trinity_de/{samples.sample}/", samples=smpls.itertuples())
	output: 
		isoform_path="results/{run}/trinity_output/trinity_de/isoform-file-paths.txt",
		isoform_count="results/{run}/trinity_output/trinity_de/edgeR-output/trinity-de.isoform.counts.matrix",
		isoform_TMM="results/{run}/trinity_output/trinity_de/edgeR-output/trinity-de.isoform.TMM.EXPR.matrix"
	params:
		edgeR_dir="results/{run}/trinity_output/trinity_de/edgeR-output"
	conda:
		config["mtrans-smk-hs"]["environment"]
	log:
		"logs/{run}/isoforms_abundance_estimates_to_matrix.log"
	benchmark:
		"benchmarks/{run}/isoforms_abundance_estimates_to_matrix.txt"
	shell: 
		"""
		ls results/{wildcards.run}/trinity_output/trinity_de/*/RSEM.isoforms.results > {output.isoform_path}
		abundance_estimates_to_matrix.pl \
  			--est_method RSEM \
  			--out_prefix {params.edgeR_dir}/trinity-de \
  			--gene_trans_map none \
  			--name_sample_by_basedir \
  			--quant_files {output.isoform_path} > {log}
		"""

rule gene_matrix:
	input:
		align_estimate_abundance=expand("results/{samples.run}/trinity_output/trinity_de/{samples.sample}/", samples=smpls.itertuples()),
		gene_trans_map="results/{run}/trinity_output/trinity_assemble/Trinity.fasta.gene_trans_map"
	output:
		gene_path="results/{run}/trinity_output/trinity_de/gene-file-paths.txt",
		gene_counts="results/{run}/trinity_output/trinity_de/edgeR-output/trinity-de.gene.counts.matrix",
		gene_TMM="results/{run}/trinity_output/trinity_de/edgeR-output/trinity-de.gene.TMM.EXPR.matrix"
	params:
		edgeR_dir="results/{run}/trinity_output/trinity_de/edgeR-output"
	conda:
		config["mtrans-smk-hs"]["environment"]
	log:
		"logs/{run}/gene_abundance_estimates_to_matrix.log"
	benchmark:
		"benchmarks/{run}/gene_abundance_estimates_to_matrix.txt"
	shell: 
		"""
		ls results/{wildcards.run}/trinity_output/trinity_de/*/RSEM.isoforms.results > {output.gene_path}
		abundance_estimates_to_matrix.pl \
  			--est_method RSEM \
  			--out_prefix {params.edgeR_dir}/trinity-de \
  			--gene_trans_map {input.gene_trans_map} \
  			--name_sample_by_basedir \
  			--quant_files {output.gene_path} > {log}
		"""

rule sample_file:
	input: 
		samples=config["samples"]
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
	log:
		"logs/{run}/isoform_DE_analysis.log"
	benchmark:
		"benchmarks/{run}/isoform_DE_analysis.txt"
	shell: 
		"""
		run_DE_analysis.pl \
    		--matrix {input.matrix} \
    		--method edgeR \
    		--samples_file {input.sample_file} \
    		--output {output.isoform_dir} > {log}
		"""

rule DE_analysis_gene:
	input: 
		matrix="results/{run}/trinity_output/trinity_de/edgeR-output/trinity-de.gene.counts.matrix",
		sample_file="results/{run}/trinity_output/trinity_de/edgeR-output/sample-file.txt"
	output: 
		gene_dir=directory("results/{run}/trinity_output/trinity_de/edgeR-output/edgeR-gene")
	conda:
		config["mtrans-smk-hs"]["environment"]
	log:
		"logs/{run}/gene_DE_analysis.log"
	benchmark:
		"benchmarks/{run}/gene_DE_analysis.txt"
	shell: 
		"""
		run_DE_analysis.pl \
    		--matrix {input.matrix} \
    		--method edgeR \
    		--samples_file {input.sample_file} \
    		--output {output.gene_dir} > {log}
		"""

rule isoform_analysis:
	input: 
		matrix="results/{run}/trinity_output/trinity_de/edgeR-output/trinity-de.isoform.TMM.EXPR.matrix",
		sample_file="results/{run}/trinity_output/trinity_de/edgeR-output/sample-file.txt"
	output: 
		touch("results/{run}/trinity_output/trinity_de/isoform.done"),
		report("results/{run}/trinity_output/trinity_de/edgeR-output/edgeR-isoform/diffExpr.P0.01_C1.0.matrix.log2.centered.genes_vs_samples_heatmap.pdf", category="Isoform analysis results", caption="../report/isoform_diffExpr_genes_vs_samples.rst"),
		report("results/{run}/trinity_output/trinity_de/edgeR-output/edgeR-isoform/diffExpr.P0.01_C1.0.matrix.log2.centered.sample_cor_matrix.pdf", category="Isoform analysis results", caption="../report/isoform_diffExpr_sample_cor_matrix.rst"),
		report("results/{run}/trinity_output/trinity_de/edgeR-output/edgeR-isoform/trinity-de.isoform.counts.matrix.C_vs_MA.edgeR.DE_results.MA_n_Volcano.pdf", category="Isoform analysis results", caption="../report/isoform_counts_C_vs_MA.rst"),
		report("results/{run}/trinity_output/trinity_de/edgeR-output/edgeR-isoform/trinity-de.isoform.TMM.EXPR.matrix.log2.prcomp.principal_components.pdf", category="Isoform analysis results", caption="../report/isoform_TMM_EXPR_prcomp.rst")
	params:
		isoform_dir="results/{run}/trinity_output/trinity_de/edgeR-output/edgeR-isoform/",
		prefix=os.getcwd(),
		P=config["trinity-DE"]["P_cutoff"],
		C=config["trinity-DE"]["fold_change"],
		PCA_components=config["trinity-DE"]["pca_components"]
	conda:
		config["mtrans-smk-hs"]["environment"]
	log:
		diff_expr="logs/{run}/isoform_analysis.log",
		PtR="logs/{run}/isoform_PtR.log"
	benchmark:
		"benchmarks/{run}/isoform_analysis.txt"
	shell:
		"""
		cd {params.isoform_dir}

		analyze_diff_expr.pl \
			--matrix {params.prefix}/{input.matrix} \
			--samples {params.prefix}/{input.sample_file} \
			-P {params.P} \
			-C {params.C} > {params.prefix}/{log.diff_expr}

		PtR \
			--matrix {params.prefix}/{input.matrix} \
			--samples {params.prefix}/{input.sample_file} \
			--log2 \
			--prin_comp {params.PCA_components} > {params.prefix}/{log.PtR}
		"""

rule gene_analysis:
	input: 
		matrix="results/{run}/trinity_output/trinity_de/edgeR-output/trinity-de.gene.TMM.EXPR.matrix",
		sample_file="results/{run}/trinity_output/trinity_de/edgeR-output/sample-file.txt"
	output: 
		touch("results/{run}/trinity_output/trinity_de/gene.done"),
		report("results/{run}/trinity_output/trinity_de/edgeR-output/edgeR-gene/diffExpr.P0.01_C1.0.matrix.log2.centered.genes_vs_samples_heatmap.pdf", category="Gene analysis results", caption="../report/genes_diffExpr_genes_vs_samples.rst"),
		report("results/{run}/trinity_output/trinity_de/edgeR-output/edgeR-gene/diffExpr.P0.01_C1.0.matrix.log2.centered.sample_cor_matrix.pdf", category="Gene analysis results", caption="../report/genes_diffExpr_sample_cor_matrix.rst"),
		report("results/{run}/trinity_output/trinity_de/edgeR-output/edgeR-gene/trinity-de.gene.counts.matrix.C_vs_MA.edgeR.DE_results.MA_n_Volcano.pdf", category="Gene analysis results", caption="../report/genes_counts_C_vs_MA.rst"),
		report("results/{run}/trinity_output/trinity_de/edgeR-output/edgeR-gene/trinity-de.gene.TMM.EXPR.matrix.log2.prcomp.principal_components.pdf", category="Gene analysis results", caption="../report/genes_TMM_EXPR_prcomp.rst")
	params:
		gene_dir="results/{run}/trinity_output/trinity_de/edgeR-output/edgeR-gene",
		prefix=os.getcwd(),
		P=config["trinity-DE"]["P_cutoff"],
		C=config["trinity-DE"]["fold_change"],
		PCA_components=config["trinity-DE"]["pca_components"]
	conda:
		config["mtrans-smk-hs"]["environment"]
	log:
		diff_expr="logs/{run}/gene_analysis.log",
		PtR="logs/{run}/isoform_PtR.log"
	benchmark:
		"benchmarks/{run}/gene_analysis.txt"
	shell:
		"""
		cd {params.gene_dir}

		analyze_diff_expr.pl \
			--matrix {params.prefix}/{input.matrix} \
			--samples {params.prefix}/{input.sample_file} \
			-P {params.P} \
			-C {params.C} > {params.prefix}/{log.diff_expr}

		PtR \
			--matrix {params.prefix}/{input.matrix} \
			--samples {params.prefix}/{input.sample_file} \
			--log2 \
			--prin_comp {params.PCA_components} > {params.prefix}/{log.PtR}
		 """