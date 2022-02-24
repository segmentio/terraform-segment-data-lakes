resource "aws_lakeformation_permissions" "segment_data_lake_formation_table" {
  principal = var.principal
  permissions = ["ALL"]

  table {
    database_name = aws_lakeformation_permissions.segment_data_lake_formation_database.database.name
    wildcard = true
  }
}

resource "aws_lakeformation_permissions" "segment_data_lake_formation_database" {
  principal   = var.principal
  permissions = ["ALL"]

  database {
    name       = var.name
  }

}
