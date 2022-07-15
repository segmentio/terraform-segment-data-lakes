data "azurerm_client_config" "current" {}

provider "azurerm" {
  features {}
}

provider "databricks" {
  host = var.workspace_url
}

resource "databricks_cluster" "segment_databricks_cluster" {
  cluster_name            = var.cluster_name
  spark_version           = "9.1.x-scala2.12"
  node_type_id            = "Standard_DS4_v2"

  autoscale {
    min_workers = 2
    max_workers = 8
  }

  spark_conf = {

    "spark.hive.mapred.supports.subdirectories": true,
    "spark.sql.storeAssignmentPolicy": "Legacy",
    "mapreduce.input.fileinputformat.input.dir.recursive": true,
    "spark.sql.hive.convertMetastoreParquet": false,

    "datanucleus.autoCreateSchema": true,
    "datanucleus.autoCreateTables": true,
    "spark.sql.hive.metastore.schema.verification": false,
    "datanucleus.fixedDatastore": false,

    "spark.sql.hive.metastore.version": "2.3.7",
    "spark.sql.hive.metastore.jars": "builtin",

    "spark.hadoop.fs.azure.account.oauth.provider.type.${var.storage_account_name}.dfs.core.windows.net": "org.apache.hadoop.fs.azurebfs.oauth2.ClientCredsTokenProvider",
    "spark.hadoop.fs.azure.account.oauth2.client.endpoint.${var.storage_account_name}.dfs.core.windows.net": "https://login.microsoftonline.com/${var.tenant_id}/oauth2/token",
    "spark.hadoop.fs.azure.account.oauth2.client.secret.${var.storage_account_name}.dfs.core.windows.net": var.service_principal_secret,
    "spark.hadoop.fs.azure.account.auth.type.${var.storage_account_name}.dfs.core.windows.net": "OAuth",
    "spark.hadoop.fs.azure.account.oauth2.client.id.${var.storage_account_name}.dfs.core.windows.net": var.service_principal_id,

    "spark.hadoop.javax.jdo.option.ConnectionDriverName": "org.mariadb.jdbc.Driver",
    "spark.hadoop.javax.jdo.option.ConnectionURL": "jdbc:mysql://${var.mysql_server_url}:3306/${var.mysql_dbname}?useSSL=true&requireSSL=false",
    "spark.hadoop.javax.jdo.option.ConnectionUserName": var.mysql_username,
    "spark.hadoop.javax.jdo.option.ConnectionPassword": var.mysql_password
  }
}

resource "databricks_group" "segment" {
  display_name = "segment"

}

resource "databricks_user" "me" {
  user_name = "datalakes@segment.com"
  external_id = var.service_principal_id
  display_name = "segment"
}

resource "databricks_group_member" "i-am-admin" {
  group_id  = databricks_group.segment.id
  member_id = databricks_user.me.id
}


resource "databricks_permissions" "cluster_usage" {
  cluster_id = databricks_cluster.segment_databricks_cluster.cluster_id

  access_control {
    group_name       = databricks_group.segment.display_name
    permission_level = "CAN_MANAGE"
  }
}


resource "databricks_secret_scope" "kv" {
  name = "segment-keyvault"

  keyvault_metadata {
    resource_id = var.keyvault_resource_id
    dns_name    = var.keyvault_dns_name
  }
}

