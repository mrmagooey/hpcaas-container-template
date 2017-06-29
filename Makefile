.PHONY: all build 

all: build

build:
	docker build --label hpcaas.metadata="`cat metadata.json`" --label hpcaas.config="`cat container_config.json`" --label hpcaas.parameters="`cat parameters.json`" -t `python scripts/get_docker_tag.py` .


