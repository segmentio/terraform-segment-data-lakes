locals {
  s3_bucket_name = "651565136086-slice-segment-data-lake"
  # Segment sources that will be enabled for Data Lakes.
  external_ids = [
    "0O8NKjDrUO", # IOS Prod
    "tGYLBslX21", # Android Prod
    "TaxmJpTiB5", # Web Prod
    "N6hYZDFTlp", # Storefront Prod
    "H5V4KbCRon", # Core API
    "0ThsmykUHG", # Slicelink
    "uUZbyyEjUarcfNYxdomUAJ", # Braze-prod
    "oIQ4q7dcTK", # partner-websites-prod
    "bH2qnkb0vZ", # slice-os-prod
    "tUbtH4DbIJ", # direct-web
    "G5yFS1KhpW", # admin
    "XPiW5h2e4n"  # consumer-landing-pages-production

  ]
  subnet_id = "subnet-9f90a1d4" # Subnet the EMR cluster will run in.
  arn_prefix = "arn:aws:iam::651565136086"
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

module "iam" {
  source = "https://github.com/segmentio/terraform-aws-data-lake/archive/v0.3.0.zip//terraform-aws-data-lake-0.3.0/modules/iam"

  s3_bucket    = local.s3_bucket_name
  external_ids = local.external_ids
}

module "emr" {
  source = "https://github.com/segmentio/terraform-aws-data-lake/archive/v0.3.0.zip//terraform-aws-data-lake-0.3.0/modules/emr"

  s3_bucket = local.s3_bucket_name
  subnet_id = local.subnet_id
  iam_emr_autoscaling_role = "${local.arn_prefix}:role/${module.iam.iam_emr_autoscaling_role}"
  iam_emr_service_role     = "${local.arn_prefix}:role/${module.iam.iam_emr_service_role}"
  iam_emr_instance_profile = "${local.arn_prefix}:instance-profile/${module.iam.iam_emr_instance_profile}"
}
