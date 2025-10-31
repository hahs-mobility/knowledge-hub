locals {
  policy = jsonencode(
    {
      Version = "2012-10-17"
      Statement = [
        {
          Sid    = "S3Access"
          Effect = "Allow"
          Action = [
            "s3:*"
          ],
          Resource = [
            var.bucket_arn,
            "${var.bucket_arn}/*"
          ],
        },
        {
          Sid    = "KMSAccess"
          Effect = "Allow"
          Action = [
            "kms:ReEncrypt*",
            "kms:GenerateDataKey*",
            "kms:Encrypt",
            "kms:DescribeKey",
            "kms:Decrypt"
          ],
          Resource = [
            var.kms_key_arn
          ],
        }
      ]
    }
  )
}
