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
docker rm -f jenkins >/dev/null 2>&1 || true
docker run -d \
  --name jenkins \
  --network infra-net \
  -p 127.0.0.1:8080:8080 \
  --memory=1536m \
  --memory-swap=1536m \
  --env-file "$SCRIPT_DIR/../.env" \
  -e SONAR_TOKEN="$SONAR_TOKEN" \
  -e CASC_JENKINS_CONFIG=/var/jenkins_home/jenkins.yaml \
  -e JAVA_OPTS="-Xms512m -Xmx768m -Djenkins.install.runSetupWizard=false" \
  -e JENKINS_OPTS="--prefix=/jenkins" \
  -v jenkins_home:/var/jenkins_home \
  -v /var/run/docker.sock:/var/run/docker.sock \
  my-jenkins
