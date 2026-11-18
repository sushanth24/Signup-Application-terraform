output "terraform_state_bucket" {
  description = "S3 bucket name for the main Terraform state."
  value       = aws_s3_bucket.terraform_state.bucket
}
