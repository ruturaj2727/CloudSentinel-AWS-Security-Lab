data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

resource "aws_security_group" "container_host" {
  name        = "container-lab-sg"
  description = "Container lab security group"
  vpc_id      = aws_vpc.lab.id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "container-lab-sg" }
}

resource "aws_instance" "container_host" {
  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = "t3.micro"
  subnet_id              = aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.container_host.id]
  iam_instance_profile   = aws_iam_instance_profile.container_profile.name

  user_data = <<-USERDATA
    #!/bin/bash
    yum update -y
    yum install -y docker
    systemctl start docker
    systemctl enable docker
    usermod -aG docker ec2-user

    # Pull and run a simple vulnerable container
    # Container simulates an application running with AWS credentials injected
    docker run -d \
      --name vulnerable-app \
      --env AWS_CONTAINER_CREDENTIALS_RELATIVE_URI=/credentials \
      -p 8080:8080 \
      python:3.9-slim \
      python3 -c "
import http.server
import socketserver

class Handler(http.server.SimpleHTTPRequestHandler):
    def do_GET(self):
        self.send_response(200)
        self.end_headers()
        self.wfile.write(b'Vulnerable container app running')

with socketserver.TCPServer(('', 8080), Handler) as httpd:
    httpd.serve_forever()
"
  USERDATA

  tags = { Name = "container-lab-host" }
}
