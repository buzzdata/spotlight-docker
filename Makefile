IMAGE ?= spotlight-docker
CONTAINER ?= spotlight-en
PORT ?= 2222

.PHONY: build run run-detached stop logs

# Extract model at build time; default CMD is spotlight_run.sh — push to ECR.
build:
	docker build -f dockerfile -t $(IMAGE) .

run:
	docker run --rm -it --name $(CONTAINER) -p $(PORT):80 $(IMAGE)

run-detached:
	docker run -d --restart unless-stopped --name $(CONTAINER) -p $(PORT):80 $(IMAGE)

logs:
	docker logs -f $(CONTAINER)

stop:
	-docker stop $(CONTAINER) 2>/dev/null
	-docker rm $(CONTAINER) 2>/dev/null
