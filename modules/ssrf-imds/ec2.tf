data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

resource "aws_security_group" "vulnerable_app" {
  name        = "ssrf-lab-sg"
  description = "Intentionally permissive SG for SSRF lab"
  vpc_id      = aws_vpc.lab.id

  ingress {
    description = "Vulnerable Flask app"
    from_port   = 5000
    to_port     = 5000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

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

  tags = { Name = "ssrf-lab-sg" }
}

resource "aws_instance" "vulnerable" {
  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = "t3.micro"
  subnet_id              = aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.vulnerable_app.id]
  iam_instance_profile   = aws_iam_instance_profile.ec2_profile.name

  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }

  user_data = <<-USERDATA
    #!/bin/bash
    yum update -y
    yum install -y python3 python3-pip
    pip3 install flask

    cat > /home/ec2-user/app.py << 'APPEOF'
    from flask import Flask, request
    import urllib.request

    app = Flask(__name__)

    @app.route('/')
    def index():
        return '<h1>Image Fetcher</h1><p>Usage: /fetch?url=http://example.com</p>'

    @app.route('/fetch')
    def fetch():
        url = request.args.get('url', '')
        if not url:
            return 'No URL provided', 400
        try:
            response = urllib.request.urlopen(url, timeout=5)
            return response.read()
        except Exception as e:
            return str(e), 500

    if __name__ == '__main__':
        app.run(host='0.0.0.0', port=5000)
    APPEOF

    nohup python3 /home/ec2-user/app.py > /home/ec2-user/app.log 2>&1 &
  USERDATA

  tags = { Name = "ssrf-lab-target" }
}
