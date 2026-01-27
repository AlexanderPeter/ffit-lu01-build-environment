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

echo "== Create infra directories =="
mkdir -p $(pwd)/{jenkins,nginx/html}

echo "== DONE =="
echo "Log out and log back in before continuing."
