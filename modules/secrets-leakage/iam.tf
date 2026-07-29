data "aws_caller_identity" "current" {}

# Attacker user — simulates any IAM principal with basic enumeration permissions
resource "aws_iam_user" "attacker" {
  name = "secrets-lab-attacker"
  tags = { Name = "secrets-lab-attacker" }
}

resource "aws_iam_access_key" "attacker_key" {
  user = aws_iam_user.attacker.name
}

resource "aws_iam_user_policy" "attacker_policy" {
  name = "secrets-lab-attacker-policy"
  user = aws_iam_user.attacker.name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ec2:DescribeInstances",
          "ec2:DescribeInstanceAttribute",
          "lambda:ListFunctions",
          "lambda:GetFunction",
          "lambda:GetFunctionConfiguration",
          "ssm:GetParameter",
          "ssm:GetParameters"
        ]
        Resource = "*"
      }
    ]
  })
}

# Role for the EC2 instance
resource "aws_iam_role" "ec2_role" {
  name = "secrets-lab-ec2-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_instance_profile" "ec2_profile" {
  name = "secrets-lab-ec2-profile"
  role = aws_iam_role.ec2_role.name
}

# Role for Lambda functions
resource "aws_iam_role" "lambda_role" {
  name = "secrets-lab-lambda-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "lambda.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy" "lambda_ssm" {
  name = "secrets-lab-lambda-ssm"
  role = aws_iam_role.lambda_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["ssm:GetParameter", "ssm:GetParameters"]
        Resource = "arn:aws:ssm:us-east-1:${data.aws_caller_identity.current.account_id}:parameter/secrets-lab/*"
      }
    ]
  })
}
