SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "== Start Nginx =="
docker rm -f nginx >/dev/null 2>&1 || true
docker run -d \
  --name nginx \
  --network infra-net \
  -p 80:80 \
  -v "$SCRIPT_DIR/default.conf:/etc/nginx/conf.d/default.conf:ro" \
  -v "$SCRIPT_DIR/html:/var/www/html:ro" \
  -v jenkins_home:/var/jenkins_home:ro \
  nginx:alpine
