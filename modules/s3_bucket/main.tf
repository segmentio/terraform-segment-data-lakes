module "s3_bucket" {
  source = "https://github.com/terraform-aws-modules/terraform-aws-s3-bucket/archive/v1.9.0.zip//terraform-aws-s3-bucket-1.9.0"

  bucket = var.s3_bucket
  acl    = "private"

  versioning = {
    enabled = false
  }

  policy = <<POLICY
  {
    "Version": "2008-10-17",
    "Id": "Policy1425281770533",
    "Statement": [
      {
        "Sid": "AllowSegmentUser",
        "Effect": "Allow",
        "Principal": {
          "AWS": "arn:aws:iam::107630771604:user/s3-copy"
        },
        "Action": "s3:PutObject",
        "Resource": "arn:aws:s3:::${var.s3_bucket}/*"
      }
    ]
  }
POLICY
}
