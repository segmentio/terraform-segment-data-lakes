# terraform-azure-data-lake

Terraform modules which create AWS and Azure resources for a Segment Data Lake as required.

# Prerequisites

* Authorized [Azure subscription](https://azure.microsoft.com/en-us/free/)
* Create a [Azure resource group](https://docs.microsoft.com/en-us/azure/azure-resource-manager/management/manage-resource-groups-portal#create-resource-groups) in your Azure account
* Create an account with [Microsoft](Microsoft.Authorization/roleAssignments/write) permissions
* A Databricks Workspace created using the Azure Console so that Segment can create a cluster using terraform script on which the jobs will run.
* Ability to run Terraform with your Azure Account. Terraform 0.12+ (you can download tfswitch to help with switching your terraform version)
* Configure the [Azure Command Line Interface](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli) (Azure CLI)
# Modules

The repository is split into multiple modules, and each can be used independently:
* [databricks](/azure_datalake/modules/databricks) - Databricks cluster to which Segment can submit jobs to load events into your Data Lake.
* [mysql](/azure_datalake/modules/mysql) - MySql Database to which Segment can get the data added to.
* [serviceprincipal](/azure_datalake/modules/serviceprincipal) - Service principle password using which Segment can access the databricks cluster.
* [StorageAccount](/azure_datalake/modules/StorageAccount) - Storage Account that Segment can write metadata to.

# Usage

## Terraform Installation
*Note*  - Skip this section if you already have a working Terraform setup
### OSX:
`brew` on OSX should install the latest version of Terraform.
```
brew install terraform
```

### Centos/Ubuntu:
* Follow instructions [here](https://phoenixnap.com/kb/how-to-install-terraform-centos-ubuntu) to install on Centos/Ubuntu OS.
* Ensure that the version installed in > 0.11.x

Verify installation works by running:
```
terraform help
```

## Set up Project
* Create project directory
```
mkdir segment-datalakes-tf
```
* Create `main.tf` file

```
terraform {
  required_providers {
    databricks = {
      source  = "databrickslabs/databricks"
    }

    azurerm = "~> 2"
  }
}

provider "azurerm" {
  features {}
}

data "azurerm_client_config" "current" {}


locals {
  region         = "my-region"
  resource_group = "my-resource-group"

  storage_account = "my-storage-account"
  container_name  = "my-container-name"

  key_vault_name = "me-key-vault"

  server_name = "my-server-db"
  db_name     = "my-database"
  db_password = "my-password"
  db_admin    = "my-admin"

  start_ip          = "0.0.0.0"
  end_ip            = "255.255.255.255"
  sku               = "premium"
  service_principal_name = "my-service-principle"

  databricks_workspace_url = "my-databricks-workspace"
  cluster_name   = "my-cluster"
  tenant_id      = "my-tenant-id"
}

resource "azurerm_resource_group" "segment_datalake" {
  name     = local.resource_group
  location = local.region
}

resource "azurerm_key_vault" "segment_vault" {
  name                     = local.key_vault_name
  location                 = azurerm_resource_group.segment_datalake.location
  resource_group_name      = azurerm_resource_group.segment_datalake.name
  tenant_id                = local.tenant_id
  soft_delete_enabled      = false
  purge_protection_enabled = false
  sku_name                 = "standard"
}

resource "azurerm_key_vault_access_policy" "segment_vault" {
  key_vault_id       = azurerm_key_vault.segment_vault.id
  tenant_id          = data.azurerm_client_config.current.tenant_id
  object_id          = data.azurerm_client_config.current.object_id
  secret_permissions = ["delete", "get", "list", "set"]
}


module "segment_data_lake_storage_account" {
  source = "git@github.com:segmentio/terraform-segment-data-lake//azure_datalake/modules/storageaccount?ref=v0.8.0"

  name           = local.storage_account
  region         = local.region
  resource_group_name = azurerm_resource_group.segment_datalake.name
  container_name = local.container_name
}

module "segment_data_lake_mysql" {
  source = "git@github.com:segmentio/terraform-segment-data-lake//azure_datalake/modules/mysql?ref=v0.8.0"


  region = local.region
  server_name = local.server_name
  resource_group_name = azurerm_resource_group.segment_datalake.name
  db_name     = local.db_name
  db_admin    = local.db_admin
  password   =  local.db_password

}

module "segment_data_lake_service_principal" {
  source = "git@github.com:segmentio/terraform-segment-data-lake//azure_datalake/modules/serviceprincipal?ref=v0.8.0"

  app_name = local.service_principal_name

}

module "segment_data_lake_databricks_cluster" {
  source = "git@github.com:segmentio/terraform-segment-data-lake//azure_datalake/modules/databricks?ref=v0.8.0"
  workspace_url = local.databricks_workspace_url

  cluster_name             = local.cluster_name
  storage_account_name     = local.storage_account
  container_name           = local.container_name
  mysql_dbname             = module.segment_data_lake_mysql.mysql_dbname
  mysql_password           = module.segment_data_lake_mysql.mysql_password
  mysql_server_url         = module.segment_data_lake_mysql.mysql_server_fqdn
  mysql_username           = module.segment_data_lake_mysql.mysql_username
  service_principal_id     = module.segment_data_lake_service_principal.client_id
  service_principal_secret = module.segment_data_lake_service_principal.spsecret
  keyvault_dns_name        = azurerm_key_vault.segment_vault.vault_uri
  keyvault_resource_id     = azurerm_key_vault.segment_vault.id
  tenant_id                = local.tenant_id

}
```

## Provision Resources
* Provide Azure credentials of the account being used. 
  ```
  az login
  ```
* Initialize the references modules
  ```
  terraform init
  ```
  You should see a success message once you run the plan:
  ```
  Terraform has been successfully initialized!
  ```
* Run plan
  This does not create any resources. It just outputs what will be created after you run apply(next step).
  ```
  terraform plan
  ```
  You should see something like towards the end of the plan:
  ```
  Plan: 19 to add, 0 to change, 0 to destroy.
  ```
* Run apply - this step creates the resources in your AWS infrastructure
  ```
  terraform apply
  ```
  You should see:
  ```
  Apply complete! Resources: 19 added, 0 changed, 0 destroyed.
  ```

Note that creating the EMR cluster can take a while (typically 5 minutes).

Once applied, make a note of the following (you'll need to enter these as settings when configuring the Data Lake):
* The **Azure Subscription ID**, **Azure Tenant ID**, **Databricks Instance URL** and the **Databricks Workspace Name** that were used.
* The **Azure Storage Account** and **Azure Storage Container** where your data files will be stored
* The **Source ID and Slug** for _each_ Segment source that will be connected to the data lake
* The generated **Databricks Cluster ID**
* The generated **Service Principal Client ID** and **Service Principal Client Secret**

# Supported Terraform Versions

Terraform 0.12 or higher is supported.

In order to support more versions of Terraform, the AWS Provider needs to held at v2,
as v3 has breaking changes we don't currently support. Our example `main.tf` has the
code to accomplish this.

# Development

To develop in this repository, you'll want the following tools set up:

* [Terraform](https://www.terraform.io/downloads.html), >= 0.12 (note that 0.12 is used to develop this module, 0.11 is no longer supported)
* [terraform-docs](https://github.com/segmentio/terraform-docs)
* [tflint](https://github.com/terraform-linters/tflint), 0.15.x - 0.26.x
* [Ruby](https://www.ruby-lang.org/en/documentation/installation/), [>= 2.4.2](https://rvm.io)
* [Bundler](https://bundler.io)

To run unit tests, you also need an AWS account to be able to provision resources.

# Releasing

Releases are made from the master branch. First, make sure you have the last code from master pulled locally:

```
* git remote update
* git checkout master
* git reset origin/master --hard
```

Then, use [`git release`](https://github.com/tj/git-extras/blob/master/Commands.md#git-release) to cut a new version that follows [semver](https://semver.org):

```
git release x.y.z
```

Lastly, craft a new [Github release](https://github.com/segmentio/terraform-aws-data-lake/releases).
