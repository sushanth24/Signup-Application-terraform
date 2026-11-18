output "ec2_instance_id" {
  description = "ID of the EC2 instance created by Terraform."
  value       = aws_instance.signup.id
}

output "ec2_public_ip" {
  description = "Public IPv4 address of the Signup Application EC2 instance."
  value       = aws_instance.signup.public_ip
}

output "application_url" {
  description = "Public URL for the Express Signup frontend."
  value       = "http://${aws_instance.signup.public_ip}:${var.app_port}"
}

output "frontend_port" {
  value = var.app_port
}

output "backend_port" {
  description = "Flask listens on localhost only; it is intentionally not exposed publicly."
  value       = 5000
}
