# MinerU VLM server — GPU image. Runs the `mineru-openai-server` (OpenAI-compatible)
# for use by the thin client (../client/) over the network.
#
# NOTE: The CUDA base version (12.4.1) must match your GPU host's driver.
# Check with: nvidia-smi --query-gpu=driver_version --format=csv,noheader
# Alternative: use MinerU's official CUDA image from
#   https://github.com/opendatalab/MinerU/tree/master/docker
FROM nvidia/cuda:12.4.1-runtime-ubuntu22.04

# Pin MinerU exactly for reproducible builds — this locks the bundled vLLM and
# the MinerU logits processor (mineru_vl_utils) that the VLM needs. Bump
# deliberately. Override at build time with --build-arg MINERU_VERSION="==X.Y.Z".
ARG MINERU_VERSION="==3.2.3"

ENV PYTHONUNBUFFERED=1 \
    PIP_NO_CACHE_DIR=1 \
    PIP_DISABLE_PIP_VERSION_CHECK=1 \
    HF_HOME=/root/.cache/huggingface \
    MODELSCOPE_CACHE=/root/.cache/modelscope

# Python 3.12 + pip. No python3.12-distutils: distutils was removed from Python
# 3.12 (PEP 632) and deadsnakes ships no such package. get-pip.py bootstraps pip
# without it; setuptools provides the distutils shim during PEP 517 builds.
RUN apt-get update && apt-get install -y --no-install-recommends \
        software-properties-common && \
    add-apt-repository ppa:deadsnakes/ppa && \
    apt-get update && apt-get install -y --no-install-recommends \
        python3.12 \
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
# vLLM engine + an explicit model pin, so we don't ride MinerU's shifting default
# VLM. MinerU consumes `--model` and hands the id to `vllm serve`; vLLM resolves
# it from Hugging Face by default. docker compose overrides this command to inject
# ${MINERU_VLM_MODEL} from .env — this literal is the standalone `docker run`
# default. (MinerU appends its logits processor automatically.)
CMD ["--engine", "vllm", "--model", "opendatalab/MinerU2.5-Pro-2605-1.2B", "--host", "0.0.0.0", "--port", "30000"]
