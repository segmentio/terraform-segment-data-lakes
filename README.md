# terraform-aws-data-lake

_Note: Data Lakes is currently in Limited Availability._

Terraform modules which create AWS resources for a Segment Data Lake.

# Getting Started

## Prerequisites

* Accept the [Data Lakes Terms of Service](https://app.segment.com/{workspace_slug}/destinations/catalog?category=DataLakes) (replace the `{workspace_slug}` with your workspace slug).
* Setup an [AWS account](https://aws.amazon.com/account/).
* Setup Terraform with the [AWS provider](https://www.terraform.io/docs/providers/aws/index.html). You muse use Terraform 0.11 or higher.
* Create a [VPC](https://github.com/terraform-aws-modules/terraform-aws-vpc) for the EMR cluster to run in.
* Create a [S3 Bucket](https://github.com/terraform-aws-modules/terraform-aws-s3-bucket) to store data.

# Setup AWS resources with TF

* [iam](/modules/iam) - IAM roles that give Segment access to your AWS resources.
* [glue](/modules/glue) - Glue tables that Segment can write metadata to.
* [emr](/modules/emr) - EMR cluster that Segment can submit jobs to load events into your Data Lake.

# Supported Terraform Versions

Terraform 0.11 or higher are supported.

# Development

To develop in this repository, you'll want the following tools setup:

* [Terraform](https://www.terraform.io/downloads.html)
* [terraform-docs](https://github.com/segmentio/terraform-docs)
* [tflint](https://github.com/terraform-linters/tflint)

# License

Released under the [MIT License](https://opensource.org/licenses/MIT).
