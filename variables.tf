# variables.tf

variable "aws_region" {
  description = "The AWS region to deploy in"
  default     = "us-east-1"
}

variable "ami_id" {
  description = "AMI ID for the EC2 instance"
}

variable "instance_type" {
  description = "EC2 instance type"
  default     = "t2.micro"
}

variable "key_name" {
  description = "Name of the SSH key pair"
}

variable "public_key_path" {
  description = "Path to the public SSH key"
}

variable "web_server_port" {
  description = "Port on which the web server listens"
  default     = 8080
}


