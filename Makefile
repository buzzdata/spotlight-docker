IMAGE ?= spotlight-docker
CONTAINER ?= spotlight-en
PORT ?= 2222
# Host directory mounted at /opt/spotlight/models (tar.gz or extracted en/, or both)
MODELS ?= $(CURDIR)/models
# Optional: tarball basename under that directory (default in spotlight_s3.sh: spotlight-model-en.tar.gz)
MODEL_TAR ?=

DOCKER_RUN_OPTS := --name $(CONTAINER) -p $(PORT):80 -v $(MODELS):/opt/spotlight/models
ifneq ($(strip $(MODEL_TAR)),)
DOCKER_RUN_OPTS += -e SPOTLIGHT_MODEL_TAR=/opt/spotlight/models/$(MODEL_TAR)
endif

.PHONY: build run run-detached stop logs

build:
	docker build -f dockerfile -t $(IMAGE) .

# Foreground (attached): JVM and Spotlight logs stream in this terminal. Ctrl+C stops the container.
run:
	docker run --rm -it $(DOCKER_RUN_OPTS) $(IMAGE) /bin/spotlight_s3.sh

# Background: use `make logs` to follow the same stdout/stderr.
run-detached:
	docker run -d --restart unless-stopped $(DOCKER_RUN_OPTS) $(IMAGE) /bin/spotlight_s3.sh

logs:
	docker logs -f $(CONTAINER)

stop:
	-docker stop $(CONTAINER) 2>/dev/null
	-docker rm $(CONTAINER) 2>/dev/null
