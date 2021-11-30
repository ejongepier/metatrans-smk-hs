import os
import yaml
import pandas as pd
#from snakemake.utils import min_version, validate

configfile: "config.yaml"

## EJ: The following file can contain text that will be included with the workflow in the report.
## It would be nice to add a short paragraph there describing what the workflow does, e.g. copy from readme.
## That way the user has that information all bundled up with the results and configuration in one report.

#report:	"report/workflow.rst"

smpls = pd.read_csv(config["samples"], dtype=str).set_index(["run", "sample"], drop=False)
smpls.index = smpls.index.set_levels([i.astype(str) for i in smpls.index.levels])

wildcard_constraints:
	sample = '[A-Za-z0-9]+',
	run = '[A-Za-z0-9]+'


rule all:
	input:
		expand("results/{samples.run}/fastqc/raw/{samples.sample}",
			samples=smpls.itertuples()),
		expand("results/{samples.run}/trimmomatic/{samples.sample}.R1.paired.fastq.gz",
			samples=smpls.itertuples()),
		expand("results/{samples.run}/fastqc/trimmed/{samples.sample}",
			samples=smpls.itertuples()),
		expand("results/{samples.run}/trinity_output/trinity_assemble/Trinity_stats.txt",
			samples=smpls.itertuples()),
		#expand("results/{samples.run}/trinity_output/trinity_de", samples=smpls.itertuples()),
		#expand("results/{samples.run}/trinity_output/trinity_de/{samples.sample}/", samples=smpls.itertuples()),
		#expand("results/{samples.run}/trinity_output/trinity_de/edgeR-output/trinity-de.isoform.counts.matrix", samples=smpls.itertuples()),
		#expand("results/{samples.run}/trinity_output/trinity_de/edgeR-output/trinity-de.gene.counts.matrix", samples=smpls.itertuples()),
		"results/demo/trinity_output/trinity_de/isoform.done",
		"results/demo/trinity_output/trinity_de/gene.done"


## EJ: Subheaders can help stucture the script and improve readability
#====================================
# GLOBAL FUNCTIONS
#====================================

## EJ: These functions can be included in the Snakefile because they are used by multiple .smk rule files.
## That is preferable over defining the same function twice

def get_fastq(wildcards):
    return smpls.loc[(wildcards.run, wildcards.sample), ["fwd","rev"]].dropna()

def get_trimmed_input(wildcards):
    return expand("results/{run}/trimmomatic/{sample}.{direction}.paired.fastq.gz", 
                   run=wildcards.run, sample=wildcards.sample, direction=["R1","R2"]
           )



#====================================
# INCLUDE
#====================================

include: "rules/fastQC.smk"
include: "rules/trimmomatic.smk"
include: "rules/trinity_assemble.smk"
include: "rules/trinity_de.smk"

## EJ: pls add on success statement with suggestion how to generate the report, see earlier email
