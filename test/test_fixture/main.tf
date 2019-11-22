provider "aws" {
  region = "us-east-1"
}

module "glue" {
  source = "../../modules/glue"

  name        = "test_db"
  description = "Glue DB for test"
}

module "iam" {
  source = "../../modules/iam"

  name               = "test-iam-role"
  s3_bucket          = "test_s3_bucket"
  glue_database_name = "test_glue_db"
  external_ids       = ["test_external_id_1", "test_external_id_2"]
  tags = {
    test = "unit-test"
  }
}
