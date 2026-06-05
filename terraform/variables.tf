variable "aws_region" {
  type    = string
  default = "ap-south-1"
}

variable "key_name" {
  type        = string
  default     = "new-key" 
  description = "The key pair name for SSH access to EC2"
}

variable "frontend_bucket_name" {
  type    = string
  default = "shravani-react-frontend-2026-prod" 
}