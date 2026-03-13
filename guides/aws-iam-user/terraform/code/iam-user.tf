module "iam_user" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-user"
  version = "5.58.0"

  create_iam_access_key         = var.create_iam_access_key
  create_iam_user_login_profile = var.create_iam_user_login_profile
  force_destroy                 = var.user_force_destroy
  iam_access_key_status         = var.user_iam_access_key_status
  name                          = var.user_name
  password_length               = var.user_password_length
  password_reset_required       = var.user_password_reset_required
  path                          = var.user_path
  permissions_boundary          = var.user_permissions_boundary
  pgp_key                       = var.user_pgp_key
  policy_arns                   = [module.iam_policy.arn]
  ssh_key_encoding              = var.user_ssh_key_encoding
  ssh_public_key                = var.user_ssh_public_key
  tags                          = var.tags
  upload_iam_user_ssh_key       = var.user_upload_iam_user_ssh_key
}
