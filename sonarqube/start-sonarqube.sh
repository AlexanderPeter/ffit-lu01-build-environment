SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "== Start SonarQube =="
docker rm -f sonarqube >/dev/null 2>&1 || true
docker run -d \
  --name sonarqube \
  --network infra-net \
  -p 9000:9000 \
  --memory=3g \
  --memory-swap=3g \
  --env-file "$SCRIPT_DIR/../.env" \
  -e SONAR_WEB_CONTEXT=/sonarqube \
  -e SONAR_WEB_JAVAOPTS="-Xms512m -Xmx1g" \
  -e SONAR_CE_JAVAOPTS="-Xms256m -Xmx768m" \
  -v sonarqube_data:/opt/sonarqube/data \
  -v sonarqube_extensions:/opt/sonarqube/extensions \
  -v sonarqube_logs:/opt/sonarqube/logs \
  sonarqube:lts
