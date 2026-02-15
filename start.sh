#!/usr/bin/env bash
set -e

cd "$(dirname "$0")"

./sonarqube/start-sonarqube.sh
./jenkins/start-jenkins.sh
./nginx/start-nginx.sh

echo "Containers started."
docker ps

