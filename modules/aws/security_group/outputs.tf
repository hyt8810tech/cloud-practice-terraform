output "id_bastion" {
  value = aws_security_group.bastion.id
}

output "id_nat" {
  value = aws_security_group.nat.id
}