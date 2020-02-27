terraform {
  backend "s3" {
    bucket   = "211459479356-terraform-state"
    key      = "data-engineering/segment-data-lake.tfstate"
    region   = "us-east-2"
    role_arn = "arn:aws:iam::211459479356:role/terraform"
    encrypt  = true
  }
}