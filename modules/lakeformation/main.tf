# Granting all permissions to the emr_instance_profile_role and segment_datalake_role.
# These permissions are needed to run the sync on emr cluster and to manage the tables in the database.

resource "aws_lakeformation_permissions" "segment_datalake_lakeformation_table_permission" {
  for_each = var.iam_roles

  principal   = each.value
  permissions = ["ALL"]

  table {
    database_name = var.name
    wildcard      = true
  }
}

resource "aws_lakeformation_permissions" "segment_datalake_lakeformation_database_permission" {
  for_each = var.iam_roles

  principal   = each.value
  permissions = ["ALL"]

  database {
    name = var.name
  }
}

# This block will set the emr_instance_profile_role as a Database creator.
resource "aws_lakeformation_permissions" "segment_datalake_lakeformation_database_creator_permission" {
  principal   = lookup(var.iam_roles, "emr_instance_profile_role")
  permissions = ["CREATE_DATABASE"]

  catalog_resource = true
}
