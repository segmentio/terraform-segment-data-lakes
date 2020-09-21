provider "aws" {
  region = "us-west-2"
}

locals {
  tags = {
    test = "unit-test"
  }
}

module "glue" {
  source = "../../modules/glue"

  name        = "data_lake_tf_test"
  description = "Glue DB for Terraform test"
}

module "iam" {
  source = "../../modules/iam"

  suffix       = "dev"
  s3_bucket    = "data_lake_tf_test_s3_bucket"
  external_ids = ["test_external_id_1", "test_external_id_2"]
  tags         = "${local.tags}"
}

module "emr" {
  source = "../../modules/emr"

  s3_bucket    = "data_lake_tf_test_s3_bucket"
  subnet_id    = "subnet-00f137e4f3a6f8356"
  tags         = "${local.tags}"
  cluster_name = "test-cluster"

  # LEAVE THIS AS-IS
  iam_emr_autoscaling_role = "${module.iam.iam_emr_autoscaling_role}"
  iam_emr_service_role     = "${module.iam.iam_emr_service_role}"
  iam_emr_instance_profile = "${module.iam.iam_emr_instance_profile}"
}
