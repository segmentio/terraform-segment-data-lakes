resource "aws_lakeformation_permissions" "segment_aws_lake_formation" {
  role        = "segment_emr_instance_profile_role"
  permissions = ["SUPER"]

  database {
    name       = var.name
  }

}
