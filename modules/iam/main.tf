# Creates the IAM role used by Segment.
# https://www.terraform.io/docs/providers/aws/r/iam_role.html
resource "aws_iam_role" "segment_data_lake_iam_role" {
  name               = "${var.name}"
  description        = "IAM Role used by Segment"
  assume_role_policy = "${data.aws_iam_policy_document.segment_data_lake_assume_role_policy_document.json}"
  tags               = "${local.tags}"
}

# Policy attached to the IAM role.
# https://www.terraform.io/docs/providers/aws/d/iam_policy_document.html
data "aws_iam_policy_document" "segment_data_lake_assume_role_policy_document" {
  version = "2012-10-17"

  # Allows Segment to assume a role.
  statement {
    actions = [
      "sts:AssumeRole",
    ]

    principals {
      type        = "AWS"
      identifiers = "${var.segment_aws_accounts}"
    }

    effect = "Allow"

    condition {
      test     = "StringEquals"
      variable = "sts:ExternalId"
      values   = "${var.external_ids}"
    }
  }
}

# https://www.terraform.io/docs/providers/aws/d/caller_identity.html
data "aws_caller_identity" "current" {}

# https://www.terraform.io/docs/providers/aws/d/region.html
data "aws_region" "current" {}

resource "aws_iam_policy" "segment_data_lake_policy" {
  name        = "SegmentDataLakePolicy"
  path        = "/"
  description = "Gives access to resources in your Data Lake"

  policy = "${data.aws_iam_policy_document.segment_data_lake_policy_document.json}"
}

data "aws_iam_policy_document" "segment_data_lake_policy_document" {
  version = "2012-10-17"

  # Allows Segment to submit EMR jobs.
  statement {
    actions = [
      "elasticmapreduce:AddJobFlowSteps",
      "elasticmapreduce:CancelSteps",
      "elasticmapreduce:DescribeCluster",
      "elasticmapreduce:DescribeStep",
    ]

    resources = [
      "*",
    ]

    condition {
      test     = "StringEquals"
      variable = "elasticmapreduce:ResourceTag/vendor"
      values = [
        "segment",
      ]
    }

    effect = "Allow"
  }

  # Allows Segment to read and write to the Glue table.
  statement {
    actions = [
      "glue:CreateTable",
      "glue:CreateDatabase",
      "glue:GetTable",
      "glue:GetTables",
      "glue:UpdateTable",
      "glue:DeleteTable",
      "glue:BatchDeleteTable",
      "glue:GetTableVersion",
      "glue:GetTableVersions",
      "glue:DeleteTableVersion",
      "glue:BatchDeleteTableVersion",
      "glue:CreatePartition",
      "glue:BatchCreatePartition",
      "glue:GetPartition",
      "glue:GetPartitions",
      "glue:BatchGetPartition",
      "glue:UpdatePartition",
      "glue:DeletePartition",
      "glue:BatchDeletePartition",
    ]

    resources = [
      "arn:aws:glue:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:catalog",
      "arn:aws:glue:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:database/default",
      "arn:aws:glue:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:database/*",
      "arn:aws:glue:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:table/*",
    ]

    effect = "Allow"
  }

  # Allows Segment to read and write from the Data Lake S3 bucket.
  statement {
    actions = [
      "*",
    ]

    resources = [
      "arn:aws:s3:::${var.s3_bucket}/*",
      "arn:aws:s3:::${var.s3_bucket}",
    ]

    effect = "Allow"
  }

  # Allows Segment to access Athena.
  statement {
    actions = [
      "athena:*",
    ]

    resources = [
      "*",
    ]

    effect = "Allow"
  }
}

resource "aws_iam_role_policy_attachment" "segment_data_lake_role_policy_attachment" {
  role       = "${aws_iam_role.segment_data_lake_iam_role.name}"
  policy_arn = "${aws_iam_policy.segment_data_lake_policy.arn}"
}
