#!/usr/bin/env bash
set -e

docker stop nginx sonarqube jenkins 2>/dev/null || true
docker rm nginx sonarqube jenkins 2>/dev/null || true

echo "Containers stopped."
