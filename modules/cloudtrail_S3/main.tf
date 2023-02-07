#C3S-IaC Module cloudtrail_s3 main.tf - Terraform coding for C3S infrastrcture as code
data "aws_caller_identity" "current" {}


resource "aws_s3_bucket" "ss-logbucket-s3" {
  bucket        = "ss-logbucket-ct"
  force_destroy = true
}


resource "aws_cloudtrail" "ss_logbucket_ct" {
  name                          = "ss_logbucket_ct"
  s3_bucket_name                = aws_s3_bucket.ss-logbucket-s3.id
  s3_key_prefix                 = "prefix"
  include_global_service_events = false
}


resource "aws_s3_bucket_policy" "ss-logbucket-s3" {
  bucket = aws_s3_bucket.ss-logbucket-s3.id
  policy = <<POLICY
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "AWSCloudTrailAclCheck",
            "Effect": "Allow",
            "Principal": {
              "Service": "cloudtrail.amazonaws.com"
            },
            "Action": "s3:GetBucketAcl",
            "Resource": "${aws_s3_bucket.ss-logbucket-s3.arn}"
        },
        {
            "Sid": "AWSCloudTrailWrite",
            "Effect": "Allow",
            "Principal": {
              "Service": "cloudtrail.amazonaws.com"
            },
            "Action": "s3:PutObject",
            "Resource": [
              "${aws_s3_bucket.ss-logbucket-s3.arn}/prefix/AWSLogs/${data.aws_caller_identity.current.account_id}/*",
              "${aws_s3_bucket.ss-logbucket-s3.arn}/prefix/AWSLogs/302071135337/*",
              "${aws_s3_bucket.ss-logbucket-s3.arn}/prefix/AWSLogs/141589809068/*"
            ],
            "Condition": {
                "StringEquals": {
                    "s3:x-amz-acl": "bucket-owner-full-control"
                }
            }
        }
    ]
}
POLICY
}
