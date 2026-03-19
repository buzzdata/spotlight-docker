#!/bin/sh
set -e

MODEL_DIR="/opt/spotlight/en"
MODEL_TAR="/tmp/model.tar.gz"

# Default S3 path (can be overridden)
S3_PATH=${S3_PATH:-"s3://dev-headless-ci/en_model.tar.gz"}

echo "Starting DBpedia Spotlight (S3 mode)..."
echo "Using S3 path: $S3_PATH"

if [ ! -d "$MODEL_DIR" ]; then
    echo "Model not found. Downloading from S3..."

    # retry logic
    for i in 1 2 3; do
        aws s3 cp "$S3_PATH" "$MODEL_TAR" && break
        echo "Download failed, retrying ($i/3)..."
        sleep 5
    done

    echo "Extracting model..."
    mkdir -p /opt/spotlight
    tar -xzf "$MODEL_TAR" -C /opt/spotlight

    echo "Cleaning up..."
    rm -f "$MODEL_TAR"

    echo "Model ready."
else
    echo "Model already exists. Skipping download."
fi

echo "Starting Spotlight server..."

exec java -jar /opt/spotlight/rest-*.jar \
    "$MODEL_DIR" \
    http://0.0.0.0:80/rest