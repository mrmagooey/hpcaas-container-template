.PHONY: all build 

all: build

METADATA_COMMAND=_hpcaas_scripts/get_config.py metadata
DAEMON_COMMAND=_hpcaas_scripts/get_config.py daemon
PARAMETERS_COMMAND=_hpcaas_scripts/get_config.py parameters
DOCKER_TAG_COMMAND=_hpcaas_scripts/get_docker_tag.py

METADATA_VALID:=$(shell $(METADATA_COMMAND) 1>&2 2> /dev/null; echo $$?)
DAEMON_VALID:=$(shell $(DAEMON_COMMAND) 1>&2 2> /dev/null; echo $$?)
PARAMETERS_VALID:=$(shell $(PARAMETERS_COMMAND) 1>&2 2> /dev/null; echo $$?)
DOCKER_TAG_VALID:=$(shell $(DOCKER_TAG_COMMAND) 1>&2 2> /dev/null; echo $$?)

METADATA:=$(shell $(METADATA_COMMAND))
DAEMON:=$(shell $(DAEMON_COMMAND))
PARAMETERS:=$(shell $(PARAMETERS_COMMAND))
DOCKER_TAG:=$(shell $(DOCKER_TAG_COMMAND))

build:
ifeq ($(METADATA_VALID), 0)
ifeq ($(DAEMON_VALID), 0)
ifeq ($(PARAMETERS_VALID), 0)
	docker build --label hpcaas.metadata="$(METADATA)" --label hpcaas.daemon="$(DAEMON)" --label hpcaas.parameters="$(PARAMETERS)" -t  $(DOCKER_TAG) .
endif
endif
endif
