#Granting all permissions to the emr_instance_profile_role and segment_datalake_role.
#These permissions are needed to run the sync on emr cluster and to manage the tables in the database.

resource "aws_lakeformation_permissions" "segment_datalake_lakeformation_table_permission" {
  for_each = var.iam_roles

  principal = each.key
  #principal = var.emr_instance_profile_role
  permissions = ["ALL"]

  table {
    database_name = var.name
    wildcard = true
  }
}

resource "aws_lakeformation_permissions" "segment_datalake_lakeformation_database_permission" {
  for_each = var.iam_roles

  principal = each.key
  #principal   = var.emr_instance_profile_role
  permissions = ["ALL"]

  database {
    name = var.name
  }
}

#This block will set the emr_instance_profile_role as a Database creator.
resource "aws_lakeformation_permissions" "segment_datalake_lakeformation_database_creator_permission" {
  principal   = tolist(var.iam_roles)[1]
  permissions = ["CREATE_DATABASE"]

  catalog_resource = true
}
/*
resource "aws_lakeformation_permissions" "segment_data_lake_formation_table_datalake" {
  principal = var.segment_datalake_role
  permissions = ["ALL"]

  table {
    database_name = var.name
    wildcard = true
  }
}

resource "aws_lakeformation_permissions" "segment_data_lake_formation_database_datalake" {
  principal   = var.segment_datalake_role
  permissions = ["ALL"]

  database {
    name       = var.name
  }
}
*/
