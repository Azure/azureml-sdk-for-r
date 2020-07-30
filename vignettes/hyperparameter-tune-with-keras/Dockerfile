FROM mcr.microsoft.com/azureml/base-gpu:openmpi3.1.2-cuda10.1-cudnn7-ubuntu18.04

RUN conda install -c r -y conda=4.8.3 r-essentials openssl=1.1.1c && \
	conda clean -ay && \
	pip install --no-cache-dir azureml-defaults tensorflow-gpu keras

ENV TAR="/bin/tar"
RUN R -e "install.packages(c('remotes', 'reticulate', 'optparse', 'azuremlsdk', 'keras'), repos = 'https://cloud.r-project.org/')"