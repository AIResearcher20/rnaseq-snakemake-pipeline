
import pandas as pd

samples = pd.read_table(config["samples"])
SAMPLES = samples["sample"].tolist()

rule star_index:
    input:
        fasta=config["genome_fasta"],
        gtf=config["gtf"]
    output:
        directory(config["star_index"])
    threads:
        config["threads"]
    log:
        "logs/star/index.log"
    benchmark:
        "benchmarks/star/index.txt"
    conda:
        "../envs/star.yaml"
    shell:
        r"""
        mkdir -p {output}
        STAR --runThreadN {threads} --runMode genomeGenerate --genomeDir {output} --genomeFastaFiles {input.fasta} --sjdbGTFfile {input.gtf} > {log} 2>&1
        """

rule star_align:
    input:
        index=config["star_index"],
        R1="data/trimmed/{sample}_R1.trimmed.fastq.gz",
        R2="data/trimmed/{sample}_R2.trimmed.fastq.gz"
    output:
        bam="results/star/{sample}.sorted.bam"
    params:
        prefix="results/star/{sample}_"
    threads:
        config["threads"]
    log:
        "logs/star/{sample}.log"
    benchmark:
        "benchmarks/star/{sample}.txt"
    conda:
        "../envs/star.yaml"
    shell:
        r"""
        mkdir -p results/star logs/star benchmarks/star
        STAR --genomeDir {input.index} --readFilesIn {input.R1} {input.R2} --readFilesCommand zcat --runThreadN {threads} --outSAMtype BAM SortedByCoordinate --outFileNamePrefix {params.prefix} > {log} 2>&1
        mv {params.prefix}Aligned.sortedByCoord.out.bam {output.bam}
        """
