FROM ubuntu:xenial

MAINTAINER sridhar <sridhar@wustl.edu>

LABEL docker_image R

RUN apt-get update -y && apt-get install -y --no-install-recommends \
    build-essential \
    bash-completion \
    ca-certificates \
    file \
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


ADD r-packages.R /opt/
RUN R -f /opt/r-packages.R

#RUN chmod +x /usr/local/lib/R/library/DEXSeq/python_scripts/* && \
#    ln -s /usr/local/lib/R/library/DEXSeq/python_scripts/ /opt/dexseq

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