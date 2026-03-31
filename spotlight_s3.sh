#!/bin/bash
set -euo pipefail

cd /opt/spotlight

MODEL_TAR="${SPOTLIGHT_MODEL_TAR:-/opt/spotlight/models/spotlight-model-en.tar.gz}"
MODEL_DIR="/opt/spotlight/models/en_model"

en_ready() {
  [ -d "$MODEL_DIR" ] && [ -n "$(ls -A "$MODEL_DIR" 2>/dev/null || true)" ]
}

if en_ready; then
  :
elif [ -f "$MODEL_TAR" ]; then
  mkdir -p /opt/spotlight/models
  tar -C /opt/spotlight/models -xf "$MODEL_TAR"
else
  echo "ERROR: Model not found at $MODEL_DIR and archive missing: $MODEL_TAR" >&2
  echo "Mount a host directory on /opt/spotlight/models with the tar.gz or an existing en_model/ tree." >&2
  exit 1
fi

if ! en_ready; then
  echo "ERROR: English model directory missing or empty: $MODEL_DIR" >&2
  echo "Provide a valid en_model/ tree or a tarball that unpacks to it under the mount." >&2
  exit 1
fi

echo "$MODEL_DIR http://0.0.0.0:80/rest/"
exec java -Dfile.encoding=UTF-8 -Xmx15G -jar /opt/spotlight/dbpedia-spotlight.jar "$MODEL_DIR" http://0.0.0.0:80/rest
