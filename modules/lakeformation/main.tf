data "aws_iam_role" "role_name" {
  name = var.principal
}

resource "aws_lakeformation_permissions" "segment_data_lake_formation_table" {
  principal = data.aws_iam_role.role_name.arn
  permissions = ["ALL"]

  table {
    database_name = var.name
    wildcard = true
  }
}

resource "aws_lakeformation_permissions" "segment_data_lake_formation_database" {
  principal   = data.aws_iam_role.role_name.arn
  permissions = ["ALL"]

  database {
    name       = var.name
  }
}

