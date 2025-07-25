---
# template: home.html
icon: material/terraform
---
# S3 Access User Terraform Configuration

This Terraform configuration creates an IAM user with access keys and assigns a policy for S3 bucket access with KMS encryption capabilities.

!!! info "Source code"

    :material-github: [guides/aws-iam-user/terraform/code/](https://github.com/hahs-mobility/knowledge-hub/tree/main/docs/guides/aws-iam-user/terraform/code)

## Overview

The code provisions the following AWS resources:

- IAM user
- IAM access keys for the user
- IAM policy granting access to a specific S3 bucket with KMS
- Policy attachment to give the user the appropriate permissions

## Prerequisites

- Terraform v1.5+
- AWS credentials with permissions to create IAM resources
- AWS CLI configured or environment variables set

## Usage

### Configure Variables
Review and adjust values in `iam.auto.tfvars` as needed:
```hcl title="Example configuration"
user_name             = "obs-external"
create_iam_access_key = true
policy_name           = "access-s3-analytics"
policy_path           = "/obs/analytics/"

region = "us-east-1"

bucket_arn = "arn:aws:s3:::hahs-s3-example-bucket"
kms_key_arn = "arn:aws:kms:eu-central-1:000000000000:key/xxxxxxx-xxxxxxx-xxxxxxx-xxxxxxx"
```
### Initialize Terraform

``` shell title="Terraform init"
cd docs/guides/aws-iam-user/terraform/code
terraform init
```

### Preview changes

``` shell title="Terraform plan"
terraform plan
```

### Apply Configuration

``` shell title="Terraform apply"
terraform apply
```

!!! danger

     Review the displayed plan and type yes to confirm applying the changes.

### Retrieve Access Keys

#### Get only the Access Key ID
``` shell title="Access Key ID"
terraform output -json | jq -r '.iam_user.value.iam_access_key_id'
```

#### Get only the Secret Access Key
``` shell title="Secret Access Key"
terraform output -json | jq -r '.iam_user.value.iam_access_key_secret'
```

#### Get both values (environment variables)
``` shell title="ENV: Access Key ID + Secret Access Key"
terraform output -json | jq -r '"export AWS_ACCESS_KEY_ID=" + .iam_user.value.iam_access_key_id + "\nexport AWS_SECRET_ACCESS_KEY=" + .iam_user.value.iam_access_key_secret'
```

#### Get both values (JSON)
``` shell title="JSON: Access Key ID + Secret Access Key"
terraform output -json | jq '{access_key: .iam_user.value.iam_access_key_id, secret_key: .iam_user.value.iam_access_key_secret}'
```

#### Get both values (.aws/credentials)
``` shell title="AWS Credentials: Access Key ID + Secret Access Key"
terraform output -json | jq -r '"aws_access_key_id = " + .iam_user.value.iam_access_key_id + "\naws_secret_access_key = " + .iam_user.value.iam_access_key_secret'
```

### Destroy Configuration
``` shell title="Terraform destroy"
terraform destroy
```

!!! danger

    Review the displayed plan and type yes to confirm destroy the configuration.
