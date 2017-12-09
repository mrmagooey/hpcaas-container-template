DOCKER_TAG:=latest

.PHONY: all build

all: build

DAEMON_COMMAND=_hpcaas_scripts/get_config.py daemon
PARAMETERS_COMMAND=_hpcaas_scripts/get_config.py parameters

DAEMON_VALID:=$(shell $(DAEMON_COMMAND) 1>&2 2> /dev/null; echo $$?)
PARAMETERS_VALID:=$(shell $(PARAMETERS_COMMAND) 1>&2 2> /dev/null; echo $$?)

DAEMON:=$(shell $(DAEMON_COMMAND))
PARAMETERS:=$(shell $(PARAMETERS_COMMAND))

build:
ifeq ($(DAEMON_VALID), 0)
ifeq ($(PARAMETERS_VALID), 0)
	docker build --label hpcaas.daemon="$(DAEMON)" --label hpcaas.parameters="$(PARAMETERS)" -t  $(DOCKER_TAG) .
endif
endif

