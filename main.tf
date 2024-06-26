terraform {
  backend "s3" {
    bucket = "terraform-state-management-1234"
    key    = "state"
    region = "us-east-1"  
    
  }
}

resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
  enable_dns_support = true
  enable_dns_hostnames = true

  tags = {
    Name = "Main VPC"
  }
}

resource "aws_subnet" "main" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.1.0/24"
  map_public_ip_on_launch = true

  tags = {
    Name = "Main Subnet"
  }
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "Main Internet Gateway"
  }
}

resource "aws_route_table" "main" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = "Main Route Table"
  }
}

resource "aws_route_table_association" "main" {
  subnet_id      = aws_subnet.main.id
  route_table_id = aws_route_table.main.id
}

resource "aws_instance" "example" {
  ami           = "ami-080e1f13689e07408"
  instance_type = var.instance_type
  subnet_id     = aws_subnet.main.id
  key_name    = "tf-ec2-keypair" 
  vpc_security_group_ids = [aws_security_group.nginx_sg.id]
  
  tags = {
    Name = "Example Instance"
  }
}


resource "aws_s3_bucket" "b" {
  bucket = var.bucket_name

  tags = {
    Name = "My S3 Bucket"
  }
}

#resource "aws_s3_bucket" "terraform_state" {
#  bucket = "terraform-state-management-123"  
#
#  versioning {
#    enabled = true
#  }
# }

resource "aws_security_group" "nginx_sg" {
  name        = "nginx-security-group"
  description = "Security group for Nginx web server"
  vpc_id      = aws_vpc.main.id
  

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"  # Make sure to allow your own port later on 
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "nginx-security-group"
  }

}

