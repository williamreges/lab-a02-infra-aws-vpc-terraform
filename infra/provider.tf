terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  backend "s3" {
    bucket = "reges-remote-state"
    key    = "lab-a02-infra-aws-vpc-terraform/terraform.tfstate"
    region = "sa-east-1"
  }

}

# Configure the AWS Provider
provider "aws" {
  region = var.regiao
}

