# terraform-aws-data-lake

Terraform modules which create AWS resources for a Segment Data Lake.

# Prerequisites

* Authorized [AWS account](https://aws.amazon.com/account/).
* Ability to run Terraform with your AWS Account. Terraform 0.11+ (you can download tfswitch to help with switching your terraform version)
* A subnet within a VPC for the EMR cluster to run in.
* An [S3 Bucket](https://github.com/terraform-aws-modules/terraform-aws-s3-bucket) for Segment to load data into. You can create a new one just for this, or re-use an existing one you already have.

## VPC

You'll need to provide a subnet within a VPC for the EMR to cluster to run in. Here are some resources that can guide you through setting up a VPC for your EMR cluster:
* https://aws.amazon.com/blogs/big-data/launching-and-running-an-amazon-emr-cluster-inside-a-vpc/
* https://docs.aws.amazon.com/emr/latest/ManagementGuide/emr-clusters-in-a-vpc.html
* https://github.com/terraform-aws-modules/terraform-aws-vpc

# Modules

The repository is split into multiple modules, and each can be used independently:
* [iam](/modules/iam) - IAM roles that give Segment access to your AWS resources.
* [emr](/modules/emr) - EMR cluster that Segment can submit jobs to load events into your Data Lake.
* [glue](/modules/glue) - Glue tables that Segment can write metadata to.

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
    * Update the `external_ids` variable in the `locals` section to the workspace ID. This will allow all sources in the workspace to be synced to the Data Lake without any extra setup.
      * **Note - Existing users** may be using the `sourceID` here instead of the `workspaceID`, which was the previous configuration. Setting this value as the `sourceID` is still supported for existing users for backwards compatibility. Follow instructions [here](#Using-workspaceID-as-the-externalID) to migrate to `workspaceID`. This will ensure you do not need to update this value for each source you want to add.
    * Update the `name` in the `aws_s3_bucket` resource to the desired name of your S3 bucket
    * Update the `subnet_id` in the `emr` module to the subnet in which to create the EMR cluster

```hcl
provider "aws" {
  # Replace this with the AWS region your infrastructure is set up in.
  region = "us-west-2"

  # Currently our modules support both the version 2 and version 3 of the AWS provider.
  version = "~> 3"
}

locals {
  external_ids = {
    # Find these in the Segment UI. Only need to set this once for all sources in
    # the workspace
    #  - Settings > General Settings 
    <Workspace Name> = "<Workspace ID>"
  }

}

# This is the target where Segment will write your data.
# You can skip this if you already have an S3 bucket and just reference that name manually later.
# If you decide to skip this and use an existing bucket, ensure that you attach a 14 day expiration lifecycle policy to
# your S3 bucket for the "segment-stage/" prefix.
resource "aws_s3_bucket" "segment_datalake_s3" {
  bucket = "my-first-segment-datalake"

  lifecycle_rule {
    enabled = true

    prefix = "segment-stage/"

    expiration {
      days = 14
    }

    abort_incomplete_multipart_upload_days = 7
  }
}

# Creates the IAM Policy that allows Segment to access the necessary resources
# in your AWS account for loading your data.
module "iam" {
  source = "git@github.com:segmentio/terraform-aws-data-lake//modules/iam?ref=v0.4.2"

  # Suffix is not strictly required if only initializing this module once.
  # However, if you need to initialize multiple times across different Terraform
  # workspaces, this hook allows the generated IAM policies to be given unique
  # names.
  suffix = "-prod"

  s3_bucket    = aws_s3_bucket.segment_datalake_s3.id
  external_ids = values(local.external_ids)
}

# Creates an EMR Cluster that Segment uses for performing the final ETL on your
# data that lands in S3.
module "emr" {
  source = "git@github.com:segmentio/terraform-aws-data-lake//modules/emr?ref=v0.4.2"

  s3_bucket = aws_s3_bucket.segment_datalake_s3.id
  subnet_id = "subnet-XXX" # Replace this with the subnet ID you want the EMR cluster to run in.

  # LEAVE THIS AS-IS
  iam_emr_autoscaling_role = module.iam.iam_emr_autoscaling_role
  iam_emr_service_role     = module.iam.iam_emr_service_role
  iam_emr_instance_profile = module.iam.iam_emr_instance_profile
}
```

## Provision Resources
* Provide AWS credentials of the account being used. More details here: https://www.terraform.io/docs/providers/aws/index.html
  ```
  export AWS_ACCESS_KEY_ID="anaccesskey"
  export AWS_SECRET_ACCESS_KEY="asecretkey"
  export AWS_DEFAULT_REGION="us-west-2"
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
  Plan: 13 to add, 0 to change, 0 to destroy.
  ```
* Run apply - this step creates the resources in your AWS infrastructure
  ```
  terraform apply
  ```
  You should see:
  ```
  Apply complete! Resources: 13 added, 0 changed, 0 destroyed.
  ```

Note that creating the EMR cluster can take a while (typically 5 minutes).

Once applied, make a note of the following (you'll need to enter these as settings when configuring the Data Lake):
* The **AWS Region** and **AWS Account ID** where your Data Lake was configured
* The **Source ID and Slug** for _each_ Segment source that will be connected to the data lake
* The generated **EMR Cluster ID**
* The generated **IAM Role ARN**

# Common Errors

## The VPC/subnet configuration was invalid: No route to any external sources detected in Route Table for Subnet

```
Error: Error applying plan:
1 error(s) occurred:
* module.emr.aws_emr_cluster.segment_data_lake_emr_cluster: 1 error(s) occurred:
* aws_emr_cluster.segment_data_lake_emr_cluster: Error waiting for EMR Cluster state to be "WAITING" or "RUNNING": TERMINATED_WITH_ERRORS: VALIDATION_ERROR: The VPC/subnet configuration was invalid: No route to any external sources detected in Route Table for Subnet: subnet-{id} for VPC: vpc-{id}
Terraform does not automatically rollback in the face of errors.
Instead, your Terraform state file has been partially updated with
any resources that successfully completed. Please address the error
above and apply again to incrementally change your infrastructure.
exit status 1
```

The EMR cluster requires a route table attached to the subnet with an internet gateway. You can follow [this guide](https://aws.amazon.com/blogs/big-data/launching-and-running-an-amazon-emr-cluster-inside-a-vpc/) for guidance on creating and attaching a route table and internet gateway.

## The subnet configuration was invalid: The subnet subnet-{id} does not exist.

```
Error: Error applying plan:
1 error(s) occurred:
* module.emr.aws_emr_cluster.segment_data_lake_emr_cluster: 1 error(s) occurred:
* aws_emr_cluster.segment_data_lake_emr_cluster: Error waiting for EMR Cluster state to be "WAITING" or "RUNNING": TERMINATED_WITH_ERRORS: VALIDATION_ERROR: The subnet configuration was invalid: The subnet subnet-{id} does not exist.
Terraform does not automatically rollback in the face of errors.
Instead, your Terraform state file has been partially updated with
any resources that successfully completed. Please address the error
above and apply again to incrementally change your infrastructure.
exit status 1
```

The EMR cluster requires a subnet with a VPC. You can follow [this guide](https://aws.amazon.com/blogs/big-data/launching-and-running-an-amazon-emr-cluster-inside-a-vpc/) to create a subnet.

If all else fails, teardown and start over.

# FAQ
## Using workspaceID as the externalID
**Note** - This is only applicable for users currently set up to use the `sourceID` as the `externalID`. All new users should use the `workspaceID` for this value.

To simplify the set up process of not requiring an update to the IAM role for each new source that is added, you can now use the `workspaceID` as the `externalID`. This only requires this value to be set once for the entire workspace. For existing users, to start using the `workspaceID`:
* Add the `workspaceID` along with the existing `sourceIds` to the list of external ids in your `main.tf`
* Reach out to `friends@segment.com` with this request to start using the `workspaceID`
* Once Segment switches you over, you can remove the source ids from this list and not worry about updating it for any new source you wish to add.


# Supported Terraform Versions

Terraform 0.11 or higher is supported.

In order to support more versions of Terraform, the AWS Provider needs to held at v2,
as v3 has breaking changes we don't currently support. Our example `main.tf` has the
code to accomplish this.

# Development

To develop in this repository, you'll want the following tools set up:

* [Terraform](https://www.terraform.io/downloads.html), >= 0.12 (note that 0.12 is used to develop this module, even though 0.11 is supported)
* [terraform-docs](https://github.com/segmentio/terraform-docs)
* [tflint](https://github.com/terraform-linters/tflint)
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

# License

Released under the [MIT License](https://opensource.org/licenses/MIT).
