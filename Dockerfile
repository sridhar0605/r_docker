FROM ubuntu:16.04

MAINTAINER sridhar <sridhar@wustl.edu>

LABEL docker_image R

RUN apt-get update --fix-missing \
    && apt-get install -q -y libcurl4-gnutls-dev libxml2 libxml2-dev libreadline6 \
               libreadline6-dev wget gfortran g++ gcc make libpng-dev libjpeg-dev \
	       libcairo2-dev python-dev


RUN wget -q https://cran.r-project.org/src/base/R-3/R-3.3.3.tar.gz -O- | tar -xz -C /opt/ && \
    cd /opt/R-3.3.3/ && \
    ./configure --with-x=no && \
    make && \
    make install && \
    rm -rf /opt/R-3.3.3 

RUN Rscript -e 'source("http://bioconductor.org/biocLite.R"); biocLite("DESeq2")' && \
    Rscript -e 'source("http://bioconductor.org/biocLite.R"); biocLite("DEXSeq")' && \
    Rscript -e 'source("http://bioconductor.org/biocLite.R"); biocLite("limma")' && \
    Rscript -e 'install.packages(c("acepack", "RcppArmadillo", "statmod"))' && \
    Rscript -e 'source("http://bioconductor.org/biocLite.R"); biocLite(pkgs=c("BiocGenerics","biomaRt","Rsamtools","geneplotter","genefilter"));' && \
    Rscript -e 'source("http://bioconductor.org/biocLite.R"); biocLite(pkgs=c("BiocParallel","Biobase","SummarizedExperiment","IRanges","GenomicRanges","DESeq2","AnnotationDbi","S4Vectors"));' && \
    Rscript -e 'source("http://bioconductor.org/biocLite.R"); biocLite(pkgs=c("GenomicFeatures","pasilla","parathyroidSE","BiocStyle"));' && \
    Rscript -e 'install.packages(c("hwriter","stringr", "statmod","RColorBrewer","knitr","ggplot2","dplyr","tidyverse","reshape2"))'

RUN \
    chmod +x /usr/local/lib/R/library/DEXSeq/python_scripts/* && \
    ln -s /usr/local/lib/R/library/DEXSeq/python_scripts/ /opt/dexseq

RUN apt-get install patch
COPY dexseq.patch /tmp/

RUN patch -i /tmp/dexseq.patch /usr/local/lib/R/library/DEXSeq/python_scripts/dexseq_prepare_annotation.py 

RUN echo 'alias dexseq_count="python /opt/dexseq/dexseq_count.py"' >> ~/.bashrc
RUN echo 'alias dexseq_prepare_annotation="python /opt/dexseq/dexseq_prepare_annotation.py"' >> ~/.bashrc

RUN apt-get install -y python-pip

RUN pip install --upgrade pip \
    && pip install numpy \
    && pip install pysam \
    && pip install HTSeq

# Clean up
RUN \
    apt-get remove -q -y unzip libncurses5-dev \
    libxml2-dev libreadline6-dev gfortran g++ gcc make \
    libpng-dev libjpeg-dev libcairo2-dev python-dev python-pip \
    && apt-get autoremove -ys
   
# needed for MGI data mounts
RUN apt-get update && apt-get install -y libnss-sss && apt-get clean all
    
RUN apt-get install -y libgfortran3 libgomp1 libcairo2 libjpeg8 python