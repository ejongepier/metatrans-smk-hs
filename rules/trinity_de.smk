rule align_samples:
	input: 
		assem_samples="results/{run}/trinity_output/assemble_samples.txt"
	output: 
		align_samples="results/{run}/trinity_output/align_samples.txt"
	run:
		samples_list = []
		with open(input.assem_samples, "r") as in_sample:
			samples_list = in_sample.readlines()
		with open(output.align_samples, "w") as out_sample:
			for line_str in samples_list:
				line = line_str.split("\t")
				out_sample.write(f"{line[0]}\tresults/{wildcards.run}/trinity_output/trinity_de/{line[1]}\t{line[2]}\t{line[3]}")

rule trinty_align_estimate_abundance:
	input: 
		assembly="results/{run}/trinity_output/trinity_assemble.Trinity.fasta",
		align_samples="results/{run}/trinity_output/align_samples.txt",
		left = expand("results/{samples.run}/sortmerna/{samples.sample}/paired_left.fq.gz", samples=smpls.itertuples()),
		right = expand("results/{samples.run}/sortmerna/{samples.sample}/paired_right.fq.gz", samples=smpls.itertuples())
	output:
		touch("results/{run}/trinity_output/align_estimate.done")
	params:
		gene_trans_map="results/{run}/trinity_output/trinity_assemble.Trinity.fasta.gene_trans_map"
	threads:
		config["trinity"]["threads"]
	conda:
		config["trinity"]["environment"]
	log:
		"logs/{run}/trinity_align_estimate_abundance.log"
	benchmark:
		"benchmarks/{run}/trinity_estimate_align_abundance.txt"
	shell:
		"""
		align_and_estimate_abundance.pl \
    	  --transcripts {input.assembly} \
    	  --seqType fq \
    	  --samples_file {input.align_samples} \
		  --thread_count {threads} \
    	  --prep_reference \
    	  --est_method RSEM \
    	  --aln_method bowtie2 \
    	  --gene_trans_map {params.gene_trans_map} > {log}
		"""

rule isoform_path:
	input: 
		#RSEM=expand("results/{samples.run}/trinity_output/trinity_de/{samples.sample}/RSEM.isoforms.results", samples=smpls.itertuples()),
		done_file="results/{run}/trinity_output/align_estimate.done"
	output: 
		isoform_path="results/{run}/trinity_output/trinity_de/isoform-file-paths.txt"
	shell: 
		"""ls results/{wildcards.run}/trinity_output/trinity_de/*/RSEM.isoforms.results > {output.isoform_path}"""

rule isoform_matrix:
	input:
		done_file="results/{run}/trinity_output/align_estimate.done",
		isoform_path="results/{run}/trinity_output/trinity_de/isoform-file-paths.txt"
	output: 
		isoform_count="results/{run}/trinity_output/trinity_de/edgeR-output/trinity-de.isoform.counts.matrix",
		isoform_TMM="results/{run}/trinity_output/trinity_de/edgeR-output/trinity-de.isoform.TMM.EXPR.matrix"
	params:
		edgeR_dir="results/{run}/trinity_output/trinity_de/edgeR-output"
	conda:
		config["trinity"]["environment"]
	log:
		"logs/{run}/isoforms_abundance_estimates_to_matrix.log"
	benchmark:
		"benchmarks/{run}/isoforms_abundance_estimates_to_matrix.txt"
	shell: 
		"""
		abundance_estimates_to_matrix.pl \
  			--est_method RSEM \
  			--out_prefix {params.edgeR_dir}/trinity-de \
  			--gene_trans_map none \
  			--name_sample_by_basedir \
  			--quant_files {input.isoform_path} > {log}
		"""

rule gene_matrix:
	input:
		done_file="results/{run}/trinity_output/align_estimate.done",
		isoform_path="results/{run}/trinity_output/trinity_de/isoform-file-paths.txt",
		gene_trans_map="results/{run}/trinity_output/trinity_assemble.Trinity.fasta.gene_trans_map"
	output:
		gene_counts="results/{run}/trinity_output/trinity_de/edgeR-output/trinity-de.gene.counts.matrix",
		gene_TMM="results/{run}/trinity_output/trinity_de/edgeR-output/trinity-de.gene.TMM.EXPR.matrix"
	params:
		edgeR_dir="results/{run}/trinity_output/trinity_de/edgeR-output"
	conda:
		config["trinity"]["environment"]
	log:
		"logs/{run}/gene_abundance_estimates_to_matrix.log"
	benchmark:
		"benchmarks/{run}/gene_abundance_estimates_to_matrix.txt"
	shell: 
		"""
		abundance_estimates_to_matrix.pl \
  		  --est_method RSEM \
  		  --out_prefix {params.edgeR_dir}/trinity-de \
  		  --gene_trans_map {input.gene_trans_map} \
  		  --name_sample_by_basedir \
  		  --quant_files {input.isoform_path} > {log}
		"""

rule sample_file:
	input: 
		samples=config["samples"]
	output: 
		sample_file="results/{run}/trinity_output/trinity_de/edgeR-output/sample-file.txt"
	conda:
		config["trinity"]["environment"]
	shell: 
		"""
		cat {input.samples} | awk -F "," '{{print $2"\t"$3}}' | awk 'NR!=1 {{print}}' | sort | uniq > {output.sample_file}
		"""

#De outputdirectory is gedefinieerd bij params vanwege een childIO error.
rule DE_analysis_isoform:
	input: 
		matrix="results/{run}/trinity_output/trinity_de/edgeR-output/trinity-de.isoform.counts.matrix",
		sample_file="results/{run}/trinity_output/trinity_de/edgeR-output/sample-file.txt"
	output: 
		isoform_done=touch("results/{run}/trinity_output/trinity_de/isoform_DE.done")
	params:
		isoform_dir=directory("results/{run}/trinity_output/trinity_de/edgeR-output/edgeR-isoform")
	conda:
		config["trinity"]["environment"]
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
    		--output {params.isoform_dir} > {log}
		"""

rule DE_analysis_gene:
	input: 
		matrix="results/{run}/trinity_output/trinity_de/edgeR-output/trinity-de.gene.counts.matrix",
		sample_file="results/{run}/trinity_output/trinity_de/edgeR-output/sample-file.txt"
	output: 
		gene_done=touch("results/{run}/trinity_output/trinity_de/gene_DE.done")
	params:
		gene_dir=directory("results/{run}/trinity_output/trinity_de/edgeR-output/edgeR-gene")
	conda:
		config["trinity"]["environment"]
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
    		--output {params.gene_dir} > {log}
		"""

rule isoform_analysis:
	input: 
		isoform_DE_done="results/{run}/trinity_output/trinity_de/isoform_DE.done",
		matrix="results/{run}/trinity_output/trinity_de/edgeR-output/trinity-de.isoform.TMM.EXPR.matrix",
		sample_file="results/{run}/trinity_output/trinity_de/edgeR-output/sample-file.txt"
	output: 
		"results/{run}/trinity_output/trinity_de/edgeR-output/edgeR-isoform/trinity-de.isoform.counts.matrix.C_vs_MA.edgeR.DE_results",
		touch("results/{run}/trinity_output/trinity_de/isoform.done"),
		touch(report("results/{run}/trinity_output/trinity_de/edgeR-output/edgeR-isoform/diffExpr.P"+str(config["trinity-DE"]["P_cutoff"])+"_C"+str(config["trinity-DE"]["fold_change"])+".matrix.log2.centered.genes_vs_samples_heatmap.pdf", category="Isoform analysis results", caption="../report/isoform_diffExpr_genes_vs_samples.rst")),
		touch(report("results/{run}/trinity_output/trinity_de/edgeR-output/edgeR-isoform/diffExpr.P"+str(config["trinity-DE"]["P_cutoff"])+"_C"+str(config["trinity-DE"]["fold_change"])+".matrix.log2.centered.sample_cor_matrix.pdf", category="Isoform analysis results", caption="../report/isoform_diffExpr_sample_cor_matrix.rst")),
		touch(report("results/{run}/trinity_output/trinity_de/edgeR-output/edgeR-isoform/trinity-de.isoform.counts.matrix.C_vs_MA.edgeR.DE_results.MA_n_Volcano.pdf", category="Isoform analysis results", caption="../report/isoform_counts_C_vs_MA.rst")),
		touch(report("results/{run}/trinity_output/trinity_de/edgeR-output/edgeR-isoform/trinity-de.isoform.TMM.EXPR.matrix.log2.prcomp.principal_components.pdf", category="Isoform analysis results", caption="../report/isoform_TMM_EXPR_prcomp.rst"))
	params:
		prefix=os.getcwd(),
		isoform_dir="results/{run}/trinity_output/trinity_de/edgeR-output/edgeR-isoform",
		P=config["trinity-DE"]["P_cutoff"],
		C=config["trinity-DE"]["fold_change"],
		PCA_components=config["trinity-DE"]["pca_components"]
	conda:
		config["trinity"]["environment"]
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
		gene_DE_done="results/{run}/trinity_output/trinity_de/gene_DE.done",
		matrix="results/{run}/trinity_output/trinity_de/edgeR-output/trinity-de.gene.TMM.EXPR.matrix",
		sample_file="results/{run}/trinity_output/trinity_de/edgeR-output/sample-file.txt"
	output: 
		touch("results/{run}/trinity_output/trinity_de/gene.done"),
		touch(report("results/{run}/trinity_output/trinity_de/edgeR-output/edgeR-gene/diffExpr.P"+str(config["trinity-DE"]["P_cutoff"])+"_C"+str(config["trinity-DE"]["fold_change"])+".matrix.log2.centered.genes_vs_samples_heatmap.pdf", category="Gene analysis results", caption="../report/genes_diffExpr_genes_vs_samples.rst")),
		touch(report("results/{run}/trinity_output/trinity_de/edgeR-output/edgeR-gene/diffExpr.P"+str(config["trinity-DE"]["P_cutoff"])+"_C"+str(config["trinity-DE"]["fold_change"])+".matrix.log2.centered.sample_cor_matrix.pdf", category="Gene analysis results", caption="../report/genes_diffExpr_sample_cor_matrix.rst")),
		touch(report("results/{run}/trinity_output/trinity_de/edgeR-output/edgeR-gene/trinity-de.gene.counts.matrix.C_vs_MA.edgeR.DE_results.MA_n_Volcano.pdf", category="Gene analysis results", caption="../report/genes_counts_C_vs_MA.rst")),
		touch(report("results/{run}/trinity_output/trinity_de/edgeR-output/edgeR-gene/trinity-de.gene.TMM.EXPR.matrix.log2.prcomp.principal_components.pdf", category="Gene analysis results", caption="../report/genes_TMM_EXPR_prcomp.rst"))
	params:
		prefix=os.getcwd(),
		gene_dir="results/{run}/trinity_output/trinity_de/edgeR-output/edgeR-gene",
		P=config["trinity-DE"]["P_cutoff"],
		C=config["trinity-DE"]["fold_change"],
		PCA_components=config["trinity-DE"]["pca_components"]
	conda:
		config["trinity"]["environment"]
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