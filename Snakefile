import re
import os
import yaml
from typing import List
from pathlib import Path
import pandas as pd
from snakemake.utils import min_version, validate

min_version("5.25")
report: "report/workflow.rst"

# ======================================================
# Config files
# ======================================================

configfile: "config.yaml"
validate(config, "schemas/config.schema.yaml")

smpls = pd.read_csv(config["samples"], dtype=str).set_index(["run", "sample"], drop=False)
smpls.index = smpls.index.set_levels([i.astype(str) for i in smpls.index.levels])
validate(smpls, schema="schemas/samples.schema.yaml")

wildcard_constraints:
    sample = '[A-Za-z0-9]+',
    run = '[A-Za-z0-9]+'

# ======================================================
# Rules
# ======================================================

rule all:
    input:
        expand("results/{samples.run}/trimmomatic/{samples.sample}.R1.paired.fastq.gz",
            samples=smpls.itertuples()
        )

# ======================================================
# Functions and Classes
# ======================================================


onsuccess:
    print("Metatrans finished!")
    print("To generate a report run: snakemake --report report/metatrans.zip")


onerror:
    print("Note the path to the log file for debugging.")
    print("Documentation is available at: ...")
    print("Issues can be raised at: https://github.com/ejongepier/metatrans-smk-hs/issues")


# ======================================================
# Global variables
# ======================================================

#======================================================
# Include
#======================================================

include: "rules/trimmomatic.smk"
