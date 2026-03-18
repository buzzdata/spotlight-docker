#!/bin/sh

set -e

MODELFOLDER=/opt/spotlight
MODEL_DIR=$MODELFOLDER/models/en
TAR_FILE=/tmp/model.tar.gz

# 🔹 CHANGE THIS to your S3 tar.gz path
S3_TAR_PATH="s3://dev-headless-ci/en_model.tar.gz"

echo "Model directory: $MODEL_DIR"

mkdir -p $MODELFOLDER/models

echo "Downloading model tar.gz from S3..."

# Download tar.gz
aws s3 cp $S3_TAR_PATH $TAR_FILE

echo "Extracting model..."

# Extract (this should create /opt/spotlight/models/en)
tar -xvf $TAR_FILE -C $MODELFOLDER/models

# Cleanup tar
rm -f $TAR_FILE

echo "$MODEL_DIR http://0.0.0.0:80/rest/"

# 🚀 Start Spotlight (same as original)
java -Dfile.encoding=UTF-8 -Xmx15G \
    -jar /opt/spotlight/dbpedia-spotlight.jar \
    $MODEL_DIR http://0.0.0.0:80/rest