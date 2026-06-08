# MinerU — CPU image. Runs the `mineru-api` FastAPI service.
#
# This image ships CPU-only PyTorch so it runs on machines without a GPU
# (e.g. this WSL2 box). For real GPU acceleration use a remote VLM server
# (MINERU_BACKEND=vlm-http-client) or MinerU's official CUDA image —
# see README.md and docker-compose.gpu.yaml.
FROM python:3.12-slim-bookworm

# Pin/relax the MinerU version from the build command if needed.
ARG MINERU_VERSION=">=3.2.1"

ENV PYTHONUNBUFFERED=1 \
    PIP_NO_CACHE_DIR=1 \
    PIP_DISABLE_PIP_VERSION_CHECK=1 \
    HF_HOME=/root/.cache/huggingface \
    MODELSCOPE_CACHE=/root/.cache/modelscope

# System deps: libGL + glib for OpenCV, Noto CJK fonts for rendering, curl for healthcheck.
RUN apt-get update && apt-get install -y --no-install-recommends \
        libgl1 \
        libglib2.0-0 \
        fonts-noto-core \
        fonts-noto-cjk \
        fontconfig \
        curl && \
    fc-cache -fv && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Install CPU-only PyTorch first so the mineru[core] resolve below does not
# drag in multi-GB CUDA wheels on a GPU-less host.
RUN pip install --index-url https://download.pytorch.org/whl/cpu torch torchvision

# MinerU with the full "core" extra: pipeline backend + the mineru-api server.
RUN pip install -U --extra-index-url https://download.pytorch.org/whl/cpu "mineru[core]${MINERU_VERSION}"

EXPOSE 8000

# FastAPI app; bind 0.0.0.0 so it is reachable from the host / other containers.
ENTRYPOINT ["mineru-api"]
CMD ["--host", "0.0.0.0", "--port", "8000"]
