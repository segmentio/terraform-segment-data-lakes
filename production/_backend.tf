terraform {
  backend "s3" {
    bucket  = "651565136086-terraform-state"
    key     = "data-engineering/segment-data-lake.tfstate"
    region  = "us-east-2"
    encrypt = true
  }
}
