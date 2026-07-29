resource "aws_iam_user" "victim" {
  name = "s3-lab-victim-user"
  tags = { Name = "s3-misconfig-victim" }
}

resource "aws_iam_access_key" "victim_key" {
  user = aws_iam_user.victim.name
}

resource "aws_iam_user_policy" "victim_policy" {
  name = "victim-s3-read"
  user = aws_iam_user.victim.name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["s3:GetObject", "s3:ListBucket"]
        Resource = [
          "arn:aws:s3:::s3-lab-private-data-${data.aws_caller_identity.current.account_id}",
          "arn:aws:s3:::s3-lab-private-data-${data.aws_caller_identity.current.account_id}/*"
        ]
      }
    ]
  })
}

data "aws_caller_identity" "current" {}
