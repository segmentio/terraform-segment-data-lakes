## Requirements

Works for version >= 0.12
Note: If you have teraform 0.12, you will have to run the setup separately for each database. For version >=0.13, the setup will work for a set of databases.


## Providers

The following providers are used by this module:

- aws

## Required Inputs

The following input variables are required:

### name

Description: Name of the glue database to add aws lake formation setup.

Type: `string`

### iam_roles

Description: This is a map containing the two roles. The iam datalake role and the emr instance profile role are to be added using the 'datalakes_iam_role' and 'emr_instance_profile_role' keys respectively.

Type: `map(string)`

