#C3S-IaC Module cloudtrail_s3 output.tf - Terraform coding for C3S infrastrcture as code

output "loging_bucket_id" {
  value = aws_s3_bucket.ss-logbucket-s3.id
}
