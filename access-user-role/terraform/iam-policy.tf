module "iam_policy" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-policy"
  version = "5.58.0"

  description = "Policy for ${var.user_name}"
  name        = var.policy_name
  path        = var.policy_path
  policy      = local.policy
  tags        = var.tags
}

