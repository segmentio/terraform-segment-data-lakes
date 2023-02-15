locals {
  s3_bucket_name = "651565136086-slice-segment-data-lake"
  # Segment sources that will be enabled for Data Lakes. add source id from https://app.segment.com/mypizza-slice/sources/<source friendly name>/settings/keys
  external_ids = [
    "jzkCRirXhM",
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
    "XPiW5h2e4n",  # consumer-landing-pages-production
    "dx7TcnkEWVuXwnDJoro7kb", # register-production
    "aMvapgiQQx7yiAADNDATTx", # drivers-app-ios-production
    "nHz8f4u55CHBWXPNhSJsVY" # drivers-app-android-production
  ]
  subnet_id = "subnet-9f90a1d4" # Subnet the EMR cluster will run in.
  arn_prefix = "arn:aws:iam::651565136086"

  default_tags =  {
    department = "data"
    subteam    = "dataeng"
    git = "https://github.com/slicelife/terraform-aws-data-lake/"
    environment = "production"
    terraformed = "yes"
  }
}

data "aws_secretsmanager_secret_version" "segment_secrets" {
  secret_id = "dataeng/segment"
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
  tags = local.default_tags
  data_account = 787212289020
}

module "iam" {
  source = "https://github.com/segmentio/terraform-aws-data-lake/archive/v0.3.0.zip//terraform-segment-data-lakes-0.3.0/modules/iam"

  s3_bucket    = local.s3_bucket_name
  external_ids = local.external_ids
  tags = local.default_tags
  
}

module "emr" {
  source = "https://github.com/segmentio/terraform-aws-data-lake/archive/v0.3.0.zip//terraform-segment-data-lakes-0.3.0/modules/emr"

  s3_bucket = local.s3_bucket_name
  subnet_id = local.subnet_id
  iam_emr_autoscaling_role = "${local.arn_prefix}:role/${module.iam.iam_emr_autoscaling_role}"
  iam_emr_service_role     = "${local.arn_prefix}:role/${module.iam.iam_emr_service_role}"
  iam_emr_instance_profile = "${local.arn_prefix}:instance-profile/${module.iam.iam_emr_instance_profile}"
  core_instance_count = 3
  core_instance_max_count = 6
  task_instance_count = 3
  task_instance_max_count = 6
  tags = local.default_tags

}

module "segment" {

  source = "../modules/segment"
  cluster_id  = module.emr.cluster_id
  environment = "prod"
  token       = jsondecode(data.aws_secretsmanager_secret_version.segment_secrets.secret_string)["token"]
  url         = jsondecode(data.aws_secretsmanager_secret_version.segment_secrets.secret_string)["url"]
}
