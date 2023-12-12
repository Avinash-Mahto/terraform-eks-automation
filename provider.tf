terraform {
    required_providers {
      aws = {
        source = "hashicorp/aws"
        version = "~>5.11.0"
      }
    }
    backend "s3" {
        bucket = "tf-backup-10302023"
        key = "state/terraform.tfstate"
        region = "ap-southeast-1"
      
    }
    required_version = ">= 1.2.0"
}
provider "aws" {
    region = "ap-southeast-1"
    profile = "admin"
}