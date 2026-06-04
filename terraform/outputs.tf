output "ec2_public_ip" {
  description = "Public IP address of EC2 instance"
  value       = aws_instance.devops_ec2.public_ip
}

output "app_url" {
  description = "Application URL"
  value       = "http://${aws_instance.devops_ec2.public_ip}:3000"
}
