provider "aws" {
  region  = "us-east-1"
  profile = "development"
}

terraform {
  required_version = "~> 0.12.0"
}
