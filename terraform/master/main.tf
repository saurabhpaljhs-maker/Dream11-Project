terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = { source = "hashicorp/aws", version = "~> 5.0" }
  }
}

provider "aws" {
  region = var.aws_region
}

# ------------------------------------------------------------
# 1. IAM - role for Master (Jenkins) machine -> talk to EKS/ECR
# ------------------------------------------------------------
resource "aws_iam_role" "master_role" {
  name = "${var.project_name}-master-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "eks_access" {
  role       = aws_iam_role.master_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

resource "aws_iam_role_policy_attachment" "ecr_access" {
  role       = aws_iam_role.master_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryFullAccess"
}

resource "aws_iam_instance_profile" "master_profile" {
  name = "${var.project_name}-master-profile"
  role = aws_iam_role.master_role.name
}

# ------------------------------------------------------------
# 2. Key Pair
# ------------------------------------------------------------
resource "tls_private_key" "master_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "master_kp" {
  key_name   = "${var.project_name}-master-key"
  public_key = tls_private_key.master_key.public_key_openssh
}

resource "local_file" "private_key_pem" {
  content         = tls_private_key.master_key.private_key_pem
  filename        = "${path.module}/${var.project_name}-master-key.pem"
  file_permission = "0400"
}

# ------------------------------------------------------------
# 3. Security Group - Jenkins UI (8080), SSH (22), JNLP (50000)
# ------------------------------------------------------------
resource "aws_security_group" "master_sg" {
  name        = "${var.project_name}-master-sg"
  description = "Master/Jenkins machine SG"

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.allowed_ssh_cidr]
  }

  ingress {
    description = "Jenkins UI"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = [var.allowed_ssh_cidr]
  }

  ingress {
    description = "Jenkins JNLP agents"
    from_port   = 50000
    to_port     = 50000
    protocol    = "tcp"
    cidr_blocks = [var.allowed_ssh_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "${var.project_name}-master-sg" }
}

# ------------------------------------------------------------
# 4. Master EC2 (t2.large) - Jenkins + Terraform + kubectl + docker
# ------------------------------------------------------------
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
}

resource "aws_instance" "master" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type
  key_name               = aws_key_pair.master_kp.key_name
  vpc_security_group_ids = [aws_security_group.master_sg.id]
  iam_instance_profile   = aws_iam_instance_profile.master_profile.name

  root_block_device {
    volume_size = 30
    volume_type = "gp3"
  }

  user_data = file("${path.module}/bootstrap.sh")

  tags = { Name = "${var.project_name}-master" }
}

output "master_public_ip" {
  value = aws_instance.master.public_ip
}
