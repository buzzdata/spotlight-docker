# Spotlight Docker (English)

This image runs [DBpedia Spotlight](https://www.dbpedia-spotlight.org/) for **English only**. It does **not** download models from DBpedia.

You **bind-mount one host directory** to **`/opt/spotlight/models`**. The startup script checks whether **`en_model/`** already has model files (the path used after extracting the English model tar); if not, it **extracts** your **`.tar.gz`** once and **does not modify or delete** the archive afterward. Then it starts the service.

The container listens on **port 80** internally; the API base path is **`/rest/`** (for example **`/rest/annotate`**).

## Requirements

- Docker
- A host folder mounted at **`/opt/spotlight/models`** containing either a populated **`en_model/`** directory or a compatible **`.tar.gz`** that unpacks so **`en_model/`** exists under that mount.
- **Memory:** the JVM uses **`-Xmx15G`** for English; ensure the host (or Docker limits) can accommodate it.

## Build

```bash
make build
```

Image tag defaults to **`spotlight-docker`** (`IMAGE=...` to override).

## Model layout (mounted path)

Default tarball path inside the mount: **`spotlight-model-en.tar.gz`**. Another basename: set **`MODEL_TAR`** in **`make`** or **`SPOTLIGHT_MODEL_TAR`** in the container.

Examples:

```bash
make run MODELS="$(pwd)/models"

make run MODELS="$(pwd)/models" MODEL_TAR=my-en-model.tar.gz
```

The mount is **not** a copy: host and container see the same files. **`spotlight_s3.sh`** only **adds** **`en_model/`** via **`tar`** when it is missing or empty; it does **not** remove or alter the **`.tar.gz`**.

## Run

| Command | Purpose |
|--------|---------|
| **`make run`** | Foreground (**`-it`**): logs in the terminal; **Ctrl+C** stops the container. |
| **`make run-detached`** | Daemon; use **`make logs`**. |
| **`make stop`** | Stop and remove **`spotlight-en`**. |
| **`make logs`** | **`docker logs -f`** for detached runs. |

Variables: **`IMAGE`**, **`CONTAINER`**, **`PORT`**, **`MODELS`**, **`MODEL_TAR`**.

## Docker Compose

```bash
docker compose -f spotlight-compose.yml up -d
```

Mounts **`./models`** → **`/opt/spotlight/models`** (same rules as above).

## Quick API check

```bash
curl "http://localhost:2222/rest/annotate" \
  --data-urlencode "text=President Obama called on Congress to extend a tax break for students." \
  --data "confidence=0.35" \
  -H "Accept: application/json"
```

Change the port with **`PORT=...`** (default **`2222`**).

## Startup script (`/bin/spotlight_s3.sh`)

1. If **`/opt/spotlight/models/en_model`** exists and is non-empty → continue.
2. Else if the configured **`.tar.gz`** exists → **`tar -xf`** into **`/opt/spotlight/models`** (nothing else before start).
3. Else → error.
4. Starts **`dbpedia-spotlight.jar`** on **`http://0.0.0.0:80/rest`**.
