output "iam_policy" {
  value = module.iam_policy
}

output "iam_user" {
  value     = module.iam_user
  sensitive = true
}
