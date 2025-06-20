# AWS Region Configuration
region = "us-east-1"

# IAM User Configuration
user_name             = "obs-external"
create_iam_access_key = true
policy_name           = "access-s3-analytics"
policy_path           = "/obs/analytics/"

# External S3 Bucket Configuration
bucket_arn  = "arn:aws:s3:::hahs-s3-example-bucket"
kms_key_arn = "arn:aws:kms:eu-central-1:000000000000:key/xxxxxxx-xxxxxxx-xxxxxxx-xxxxxxx"

# Tags for IAM User and Policy
tags = {
  "obs-analytics" = true
  "terraform"     = true
}
