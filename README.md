# terraform-aws-data-lake

_Note: Data Lakes is currently in Limited Availability._

Terraform modules which create AWS resources for a Segment Data Lake.

# Getting Started

## Prerequisites

* Accept the [Data Lakes Terms of Service](https://app.segment.com/{workspace_slug}/destinations/catalog?category=DataLakes) (replace the `{workspace_slug}` with your workspace slug).
* Authorized [AWS account](https://aws.amazon.com/account/).
* Ability to run Terraform with your AWS Account. You must use Terraform 0.11 or higher.
* [VPC](https://github.com/terraform-aws-modules/terraform-aws-vpc) for the EMR cluster to run in.
* [S3 Bucket](https://github.com/terraform-aws-modules/terraform-aws-s3-bucket) to send data from Segment to.

# Set up AWS resources with TF

* [iam](/modules/iam) - IAM roles that give Segment access to your AWS resources.
* [glue](/modules/glue) - Glue tables that Segment can write metadata to.
* [emr](/modules/emr) - EMR cluster that Segment can submit jobs to load events into your Data Lake.

# Supported Terraform Versions

Terraform 0.11 or higher is supported.

# Development

To develop in this repository, you'll want the following tools set up:

* [Terraform](https://www.terraform.io/downloads.html), >= 0.12 (note that 0.12 is used to develop this module, even though 0.11 is supported)
* [terraform-docs](https://github.com/segmentio/terraform-docs)
* [tflint](https://github.com/terraform-linters/tflint)
* [Ruby](https://www.ruby-lang.org/en/documentation/installation/), [>= 2.4.2](https://rvm.io)
* [Bundler](https://bundler.io)

To run unit tests, you also need an AWS account to be able to provision resources.

# License

Released under the [MIT License](https://opensource.org/licenses/MIT).
