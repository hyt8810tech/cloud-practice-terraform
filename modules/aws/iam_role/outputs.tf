output "name_cp_bastion" {
  value = aws_iam_role.cp_bastion.name
}

output "name_cp_nat" {
  value = aws_iam_role.cp_nat.name
}