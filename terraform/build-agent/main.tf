terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = { source = "hashicorp/aws", version = "~> 5.0" }
  }
}

provider "aws" {
  region = var.aws_region
}

resource "aws_security_group" "agent_sg" {
  name        = "${var.project_name}-build-agent-sg"
  description = "only allow SSH, jenkins connects to this from outside"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.allowed_ssh_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "${var.project_name}-build-agent-sg" }
}

resource "tls_private_key" "agent_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "agent_kp" {
  key_name   = "${var.project_name}-build-agent-key"
  public_key = tls_private_key.agent_key.public_key_openssh
}

resource "local_file" "agent_pem" {
  content         = tls_private_key.agent_key.private_key_pem
  filename        = "${path.module}/${var.project_name}-build-agent-key.pem"
  file_permission = "0400"
}

data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
}

resource "aws_instance" "build_agent" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type
  key_name               = aws_key_pair.agent_kp.key_name
  vpc_security_group_ids = [aws_security_group.agent_sg.id]

  root_block_device {
    volume_size = 20
    volume_type = "gp3"
  }

  user_data = file("${path.module}/bootstrap.sh")

  tags = { Name = "${var.project_name}-build-agent" }
}

output "agent_public_ip" {
  value = aws_instance.build_agent.public_ip
}

output "ssh_command" {
  value = "ssh -i ${var.project_name}-build-agent-key.pem ubuntu@${aws_instance.build_agent.public_ip}"
}
