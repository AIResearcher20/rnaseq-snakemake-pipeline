FROM mambaorg/micromamba:latest

WORKDIR /pipeline

COPY . /pipeline

RUN micromamba install -y \
    -n base \
    -c conda-forge \
    -c bioconda \
    snakemake \
    fastqc \
    fastp \
    star \
    subread \
    multiqc

CMD ["snakemake","--cores","4"]