FROM ubuntu:16.04

USER root:root
ENV LANG=C.UTF-8 LC_ALL=C.UTF-8
ENV DEBIAN_FRONTEND noninteractive
ENV TAR="/bin/tar"

# Install Common Dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    # SSH and RDMA
    libmlx4-1 \
    libmlx5-1 \
    librdmacm1 \
    libibverbs1 \
    libmthca1 \
    libdapl2 \
    dapl2-utils \
    openssh-client \
    openssh-server \
    iproute2 && \
    # Others
    apt-get install -y \
    build-essential \
    bzip2=1.0.6-8ubuntu0.2 \
    libbz2-1.0=1.0.6-8ubuntu0.2 \
    git=1:2.7.4-0ubuntu1.6 \
    wget \
    cpio && \
    apt-get clean -y && \
    rm -rf /var/lib/apt/lists/*

# Miniconda
ENV MINICONDA_VERSION 4.5.11
ENV PATH /opt/miniconda/bin:$PATH
RUN wget -qO /tmp/miniconda.sh https://repo.continuum.io/miniconda/Miniconda3-${MINICONDA_VERSION}-Linux-x86_64.sh && \
    bash /tmp/miniconda.sh -bf -p /opt/miniconda && \
    conda clean -ay && \
    rm -rf /opt/miniconda/pkgs && \
    rm /tmp/miniconda.sh && \
    find / -type d -name __pycache__ | xargs rm -rf

# R Packages
RUN conda install -c r -y r-essentials r-devtools && conda clean -ay

# AzureML SDK
# Get personal access token from https://github.com/settings/tokens
ARG GITHUB_AUTH_TOKEN
RUN pip install --no-cache-dir azureml-defaults && \
    R -e "devtools::install_github(repo = 'https://github.com/Azure/azureml-sdk-for-r', auth_token = '${GITHUB_AUTH_TOKEN}')"