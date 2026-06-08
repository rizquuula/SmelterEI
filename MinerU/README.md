# MinerU — Document Reader for SmelterEI

[MinerU](https://github.com/opendatalab/MinerU) turns PDFs (and images/Office docs)
into clean Markdown + structured JSON. In SmelterEI it's the **front door**: feed a
PDF → get extracted document → hand it to the agentic dataset generator.

This folder runs MinerU as an HTTP API via Docker Compose. **CPU by default** (runs on
this machine, no GPU), and **configurable for a remote model** when you want GPU speed.

```
PDF ──▶ mineru-api (this folder) ──▶ Markdown + JSON ──▶ dataset generator
                  │
                  └── backend=pipeline         → runs locally on CPU
                  └── backend=vlm-http-client  → offloads to a remote GPU server
```

## Quick start (CPU)

```bash
cd MinerU
cp .env.example .env          # already present; edit if you like
docker compose up -d --build  # first build ~ a few min; first parse downloads models
docker compose logs -f        # wait for "Start MinerU FastAPI Service"
```

API is then on <http://localhost:8000> (Swagger UI at `/docs`).

Test it:

```bash
./smoke-test.sh some.pdf
# or raw curl:
curl -X POST http://localhost:8000/file_parse \
  -F "files=@some.pdf" \
  -F "backend=pipeline" \
  -F "return_md=true" \
  -F "return_content_list=true"
```

> First parse pulls a few GB of pipeline models into `./models` (mounted cache).
> Subsequent runs are fast. CPU parsing is slower per page than GPU — fine for dev.

## Configuration (`.env`)

| Variable | Default | Meaning |
|---|---|---|
| `MINERU_API_PORT` | `8000` | Host port for the API |
| `MINERU_API_MAX_CONCURRENT_REQUESTS` | `3` | Parallel parse requests |
| `MINERU_DEVICE_MODE` | `cpu` | `cpu` or `cuda` |
| `MINERU_MODEL_SOURCE` | `huggingface` | `huggingface` \| `modelscope` \| `local` |
| `MINERU_MODELS_DIR` | `./models` | Host model cache (persisted) |
| `MINERU_OUTPUT_DIR` | `./output` | Host output dir (CLI use) |
| `MINERU_FORMULA_ENABLE` | `true` | Parse formulas |
| `MINERU_TABLE_ENABLE` | `true` | Parse tables |
| `MINERU_BACKEND` | `pipeline` | Backend the generator requests (see below) |
| `MINERU_VLM_SERVER_URL` | _(empty)_ | Remote VLM server URL for `vlm-http-client` |

## Remote model (GPU without a local GPU)

The backend is chosen **per request**, so this local CPU service stays a thin
orchestrator and the heavy model runs elsewhere:

1. On a GPU box, run MinerU's official VLM server (port `30000`) — see MinerU's
   [docker dir](https://github.com/opendatalab/MinerU/tree/master/docker).
2. Here, set in `.env`:
   ```dotenv
   MINERU_BACKEND=vlm-http-client
   MINERU_VLM_SERVER_URL=http://gpu-host:30000
   ```
3. Calls then offload inference to that server:
   ```bash
   curl -X POST http://localhost:8000/file_parse \
     -F "files=@some.pdf" \
     -F "backend=vlm-http-client" \
     -F "server_url=http://gpu-host:30000" \
     -F "return_md=true"
   ```
   (`./smoke-test.sh` adds `server_url` automatically when the backend is an http-client.)

## Local GPU (later)

On an NVIDIA host with `nvidia-container-toolkit`:

```bash
docker compose -f docker-compose.yaml -f docker-compose.gpu.yaml up -d
```

Note: the default image ships **CPU-only PyTorch**. For true local GPU inference,
point `image:` in `docker-compose.gpu.yaml` at MinerU's official CUDA image. For most
cases the **remote-model** path above is simpler.

## Key endpoints

- `POST /file_parse` — main entry. Form fields: `files` (one or more), `backend`,
  `server_url`, `lang_list`, `formula_enable`, `table_enable`, `start_page_id`,
  `end_page_id`, `return_md`, `return_content_list`, `return_middle_json`,
  `response_format_zip`, …
- `GET /docs` — Swagger UI / full schema.

## How the generator consumes this

Point the dataset generator at `http://localhost:${MINERU_API_PORT}/file_parse`,
read `MINERU_BACKEND` / `MINERU_VLM_SERVER_URL` from this same `.env`, and use the
returned Markdown + `content_list` JSON as the extracted-document input.
