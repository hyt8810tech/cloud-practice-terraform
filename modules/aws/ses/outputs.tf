output "dkim_tokens_cloud_pratica" {
  value = aws_sesv2_email_identity.cloud_pratica.dkim_signing_attributes[0].tokens
}
