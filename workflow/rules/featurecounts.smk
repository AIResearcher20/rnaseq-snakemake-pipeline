
import pandas as pd

samples = pd.read_table(config["samples"])
SAMPLES = samples["sample"].tolist()

rule featurecounts:
    input:
        bam=expand("results/star/{sample}.sorted.bam", sample=SAMPLES),
        gtf=config["gtf"]
    output:
        counts="results/counts/gene_counts.txt"
    threads:
        config["threads"]
    log:
        "logs/featurecounts/featurecounts.log"
    benchmark:
        "benchmarks/featurecounts/featurecounts.txt"
    conda:
        "../envs/subread.yaml"
    shell:
        r"""
        mkdir -p results/counts logs/featurecounts benchmarks/featurecounts
        featureCounts -T {threads} -p -a {input.gtf} -o {output.counts} {input.bam} > {log} 2>&1
        """
