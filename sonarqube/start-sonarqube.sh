SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "== Start SonarQube =="
docker rm -f sonarqube >/dev/null 2>&1 || true
docker run -d \
  --name sonarqube \
  --network infra-net \
  -p 127.0.0.1:9000:9000 \
  --env-file "$SCRIPT_DIR/../.env" \
  -e SONAR_WEB_CONTEXT=/sonarqube \
  -e SONAR_WEB_JAVAOPTS="-Xms256m -Xmx512m" \
  -e SONAR_CE_JAVAOPTS="-Xms128m -Xmx256m" \
  -v sonarqube_data:/opt/sonarqube/data \
  -v sonarqube_extensions:/opt/sonarqube/extensions \
  -v sonarqube_logs:/opt/sonarqube/logs \
  sonarqube:lts
