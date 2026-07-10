
import pandas as pd

samples = pd.read_table(config["samples"])
SAMPLES = samples["sample"].tolist()

rule multiqc:
    input:
        expand("results/fastqc/{sample}_R1_fastqc.zip", sample=SAMPLES),
        expand("results/fastqc/{sample}_R2_fastqc.zip", sample=SAMPLES),
        expand("results/fastp/{sample}.json", sample=SAMPLES),
        expand("results/star/{sample}.sorted.bam", sample=SAMPLES),
        "results/counts/gene_counts.txt"
    output:
        html="results/multiqc/multiqc_report.html",
        data=directory("results/multiqc/multiqc_data")
    threads:
        2
    log:
        "logs/multiqc/multiqc.log"
    benchmark:
        "benchmarks/multiqc/multiqc.txt"
    conda:
        "../envs/multiqc.yaml"
    shell:
        r"""
        mkdir -p results/multiqc logs/multiqc benchmarks/multiqc
        multiqc results --outdir results/multiqc --force > {log} 2>&1
        """
