resource "aws_iam_user" "low_priv" {
  name = "low-priv-user"
  tags = { Name = "iam-privesc-low-priv-user" }
}

resource "aws_iam_access_key" "low_priv_key" {
  user = aws_iam_user.low_priv.name
}

# The misconfiguration: this user can attach ANY policy to themselves
resource "aws_iam_user_policy" "attach_policy_perm" {
  name = "allow-attach-user-policy"
  user = aws_iam_user.low_priv.name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = "sts:GetCallerIdentity"
        Resource = "*"
      }
    ]
  })
}
