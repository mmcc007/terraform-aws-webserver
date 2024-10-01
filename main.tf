# main.tf

provider "aws" {
  region = var.aws_region
}

resource "aws_instance" "web_server" {
  ami           = var.ami_id
  instance_type = var.instance_type
  key_name      = aws_key_pair.generated_key.key_name

  user_data = file("user_data.sh")

  vpc_security_group_ids = [aws_security_group.web_server_sg.id]

  tags = {
    Name = "WebServer"
  }
}

resource "aws_security_group" "web_server_sg" {
  name        = "web_server_sg"
  description = "Allow HTTP and SSH"

  ingress {
    from_port   = var.web_server_port
    to_port     = var.web_server_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Allow from anywhere
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Allow SSH from anywhere (consider restricting this)
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_key_pair" "generated_key" {
  key_name   = var.key_name
  public_key = file(var.public_key_path)
}
