# Spotlight Docker (English)

[DBpedia Spotlight](https://www.dbpedia-spotlight.org/) for **English only** — no runtime download from DBpedia.

## What you ship to ECR

1. Put **`spotlight-model-en.tar.gz`** in **`models/spotlight-model-en.tar.gz`** (next to the **`dockerfile`**).
2. **`make build`** — Docker **extracts** the tarball into **`/opt/spotlight/models/`** during the build (**`en_model/`** ends up in the image). The **`.tar.gz`** is removed from the image after extract; the **extracted files remain**.
3. **Tag and push** to ECR.
4. **Run** with **no** models volume. **`CMD`** is **`/bin/spotlight_run.sh`** — the model is already in the image, so there is **no separate prepare step**.

The container listens on **port 80** internally; REST base **`/rest/`** (e.g. **`/rest/annotate`**).

## Requirements

- **`models/spotlight-model-en.tar.gz`** in the build context.
- **Memory:** **`-Xmx15G`** for English; size the task/node accordingly.

## Entrypoint

**`/bin/spotlight_run.sh`** — verifies **`en_model/`**, then starts **`dbpedia-spotlight.jar`**. To use a different model, change the tarball and **`make build`** again.

## Makefile

| Target | Purpose |
|--------|---------|
| **`make build`** | Build image (extract model during build). |
| **`make run`** / **`make run-detached`** | Run locally (same as ECR: no volume). |
| **`make stop`** / **`make logs`** | Container lifecycle. |

Variables: **`IMAGE`**, **`CONTAINER`**, **`PORT`**.

## Docker Compose

```bash
docker compose -f spotlight-compose.yml up -d
```

## Quick API check

```bash
curl "http://localhost:2222/rest/annotate" \
  --data-urlencode "text=President Obama called on Congress to extend a tax break for students." \
  --data "confidence=0.35" \
  -H "Accept: application/json"
```

Use **`PORT=...`** if not using **2222**.
