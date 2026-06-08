# MinerU VLM server — GPU image. Runs the `mineru-openai-server` (OpenAI-compatible)
# for use by the thin client (../client/) over the network.
#
# NOTE: The CUDA base version (12.4.1) must match your GPU host's driver.
# Check with: nvidia-smi --query-gpu=driver_version --format=csv,noheader
# Alternative: use MinerU's official CUDA image from
#   https://github.com/opendatalab/MinerU/tree/master/docker
FROM nvidia/cuda:12.4.1-runtime-ubuntu22.04

# Pin/relax the MinerU version from the build command if needed.
ARG MINERU_VERSION=">=3.2.1"

ENV PYTHONUNBUFFERED=1 \
    PIP_NO_CACHE_DIR=1 \
    PIP_DISABLE_PIP_VERSION_CHECK=1 \
    HF_HOME=/root/.cache/huggingface \
    MODELSCOPE_CACHE=/root/.cache/modelscope

# Python 3.12 + pip.
RUN apt-get update && apt-get install -y --no-install-recommends \
        software-properties-common && \
    add-apt-repository ppa:deadsnakes/ppa && \
    apt-get update && apt-get install -y --no-install-recommends \
        python3.12 \
        python3.12-distutils \
        curl && \
    curl -sS https://bootstrap.pypa.io/get-pip.py | python3.12 && \
    update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.12 1 && \
    update-alternatives --install /usr/bin/pip pip /usr/local/bin/pip3 1 && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# MinerU with the vllm extra: pulls vllm + CUDA torch wheels.
# First run will download model weights into the mounted cache volume.
RUN pip install -U "mineru[vllm]${MINERU_VERSION}"

EXPOSE 30000

# OpenAI-compatible VLM server; client reaches it at http://<host>:30000.
ENTRYPOINT ["mineru-openai-server"]
CMD ["--engine", "vllm", "--host", "0.0.0.0", "--port", "30000"]
