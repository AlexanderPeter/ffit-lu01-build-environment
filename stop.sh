#!/usr/bin/env bash
set -e

docker stop nginx jenkins 2>/dev/null || true
docker rm nginx jenkins 2>/dev/null || true

echo "Containers stopped."
