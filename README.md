# terraform-data-lake

Terraform modules which create AWS or Azure resources for a Segment Data Lake as required.

# Usage

If you want to create an AWS datalake refer to the modules and setup guide in [aws_datalake](aws_datalake) folder 

If you want to create an Azure datalake refer to the modules and setup guide in [azure_datalake](azure_datalake) folder

# FAQ
## Using workspaceID as the externalID
**Note** - This is only applicable for users currently set up to use the `sourceID` as the `externalID`. All new users should use the `workspaceID` for this value.

To simplify the set up process of not requiring an update to the IAM role for each new source that is added, you can now use the `workspaceID` as the `externalID`. This only requires this value to be set once for the entire workspace. For existing users, to start using the `workspaceID`:
* Add the `workspaceID` along with the existing `sourceIds` to the list of external ids in your `main.tf`
* Reach out to `friends@segment.com` with this request to start using the `workspaceID`
* Once Segment switches you over, you can remove the source ids from this list and not worry about updating it for any new source you wish to add.


# Supported Terraform Versions

Terraform 0.12 or higher is supported.

In order to support more versions of Terraform, the AWS Provider needs to held at v2,
as v3 has breaking changes we don't currently support. Our example `main.tf` has the
code to accomplish this.

# License

Released under the [MIT License](https://opensource.org/licenses/MIT).
