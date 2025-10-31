variable "bucket_arn" {
  description = "The ARN of the S3 bucket"
  type        = string
}

variable "create_iam_access_key" {
  description = "Create an IAM access key for the user"
  type        = bool
  default     = false
}

variable "create_iam_user_login_profile" {
  description = "Create a login profile for the IAM user"
  type        = bool
  default     = false
}

variable "kms_key_arn" {
  description = "The ARN of the KMS key"
  type        = string
}

variable "policy_name" {
  description = "The name of the policy"
  type        = string
}

variable "policy_path" {
  description = "The path to the policy"
  type        = string
}

variable "region" {
  description = "The AWS region where the resources will be created"
  type        = string
}

variable "tags" {
  description = "A map of tags to assign to the user and policy"
  type        = map(string)
  default     = {}
}

variable "user_force_destroy" {
  description = "Force destroy the IAM user"
  type        = bool
  default     = false
}

variable "user_iam_access_key_status" {
  description = "Status of the IAM access key for the user"
  type        = string
  default     = "Active"
}
variable "user_name" {
  description = "Desired name for the IAM user"
  type        = string
}
variable "user_password_length" {
  description = "Length of the password for the IAM user"
  type        = number
  default     = 16
}
variable "user_password_reset_required" {
  description = "Whether the IAM user must reset their password upon first login"
  type        = bool
  default     = true
}
variable "user_path" {
  description = "The path to the IAM user"
  type        = string
  default     = "/"
}
variable "user_permissions_boundary" {
  description = "The ARN of the permissions boundary for the IAM user"
  type        = string
  default     = ""
}

variable "user_pgp_key" {
  description = "The PGP key for the IAM user"
  type        = string
  default     = ""
}

variable "user_ssh_key_encoding" {
  description = "The encoding of the SSH key for the IAM user"
  type        = string
  default     = "SSH"
}

variable "user_ssh_public_key" {
  description = "The SSH public key for the IAM user"
  type        = string
  default     = ""
}

variable "user_upload_iam_user_ssh_key" {
  description = "Whether to upload the SSH public key for the IAM user"
  type        = bool
  default     = false
}
