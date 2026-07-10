
import pandas as pd

samples = pd.read_csv(config["samples"], sep="\t")
SAMPLES = samples["sample"].tolist()

rule all:
    input:
        expand("results/multiqc/multiqc_report.html", sample=SAMPLES)

rule fastp:
    input:
        r1="data/raw/{sample}_R1.fastq.gz",
        r2="data/raw/{sample}_R2.fastq.gz"
    output:
        r1="data/trimmed/{sample}_R1.fastq.gz",
        r2="data/trimmed/{sample}_R2.fastq.gz"
    threads: config["threads"]
    shell:
        """
        mkdir -p data/trimmed
        fastp \
          -i {input.r1} \
          -I {input.r2} \
          -o {output.r1} \
          -O {output.r2}
        """

rule star_align:
    input:
        r1="data/trimmed/{sample}_R1.fastq.gz",
        r2="data/trimmed/{sample}_R2.fastq.gz"
    output:
        bam="results/star/{sample}.bam"
    threads: config["threads"]
    shell:
        """
        mkdir -p results/star

        STAR \
          --genomeDir resources/star_index \
          --readFilesIn {input.r1} {input.r2} \
          --readFilesCommand zcat \
          --runThreadN {threads} \
          --outSAMtype BAM SortedByCoordinate \
          --outFileNamePrefix results/star/{wildcards.sample}_

        mv results/star/{wildcards.sample}_Aligned.sortedByCoord.out.bam {output.bam}
        """

rule featurecounts:
    input:
        bam="results/star/{sample}.bam"
    output:
        txt="results/counts/{sample}.txt"
    threads: config["threads"]
    shell:
        """
        mkdir -p results/counts

        featureCounts \
          -T {threads} \
          -a resources/annotation/chr22.gtf \
          -o {output.txt} \
          {input.bam}
        """

rule multiqc:
    input:
        expand("results/counts/{sample}.txt", sample=SAMPLES)
    output:
        "results/multiqc/multiqc_report.html"
    shell:
        """
        mkdir -p results/multiqc
        multiqc results -o results/multiqc
        """
