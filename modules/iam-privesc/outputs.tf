output "low_priv_access_key_id" {
  value     = aws_iam_access_key.low_priv_key.id
  sensitive = true
}

output "low_priv_secret_access_key" {
  value     = aws_iam_access_key.low_priv_key.secret
  sensitive = true
}

output "low_priv_user_arn" {
  value = aws_iam_user.low_priv.arn
}
