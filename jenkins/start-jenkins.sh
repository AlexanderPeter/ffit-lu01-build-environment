SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "== Start Jenkins =="
docker rm -f jenkins >/dev/null 2>&1 || true
docker run -d \
  --name jenkins \
  --network infra-net \
  -p 127.0.0.1:8080:8080 \
  --env-file "$SCRIPT_DIR/../.env" \
  -v jenkins_home:/var/jenkins_home \
  -e CASC_JENKINS_CONFIG=/var/jenkins_home/jenkins.yaml \
  -e JAVA_OPTS="-Djenkins.install.runSetupWizard=false" \
  -e JENKINS_OPTS="--prefix=/jenkins" \
  my-jenkins
