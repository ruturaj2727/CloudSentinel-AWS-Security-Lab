# Scenario B — credentials in Lambda environment variables (insecure)
resource "aws_lambda_function" "insecure" {
  filename         = data.archive_file.lambda_zip.output_path
  function_name    = "secrets-lab-insecure-function"
  role             = aws_iam_role.lambda_role.arn
  handler          = "index.handler"
  runtime          = "nodejs18.x"
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256

  # Credentials stored as plaintext environment variables
  environment {
    variables = {
      DB_HOST        = "prod-db.internal.company.com"
      DB_PASSWORD    = "Sup3rS3cr3tDBP@ssw0rd!"
      API_KEY        = "sk-prod-a8f3k2m9x7q1w4e6r0t5"
      STRIPE_SECRET  = "sk_live_51fake9ABCDEFGHIJKLMN"
      ENVIRONMENT    = "production"
    }
  }

  tags = { Name = "secrets-lab-insecure" }
}

# Scenario C — SSM Parameter Store (secure pattern)
resource "aws_lambda_function" "secure" {
  filename         = data.archive_file.lambda_zip.output_path
  function_name    = "secrets-lab-secure-function"
  role             = aws_iam_role.lambda_role.arn
  handler          = "index.handler"
  runtime          = "nodejs18.x"
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256

  # No credentials here — fetched from SSM at runtime
  environment {
    variables = {
      DB_HOST_PARAM     = "/secrets-lab/db-host"
      DB_PASSWORD_PARAM = "/secrets-lab/db-password"
      API_KEY_PARAM     = "/secrets-lab/api-key"
      ENVIRONMENT       = "production"
    }
  }

  tags = { Name = "secrets-lab-secure" }
}

# Lambda deployment package
data "archive_file" "lambda_zip" {
  type        = "zip"
  output_path = "/tmp/lambda_function.zip"

  source {
    content  = <<-CODE
      exports.handler = async (event) => {
        return { statusCode: 200, body: "Function executed" };
      };
    CODE
    filename = "index.js"
  }
}
