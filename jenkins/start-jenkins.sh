CONTAINER_NAME="jenkins"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
TOKEN_FILE="$SCRIPT_DIR/../sonarqube/token.txt"

export SONAR_TOKEN
SONAR_TOKEN=$(cat "$TOKEN_FILE")
echo "DEBUG token is: $SONAR_TOKEN"

### Validate required token
if [ -z "${SONAR_TOKEN:-}" ]; then
  echo "ERROR: SONAR_TOKEN is not set"
  exit 1
fi

echo "== Start Jenkins =="
if docker ps -a --format '{{.Names}}' | grep -Eq "^${CONTAINER_NAME}$"; then
  echo "Existing container will be started"
  docker start ${CONTAINER_NAME}
else
  echo "New container will be created"
  docker run -d \
    --name jenkins \
    --restart unless-stopped \
    --network infra-net \
    -p 127.0.0.1:8080:8080 \
    --memory=3g \
    --memory-swap=3g \
    --env-file "$SCRIPT_DIR/../.env" \
    -e SONAR_TOKEN="$SONAR_TOKEN" \
    -e JAVA_OPTS="-Xms512m -Xmx768m -Djenkins.install.runSetupWizard=false" \
    -e JENKINS_OPTS="--prefix=/jenkins" \
    -v jenkins_home:/var/jenkins_home \
    -v /var/run/docker.sock:/var/run/docker.sock \
    --group-add $(getent group docker | cut -d: -f3) \
    my-jenkins
fi
