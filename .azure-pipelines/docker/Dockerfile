FROM ubuntu:16.04

USER root:root
ENV LANG=C.UTF-8 LC_ALL=C.UTF-8
ENV DEBIAN_FRONTEND noninteractive

# Miniconda
ENV MINICONDA_VERSION 4.5.11
ENV PATH /opt/miniconda/bin:$PATH
RUN apt-get update && apt-get install -y bzip2 wget git libxrender1 && \
    wget -qO /tmp/miniconda.sh https://repo.continuum.io/miniconda/Miniconda3-${MINICONDA_VERSION}-Linux-x86_64.sh && \
    bash /tmp/miniconda.sh -bf -p /opt/miniconda && \
    conda clean -ay && \
    rm -rf /opt/miniconda/pkgs && \
    rm /tmp/miniconda.sh && \
    find / -type d -name __pycache__ | xargs rm -rf

RUN conda install -c r -y r-essentials r-devtools r-testthat r-reticulate && conda clean -ay && \
    pip install azureml-defaults azureml-dataprep[pandas,fuse]

# Azure CLI
RUN curl -sL https://aka.ms/InstallAzureCLIDeb | bash

# Install R packages from CRAN
RUN R -e 'install.packages(c("roxygen2", "pkgdown", "rcmdcheck", "fs", "lintr"), repos = "https://cloud.r-project.org/")'