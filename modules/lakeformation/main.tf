resource "aws_lakeformation_permissions" "segment_aws_lake_formation" {
  principal   = "arn:aws:iam::874799288871:role/segment_emr_instance_profile_role"
  permissions = ["ALL"]

  database {
    name       = var.name
  }

}
