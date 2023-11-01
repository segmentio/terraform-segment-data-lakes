
data "aws_iam_policy_document" "segment_policy_doc" {
  statement {
    sid = "cross_account"

    actions = [
      "s3:GetBucketLocation",
      "s3:ListBucket",
      "s3:GetObject",
      "s3:PutObject",
      "s3:PutObjectAcl",
      "s3:GetObjectAcl",
      "s3:DeleteObject"
    ]

    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${var.data_account}:root"]
    }

    resources = [
      "arn:aws:s3:::${var.s3_bucket}",
      "arn:aws:s3:::${var.s3_bucket}/*"
    ]

  }

  statement {
    sid    = "AllowSegmentUser"
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::107630771604:user/s3-copy"]
    }
    actions   = ["S3:PutObject"]
    resources = ["arn:aws:s3:::${var.s3_bucket}/*"]
  }

}


module "s3_bucket" {
  source = "https://github.com/terraform-aws-modules/terraform-aws-s3-bucket/archive/v1.9.0.zip//terraform-aws-s3-bucket-1.9.0"

  bucket = var.s3_bucket
  acl    = "private"

  versioning = {
    enabled = false
  }

  tags = local.tags


  policy        = data.aws_iam_policy_document.segment_policy_doc.json
  attach_policy = true
}
