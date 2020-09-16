locals {
  s3_bucket_name = "211459479356-slice-segment-data-lake"
  external_ids = [
    "KnSuvLUHMG",                        #Direct-Web-QA,
    "42ukzMtDak",                        #Storefront-QA
    "e398yK2CXsbPJFbTRU9Nf8"             #Braze-Dev
  ]                                      # Segment sources that will be enabled for Data Lakes.
  subnet_id = "subnet-097e2dc4f7499f77a" # Subnet the EMR cluster will run in.
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
  source = "https://github.com/segmentio/terraform-aws-data-lake/archive/v0.2.0.zip//terraform-aws-data-lake-0.2.0/modules/glue"

  name = "segment_data_lake"
}

module "iam" {
  source = "git@github.com:segmentio/terraform-aws-data-lake//modules/iam?ref=v0.4.0"

  s3_bucket    = "${local.s3_bucket_name}"
  external_ids = "${local.external_ids}"
}

module "emr" {
  source = "git@github.com:segmentio/terraform-aws-data-lake//modules/emr?ref=v0.4.0"

  s3_bucket = "${local.s3_bucket_name}"
  subnet_id = "${local.subnet_id}"
  iam_emr_autoscaling_role = "${module.iam.iam_emr_autoscaling_role}"
  iam_emr_service_role     = "${module.iam.iam_emr_service_role}"
  iam_emr_instance_profile = "${module.iam.iam_emr_instance_profile}"
}
