FROM mcr.microsoft.com/azureml/base:openmpi3.1.2-ubuntu16.04

RUN conda install -c r -y r-essentials=3.6.0 rpy2 r-reticulate r-remotes r-e1071 r-optparse psutil && conda clean -ay && \
    pip install --no-cache-dir azureml-sdk azureml-dataprep[pandas,fuse] scikit-learn azure-storage-queue~=2.1 azure-storage-common~=2.1 filelock~=3.0 tensorflow==1.13.1 pillow tzlocal numpy

ENV TAR="/bin/tar"
RUN R -e "remotes::install_github(repo = 'https://github.com/Azure/azureml-sdk-for-r', ref = 'v0.5.6', upgrade = FALSE)"
RUN R -e "install.packages(c(\"tensorflow\", \"here\"), repos = \"http://cran.us.r-project.org\")"
