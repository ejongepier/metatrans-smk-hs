import os
import yaml
import pandas as pd
#from snakemake.utils import min_version, validate

configfile: "config.yaml"

smpls = pd.read_csv(config["samples"], dtype=str).set_index(["run", "sample"], drop=False)
smpls.index = smpls.index.set_levels([i.astype(str) for i in smpls.index.levels])

wildcard_constraints:
	sample = '[A-Za-z0-9]+',
	run = '[A-Za-z0-9]+'


rule all:
	input:
		#expand("results/{samples.run}/fastqc/raw/{samples.sample}",
		#	samples=smpls.itertuples()),
		#expand("results/{samples.run}/trimmomatic/{samples.sample}.R1.paired.fastq.gz",
		#	samples=smpls.itertuples()),
		#expand("results/{samples.run}/fastqc/trimmed/{samples.sample}",
		#	samples=smpls.itertuples())
		#expand("results/{samples.run}/trinity_output/trinity_assemble/Trinity_stats.txt",
		#	samples=smpls.itertuples())
		#expand("results/{samples.run}/trinity_output/trinity_de", samples=smpls.itertuples())
		##"results/demo/trinity_output/trinity_de.done"
		#expand("results/{samples.run}/trinity_output/trinity_de/{samples.sample}/", samples=smpls.itertuples())
		#expand("results/{samples.run}/trinity_output/trinity_de/edgeR-output/trinity-de.isoform.counts.matrix", samples=smpls.itertuples()),
		#expand("results/{samples.run}/trinity_output/trinity_de/edgeR-output/trinity-de.gene.counts.matrix", samples=smpls.itertuples())
		"results/demo/trinity_output/trinity_de/isoform.done",
		"results/demo/trinity_output/trinity_de/gene.done"



include: "rules/fastQC.smk"
include: "rules/trimmomatic.smk"
include: "rules/trinity_assemble.smk"
include: "rules/trinity_de.smk"
