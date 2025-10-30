terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.5"
    }
  }

  cloud {
    organization = "cloudgenius-acme"

    workspaces {
      name = "cicd-using-jenkins-terraform-and-aws"
    }
  }
}

provider "aws" {
  region = var.aws_region
}
