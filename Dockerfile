FROM mrmagooey/hpcaas-container-base:0.1.2

### Install your dependencies ###
# RUN apt-get install -y <dependencies>

### Copy your code ###
# COPY code/* /hpcaas/code/

### Clean up APT when done ###
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

