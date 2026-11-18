# Signup Application – AWS Terraform Task 1

This project provisions one Ubuntu EC2 instance and its security group with Terraform. EC2 user-data installs Python, Node.js, Git, Flask dependencies and Express dependencies, retrieves the MongoDB URI from SSM Parameter Store using an EC2 instance role, and configures both applications as systemd services.

## Architecture

- Express frontend: TCP 3000 (public)
- Flask backend: TCP 5000 bound to 127.0.0.1 (not publicly exposed)
- MongoDB Atlas: external database
- Terraform provisions EC2, security group, IAM role/profile and SSM SecureString parameter.
- The instance uses the default VPC and one of its subnets as data sources.

## Prerequisites

- Terraform >= 1.10
- AWS CLI configured with credentials that can create EC2, IAM, SSM and S3 resources
- A public GitHub repository containing this application
- MongoDB Atlas URI
- Your public IPv4 address

## 1. Create the remote state bucket (bootstrap)

The bootstrap uses local state only to create a private, versioned, encrypted S3 bucket. Run from PowerShell:

```powershell
cd terraform/bootstrap
terraform init
terraform fmt -recursive
terraform validate
terraform plan
terraform apply
terraform output -raw terraform_state_bucket
```

Copy the output bucket name.

## 2. Configure the main Terraform deployment

From the `terraform` directory, create `terraform.tfvars` by copying `terraform.tfvars.example`. Set your actual GitHub URL, your public IPv4 address with `/32`, and your MongoDB Atlas URI. Do not commit this file.

Initialize the S3 backend, replacing the bucket value with the name returned by the bootstrap:

```powershell
cd ..
terraform init -backend-config="bucket=YOUR_STATE_BUCKET_NAME"
```

Then run:

```powershell
terraform fmt -recursive
terraform validate
terraform plan
terraform apply
```

Review the plan carefully before approving `apply`.

## 3. Verify deployment

Get the application URL:

```powershell
terraform output -raw application_url
```

Open the URL in a browser. The instance may need several minutes to finish cloud-init/user-data after EC2 first becomes running.

SSH into the instance if troubleshooting is required. Check bootstrap output with:

```bash
sudo tail -n 200 /var/log/signup-user-data.log
sudo cloud-init status --long
sudo systemctl status signup-backend --no-pager
sudo systemctl status signup-frontend --no-pager
sudo journalctl -u signup-backend -n 100 --no-pager
sudo journalctl -u signup-frontend -n 100 --no-pager
```

## Security notes

- SSH is restricted to the `ssh_cidr` address in `terraform.tfvars`.
- Flask is bound to localhost and port 5000 is not opened in the security group.
- The MongoDB URI is stored as an SSM SecureString and retrieved by the EC2 instance role.
- Terraform state can contain sensitive values. The S3 backend bucket is private, versioned and encrypted. Restrict access to it. Never commit Terraform state or `terraform.tfvars`.
- The demo application currently stores submitted passwords as provided by its original code. Use dummy test data only; implement password hashing before any real use.

## Clean up

After collecting evidence, destroy the main deployment:

```powershell
terraform destroy
```

The SSM parameter and IAM/EC2 resources managed by the main configuration are removed. The separate S3 state bucket is intentionally retained. Destroy the bootstrap stack only if you no longer need the remote state bucket and have safely archived any required state/history.
