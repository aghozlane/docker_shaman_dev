FROM ubuntu:15.04

MAINTAINER Amine Ghozlane "amine.ghozlane@pasteur.fr"
#pandoc-citeproc   pandoc  sudo 

RUN apt-get update && apt-get install -y \
    r-base \
    wget \
    gdebi-core \
    libcurl4-openssl-dev\
    libcairo2-dev \
    libxt-dev \
    libxml2-dev \
    libxml2 \
    git \
    libssl-dev \
    libssh2-1-dev

#Download and install shiny server
RUN wget --no-verbose https://s3.amazonaws.com/rstudio-shiny-server-os-build/ubuntu-12.04/x86_64/VERSION -O "version.txt" && \
    VERSION=$(cat version.txt)  && \
    wget --no-verbose "https://s3.amazonaws.com/rstudio-shiny-server-os-build/ubuntu-12.04/x86_64/shiny-server-$VERSION-amd64.deb" -O ss-latest.deb && \
    gdebi -n ss-latest.deb && \
    rm -f version.txt ss-latest.deb

RUN R -e """install.packages(c('digest', 'gtable', 'plyr', 'reshape2', 'scales','lazyeval', 'lme4', 'assertthat', 'R6', 'DBI', 'BH'), repos='http://cran.univ-paris1.fr/');install.packages(c('http://cran.r-project.org/src/contrib/Archive/ggplot2/ggplot2_2.1.0.tar.gz','http://cran.r-project.org/src/contrib/Archive/tibble/tibble_1.3.0.tar.gz'), repos=NULL, type='source'); library(tibble); install.packages('http://cran.r-project.org/src/contrib/Archive/dplyr/dplyr_0.5.0.tar.gz', repos=NULL, type='source');install.packages(c('shiny', 'shinydashboard', 'shinythemes', 'shinyjs', 'Rcpp', 'rjson', 'devtools', 'psych', 'vegan','dendextend','circlize', 'googleVis', 'DT', 'RColorBrewer', 'ade4', 'scales', 'gplots', 'maps','animation', 'clusterGeneration', 'coda', 'combinat', 'msm', 'numDeriv',  'plotrix', 'scatterplot3d', 'quadprog', 'igraph', 'fastmatch', 'sendmailR','shinyBS','flexdashboard', 'backports', 'readr', 'jsonlite', 'shinyFiles', 'philentropy'), repos='http://cran.univ-paris1.fr/'); source('http://bioconductor.org/biocLite.R'); biocLite(c('BiocInstaller', 'genefilter', 'DESeq2')); options(download.file.method = 'wget'); library(backports); devtools::install_github(c('aghozlane/biomformat', 'aghozlane/rNVD3', 'timelyportfolio/d3vennR', 'aghozlane/d3heatmap', 'aghozlane/scatterD3', 'pierreLec/treeWeightD3', 'aghozlane/shinydashboard', 'aghozlane/ape', 'aghozlane/phangorn', 'aghozlane/phytools', 'aghozlane/GUniFrac', 'pierreLec/PhyloTreeMetaR', 'pierreLec/KronaR', 'mangothecat/shinytoastr', 'aghozlane/shinyWidgets'))"""

COPY shiny-server.conf  /etc/shiny-server/shiny-server.conf

RUN git clone https://github.com/pierreLec/KronaRShy /srv/shiny-server/kronarshy &&\
    chown -R shiny.shiny  /srv/shiny-server/

EXPOSE 80

EXPOSE 5438

COPY shiny-server.sh /usr/bin/shiny-server.sh

COPY run_kronarshy.R /usr/bin/run_kronarshy.R

CMD ["/usr/bin/shiny-server.sh"]
