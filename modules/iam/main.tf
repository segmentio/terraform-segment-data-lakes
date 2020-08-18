# Creates the IAM role used by Segment.
# https://www.terraform.io/docs/providers/aws/r/iam_role.html
resource "aws_iam_role" "segment_data_lake_iam_role" {
  name               = "SegmentDataLakeRole${var.suffix}"
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
  name        = "SegmentDataLakePolicy${var.suffix}"
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
      "elasticmapreduce:RunJobFlow",
      "elasticmapreduce:TerminateJobFlows",
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

  # Gives the EMR service role permission to create cluster
  statement {
    actions = [
      "iam:PassRole",
    ]

    resources = [
      "${aws_iam_role.segment_emr_service_role.arn}",
      "${aws_iam_role.segment_emr_instance_profile_role.arn}",
      "${aws_iam_role.segment_emr_autoscaling_role.arn}",
    ]

    effect = "Allow"
  }
}

resource "aws_iam_role_policy_attachment" "segment_data_lake_role_policy_attachment" {
  role       = "${aws_iam_role.segment_data_lake_iam_role.name}"
  policy_arn = "${aws_iam_policy.segment_data_lake_policy.arn}"
}

# IAM role for EMR Service
resource "aws_iam_role" "segment_emr_service_role" {
  name = "SegmentEMRServiceRole${var.suffix}"

  assume_role_policy = <<EOF
{
  "Version": "2008-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "elasticmapreduce.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "segment_emr_service_policy" {
  name = "SegmentEMRServicePolicy${var.suffix}"
  role = "${aws_iam_role.segment_emr_service_role.id}"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [{
        "Effect": "Allow",
        "Resource": "*",
        "Action": [
                "ec2:AuthorizeSecurityGroupEgress",
                "ec2:AuthorizeSecurityGroupIngress",
                "ec2:CancelSpotInstanceRequests",
                "ec2:CreateNetworkInterface",
                "ec2:CreateSecurityGroup",
                "ec2:CreateTags",
                "ec2:DeleteNetworkInterface",
                "ec2:DeleteSecurityGroup",
                "ec2:DeleteTags",
                "ec2:DescribeAvailabilityZones",
                "ec2:DescribeAccountAttributes",
                "ec2:DescribeDhcpOptions",
                "ec2:DescribeImages",
                "ec2:DescribeInstanceStatus",
                "ec2:DescribeInstances",
                "ec2:DescribeKeyPairs",
                "ec2:DescribeNetworkAcls",
                "ec2:DescribeNetworkInterfaces",
                "ec2:DescribePrefixLists",
                "ec2:DescribeRouteTables",
                "ec2:DescribeSecurityGroups",
                "ec2:DescribeSpotInstanceRequests",
                "ec2:DescribeSpotPriceHistory",
                "ec2:DescribeSubnets",
                "ec2:DescribeTags",
                "ec2:DescribeVpcAttribute",
                "ec2:DescribeVpcEndpoints",
                "ec2:DescribeVpcEndpointServices",
                "ec2:DescribeVpcs",
                "ec2:DetachNetworkInterface",
                "ec2:ModifyImageAttribute",
                "ec2:ModifyInstanceAttribute",
                "ec2:RequestSpotInstances",
                "ec2:RevokeSecurityGroupEgress",
                "ec2:RunInstances",
                "ec2:TerminateInstances",
                "ec2:DeleteVolume",
                "ec2:DescribeVolumeStatus",
                "ec2:DescribeVolumes",
                "ec2:DetachVolume",
                "iam:GetRole",
                "iam:GetRolePolicy",
                "iam:ListInstanceProfiles",
                "iam:ListRolePolicies",
                "iam:PassRole",
                "s3:CreateBucket",
                "s3:Get*",
                "s3:List*",
                "sdb:BatchPutAttributes",
                "sdb:Select",
                "sqs:CreateQueue",
                "sqs:Delete*",
                "sqs:GetQueue*",
                "sqs:PurgeQueue",
                "sqs:ReceiveMessage",
                "cloudwatch:PutMetricAlarm",
                "cloudwatch:DescribeAlarms",
                "cloudwatch:DeleteAlarms",
                "application-autoscaling:RegisterScalableTarget",
                "application-autoscaling:DeregisterScalableTarget",
                "application-autoscaling:PutScalingPolicy",
                "application-autoscaling:DeleteScalingPolicy",
                "application-autoscaling:Describe*"
            ]
    }]
}
EOF
}

# IAM Role for EC2 Instance Profile
resource "aws_iam_role" "segment_emr_instance_profile_role" {
  name = "SegmentEMRInstanceProfileRole${var.suffix}"

  assume_role_policy = <<EOF
{
  "Version": "2008-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_instance_profile" "segment_emr_instance_profile" {
  name  = "SegmentEMRInstanceProfile${var.suffix}"
  roles = ["${aws_iam_role.segment_emr_instance_profile_role.name}"]
}

resource "aws_iam_role_policy" "segment_emr_instance_profile_policy" {
  name = "SegmentEMRInstanceProfilePolicy${var.suffix}"
  role = "${aws_iam_role.segment_emr_instance_profile_role.id}"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [{
        "Effect": "Allow",
        "Resource": "*",
        "Action": [
            "cloudwatch:*",
            "ec2:Describe*",
            "elasticmapreduce:Describe*",
            "sdb:*"
        ]
    },
    {
            "Effect": "Allow",
            "Action": [
                "s3:AbortMultipartUpload",
                "s3:CreateBucket",
                "s3:DeleteObject",
                "s3:GetBucketVersioning",
                "s3:GetObject",
                "s3:GetObjectTagging",
                "s3:GetObjectVersion",
                "s3:ListBucket",
                "s3:ListBucketMultipartUploads",
                "s3:ListBucketVersions",
                "s3:ListMultipartUploadParts",
                "s3:PutBucketVersioning",
                "s3:PutObject",
                "s3:PutObjectTagging"
            ],
            "Resource": [
                "arn:aws:s3:::${var.s3_bucket}",
                "arn:aws:s3:::${var.s3_bucket}/*"
            ]
        },
    {
            "Effect": "Allow",
            "Resource": "*",
            "Action": [
                "glue:CreateDatabase",
                "glue:UpdateDatabase",
                "glue:DeleteDatabase",
                "glue:GetDatabase",
                "glue:GetDatabases",
                "glue:CreateTable",
                "glue:UpdateTable",
                "glue:DeleteTable",
                "glue:GetTable",
                "glue:GetTables",
                "glue:GetTableVersions",
                "glue:CreatePartition",
                "glue:BatchCreatePartition",
                "glue:UpdatePartition",
                "glue:DeletePartition",
                "glue:BatchDeletePartition",
                "glue:GetPartition",
                "glue:GetPartitions",
                "glue:BatchGetPartition",
                "glue:CreateUserDefinedFunction",
                "glue:UpdateUserDefinedFunction",
                "glue:DeleteUserDefinedFunction",
                "glue:GetUserDefinedFunction",
                "glue:GetUserDefinedFunctions"
            ]
        }
]
}
EOF
}

# IAM Role for EMR Autoscaling role
resource "aws_iam_role" "segment_emr_autoscaling_role" {
  name = "SegmentEMRAutoscalingRole${var.suffix}"

  assume_role_policy = <<EOF
{
  "Version": "2008-10-17",
  "Statement": [    {
      "Effect": "Allow",
      "Principal": {
        "Service": [
          "application-autoscaling.amazonaws.com",
          "elasticmapreduce.amazonaws.com",
          "ec2.amazonaws.com"
        ]
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "segmnet_emr_autoscaling_policy" {
  name = "SegmentEMRAutoscalingPolicy${var.suffix}"
  role = "${aws_iam_role.segment_emr_autoscaling_role.id}"

  policy = <<EOF
{
    "Version": "2012-10-17",
     "Statement": [{
        "Effect": "Allow",
        "Resource": "*",
        "Action": [
            "cloudwatch:DescribeAlarms",
            "elasticmapreduce:ListInstanceGroups",
            "elasticmapreduce:ModifyInstanceGroups"
        ]
    }]
}
EOF
}
