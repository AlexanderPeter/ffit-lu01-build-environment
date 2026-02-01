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

echo "== Increase vm.max_map_count (Sonar requirement) =="
sudo sysctl -w vm.max_map_count=262144
echo "vm.max_map_count=262144" | sudo tee /etc/sysctl.d/99-sonarqube.conf

echo "== Create Docker network =="
docker network create infra-net || true

echo "== Create Docker volumes =="
docker volume create sonarqube_data || true
docker volume create sonarqube_extensions || true
docker volume create sonarqube_logs || true
docker volume create sonarqube_db || true

echo "== Create infra directories =="
mkdir -p \
  $(pwd)/sonarqube \
  $(pwd)/nginx \
  $(pwd)/jenkins \
  $(pwd)/nginx/html

echo "== Build Jenkins docker file =="
docker build -t my-jenkins ./jenkins

echo "== Completed initial setup =="
echo "Please logout & login again to apply Docker group changes."
