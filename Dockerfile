FROM ubuntu:18.04
ARG SOURCE_VERSION=202310
ARG CRAN_SOURCE=http://cran.irsn.fr/
MAINTAINER Amine Ghozlane "amine.ghozlane@pasteur.fr"
ENV TZ=Europe/Paris
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone
RUN apt-get update && apt-get install -y \
    wget \
    gdebi-core \
    libcurl4-openssl-dev\
    libcairo2-dev \
    libjpeg-dev \
    libtiff5-dev \
    libxt-dev \
    libxml2-dev \
    libxml2 \
    libreadline6-dev \
    git \
    libssl-dev \
    libssh2-1-dev \
    libnlopt-dev \
    python3-pip \
    python3-yaml \
    gcc \ 
    gfortran \ 
    g++ \
    make \
    openjdk-8-jdk \
    libmagick++-dev \
    tzdata
    
RUN pip3 install bioblend python-daemon==2.3.2

RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

#Download and install shiny server
RUN wget --no-verbose https://cran.r-project.org/src/base/R-3/R-3.6.1.tar.gz -P /opt/ && \
    tar -zxf /opt/R-3.6.1.tar.gz -C /opt && rm /opt/R-3.6.1.tar.gz && \
    cd /opt/R-3.6.1/ && ./configure --with-x=no && \
    make -j 4  && make install && cd / && rm -rf  /opt/R-3.6.1 && \  
    wget --no-verbose https://s3.amazonaws.com/rstudio-shiny-server-os-build/ubuntu-12.04/x86_64/VERSION -O "version.txt" && \
    VERSION=$(cat version.txt)  && \
    wget --no-verbose "https://s3.amazonaws.com/rstudio-shiny-server-os-build/ubuntu-12.04/x86_64/shiny-server-$VERSION-amd64.deb" -O ss-latest.deb && \
    gdebi -n ss-latest.deb && \
    rm -f version.txt ss-latest.deb && \
    wget https://zenodo.org/record/10001137/files/shaman_package_${SOURCE_VERSION}.tar.gz -P /opt && \
    mkdir /opt/packman

RUN R -e """install.packages('packrat', repos='${CRAN_SOURCE}');packrat::unbundle('/opt/shaman_package_${SOURCE_VERSION}.tar.gz', '/opt/packman')"""

COPY shiny-server.conf  /etc/shiny-server/shiny-server.conf
COPY .Rprofile  /srv/shiny-server/
COPY shiny-server.sh /usr/bin/shiny-server.sh
COPY run_kronarshy.R /usr/bin/run_kronarshy.R

RUN git clone https://github.com/pierreLec/KronaRShy.git /srv/shiny-server/kronarshy && \
    git clone https://github.com/aghozlane/shaman_bioblend.git /usr/bin/shaman_bioblend && \
    chown -R shiny.shiny  /srv/shiny-server/ && \
    chown -R shiny.shiny  /opt/packman/ && \
    rm /opt/shaman_package_${SOURCE_VERSION}.tar.gz && \
    cp /srv/shiny-server/.Rprofile /srv/shiny-server/kronarshy/.Rprofile && \
    chmod +x /usr/bin/shiny-server.sh

EXPOSE 80

EXPOSE 5438



CMD ["/usr/bin/shiny-server.sh"] 
