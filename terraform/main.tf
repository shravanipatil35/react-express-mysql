resource "aws_security_group" "backend_sg" {
  name        = "express-backend-sg"
  description = "Allow traffic for Express API"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] 
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "express_server" {
  ami                    = "ami-03f4878755434977f" 
  instance_type          = "t2.medium"
  key_name               = var.key_name
  vpc_security_group_ids = [aws_security_group.backend_sg.id]

  user_data = <<-EOF
              #!/bin/bash
              apt-get update -y
              curl -fsSL https://deb.nodesource.com/setup_20.x | bash -
              apt-get install -y nodejs git
              npm install -global pm2
              EOF

  tags = {
    Name = "express-backend-production"
  }
}

resource "aws_s3_bucket" "react_bucket" {
  bucket        = var.frontend_bucket_name
  force_destroy = true
}

resource "aws_s3_bucket_public_access_block" "react_bucket_public" {
  bucket = aws_s3_bucket.react_bucket.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_website_configuration" "react_website" {
  bucket = aws_s3_bucket.react_bucket.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "index.html"
  }
}

resource "aws_s3_bucket_policy" "public_read_policy" {
  depends_on = [aws_s3_bucket_public_access_block.react_bucket_public]
  bucket     = aws_s3_bucket.react_bucket.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "PublicReadGetObject"
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:GetObject"
        Resource  = "${aws_s3_bucket.react_bucket.arn}/*"
      }
    ]
  })
}

output "ec2_public_ip" {
  value       = aws_instance.express_server.public_ip
  description = "Public IP address of the EC2 instance"
}

output "s3_website_url" {
  value       = aws_s3_bucket_website_configuration.react_website.website_endpoint
  description = "S3 Static Website URL Host"
}