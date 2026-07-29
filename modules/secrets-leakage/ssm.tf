resource "aws_ssm_parameter" "db_host" {
  name  = "/secrets-lab/db-host"
  type  = "String"
  value = "prod-db.internal.company.com"
  tags  = { Name = "secrets-lab-db-host" }
}

resource "aws_ssm_parameter" "db_password" {
  name  = "/secrets-lab/db-password"
  type  = "SecureString"
  value = "Sup3rS3cr3tDBP@ssw0rd!"
  tags  = { Name = "secrets-lab-db-password" }
}

resource "aws_ssm_parameter" "api_key" {
  name  = "/secrets-lab/api-key"
  type  = "SecureString"
  value = "sk-prod-a8f3k2m9x7q1w4e6r0t5"
  tags  = { Name = "secrets-lab-api-key" }
}
