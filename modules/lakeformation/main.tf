resource "aws_lakeformation_permissions" "segment_data_lake_formation_table_emr" {
  principal = var.emr_role
  permissions = ["ALL"]

  table {
    database_name = var.name
    wildcard = true
  }
}

resource "aws_lakeformation_permissions" "segment_data_lake_formation_database_emr" {
  principal   = var.emr_role
  permissions = ["ALL"]

  database {
    name       = var.name
  }
}

resource "aws_lakeformation_permissions" "segment_data_lake_formation_database_creator" {
  principal   = var.emr_role
  permissions = ["CREATE_DATABASE"]

  catalog_resource = true
}

resource "aws_lakeformation_permissions" "segment_data_lake_formation_table_datalake" {
  principal = var.datalake_role
  permissions = ["ALL"]

  table {
    database_name = var.name
    wildcard = true
  }
}

resource "aws_lakeformation_permissions" "segment_data_lake_formation_database_datalake" {
  principal   = var.datalake_role
  permissions = ["ALL"]

  database {
    name       = var.name
  }
}

