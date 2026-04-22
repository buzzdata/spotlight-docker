#!/bin/bash
set -euo pipefail

cd /opt/spotlight

MODEL_DIR="${1:-${SPOTLIGHT_MODEL_DIR:-/opt/spotlight/models/en_model}}"

en_ready() {
  [ -d "$MODEL_DIR" ] && [ -n "$(ls -A "$MODEL_DIR" 2>/dev/null || true)" ]
}

if ! en_ready; then
  echo "ERROR: No model at $MODEL_DIR — rebuild the image with models/spotlight-model-en.tar.gz in the build context." >&2
  exit 1
fi

echo "$MODEL_DIR http://0.0.0.0:80/rest/"
exec java -Dfile.encoding=UTF-8 -Xmx15G -jar /opt/spotlight/dbpedia-spotlight.jar "$MODEL_DIR" http://0.0.0.0:80/rest
