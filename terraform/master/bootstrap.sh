#!/bin/bash
set -euxo pipefail

apt-get update -y
apt-get install -y fontconfig openjdk-17-jre unzip curl gnupg software-properties-common

# ---------------- Docker ----------------
curl -fsSL https://get.docker.com | sh
usermod -aG docker ubuntu
systemctl enable docker

# ---------------- Jenkins ----------------
curl -fsSL https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key | tee \
  /usr/share/keyrings/jenkins-keyring.asc > /dev/null
echo "deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc]" \
  "https://pkg.jenkins.io/debian-stable binary/" | tee /etc/apt/sources.list.d/jenkins.list > /dev/null
apt-get update -y
apt-get install -y jenkins
usermod -aG docker jenkins
systemctl enable jenkins
systemctl start jenkins

# ---------------- Terraform ----------------
curl -fsSL https://apt.releases.hashicorp.com/gpg | gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg]" \
  "https://apt.releases.hashicorp.com $(lsb_release -cs) main" | tee /etc/apt/sources.list.d/hashicorp.list
apt-get update -y
apt-get install -y terraform

# ---------------- kubectl ----------------
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

# ---------------- AWS CLI v2 ----------------
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip -q awscliv2.zip
./aws/install

# ---------------- eksctl ----------------
curl --silent --location \
  "https://github.com/eksctl-io/eksctl/releases/latest/download/eksctl_Linux_amd64.tar.gz" \
  | tar xz -C /tmp
mv /tmp/eksctl /usr/local/bin

# ---------------- Helm ----------------
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

# ---------------- Trivy ----------------
curl -sfL https://raw.githubusercontent.com/aquasecurity/trivy/main/contrib/install.sh | sh -s -- -b /usr/local/bin

echo "Master bootstrap complete. Jenkins running on :8080"
