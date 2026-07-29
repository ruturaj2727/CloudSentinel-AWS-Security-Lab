resource "aws_iam_role" "ec2_role" {
  name = "ssrf-lab-ec2-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Principal = { Service = "ec2.amazonaws.com" }
        Action    = "sts:AssumeRole"
      }
    ]
  })

  tags = { Name = "ssrf-lab-ec2-role" }
}

resource "aws_iam_role_policy" "s3_read" {
  name = "ssrf-lab-s3-read"
  role = aws_iam_role.ec2_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["s3:GetObject", "s3:ListBucket"]
        Resource = [
          aws_s3_bucket.sensitive.arn,
          "${aws_s3_bucket.sensitive.arn}/*"
        ]
      }
    ]
  })
}

resource "aws_iam_instance_profile" "ec2_profile" {
  name = "ssrf-lab-ec2-profile"
  role = aws_iam_role.ec2_role.name
}
