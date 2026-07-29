# -----------------------------------------------
# Scenario A+B — Public bucket with sensitive data
# -----------------------------------------------
resource "aws_s3_bucket" "public" {
  bucket        = "s3-lab-public-exposed-${data.aws_caller_identity.current.account_id}"
  force_destroy = true
  tags          = { Name = "s3-lab-public-exposed" }
}

# Disable ALL public access blocks — this is the misconfiguration
resource "aws_s3_bucket_public_access_block" "public" {
  bucket                  = aws_s3_bucket.public.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Bucket policy granting read access to anyone on the internet
resource "aws_s3_bucket_policy" "public" {
  bucket     = aws_s3_bucket.public.id
  depends_on = [aws_s3_bucket_public_access_block.public]

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:GetObject"
        Resource  = "${aws_s3_bucket.public.arn}/*"
      }
    ]
  })
}

# Scenario B — Sensitive files in the public bucket
resource "aws_s3_object" "internal_doc" {
  bucket  = aws_s3_bucket.public.id
  key     = "internal/employee-data.csv"
  content = <<-CONTENT
    employee_id,name,email,salary,ssn
    1001,John Smith,john.smith@company.com,95000,XXX-XX-1234
    1002,Jane Doe,jane.doe@company.com,110000,XXX-XX-5678
    1003,Bob Johnson,bob.johnson@company.com,88000,XXX-XX-9012
    [SIMULATED PII DATA - This represents what attackers find in misconfigured buckets]
  CONTENT
}

resource "aws_s3_object" "config_file" {
  bucket  = aws_s3_bucket.public.id
  key     = "config/app-config.json"
  content = <<-CONTENT
    {
      "environment": "production",
      "database": {
        "host": "prod-db.internal.company.com",
        "port": 5432,
        "name": "customers_db"
      },
      "api_endpoint": "https://internal-api.company.com",
      "debug": false
    }
  CONTENT
}

# Scenario C — Hardcoded AWS credentials in a public file
resource "aws_s3_object" "leaked_creds" {
  bucket  = aws_s3_bucket.public.id
  key     = "dev/deployment-notes.txt"
  content = <<-CONTENT
    Deployment Notes - DO NOT SHARE
    ================================
    Dev AWS credentials for testing (rotate these later):
    AWS_ACCESS_KEY_ID=${aws_iam_access_key.victim_key.id}
    AWS_SECRET_ACCESS_KEY=${aws_iam_access_key.victim_key.secret}
    Region: us-east-1

    Private bucket to verify access: s3-lab-private-data-${data.aws_caller_identity.current.account_id}
  CONTENT
}

# -----------------------------------------------
# Private bucket — only accessible with victim credentials
# -----------------------------------------------
resource "aws_s3_bucket" "private" {
  bucket        = "s3-lab-private-data-${data.aws_caller_identity.current.account_id}"
  force_destroy = true
  tags          = { Name = "s3-lab-private-data" }
}

resource "aws_s3_object" "private_data" {
  bucket  = aws_s3_bucket.private.id
  key     = "sensitive/customer-records.txt"
  content = <<-CONTENT
    [SIMULATED PRIVATE DATA]
    Customer database export - Q4 2025
    Records: 50,000 customers
    Contains: PII, payment info, transaction history
    Classification: CONFIDENTIAL
    This file represents what an attacker accesses after pivoting from the public bucket.
  CONTENT
}
