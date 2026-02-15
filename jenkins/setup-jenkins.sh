export SONAR_TOKEN=$(cat ../sonarqube/token.txt)
echo "DEBUG token is: $SONAR_TOKEN"

### Validate required username
if [ -z "${SONAR_TOKEN:-}" ]; then
  echo "ERROR: SONAR_TOKEN is not set"
  echo "Set it via environment variable or .env file"
  exit 1
fi

echo "== Build Jenkins docker file =="
docker build -t my-jenkins "$(dirname "$0")"

echo "== Prepare Jenkins directories =="
docker run --rm \
  -v jenkins_home:/var/jenkins_home \
  alpine \
  sh -c "mkdir -p /var/jenkins_home/projects && chown -R 1000:1000 /var/jenkins_home"
