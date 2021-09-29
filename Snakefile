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
		expand("results/{samples.run}/fastqc/{samples.sample}_fastqc.html",
			samples=smpls.itertuples())
		#expand("results/{samples.run}/trimmomatic/{samples.sample}.R1.paired.fastq.gz",
		#	samples=smpls.itertuples()),
		#"test/trinity-assemble/trinity-output/", 
		#"test/trinity-de/trinity-output/"



include: "rules/fastQC.smk"
include: "rules/trimmomatic.smk"
include: "rules/trinity_assemble.smk"
include: "rules/trinity_de.smk"