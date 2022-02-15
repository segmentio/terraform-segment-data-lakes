resource "aws_lakeformation_permissions" "segment_aws_lake_formation" {
  principal   = "IAMAllowedPrincipals"
  permissions = ["ALL"]

  database {
    name       = var.name
  }

}
