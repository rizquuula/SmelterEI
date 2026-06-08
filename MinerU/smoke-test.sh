#!/usr/bin/env bash
# Smoke-test the MinerU API: POST a PDF to /file_parse and print the markdown.
#
#   ./smoke-test.sh path/to/file.pdf
#
# Honors .env (MINERU_API_PORT, MINERU_BACKEND, MINERU_VLM_SERVER_URL).
set -euo pipefail
cd "$(dirname "$0")"

# Load .env if present (for PORT / BACKEND / SERVER_URL).
if [[ -f .env ]]; then set -a; . ./.env; set +a; fi

PDF="${1:?usage: ./smoke-test.sh path/to/file.pdf}"
PORT="${MINERU_API_PORT:-8000}"
BACKEND="${MINERU_BACKEND:-pipeline}"
URL="http://localhost:${PORT}/file_parse"

args=(-F "files=@${PDF}" -F "backend=${BACKEND}" -F "return_md=true" -F "return_content_list=true")

# For the remote-model backend, forward the server URL.
if [[ "${BACKEND}" == *http-client* && -n "${MINERU_VLM_SERVER_URL:-}" ]]; then
  args+=(-F "server_url=${MINERU_VLM_SERVER_URL}")
fi

echo ">> POST ${URL}  (backend=${BACKEND})"
curl -sS -X POST "${URL}" "${args[@]}"
echo
