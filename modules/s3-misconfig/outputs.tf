output "public_bucket_name" {
  value = aws_s3_bucket.public.id
}

output "public_bucket_url" {
  value = "https://${aws_s3_bucket.public.id}.s3.amazonaws.com"
}

output "attack_url_employee_data" {
  value = "https://${aws_s3_bucket.public.id}.s3.amazonaws.com/internal/employee-data.csv"
}

output "attack_url_config" {
  value = "https://${aws_s3_bucket.public.id}.s3.amazonaws.com/config/app-config.json"
}

output "attack_url_leaked_creds" {
  value = "https://${aws_s3_bucket.public.id}.s3.amazonaws.com/dev/deployment-notes.txt"
}

output "private_bucket_name" {
  value = aws_s3_bucket.private.id
}

output "victim_access_key_id" {
  value     = aws_iam_access_key.victim_key.id
  sensitive = true
}
