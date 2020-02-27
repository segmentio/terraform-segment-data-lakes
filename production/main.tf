locals {
  s3_bucket_name = "651565136086-slice-segment-data-lake"
  external_ids   = ["0O8NKjDrUO","tGYLBslX21","TaxmJpTiB5","N6hYZDFTlp"] # Segment sources that will be enabled for Data Lakes.
  subnet_id      = "subnet-9f90a1d4" # Subnet the EMR cluster will run in.
}

locals {
  tags = {
    s3_bucket_name = "${local.s3_bucket_name}"
    external_ids   = "${local.external_ids}"
    subnet_id      = "${local.subnet_id}"
  }
}

module "s3_bucket" {
  source    = "../modules/s3_bucket"
  s3_bucket = local.s3_bucket_name
}

module "glue" {
  source = "https://github.com/segmentio/terraform-aws-data-lake/archive/v0.1.1.zip//terraform-aws-data-lake-0.1.1/modules/glue"

  name        = "segment_data_lake"
}

module "iam" {
  source = "https://github.com/segmentio/terraform-aws-data-lake/archive/v0.1.4.zip//terraform-aws-data-lake-0.1.4/modules/iam"

  name               = "segment-data-lake-iam-role"
  s3_bucket          = local.s3_bucket_name
  external_ids       = local.external_ids
}

module "emr" {
  source = "https://github.com/segmentio/terraform-aws-data-lake/archive/v0.1.1.zip//terraform-aws-data-lake-0.1.1/modules/emr"

  s3_bucket = local.s3_bucket_name
  subnet_id = local.subnet_id
}