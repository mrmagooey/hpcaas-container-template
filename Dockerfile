FROM mrmagooey/hpcaas-container-base:0.1.0

## Install your dependencies ##
# RUN apt-get install -y <dependencies>

## Copy the code ##
COPY code/* /hpcaas/code/
# ENV CODE_BINARY_NAME=hpc_code

# Clean up APT when done.
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

