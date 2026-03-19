# Variables
IMAGE_NAME=dbpedia-spotlight

# S3_PATH: from .env (if present), else fallback; override with make run S3_PATH=...
-include .env
S3_PATH ?= s3://dev-headless-ci/en_model.tar.gz
export S3_PATH

# Build image
build:
	docker build \
	--build-arg AWS_ACCESS_KEY_ID="${AWS_ACCESS_KEY_ID}" \
    --build-arg AWS_SECRET_ACCESS_KEY="${AWS_SECRET_ACCESS_KEY}" \
    --build-arg AWS_DEFAULT_REGION="${AWS_DEFAULT_REGION}" \
	-t $(IMAGE_NAME) .

# Run only spotlight service (detached)
deploy:
	docker compose -f spotlight-compose.yml --compatibility up -d

# Run in foreground with logs (default S3 path or: make run S3_PATH=s3://bucket/key)
run:
	docker compose -f spotlight-compose.yml --compatibility up

# Stop service
stop:
	docker compose -f spotlight-compose.yml stop

# Logs (follow)
logs:
	docker compose -f spotlight-compose.yml logs -f

# Remove container + volume (force fresh download)
reset:
	docker compose -f spotlight-compose.yml down -v
