# Variables
IMAGE_NAME=dbpedia-spotlight
SERVICE_NAME=spotlight
S3_PATH?=s3://dev-headless-ci/en_model.tar.gz

# Build image
build:
	docker build -t $(IMAGE_NAME) .

# Run only spotlight service
deploy:
	S3_PATH=$(S3_PATH) docker compose up -d $(SERVICE_NAME)

# Rebuild + run
run: 
	docker compose up $(SERVICE_NAME)

# Stop service
down:
	docker compose stop $(SERVICE_NAME)

# Logs
logs:
	docker compose logs -f $(SERVICE_NAME)

# Remove container + volume (force fresh download)
reset:
	docker compose down -v
