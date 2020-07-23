locals {
  s3_bucket_name = "211459479356-slice-segment-data-lake"
  external_ids   = ["KnSuvLUHMG", #Direct-Web-QA,
                    "42ukzMtDak" #Storefront-QA
    ] # Segment sources that will be enabled for Data Lakes.
  subnet_id      = "subnet-097e2dc4f7499f77a" # Subnet the EMR cluster will run in.
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

  name        = "segment_data_lake"
}

module "iam" {
  source = "https://github.com/segmentio/terraform-aws-data-lake/archive/v0.2.0.zip//terraform-aws-data-lake-0.2.0/modules/iam"

  name               = "segment-data-lake-iam-role"
  s3_bucket          = "${local.s3_bucket_name}"
  external_ids       = "${local.external_ids}"
}

module "emr" {
  source = "https://github.com/segmentio/terraform-aws-data-lake/archive/v0.1.5.zip//terraform-aws-data-lake-0.1.5/modules/emr"

  s3_bucket = "${local.s3_bucket_name}"
  subnet_id = "${local.subnet_id}"
}
