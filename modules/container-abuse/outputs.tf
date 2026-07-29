output "instance_public_ip" {
  value = aws_instance.container_host.public_ip
}

output "instance_id" {
  value = aws_instance.container_host.id
}

output "s3_bucket_name" {
  value = aws_s3_bucket.sensitive.id
}

output "ssh_command" {
  value = "ssh -i <your-key>.pem ec2-user@${aws_instance.container_host.public_ip}"
}
