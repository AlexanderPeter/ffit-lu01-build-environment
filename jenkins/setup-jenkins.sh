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

echo "== Build Jenkins docker file =="
docker build -t my-jenkins "$(dirname "$0")"

echo "== Prepare Jenkins directories =="
docker run --rm \
  -v jenkins_home:/var/jenkins_home \
  alpine \
  sh -c "mkdir -p /var/jenkins_home/projects && chown -R 1000:1000 /var/jenkins_home"

echo "== Bootstrap Jenkins with JCasC =="
docker run --rm \
  --name jenkins-bootstrap \
  --network infra-net \
  -p 127.0.0.1:8080:8080 \
  --memory=3g \
  --memory-swap=3g \
  --env-file "$SCRIPT_DIR/../.env" \
  -e SONAR_TOKEN="$SONAR_TOKEN" \
  -e CASC_JENKINS_CONFIG=/var/jenkins_home/jenkins.yaml \
  -v jenkins_home:/var/jenkins_home \
  my-jenkins \
  bash -c "
    /usr/local/bin/jenkins.sh &
    PID=\$!
    echo 'Waiting for Jenkins...'
    until curl -s http://localhost:8080/login >/dev/null; do
      sleep 5
    done
    echo 'Jenkins ready → stopping bootstrap'
    kill \$PID
  "
