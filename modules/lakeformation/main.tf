resource "aws_lakeformation_permissions" "segment_data_lake_formation" {
  principal   = var.principal
  permissions = ["ALL"]

  database {
    name       = var.name
  }
  table {
    database_name = var.name
    wildcard = true
  }
}
