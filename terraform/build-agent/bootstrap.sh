#!/bin/bash
set -e

apt-get update -y
apt-get install -y openjdk-17-jre git unzip curl

curl -fsSL https://get.docker.com | sh
usermod -aG docker ubuntu

curl -sfL https://raw.githubusercontent.com/aquasecurity/trivy/main/contrib/install.sh | sh -s -- -b /usr/local/bin
