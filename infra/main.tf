terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
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

resource "aws_s3_bucket" "demo_bucket" {
  bucket = "cloudgenius-demo-bucket-${random_id.rand.hex}"
  tags = {
    Name = "TerraformCloudDemo"
  }
}

resource "random_id" "rand" {
  byte_length = 4
}

output "bucket_name" {
  value = aws_s3_bucket.demo_bucket.bucket
}
