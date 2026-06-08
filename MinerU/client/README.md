# MinerU client

Thin `mineru-api` container — **no model, no PyTorch**. Routes parse requests to a
remote VLM server (`../server/`) via the `vlm-http-client` backend.

## Requirements

- Docker + Docker Compose
- A running `mineru-vlm-server` (see `../server/README.md`) reachable over the network

## Quick start

```bash
cd MinerU/client
cp .env.example .env        # set MINERU_VLM_SERVER_URL to your GPU host
docker compose up -d --build
docker compose logs -f      # watch for "Start MinerU FastAPI Service"
```

API is then on <http://localhost:8000> (Swagger UI at `/docs`).

## Configuration (`.env`)

| Variable | Default | Meaning |
|---|---|---|
| `MINERU_API_PORT` | `8000` | Host port for the API |
| `MINERU_API_MAX_CONCURRENT_REQUESTS` | `3` | Parallel parse requests |
| `MINERU_BACKEND` | `vlm-http-client` | Backend used per request |
| `MINERU_VLM_SERVER_URL` | `http://gpu-host:30000` | Remote VLM server URL |

## Smoke test

```bash
./smoke-test.sh path/to/file.pdf
```

Reads `MINERU_BACKEND` and `MINERU_VLM_SERVER_URL` from `.env` and forwards them in
the POST. Returns Markdown on success.

## Key endpoints

- `POST /file_parse` — main entry. Form fields: `files`, `backend`, `server_url`,
  `return_md`, `return_content_list`, `lang_list`, …
- `GET /docs` — Swagger UI / full schema.
