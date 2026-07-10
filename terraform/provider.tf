provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = "DevOps-Demo-Project-0"
      Environment = var.environment
      ManagedBy   = "Terraform"
    }
  }
}
