ARG osversion=xenial
FROM ubuntu:${osversion}

ARG VERSION=master
ARG VCS_REF
ARG BUILD_DATE
ARG osversion

RUN echo "osversion: "${osversion}", VCS_REF: "${VCS_REF}", BUILD_DATE: "${BUILD_DATE}", VERSION: "${VERSION}

LABEL maintainer="frank.foerster@ime.fraunhofer.de" \
      description="Dockerfile providing the DSS differential methylation package for GNU R" \
      version=${VERSION} \
      org.label-schema.vcs-ref=${VCS_REF} \
      org.label-schema.build-date=${BUILD_DATE} \
      org.label-schema.vcs-url="https://github.com/greatfireball/ime_dss.git"

RUN apt update && \
    apt --yes install \
       apt-transport-https \
       software-properties-common \
       wget && \
    apt-key adv --keyserver keyserver.ubuntu.com --recv-keys E298A3A825C0D65DFD57CBB651716619E084DAB9 && \
    add-apt-repository 'deb [arch=amd64,i386] https://cran.rstudio.com/bin/linux/ubuntu '${osversion}'/' && \
    apt update && \
    apt install --yes \
       libcurl4-openssl-dev \
       r-base \
       r-base-dev && \
    wget -O - http://ftp.gnu.org/gnu/parallel/parallel-20180622.tar.bz2 | tar xjf - && \
    cd parallel-20180622 && \
    ./configure && make && make install && \
    cd .. && rm -rf parallel-20180622 && \
    apt --yes autoremove \
    && apt autoclean \
    && rm -rf /var/lib/apt/lists/* /var/log/dpkg.log

RUN Rscript -e 'source("https://bioconductor.org/biocLite.R"); biocLite("DSS",suppressUpdates=T, ask=F, suppressAutoUpdate=T);'
RUN Rscript -e 'install.packages("tictoc")'

# Setup of /data volume and set it as working directory
VOLUME /data
WORKDIR /data
