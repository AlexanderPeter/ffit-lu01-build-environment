#!/usr/bin/env bash
set -e

echo "== OS update =="
sudo dnf update -y

echo "== Install Docker =="
sudo dnf install docker -y

echo "== Enable & start Docker =="
sudo systemctl enable docker
sudo systemctl start docker

echo "== Add ec2-user to docker group =="
sudo usermod -aG docker ec2-user

echo "== Completed initial setup =="
echo "Please logout & login again to apply Docker group changes."

echo "== Increase vm.max_map_count (Sonar requirement) =="
sudo sysctl -w vm.max_map_count=262144
echo "vm.max_map_count=262144" | sudo tee /etc/sysctl.d/99-sonarqube.conf

echo "== Create Docker network =="
docker network inspect infra-net >/dev/null 2>&1 || docker network create infra-net

echo "== Create Docker volumes =="
for v in sonarqube_data sonarqube_extensions sonarqube_logs sonarqube_db jenkins_home; do
  docker volume inspect $v >/dev/null 2>&1 || docker volume create $v
done

./nginx/start-nginx.sh
./sonarqube/start-sonarqube.sh
./sonarqube/setup-sonarqube.sh
./jenkins/setup-jenkins.sh
./jenkins/start-jenkins.sh
until docker exec jenkins true; do sleep 2; done
docker exec jenkins git config --global --add safe.directory '*'


