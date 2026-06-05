terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {
    bucket  = "tf-state-bucket-shravani" 
    key     = "state/react-express-app.tfstate"
    region  = "ap-south-1"
    encrypt = true                            
  }
}

provider "aws" {
  region = var.aws_region
}