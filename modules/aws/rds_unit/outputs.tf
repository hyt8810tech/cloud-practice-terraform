output "password" {
  value = aws_db_instance.main.password
  sensitive = true
}