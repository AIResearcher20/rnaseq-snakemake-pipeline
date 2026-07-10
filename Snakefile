
configfile: "config/config.yaml"

import pandas as pd

# Include rules
include: "workflow/rules/fastqc.smk"
include: "workflow/rules/fastp.smk"
include: "workflow/rules/star.smk"
include: "workflow/rules/featurecounts.smk"
include: "workflow/rules/multiqc.smk"

# Read samples
samples = pd.read_table(config["samples"])
SAMPLES = samples["sample"].tolist()

# Target rule
rule all:
    input:
        "results/multiqc/multiqc_report.html"
