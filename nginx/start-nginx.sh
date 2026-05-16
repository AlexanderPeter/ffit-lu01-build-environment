CONTAINER_NAME="nginx"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "== Start Nginx =="
if docker ps -a --format '{{.Names}}' | grep -Eq "^${CONTAINER_NAME}\$"; then
  echo "Existing container will be started"
  docker start ${CONTAINER_NAME}
else
  echo "New container will be created"
  docker run -d \
    --name nginx \
    --restart unless-stopped \
    --network infra-net \
    -p 80:80 \
    --memory=64m \
    --memory-swap=64m \
    -v "$SCRIPT_DIR/default.conf:/etc/nginx/conf.d/default.conf:ro" \
    -v "$SCRIPT_DIR/html:/var/www/html:ro" \
    -v jenkins_home:/var/jenkins_home:ro \
    nginx:alpine
fi
