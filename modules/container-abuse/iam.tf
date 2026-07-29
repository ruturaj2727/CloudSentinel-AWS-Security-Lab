data "aws_caller_identity" "current" {}

resource "aws_iam_role" "container_role" {
  name = "container-lab-task-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })

  tags = { Name = "container-lab-task-role" }
}

resource "aws_iam_role_policy" "container_s3" {
  name = "container-lab-s3-read"
  role = aws_iam_role.container_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = ["s3:GetObject", "s3:ListBucket"]
      Resource = [
        aws_s3_bucket.sensitive.arn,
        "${aws_s3_bucket.sensitive.arn}/*"
      ]
    }]
  })
}

resource "aws_iam_instance_profile" "container_profile" {
  name = "container-lab-instance-profile"
  role = aws_iam_role.container_role.name
}

resource "aws_iam_role_policy_attachment" "ssm_policy" {
  role       = aws_iam_role.container_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}
