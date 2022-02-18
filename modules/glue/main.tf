# Creates a Glue Catalog database which serves as the schema repository where tables for 
# each event type will be created by Segment.
# The AWS Glue Data Catalog is the central schema registry in the AWS eco-system which 
# makes the schema available to various tools like Athena, Spectrum, EMR etc.
# https://www.terraform.io/docs/providers/aws/r/glue_catalog_database.html
resource "aws_lakeformation_permissions" "segment_data_lake_formation" {
  principal        = var.principal
  permissions = ["ALL"]

  database {
    name       = aws_glue_catalog_database.segment_data_lake_glue_catalog.name
  }
}

resource "aws_glue_catalog_database" "segment_data_lake_glue_catalog" {
  name        = "${var.name}"
  description = "${var.description}"
}
