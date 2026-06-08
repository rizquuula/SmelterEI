# MinerU client — thin http-client image. Runs the `mineru-api` FastAPI service
# with NO local model and NO PyTorch. All inference is offloaded to a remote VLM
# server (MINERU_VLM_SERVER_URL). Set MINERU_BACKEND=vlm-http-client in .env.
FROM python:3.12-slim-bookworm

# Pin/relax the MinerU version from the build command if needed.
ARG MINERU_VERSION=">=3.2.1"

ENV PYTHONUNBUFFERED=1 \
    PIP_NO_CACHE_DIR=1 \
    PIP_DISABLE_PIP_VERSION_CHECK=1 \
    HF_HOME=/root/.cache/huggingface \
    MODELSCOPE_CACHE=/root/.cache/modelscope

# System deps: libGL + glib for opencv-python (base dep), curl for healthcheck.
# Fonts dropped — rendering is server-side.
RUN apt-get update && apt-get install -y --no-install-recommends \
        libgl1 \
        libglib2.0-0 \
        curl && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# No PyTorch here — mineru base deps are enough for mineru-api + vlm-http-client.
RUN pip install -U "mineru${MINERU_VERSION}"

EXPOSE 8000

# FastAPI app; bind 0.0.0.0 so it is reachable from the host / other containers.
ENTRYPOINT ["mineru-api"]
CMD ["--host", "0.0.0.0", "--port", "8000"]
