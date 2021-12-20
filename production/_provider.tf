provider "aws" {
  region  = "us-east-1"
  profile = "production"
  version = "2.50"

  default_tags {
    tags = {
      department = "data"
      subteam    = "dataeng"
      git = https://github.com/slicelife/terraform-aws-data-lake/
      environment = production
      terraformed = yes
    }
  }
}

terraform {
  required_version = "~> 0.12.0"
}
