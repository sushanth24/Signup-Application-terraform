variable "aws_region" {
  description = "AWS region for the Terraform state bucket."
  type        = string
  default     = "ap-south-1"
}

variable "state_bucket_prefix" {
  description = "Globally unique prefix for the Terraform state bucket."
  type        = string
  default     = "signup-app-tfstate"
}
