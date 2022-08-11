import os
import yaml
import pandas as pd
from snakemake.utils import min_version, validate

configfile: "config.yaml"
report:	"report/workflow.rst"

smpls = pd.read_csv(config["samples"], dtype=str).set_index(["run", "sample"], drop=False)
smpls.index = smpls.index.set_levels([i.astype(str) for i in smpls.index.levels])

wildcard_constraints:
	sample = '[A-Za-z0-9_]+'

PARTS, = glob_wildcards("results/demo/interproscan/split_proteins/{part}.pep")

rule all:
	input:
		expand("results/{samples.run}/fastqc/raw/{samples.sample}",
			samples=smpls.itertuples()),
		expand("results/{samples.run}/trimmomatic/{samples.sample}.R1.paired.fastq.gz",
			samples=smpls.itertuples()),
		expand("results/{samples.run}/sortmerna/{samples.sample}/paired_left.fq.gz",
			samples=smpls.itertuples()),
		expand("results/{samples.run}/fastqc/trimmed_filtered/{samples.sample}",
			samples=smpls.itertuples()),
		expand("results/{samples.run}/trinity_output/trinity_assemble/Trinity_stats.txt",
			samples=smpls.itertuples()),
		expand("results/{samples.run}/trinity_output/trinity_de/isoform.done",
			samples=smpls.itertuples()),
		expand("results/{samples.run}/trinity_output/trinity_de/gene.done",
			samples=smpls.itertuples()),
		expand("results/{samples.run}/plots/processed_reads.pdf",
			samples=smpls.itertuples()),
		expand("results/{samples.run}/interproscan/split_proteins",
			samples=smpls.itertuples()),
		expand("results/{samples.run}/interproscan/output",
			samples=smpls.itertuples())

#====================================
# GLOBAL FUNCTIONS
#====================================

def get_raw_input(wildcards):
    return smpls.loc[(wildcards.run, wildcards.sample), ["fwd","rev"]].dropna()

def get_all_raw_input(wildcards):
	raw = smpls.loc[(wildcards.run), ["fwd","rev"]].dropna().values.tolist()
	flat_raw = []
	for item in raw:
		if type(item) == list:
			flat_raw.extend(item)
		else:
			flat_raw.append(item)
	return flat_raw

def get_trim_input(wildcards):
	return expand("results/{run}/trimmomatic/{sample}.R{direction}.paired.fastq.gz",
		run=wildcards.run, sample=wildcards.sample, direction=["1","2"])

def get_filter_input(wildcards):
    return expand("results/{run}/sortmerna/{sample}/paired_{direction}.fq.gz", 
    	run=wildcards.run, sample=wildcards.sample, direction=["left","right"])

#====================================
# HELP FUNCTIONS
#====================================

rule help:
	input:
		"Help.txt"
	shell:
		"cat {input}"

rule fastQC:
	input:
		expand("results/{samples.run}/fastqc/raw/{samples.sample}",
			samples=smpls.itertuples()),
		expand("results/{samples.run}/fastqc/trimmed_filtered/{samples.sample}",
			samples=smpls.itertuples())

rule rrna_databasen:
	input:
		expand("db/sortmerna/smr_v4.3_{database_type}_db.fasta", database_type=config["sortmerna"]["ref_database"])

rule filter_rna:
	input:
		expand("results/{samples.run}/sortmerna/{samples.sample}/paired_{direction}.fq.gz",
				samples=smpls.itertuples(), direction=["left","right"])

rule trinity_assembly:
	input:
		expand("results/{samples.run}/trinity_output/trinity_assemble/Trinity_stats.txt",
				samples=smpls.itertuples())

rule isoforms_analysis:
	input:
		expand("results/{samples.run}/trinity_output/trinity_de/isoform.done",
			samples=smpls.itertuples())

rule genes_analysis:
	input:
		expand("results/{samples.run}/trinity_output/trinity_de/gene.done",
			samples=smpls.itertuples())

rule read_analysis:
	input: 
		expand("results/{samples.run}/plots/processed_reads.pdf",
			samples=smpls.itertuples())

# ======================================================
# Functions and Classes
# ======================================================

onsuccess:
    print("DiFlex finished!")
    print("To generate a report run: snakemake --report reports/report.zip")

#====================================
# INCLUDE
#====================================

include: "rules/fastQC.smk"
include: "rules/trimmomatic.smk"
include: "rules/sortmerna.smk"
include: "rules/trinity_assemble.smk"
include: "rules/trinity_de.smk"
include: "rules/read_analyse.smk"
include: "rules/interproscan.smk"
