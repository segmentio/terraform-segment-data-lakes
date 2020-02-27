provider "aws" {
  region  = "us-east-1"
  profile = "production"
}

terraform {
  required_version = "~> 0.12.0"
}
