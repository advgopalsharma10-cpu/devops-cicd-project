resource "aws_security_group" "devops_sg" {
  name        = "devops-project-sg"
  description = "Allow SSH, HTTP, and app port"

  ingress {
    description = "SSH from my public IP only"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.ssh_allowed_cidr]
  }

  ingress {
    description = "HTTP access"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Node app access"
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "devops_ec2" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  key_name               = var.ec2_key_name
  vpc_security_group_ids = [aws_security_group.devops_sg.id]

  user_data_replace_on_change = true

  user_data = <<-EOF
    #!/bin/bash
    apt-get update -y
    apt-get install -y docker.io
    systemctl start docker
    systemctl enable docker

    docker stop devops-node-app || true
    docker rm devops-node-app || true
    docker pull ${var.docker_image}:${var.docker_tag}
    docker run -d --restart always --name devops-node-app -p 3000:3000 ${var.docker_image}:${var.docker_tag}
  EOF

  tags = {
    Name = "devops-cicd-project-ec2"
  }
}
