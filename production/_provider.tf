provider "aws" {
  region  = "us-east-1"
  profile = "production"
  version = "2.50"
}

terraform {
  required_version = "~> 0.12.0"
}
