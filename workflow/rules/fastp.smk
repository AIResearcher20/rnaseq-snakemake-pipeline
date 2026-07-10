
import pandas as pd

samples = pd.read_table(config["samples"])

rule fastp:
    input:
        R1=lambda wc: f"{config['raw_reads']}/{samples.loc[samples.sample==wc.sample,'R1'].values[0]}",
        R2=lambda wc: f"{config['raw_reads']}/{samples.loc[samples.sample==wc.sample,'R2'].values[0]}"
    output:
        R1="data/trimmed/{sample}_R1.trimmed.fastq.gz",
        R2="data/trimmed/{sample}_R2.trimmed.fastq.gz",
        html="results/fastp/{sample}.html",
        json="results/fastp/{sample}.json"
    params:
        outdir="results/fastp"
    log:
        "logs/fastp/{sample}.log"
    benchmark:
        "benchmarks/fastp/{sample}.txt"
    threads:
        config["threads"]
    conda:
        "../envs/fastp.yaml"
    shell:
        r"""
        mkdir -p data/trimmed results/fastp logs/fastp benchmarks/fastp
        fastp --thread {threads} --in1 {input.R1} --in2 {input.R2} --out1 {output.R1} --out2 {output.R2} --html {output.html} --json {output.json} > {log} 2>&1
        """
