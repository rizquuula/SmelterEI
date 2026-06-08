# MinerU — Document Reader for SmelterEI

[MinerU](https://github.com/opendatalab/MinerU) turns PDFs (and images/Office docs)
into clean Markdown + structured JSON. In SmelterEI it's the **front door**: feed a
PDF → get extracted document → hand it to the agentic dataset generator.

This folder is split into two independently deployable services:

```
┌─────────────────────────────────────────────┐
│  Dev / CPU box                              │
│                                             │
│  mineru-client (:8000)                      │
│  client/docker-compose.yaml                 │
│  no model, no PyTorch                       │
└─────────────────┬───────────────────────────┘
                  │  HTTP :30000
                  │  MINERU_VLM_SERVER_URL
                  ▼
┌─────────────────────────────────────────────┐
│  GPU host                                   │
│                                             │
│  mineru-vlm-server (:30000)                 │
│  server/docker-compose.yaml                 │
│  CUDA + vllm + model weights                │
└─────────────────────────────────────────────┘
```

| Side | Path | Image size | GPU needed |
|---|---|---|---|
| Client (API gateway) | `client/` | ~200 MB | No |
| VLM server (inference) | `server/` | multi-GB | Yes (NVIDIA) |

## Client quick start

The client is the primary day-to-day workflow:

```bash
cd MinerU/client
cp .env.example .env          # set MINERU_VLM_SERVER_URL to your GPU host
docker compose up -d --build
docker compose logs -f        # watch for "Start MinerU FastAPI Service"
```

API is then on <http://localhost:8000> (Swagger UI at `/docs`).

Smoke test:

```bash
cd MinerU/client
./smoke-test.sh path/to/file.pdf
# or raw curl:
curl -X POST http://localhost:8000/file_parse \
  -F "files=@some.pdf" \
  -F "backend=vlm-http-client" \
  -F "server_url=http://gpu-host:30000" \
  -F "return_md=true"
```

See [`client/README.md`](client/README.md) for configuration details.

## GPU server

Deploy on your NVIDIA box:

```bash
cd MinerU/server
cp .env.example .env
docker compose up -d --build  # first run downloads model weights
```

See [`server/README.md`](server/README.md) for requirements and details.

## Per-request backend contract

The backend is chosen **per request** via the `backend` form field. Supported values
in MinerU 3.2.x:

| Backend | Where inference runs |
|---|---|
| `vlm-http-client` | Remote VLM server (default for this client) |
| `hybrid-http-client` | Remote VLM server (hybrid mode) |
| `vlm-auto-engine` | Local GPU (not this image) |
| `pipeline` | Local CPU/GPU (not this image) |

When using an `*http-client` backend, pass `server_url` in the form body (or set
`MINERU_VLM_SERVER_URL` in `.env`; `smoke-test.sh` forwards it automatically).

## Key endpoints

- `POST /file_parse` — main entry. Form fields: `files` (one or more), `backend`,
  `server_url`, `lang_list`, `formula_enable`, `table_enable`, `start_page_id`,
  `end_page_id`, `return_md`, `return_content_list`, `return_middle_json`,
  `response_format_zip`, …
- `GET /docs` — Swagger UI / full schema.
