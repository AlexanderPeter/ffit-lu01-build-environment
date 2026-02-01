#!/usr/bin/env bash
set -e

cd "$(dirname "$0")"

echo "== Docker network =="
docker network inspect infra-net >/dev/null 2>&1 || docker network create infra-net

echo "== Jenkins volume =="
docker volume inspect jenkins_home >/dev/null 2>&1 || docker volume create jenkins_home

echo "== Prepare Jenkins directories =="
docker run --rm \
  -v jenkins_home:/var/jenkins_home \
  alpine \
  sh -c "mkdir -p /var/jenkins_home/projects && chown -R 1000:1000 /var/jenkins_home"

echo "== Start Jenkins =="
docker rm -f jenkins >/dev/null 2>&1 || true
docker run -d \
  --name jenkins \
  --network infra-net \
  -p 127.0.0.1:8080:8080 \
  -p 127.0.0.1:50000:50000 \
  --env-file .env \
  -v jenkins_home:/var/jenkins_home \
  -v $(pwd)/jenkins/jenkins.yaml:/var/jenkins_home/jenkins.yaml:ro \
  -e CASC_JENKINS_CONFIG=/var/jenkins_home/jenkins.yaml \
  -e JAVA_OPTS="-Djenkins.install.runSetupWizard=false" \
  -e JENKINS_OPTS="--prefix=/jenkins" \
  jenkins/jenkins:lts

echo "== Start SonarQube =="
docker rm -f sonarqube >/dev/null 2>&1 || true
docker run -d \
  --name sonarqube \
  --network infra-net \
  -p 127.0.0.1:9000:9000 \
  --env-file .env \
  -e SONAR_WEB_CONTEXT=/sonarqube \
  -v sonarqube_data:/opt/sonarqube/data \
  -v sonarqube_extensions:/opt/sonarqube/extensions \
  -v sonarqube_logs:/opt/sonarqube/logs \
  sonarqube:lts

echo "== Start Nginx =="
docker rm -f nginx >/dev/null 2>&1 || true
docker run -d \
  --name nginx \
  --network infra-net \
  -p 80:80 \
  -v $(pwd)/nginx/default.conf:/etc/nginx/conf.d/default.conf:ro \
  -v $(pwd)/nginx/html:/var/www/html:ro \
  -v jenkins_home:/var/jenkins_home:ro \
  nginx:alpine

echo "== DONE =="
docker ps

