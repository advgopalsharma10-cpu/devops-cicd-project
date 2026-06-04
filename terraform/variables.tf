variable "aws_region" {
  description = "AWS region where resources will be created"
  type        = string
  default     = "ap-south-1"
}

variable "ami_id" {
  description = "AMI ID for Ubuntu EC2 instance in selected region"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.micro"
}

variable "ec2_key_name" {
  description = "Existing AWS EC2 key pair name"
  type        = string
}

variable "ssh_allowed_cidr" {
  description = "Public IP CIDR allowed for SSH, example 1.2.3.4/32"
  type        = string
}

variable "docker_image" {
  description = "Docker image repository, example username/devops-node-app"
  type        = string
}

variable "docker_tag" {
  description = "Docker image tag to deploy"
  type        = string
}
