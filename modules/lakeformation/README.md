## Requirements

Works for version >= 0.13

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

