resource "aws_security_group" "signup_ec2" {
  name        = "${var.project_name}-sg"
  description = "Allow SSH from the operator and public access to the Express frontend."
  vpc_id      = data.aws_vpc.default.id

  ingress {
    description = "SSH from the operator's current public IP only"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.ssh_cidr]
  }

  ingress {
    description = "Signup Express frontend"
    from_port   = var.app_port
    to_port     = var.app_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Outbound access for package installation, GitHub and MongoDB Atlas"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-sg"
  }
}

resource "aws_iam_role" "ec2_ssm_parameter" {
  name = "${var.project_name}-ec2-ssm-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_ssm_parameter" "mongo_uri" {
  name        = "/signup-application/task1/mongo-uri"
  description = "MongoDB URI for the Signup Application backend"
  type        = "SecureString"
  value       = var.mongo_uri
  overwrite   = true

  tags = {
    Project = var.project_name
  }
}

resource "aws_iam_role_policy" "read_mongo_uri" {
  name = "read-signup-mongodb-uri"
  role = aws_iam_role.ec2_ssm_parameter.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["ssm:GetParameter"]
        Resource = "arn:aws:ssm:${var.aws_region}:${data.aws_caller_identity.current.account_id}:parameter/signup-application/task1/mongo-uri"
      },
      {
        Effect   = "Allow"
        Action   = ["kms:Decrypt"]
        Resource = "*"
        Condition = {
          StringEquals = {
            "kms:ViaService" = "ssm.${var.aws_region}.amazonaws.com"
          }
        }
      }
    ]
  })
}

resource "aws_iam_instance_profile" "ec2" {
  name = "${var.project_name}-instance-profile"
  role = aws_iam_role.ec2_ssm_parameter.name
}

resource "aws_instance" "signup" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = var.instance_type
  subnet_id                   = sort(data.aws_subnets.default_vpc.ids)[0]
  vpc_security_group_ids      = [aws_security_group.signup_ec2.id]
  associate_public_ip_address = true
  iam_instance_profile        = aws_iam_instance_profile.ec2.name

  user_data = templatefile("${path.module}/user_data.sh.tftpl", {
    github_repo_url = var.github_repo_url
    github_branch   = var.github_branch
    aws_region      = var.aws_region
    mongo_parameter = aws_ssm_parameter.mongo_uri.name
  })
  user_data_replace_on_change = true

  root_block_device {
    volume_type           = "gp3"
    volume_size           = 12
    encrypted             = true
    delete_on_termination = true
  }

  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }

  tags = {
    Name = "${var.project_name}-ec2"
  }

  depends_on = [aws_iam_role_policy.read_mongo_uri]
}
