output "insecure_instance_id" {
  value = aws_instance.insecure.id
}

output "insecure_lambda_name" {
  value = aws_lambda_function.insecure.function_name
}

output "secure_lambda_name" {
  value = aws_lambda_function.secure.function_name
}

output "attacker_access_key_id" {
  value     = aws_iam_access_key.attacker_key.id
  sensitive = true
}

output "attacker_secret_key" {
  value     = aws_iam_access_key.attacker_key.secret
  sensitive = true
}
