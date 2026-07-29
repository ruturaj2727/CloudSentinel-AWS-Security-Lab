data "aws_caller_identity" "current" {}

# High-privilege role that the attacker wants to abuse
resource "aws_iam_role" "admin_role" {
  name = "lambda-privesc-admin-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "lambda.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })

  tags = { Name = "lambda-privesc-admin-role" }
}

resource "aws_iam_role_policy_attachment" "admin_role_policy" {
  role       = aws_iam_role.admin_role.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

# Low-privilege attacker user
resource "aws_iam_user" "attacker" {
  name = "lambda-privesc-attacker"
  tags = { Name = "lambda-privesc-attacker" }
}

resource "aws_iam_access_key" "attacker_key" {
  user = aws_iam_user.attacker.name
}

# Misconfigured policy — three permissions that enable full privesc
resource "aws_iam_user_policy" "attacker_policy" {
  name = "lambda-privesc-attacker-policy"
  user = aws_iam_user.attacker.name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "iam:PassRole",
          "lambda:CreateFunction",
          "lambda:InvokeFunction",
          "lambda:GetFunction",
          "sts:GetCallerIdentity"
        ]
        Resource = "*"
      }
    ]
  })
}
