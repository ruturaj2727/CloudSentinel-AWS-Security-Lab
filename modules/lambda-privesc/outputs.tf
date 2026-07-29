output "attacker_access_key_id" {
  value     = aws_iam_access_key.attacker_key.id
  sensitive = true
}

output "attacker_secret_key" {
  value     = aws_iam_access_key.attacker_key.secret
  sensitive = true
}

output "admin_role_arn" {
  value = aws_iam_role.admin_role.arn
}

output "attacker_user_arn" {
  value = aws_iam_user.attacker.arn
}
