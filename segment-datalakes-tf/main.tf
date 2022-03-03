provider "aws" {
  # Replace this with the AWS region your infrastructure is set up in.
  region = "us-west-2"

  # Currently our modules require the older v2 AWS provider, as upgrading to v3 has notable breaking changes.
  version = "~> 2"
}

locals {
  external_ids = {
    # Find these in the Segment UI. Only need to set this once for all sources in
    # the workspace
    #  - Settings > General Settings 
    "Sauron Stage" = "9a2aceada4"
  }

}

# This is the target where Segment will write your data.
# You can skip this if you already have an S3 bucket and just reference that name manually later.
# If you decide to skip this and use an existing bucket, ensure that you attach a 14 day expiration lifecycle policy to
# your S3 bucket for the "segment-stage/" prefix.
resource "aws_s3_bucket" "segment_datalake_s3" {
  bucket = "onboarding-shayan"

}

# Creates the IAM Policy that allows Segment to access the necessary resources
# in your AWS account for loading your data.
module "iam" {
  source = "git@github.com:segmentio/terraform-aws-data-lake//modules/iam?ref=v0.5.0"

  # Suffix is not strictly required if only initializing this module once.
  # However, if you need to initialize multiple times across different Terraform
  # workspaces, this hook allows the generated IAM policies to be given unique
  # names.
  suffix = "_shayan_golafshani"

  s3_bucket    = aws_s3_bucket.segment_datalake_s3.id
  external_ids = values(local.external_ids)
}

# Creates an EMR Cluster that Segment uses for performing the final ETL on your
# data that lands in S3.
module "emr" {
  source = "git@github.com:segmentio/terraform-aws-data-lake//modules/emr?ref=v0.5.0"

  s3_bucket = aws_s3_bucket.segment_datalake_s3.id
  subnet_id = "subnet-00f137e4f3a6f8356" # Replace this with the subnet ID you want the EMR cluster to run in.

  # LEAVE THIS AS-IS
  iam_emr_autoscaling_role = module.iam.iam_emr_autoscaling_role
  iam_emr_service_role     = module.iam.iam_emr_service_role
  iam_emr_instance_profile = module.iam.iam_emr_instance_profile
}