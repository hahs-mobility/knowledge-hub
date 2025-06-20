# S3 Access User Terraform Configuration

This Terraform configuration creates an IAM user with access keys and assigns a policy for S3 bucket access with KMS encryption capabilities.

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
```hcl
user_name             = "obs-external"
create_iam_access_key = true
policy_name           = "access-s3-analytics"
policy_path           = "/obs/analytics/"

region = "us-east-1"

bucket_arn = "arn:aws:s3:::hahs-s3-example-bucket"
kms_key_arn = "arn:aws:kms:eu-central-1:000000000000:key/xxxxxxx-xxxxxxx-xxxxxxx-xxxxxxx"
```
### Initialize Terraform

```shell
cd access-user-role/terraform
terraform init
```

### Preview changes

```shell
terraform plan
```

### Apply Configuration

```shell
terraform apply
```
> [!IMPORTANT]
> Review the displayed plan and type yes to confirm applying the changes.

### Retrieve Access Keys

#### Get only the Access Key ID
```shell
terraform output -json | jq -r '.iam_user.value.iam_access_key_id'
```

#### Get only the Secret Access Key
```shell
terraform output -json | jq -r '.iam_user.value.iam_access_key_secret'
```

#### Get both values (environment variables)
```shell
terraform output -json | jq -r '"export AWS_ACCESS_KEY_ID=" + .iam_user.value.iam_access_key_id + "\nexport AWS_SECRET_ACCESS_KEY=" + .iam_user.value.iam_access_key_secret'
```

#### Get both values (JSON)
```shell
terraform output -json | jq '{access_key: .iam_user.value.iam_access_key_id, secret_key: .iam_user.value.iam_access_key_secret}'
```

#### Get both values (.aws/credentials)
```shell
terraform output -json | jq -r '"aws_access_key_id = " + .iam_user.value.iam_access_key_id + "\naws_secret_access_key = " + .iam_user.value.iam_access_key_secret'
```

### Destroy Configuration
```shell
terraform destroy
```

> [!IMPORTANT]
> Review the displayed plan and type yes to confirm destroy the configuration.

----

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name                                                                      | Version |
|---------------------------------------------------------------------------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >=1.5   |
| <a name="requirement_aws"></a> [aws](#requirement\_aws)                   | >=5     |

## Providers

No providers.

## Modules

| Name                                                                 | Source                                            | Version |
|----------------------------------------------------------------------|---------------------------------------------------|---------|
| <a name="module_iam_policy"></a> [iam\_policy](#module\_iam\_policy) | terraform-aws-modules/iam/aws//modules/iam-policy | 5.58.0  |
| <a name="module_iam_user"></a> [iam\_user](#module\_iam\_user)       | terraform-aws-modules/iam/aws//modules/iam-user   | 5.58.0  |

## Resources

No resources.

## Inputs

| Name                                                                                                                              | Description                                                     | Type          | Default    | Required |
|-----------------------------------------------------------------------------------------------------------------------------------|-----------------------------------------------------------------|---------------|------------|:--------:|
| <a name="input_bucket_arn"></a> [bucket\_arn](#input\_bucket\_arn)                                                                | The ARN of the S3 bucket                                        | `string`      | n/a        |   yes    |
| <a name="input_create_iam_access_key"></a> [create\_iam\_access\_key](#input\_create\_iam\_access\_key)                           | Create an IAM access key for the user                           | `bool`        | `false`    |    no    |
| <a name="input_create_iam_user_login_profile"></a> [create\_iam\_user\_login\_profile](#input\_create\_iam\_user\_login\_profile) | Create a login profile for the IAM user                         | `bool`        | `false`    |    no    |
| <a name="input_kms_key_arn"></a> [kms\_key\_arn](#input\_kms\_key\_arn)                                                           | The ARN of the KMS key                                          | `string`      | n/a        |   yes    |
| <a name="input_policy_name"></a> [policy\_name](#input\_policy\_name)                                                             | The name of the policy                                          | `string`      | n/a        |   yes    |
| <a name="input_policy_path"></a> [policy\_path](#input\_policy\_path)                                                             | The path to the policy                                          | `string`      | n/a        |   yes    |
| <a name="input_region"></a> [region](#input\_region)                                                                              | The AWS region where the resources will be created              | `string`      | n/a        |   yes    |
| <a name="input_tags"></a> [tags](#input\_tags)                                                                                    | A map of tags to assign to the user and policy                  | `map(string)` | `{}`       |    no    |
| <a name="input_user_force_destroy"></a> [user\_force\_destroy](#input\_user\_force\_destroy)                                      | Force destroy the IAM user                                      | `bool`        | `false`    |    no    |
| <a name="input_user_iam_access_key_status"></a> [user\_iam\_access\_key\_status](#input\_user\_iam\_access\_key\_status)          | Status of the IAM access key for the user                       | `string`      | `"Active"` |    no    |
| <a name="input_user_name"></a> [user\_name](#input\_user\_name)                                                                   | Desired name for the IAM user                                   | `string`      | n/a        |   yes    |
| <a name="input_user_password_length"></a> [user\_password\_length](#input\_user\_password\_length)                                | Length of the password for the IAM user                         | `number`      | `16`       |    no    |
| <a name="input_user_password_reset_required"></a> [user\_password\_reset\_required](#input\_user\_password\_reset\_required)      | Whether the IAM user must reset their password upon first login | `bool`        | `true`     |    no    |
| <a name="input_user_path"></a> [user\_path](#input\_user\_path)                                                                   | The path to the IAM user                                        | `string`      | `"/"`      |    no    |
| <a name="input_user_permissions_boundary"></a> [user\_permissions\_boundary](#input\_user\_permissions\_boundary)                 | The ARN of the permissions boundary for the IAM user            | `string`      | `""`       |    no    |
| <a name="input_user_pgp_key"></a> [user\_pgp\_key](#input\_user\_pgp\_key)                                                        | The PGP key for the IAM user                                    | `string`      | `""`       |    no    |
| <a name="input_user_ssh_key_encoding"></a> [user\_ssh\_key\_encoding](#input\_user\_ssh\_key\_encoding)                           | The encoding of the SSH key for the IAM user                    | `string`      | `"SSH"`    |    no    |
| <a name="input_user_ssh_public_key"></a> [user\_ssh\_public\_key](#input\_user\_ssh\_public\_key)                                 | The SSH public key for the IAM user                             | `string`      | `""`       |    no    |
| <a name="input_user_upload_iam_user_ssh_key"></a> [user\_upload\_iam\_user\_ssh\_key](#input\_user\_upload\_iam\_user\_ssh\_key)  | Whether to upload the SSH public key for the IAM user           | `bool`        | `false`    |    no    |

## Outputs

| Name                                                                 | Description |
|----------------------------------------------------------------------|-------------|
| <a name="output_iam_policy"></a> [iam\_policy](#output\_iam\_policy) | n/a         |
| <a name="output_iam_user"></a> [iam\_user](#output\_iam\_user)       | n/a         |
<!-- END_TF_DOCS -->
