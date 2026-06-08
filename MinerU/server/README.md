# MinerU VLM server

GPU-side container — runs `mineru-openai-server` (OpenAI-compatible API, port 30000).
Deploy this on the box with an NVIDIA GPU; the thin client (`../client/`) calls it over
the network.

## Requirements

- Docker + Docker Compose
- [nvidia-container-toolkit](https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/install-guide.html) installed on the host
- NVIDIA driver compatible with CUDA 12.4 (check: `nvidia-smi`)

## Quick start

```bash
cd MinerU/server
cp .env.example .env          # adjust MINERU_MODELS_DIR if needed
docker compose up -d --build  # first run downloads model weights (several GB)
docker compose logs -f        # watch; ready when you see the server listening
```

Server is then on <http://localhost:30000>. Verify:

```bash
curl http://localhost:30000/v1/models
```

Then point the client at it:

```dotenv
# MinerU/client/.env
MINERU_VLM_SERVER_URL=http://<this-host>:30000
```

## Configuration (`.env`)

| Variable | Default | Meaning |
|---|---|---|
| `MINERU_VLM_PORT` | `30000` | Host port for the VLM server |
| `MINERU_MODEL_SOURCE` | `huggingface` | `huggingface` \| `modelscope` \| `local` |
| `MINERU_MODELS_DIR` | `./models` | Host model cache (persisted across restarts) |

## Notes

- Model weights are downloaded into `./models` on first start and reused.
- For an alternative to building from this Dockerfile, use MinerU's official CUDA image:
  <https://github.com/opendatalab/MinerU/tree/master/docker>
- The CUDA base in the Dockerfile (`12.4.1`) must match your host driver. Adjust the
  `FROM` line if needed.
