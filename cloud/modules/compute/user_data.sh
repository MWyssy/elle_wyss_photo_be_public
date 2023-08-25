#!/bin/sh

set -ex

sudo apt-get update -y
sudo apt-get install -y \
    ca-certificates \
    curl \
    gnupg \
    lsb-release

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt-get update -y
sudo apt-get install -y docker-ce docker-ce-cli containerd.io

usermod -aG docker ubuntu

docker login -u $DOCKERHUB_USER -p $DOCKER_HUB_PASS https://index.docker.io/v1

docker pull mwyssy/ewp-be:latest 

docker run -p 5000:5000 mwyssy/ewp-be:latest 