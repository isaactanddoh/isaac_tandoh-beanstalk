# Backend Configuration
terraform {
    backend "s3" {
    bucket = "isaac-beanstalk-dev-tfstate-bucket"
    key = "beanstalk/dev.tfstate"
    region = "us-east-1"
    }
}

# Provider Configuration
terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  # Set region to us-east-1
  region = "us-east-1"
}

