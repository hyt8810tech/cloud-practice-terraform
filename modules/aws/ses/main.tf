resource "aws_sesv2_email_identity" "cloud_pratica" {
  email_identity = var.cloud_pratica.domain
}
resource "aws_sesv2_email_identity_mail_from_attributes" "cloud_pratica" {
  email_identity   = aws_sesv2_email_identity.cloud_pratica.email_identity
  mail_from_domain = "mail.${var.cloud_pratica.domain}"
}
