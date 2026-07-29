resource "aws_s3_bucket" "sensitive" {
  bucket        = "container-lab-sensitive-${data.aws_caller_identity.current.account_id}"
  force_destroy = true
  tags          = { Name = "container-lab-sensitive" }
}

resource "aws_s3_object" "secret_data" {
  bucket  = aws_s3_bucket.sensitive.id
  key     = "private/container-secrets.txt"
  content = <<-CONTENT
    [SIMULATED SENSITIVE DATA]
    Accessed via container task role credential theft
    Internal API endpoint: https://internal-api.company.com
    Service account token: eyJhbGciOiJSUzI1NiIsImtpZCI6IjEifQ...
    Database connection: postgresql://admin:secret@prod-db:5432/customers
    This data was accessed by stealing credentials from inside a container.
  CONTENT
}
