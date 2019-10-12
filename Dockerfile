FROM jupyter/scipy-notebook:latest
ENV LANG=C.UTF-8 LC_ALL=C.UTF-8
USER root
RUN apt-get update --fix-missing && apt-get install -y \
    byobu \
    ca-certificates \
    curl \
    git-core \
    htop \
    unzip \
    wget \
    libpq-dev \
    python-dev \
    python3-dev \
    build-essential \
    libspatialindex-dev \
    && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

#RUN wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O ~/miniconda.sh && \
#    /bin/bash ~/miniconda.sh -b -p /opt/conda

ENV PATH /opt/conda/bin:$PATH


RUN pip install --upgrade pip

RUN pip --no-cache-dir install \
    jupyter \
    jupyterlab \
    numpy \
    pandas \
    geopandas \
    descartes \
    osmnx \
    imblearn

RUN pip uninstall -y numpy; pip uninstall -y numpy;pip uninstall -y numpy
RUN pip --no-cache-dir install numpy


USER jovyan
WORKDIR /home/jovyan/

RUN rm -rf /home/jovyan/.jupyter

RUN jupyter notebook --generate-config
CMD jupyter lab --allow-root --ip=0.0.0.0
