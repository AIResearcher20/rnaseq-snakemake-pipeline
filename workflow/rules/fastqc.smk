
import pandas as pd

samples = pd.read_table(config["samples"])
SAMPLES = samples["sample"].tolist()

rule fastqc:
    input:
        R1=lambda wc: f"{config['raw_reads']}/{samples.loc[samples.sample==wc.sample,'R1'].values[0]}",
        R2=lambda wc: f"{config['raw_reads']}/{samples.loc[samples.sample==wc.sample,'R2'].values[0]}"
    output:
        R1_html="results/fastqc/{sample}_R1_fastqc.html",
        R1_zip="results/fastqc/{sample}_R1_fastqc.zip",
        R2_html="results/fastqc/{sample}_R2_fastqc.html",
        R2_zip="results/fastqc/{sample}_R2_fastqc.zip"
    params:
        outdir="results/fastqc"
    log:
        "logs/fastqc/{sample}.log"
    benchmark:
        "benchmarks/fastqc/{sample}.txt"
    threads:
        config["threads"]
    conda:
        "../envs/fastqc.yaml"
    shell:
        r"""
        mkdir -p {params.outdir}
        fastqc --threads {threads} --outdir {params.outdir} {input.R1} {input.R2} > {log} 2>&1
        """
