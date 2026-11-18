variable "aws_region" {
  description = "AWS region for this deployment."
  type        = string
  default     = "ap-south-1"
}

variable "project_name" {
  description = "Name used for AWS resources and tags."
  type        = string
  default     = "signup-application-task1"
}

variable "instance_type" {
  description = "EC2 instance type. Confirm current pricing and account eligibility before applying."
  type        = string
  default     = "t3.micro"
}

variable "ssh_cidr" {
  description = "Your public IPv4 address in CIDR notation, for example 203.0.113.10/32."
  type        = string

  validation {
    condition     = can(cidrnetmask(var.ssh_cidr)) && endswith(var.ssh_cidr, "/32")
    error_message = "ssh_cidr must be one IPv4 address with /32, for example 203.0.113.10/32."
  }
}

variable "github_repo_url" {
  description = "HTTPS clone URL of your public Signup Application GitHub repository."
  type        = string

  validation {
    condition     = can(regex("^https://github\\.com/.+/.+(.git)?$", var.github_repo_url))
    error_message = "Provide an HTTPS GitHub repository URL."
  }
}

variable "github_branch" {
  description = "Git branch containing the deployment-ready application code."
  type        = string
  default     = "main"
}

variable "mongo_uri" {
  description = "MongoDB Atlas connection URI. Stored as an SSM SecureString; Terraform state must remain private."
  type        = string
  sensitive   = true
}

variable "app_port" {
  description = "Public Express frontend port."
  type        = number
  default     = 3000
}
