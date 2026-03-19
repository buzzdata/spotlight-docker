#!/bin/sh
set -e

DATA_DIR="/opt/spotlight/data"
MODEL_TAR="/tmp/model.tar.gz"

# S3_PATH must be set by environment (.env or Makefile)
if [ -z "$S3_PATH" ]; then
    echo "Error: S3_PATH is not set. Set it in .env or run with S3_PATH=..."
    exit 1
fi

echo "Starting DBpedia Spotlight (S3 mode)..."
echo "Using S3 path: $S3_PATH"

# Download if no valid model (JAR needs model/tokens.mem under DATA_DIR)
NEED_DOWNLOAD=true
if [ -d "$DATA_DIR" ] && [ -n "$(find "$DATA_DIR" -type f -path '*/model/tokens.mem' 2>/dev/null | head -1)" ]; then
    NEED_DOWNLOAD=false
fi
if [ "$NEED_DOWNLOAD" = true ]; then
    echo "Model not found. Downloading from S3..."

    # retry logic
    for i in 1 2 3; do
        aws s3 cp "$S3_PATH" "$MODEL_TAR" && break
        echo "Download failed, retrying ($i/3)..."
        sleep 5
    done

    echo "Extracting model..."
    mkdir -p "$DATA_DIR"
    tar -xzf "$MODEL_TAR" -C "$DATA_DIR"

    echo "Cleaning up..."
    rm -f "$MODEL_TAR"

    echo "Model ready."
else
    echo "Model already exists. Skipping download."
fi

# JAR expects a dir that contains model/tokens.mem; tarball may have en/, en_model/en/, etc.
MODEL_TOKENS=$(find "$DATA_DIR" -type f -path '*/model/tokens.mem' 2>/dev/null | head -1)
if [ -z "$MODEL_TOKENS" ]; then
    echo "Error: Could not find model/tokens.mem under $DATA_DIR (invalid or unexpected tarball layout)"
    exit 1
fi
MODEL_DIR=$(dirname "$(dirname "$MODEL_TOKENS")")
echo "Using model directory: $MODEL_DIR"

echo "Starting Spotlight server..."

exec java -Dfile.encoding=UTF-8 -Xmx15G -jar /opt/spotlight/dbpedia-spotlight.jar \
    "$MODEL_DIR" \
    http://0.0.0.0:80/rest