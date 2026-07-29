data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

resource "aws_security_group" "ec2" {
  name        = "secrets-lab-ec2-sg"
  description = "Secrets lab EC2 SG"
  vpc_id      = aws_vpc.lab.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "secrets-lab-ec2-sg" }
}

# Scenario A — credentials hardcoded in user data
resource "aws_instance" "insecure" {
  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = "t3.micro"
  subnet_id              = aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.ec2.id]
  iam_instance_profile   = aws_iam_instance_profile.ec2_profile.name

  user_data = <<-USERDATA
    #!/bin/bash
    # Insecure pattern — credentials hardcoded in user data
    export DB_HOST="prod-db.internal.company.com"
    export DB_USER="admin"
    export DB_PASSWORD="Sup3rS3cr3tDBP@ssw0rd!"
    export API_KEY="sk-prod-a8f3k2m9x7q1w4e6r0t5"
    export STRIPE_SECRET="sk_live_51fake9ABCDEFGHIJKLMN"

    yum update -y
    echo "Application started with hardcoded credentials" >> /var/log/app.log
  USERDATA

  tags = { Name = "secrets-lab-insecure-ec2" }
}
