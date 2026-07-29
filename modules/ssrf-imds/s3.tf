resource "aws_s3_bucket" "sensitive" {
  bucket        = "ssrf-lab-sensitive-data-${data.aws_caller_identity.current.account_id}"
  force_destroy = true
  tags          = { Name = "ssrf-lab-sensitive" }
}

data "aws_caller_identity" "current" {}

resource "aws_s3_object" "secret_file" {
  bucket  = aws_s3_bucket.sensitive.id
  key     = "confidential/credentials.txt"
  content = <<-CONTENT
    [SIMULATED SENSITIVE DATA]
    Database host: prod-db.internal.company.com
    Database user: admin
    Database pass: Sup3rS3cr3tP@ssw0rd
    API key: sk-prod-a8f3k2m9x7q1w4e6r0t5
    This file represents what an attacker finds after stealing IAM credentials.
  CONTENT
}
