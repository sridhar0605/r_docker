FROM ubuntu:16.04

MAINTAINER sridhar <sridhar@wustl.edu>

LABEL docker_image R

RUN apt-get update -y && apt-get install -y --no-install-recommends \
    build-essential \
    g++ \
    bzip2 \
    gfortran \
    gsfonts \
    libbz2-1.0 \
    libcurl3 \
    libicu55 \
    libjpeg-turbo8 \
    libopenblas-dev \
    libpangocairo-1.0-0 \
    libpcre3 \
    libpng12-0 \
    libtiff5 \
    liblzma5 \
    locales \
    zlib1g \
    libbz2-dev \
    libcairo2-dev \
    libcurl4-openssl-dev \
    libpango1.0-dev \
    libjpeg-dev \
    libicu-dev \
    libmariadb-client-lgpl-dev \
    libmysqlclient-dev \
    libpcre3-dev \
    libpng-dev \
    libreadline-dev \
    libtiff5-dev \
    liblzma-dev \
    libx11-dev \
    libxt-dev \
    tcl8.5-dev \
    tk8.5-dev \
    texinfo \
    texlive-extra-utils \
    texlive-fonts-recommended \
    texlive-fonts-extra \
    texlive-latex-recommended \
    x11proto-core-dev \
    xauth \
    xfonts-base \
    xvfb \
    zlib1g-dev \
    python-dev \
    wget


RUN wget -q https://cran.r-project.org/src/base/R-3/R-3.3.3.tar.gz --no-check-certificate && \
    tar -xzf R-3.3.3.tar.gz -C /opt && \
    cd /opt/R-3.3.3/ && \
    ./configure --with-x=no && \
    make && \
    make install && \
    rm -rf /opt/R-3.3.3

RUN Rscript -e 'source("http://bioconductor.org/biocLite.R"); biocLite("DESeq2")' 
RUN Rscript -e 'source("http://bioconductor.org/biocLite.R"); biocLite("DEXSeq")'
RUN Rscript -e 'source("http://bioconductor.org/biocLite.R"); biocLite("limma")'
RUN Rscript -e 'install.packages(c("acepack", "RcppArmadillo", "statmod"))'
RUN Rscript -e 'source("http://bioconductor.org/biocLite.R"); biocLite(pkgs=c("BiocGenerics","biomaRt","Rsamtools","geneplotter","genefilter"))'
RUN Rscript -e 'source("http://bioconductor.org/biocLite.R"); biocLite(pkgs=c("BiocParallel","Biobase","SummarizedExperiment","IRanges","GenomicRanges","DESeq2","AnnotationDbi","S4Vectors"));'
RUN Rscript -e 'source("http://bioconductor.org/biocLite.R"); biocLite(pkgs=c("GenomicFeatures","pasilla","parathyroidSE","BiocStyle"));'
RUN Rscript -e 'install.packages(c("hwriter","stringr", "statmod","RColorBrewer","knitr","ggplot2","dplyr","tidyverse","reshape2"))'

RUN chmod +x /usr/local/lib/R/library/DEXSeq/python_scripts/* && \
    ln -s /usr/local/lib/R/library/DEXSeq/python_scripts/ /opt/dexseq

RUN apt-get install patch


RUN apt-get install -y python-pip

RUN pip install --upgrade pip \
    && pip install numpy \
    && pip install pysam \
    && pip install HTSeq

# Clean up
RUN apt-get remove -q -y unzip libncurses5-dev && \
    libxml2-dev libreadline6-dev gfortran g++ gcc make && \
    libpng-dev libjpeg-dev libcairo2-dev python-dev python-pip && \
    apt-get autoremove -ys
   
# needed for MGI data mounts
RUN apt-get update && apt-get install -y libnss-sss && apt-get clean all
    
RUN apt-get install -y libgfortran3 libgomp1 libcairo2 libjpeg8 python