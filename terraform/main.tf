resource "aws_security_group" "backend_sg" {
  name        = "express-backend-sg"
  description = "Allow traffic for Express API and Nginx Frontend"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] 
  }

  ingress {
    from_port   = 80
    to_port     = 80
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
              apt-get install -y docker.io docker-compose awscli
              systemctl start docker
              systemctl enable docker
              usermod -aG docker ubuntu
              EOF

  tags = {
    Name = "express-backend-production"
  }
}

resource "aws_ecr_repository" "backend" {
  name                 = "express-backend"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_ecr_repository" "frontend" {
  name                 = "express-frontend"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

output "ec2_public_ip" {
  value       = aws_instance.express_server.public_ip
  description = "Public IP address of the EC2 instance"
}

output "backend_ecr_url" {
  value       = aws_ecr_repository.backend.repository_url
  description = "Amazon ECR Private Registry URL for Express Backend"
}

output "frontend_ecr_url" {
  value = aws_ecr_repository.frontend.repository_url
  description = "Amazon ECR Private Registry URL for React Frontend"
}